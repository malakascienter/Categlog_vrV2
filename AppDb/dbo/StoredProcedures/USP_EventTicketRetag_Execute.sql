
CREATE PROCEDURE dbo.USP_EventTicketRetag_Execute
    @PropertyId                       INT,
    @EventReservationID               INT,
    @ExpectedCurrentEventDateDetailID INT,
    @TargetEventDateDetailID          INT,
    @Reason                           NVARCHAR(500) = NULL,
    @UserId                           INT,
    @UserName                         NVARCHAR(100) = NULL,
    @RequireConfirmedStatus           BIT           = 1,
    @AllowFutureSource                BIT           = 1,
    @SourceScreen                     VARCHAR(100)  = 'EventTicketRetag',
    @AsAtDateTime                     DATETIME      = NULL,
    /*  Appended at the end, after every pre-existing parameter, so a caller
        using positional arguments up to @AsAtDateTime is unaffected. Only used
        for a cross-event move; forwarded as-is to USP_EventTicketRetag_Validate.
        See its header comment.  */
    @RequestedTicketMappingJson       NVARCHAR(MAX) = NULL,
    /*  The application reads the result set below (DbConnectivity.SelectSingleSP).
        These OUTPUT parameters exist because this procedure owns a transaction:
        a T-SQL caller cannot use INSERT ... EXEC on it (a ROLLBACK inside an
        INSERT-EXEC is illegal, and it nests an INSERT-EXEC of its own), so the
        test script and any future stored-procedure caller read these instead.  */
    @OutIsSuccess                     BIT           = NULL OUTPUT,
    @OutErrorCode                     VARCHAR(50)   = NULL OUTPUT,
    @OutMessage                       VARCHAR(500)  = NULL OUTPUT,
    @OutRetagId                       BIGINT        = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @AsAtDateTime IS NULL SET @AsAtDateTime = GETDATE();

    DECLARE @IsSuccess BIT          = 0,
            @ErrorCode VARCHAR(50)  = 'OK',
            @Message   VARCHAR(500) = '',
            @RetagId   BIGINT       = 0,
            @Abort     BIT          = 0,
            /*  Composable: if the caller already owns a transaction we take a
                savepoint instead of a nested BEGIN/ROLLBACK, so a rejected
                re-tag undoes only its own work and never the caller's.  */
            @OuterTran BIT          = CASE WHEN @@TRANCOUNT > 0 THEN 1 ELSE 0 END;

    DECLARE @TicketMappingJson NVARCHAR(MAX),
            @CurrentDDID       INT,
            @TargetEventID     INT,
            @TargetEventNo     VARCHAR(50),
            @TargetEventName   NVARCHAR(400),
            @IsCrossEvent      BIT,
            @NewSeqNo          INT,
            @LockedID          INT,
            @LockedTargetRows  INT,
            @ChangesJson       NVARCHAR(MAX),
            @RecordLabel       NVARCHAR(200),
            @RecordId          VARCHAR(50) = CAST(@EventReservationID AS VARCHAR(50));

    CREATE TABLE #Validation
    (
        IsValid                   BIT,
        ErrorCode                 VARCHAR(50),
        [Message]                 VARCHAR(500),
        EventReservationID        INT,
        EventTransactionHeaderID  INT,
        MobileNo                  VARCHAR(20),
        CustomerName              NVARCHAR(500),
        EventID                   INT,
        EventNo                   VARCHAR(50),
        EventName                 NVARCHAR(400),
        OutletCode                VARCHAR(5),
        PropertyId                INT,
        CurrentEventDateDetailID  INT,
        CurrentEventDate          DATE,
        CurrentFromTime           TIME(7),
        CurrentToTime             TIME(7),
        OriginalEventDateDetailID INT,
        RetagCount                INT,
        TargetEventDateDetailID   INT,
        TargetEventDate           DATE,
        TargetFromTime            TIME(7),
        TargetToTime              TIME(7),
        TargetEventID             INT,
        TargetEventNo             VARCHAR(50),
        TargetEventName           NVARCHAR(400),
        IsCrossEvent              BIT,
        BookingStatusID           INT,
        BookingStatus             VARCHAR(50),
        IsComplete                BIT,
        TotalTickets              INT,
        TotalAmount               DECIMAL(18,2),
        TargetTotalAmount         DECIMAL(18,2),
        TicketMappingJson         NVARCHAR(MAX)
    );

    BEGIN TRY
        IF @OuterTran = 1
            SAVE TRANSACTION EvtRetagSave;
        ELSE
            BEGIN TRANSACTION;

        /* Serialise against a concurrent re-tag of the same ticket ... */
        SELECT  @LockedID = ID
        FROM    dbo.EventTransactionDetail WITH (UPDLOCK, ROWLOCK)
        WHERE   ID = @EventReservationID;

        /* ... and against a concurrent re-tag onto the same target occurrence,
           so the allotment check below cannot be overtaken. */
        SELECT  @LockedTargetRows = COUNT(*)
        FROM    dbo.EventTransactionDetail WITH (UPDLOCK, HOLDLOCK)
        WHERE   EventDateDetailID = @TargetEventDateDetailID;

        INSERT INTO #Validation
        EXEC dbo.USP_EventTicketRetag_Validate
                @PropertyId                 = @PropertyId,
                @EventReservationID         = @EventReservationID,
                @TargetEventDateDetailID    = @TargetEventDateDetailID,
                @RequestedTicketMappingJson = @RequestedTicketMappingJson,
                @RequireConfirmedStatus     = @RequireConfirmedStatus,
                @AllowFutureSource          = @AllowFutureSource,
                @AsAtDateTime               = @AsAtDateTime;

        SELECT  @ErrorCode         = ErrorCode,
                @Message           = [Message],
                @TicketMappingJson = TicketMappingJson,
                @CurrentDDID       = CurrentEventDateDetailID,
                @TargetEventID     = TargetEventID,
                @TargetEventNo     = TargetEventNo,
                @TargetEventName   = TargetEventName,
                @IsCrossEvent      = IsCrossEvent,
                @NewSeqNo          = ISNULL(RetagCount, 0) + 1
        FROM    #Validation;

        IF NOT EXISTS (SELECT 1 FROM #Validation WHERE IsValid = 1)
        BEGIN
            SET @Abort = 1;
            IF @Message IS NULL OR @Message = ''
                SELECT @ErrorCode = 'NOT_FOUND', @Message = 'Ticket not found.';
        END

        /* Optimistic guard: the screen must have been looking at the same
           current occurrence, so two users cannot both move the ticket. */
        IF @Abort = 0
           AND @ExpectedCurrentEventDateDetailID IS NOT NULL
           AND @ExpectedCurrentEventDateDetailID <> 0
           AND @ExpectedCurrentEventDateDetailID <> @CurrentDDID
            SELECT @Abort     = 1,
                   @ErrorCode = 'STALE',
                   @Message   = 'This ticket was moved by another user. Please refresh and retry.';

        /* 1. Move the ticket itself. EventDateDetailID keeps its meaning of "the
              occurrence the ticket is valid for"; the original occurrence (and,
              for a cross-event move, the original event) is captured the first
              time only. The WHERE clause is the last-moment guard - a ticket is
              always assigned to exactly ONE occurrence. */
        IF @Abort = 0
        BEGIN
            UPDATE  ETD
               SET  OriginalEventDateDetailID = ISNULL(ETD.OriginalEventDateDetailID, ETD.EventDateDetailID),
                    OriginalEventID           = ISNULL(ETD.OriginalEventID, ETD.EventID),
                    EventID                   = @TargetEventID,
                    EventDateDetailID         = @TargetEventDateDetailID,
                    [Date]                    = CAST(V.TargetEventDate AS DATETIME),
                    RetagCount                = ETD.RetagCount + 1,
                    LastRetagDate             = @AsAtDateTime,
                    LastRetagBy               = @UserId
            FROM    dbo.EventTransactionDetail ETD
            CROSS JOIN #Validation V
            WHERE   ETD.ID = @EventReservationID
              AND   ETD.EventDateDetailID = @CurrentDDID;

            IF @@ROWCOUNT <> 1
                SELECT @Abort     = 1,
                       @ErrorCode = 'STALE',
                       @Message   = 'This ticket was moved by another user. Please refresh and retry.';
        END

        IF @Abort = 0
        BEGIN
            /* 2. Re-point the purchased ticket lines to the target ticket types
                  so the target allotment is consumed and the POSAPI ticket
                  summary keeps resolving. */
            UPDATE  ETTD
               SET  OriginalTicketID = ISNULL(ETTD.OriginalTicketID, ETTD.TicketID),
                    TicketID         = M.TargetTicketID
            FROM    dbo.EventTransactionTicketDetail ETTD
            INNER JOIN OPENJSON(@TicketMappingJson)
                   WITH (TransactionTicketDetailID INT '$.TransactionTicketDetailID',
                         TargetTicketID            INT '$.TargetTicketID') M
                    ON M.TransactionTicketDetailID = ETTD.ID
            WHERE   ETTD.EventTransactionDetailID = @EventReservationID;

            /* 3. The customer must be reminded about the NEW date. */
            UPDATE  ETH
               SET  FirstReminderSent  = 0,
                    SecondReminderSent = 0
            FROM    dbo.EventTransactionHeader ETH
            INNER JOIN #Validation V ON V.EventTransactionHeaderID = ETH.ID;

            /* 4. Audit row. */
            INSERT INTO dbo.EventTicketRetagHistory
            (
                PropertyId, OutletCode, EventReservationID, EventTransactionHeaderID,
                MobileNo, CustomerName, EventID, EventNo, EventName,
                FromEventDateDetailID, FromEventDate, FromFromTime, FromToTime,
                ToEventDateDetailID,   ToEventDate,   ToFromTime,   ToToTime,
                ToEventID, ToEventNo, ToEventName, IsCrossEvent,
                PreviousBookingStatusId, PreviousBookingStatus, PreviousIsComplete,
                NewBookingStatusId,      NewBookingStatus,      NewIsComplete,
                TotalTickets, TotalAmount, TargetTotalAmount, TicketMappingJson,
                RetagSeqNo, RetaggedDate, RetaggedBy, RetaggedByName, Reason, SourceScreen
            )
            SELECT  V.PropertyId, V.OutletCode, V.EventReservationID, V.EventTransactionHeaderID,
                    V.MobileNo, V.CustomerName, V.EventID, V.EventNo, V.EventName,
                    V.CurrentEventDateDetailID, V.CurrentEventDate, V.CurrentFromTime, V.CurrentToTime,
                    V.TargetEventDateDetailID,  V.TargetEventDate,  V.TargetFromTime,  V.TargetToTime,
                    V.TargetEventID, V.TargetEventNo, V.TargetEventName, V.IsCrossEvent,
                    V.BookingStatusID, V.BookingStatus, V.IsComplete,
                    V.BookingStatusID, V.BookingStatus, 0,
                    V.TotalTickets, V.TotalAmount, V.TargetTotalAmount, V.TicketMappingJson,
                    @NewSeqNo, @AsAtDateTime, @UserId, @UserName, @Reason, @SourceScreen
            FROM    #Validation V;

            SET @RetagId = CAST(SCOPE_IDENTITY() AS BIGINT);

            /* 5. General application audit log, when that migration is present. */
            IF OBJECT_ID('dbo.App_AuditLog_Insert', 'P') IS NOT NULL
            BEGIN
                SELECT  @RecordLabel = LEFT(ISNULL(V.EventNo, '') + N' - ' + ISNULL(V.CustomerName, N''), 200),
                        @ChangesJson =
                        (
                            SELECT C.FieldName, C.OldValue, C.NewValue
                            FROM (
                                SELECT 'EventDateDetailID' AS FieldName,
                                       CAST(V.CurrentEventDateDetailID AS NVARCHAR(500)) AS OldValue,
                                       CAST(V.TargetEventDateDetailID  AS NVARCHAR(500)) AS NewValue
                                UNION ALL
                                SELECT 'EventDate',
                                       CAST(CONVERT(NVARCHAR(10), V.CurrentEventDate, 103) AS NVARCHAR(500)),
                                       CAST(CONVERT(NVARCHAR(10), V.TargetEventDate,  103) AS NVARCHAR(500))
                                UNION ALL
                                SELECT 'Reason',
                                       CAST(NULL AS NVARCHAR(500)),
                                       CAST(@Reason AS NVARCHAR(500))
                            ) C
                            FOR JSON PATH
                        )
                FROM    #Validation V;

                EXEC dbo.App_AuditLog_Insert
                        @PropertyId   = @PropertyId,
                        @EntityName   = 'EventTicketRetag',
                        @RecordId     = @RecordId,
                        @RecordLabel  = @RecordLabel,
                        @Action       = 'U',
                        @UserId       = @UserId,
                        @Username     = @UserName,
                        @SourceScreen = @SourceScreen,
                        @ChangesJson  = @ChangesJson;
            END
        END

        IF @Abort = 1
        BEGIN
            IF @OuterTran = 1
                ROLLBACK TRANSACTION EvtRetagSave;
            ELSE IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
            SET @RetagId = 0;
        END
        ELSE
        BEGIN
            IF @OuterTran = 0 COMMIT TRANSACTION;

            SET @IsSuccess = 1;
            SET @ErrorCode = 'OK';

            SELECT  @Message = 'Ticket re-tagged from '
                             + CONVERT(VARCHAR(10), V.CurrentEventDate, 103) + ' to '
                             + CONVERT(VARCHAR(10), V.TargetEventDate,  103)
                             + CASE WHEN V.IsCrossEvent = 1
                                    THEN ' (moved to "' + V.TargetEventName + '").'
                                    ELSE '.' END
            FROM    #Validation V;
        END
    END TRY
    BEGIN CATCH
        /*  XACT_STATE() = -1 means the transaction is uncommittable and the
            whole thing (savepoint or not) has to go.  */
        IF XACT_STATE() = -1
            ROLLBACK TRANSACTION;
        ELSE IF XACT_STATE() = 1
        BEGIN
            IF @OuterTran = 1
                ROLLBACK TRANSACTION EvtRetagSave;
            ELSE
                ROLLBACK TRANSACTION;
        END

        SELECT  @IsSuccess = 0,
                @ErrorCode = 'ERROR',
                @Message   = LEFT('Re-tag failed: ' + ERROR_MESSAGE(), 500),
                @RetagId   = 0;
    END CATCH

    SELECT  @OutIsSuccess = @IsSuccess,
            @OutErrorCode = @ErrorCode,
            @OutMessage   = @Message,
            @OutRetagId   = @RetagId;

    SELECT  @IsSuccess              AS IsSuccess,
            @ErrorCode              AS ErrorCode,
            @Message                AS [Message],
            @RetagId                AS RetagId,
            @EventReservationID     AS EventReservationID,
            @TargetEventDateDetailID AS TargetEventDateDetailID;

    IF OBJECT_ID('tempdb..#Validation') IS NOT NULL DROP TABLE #Validation;
END

GO

