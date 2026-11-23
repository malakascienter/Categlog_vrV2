
CREATE PROCEDURE dbo.USP_EventTicketRetag_Validate
    @PropertyId                  INT,
    @EventReservationID          INT,
    @TargetEventDateDetailID     INT,
    @RequireConfirmedStatus      BIT      = 1,
    @AllowFutureSource           BIT      = 1,
    @AsAtDateTime                DATETIME = NULL,
    /*  Appended at the end, after every pre-existing parameter, so a caller
        using positional arguments up to @AsAtDateTime is unaffected. Only used
        for a cross-event move: [{TransactionTicketDetailID,TargetTicketID}]
        the admin chose on USP_EventTicketRetag_SelectTargetTicketTypes. Ignored
        (and unnecessary) when the target is an occurrence of the SAME event -
        that case keeps matching ticket types by name, as before.  */
    @RequestedTicketMappingJson  NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @AsAtDateTime IS NULL SET @AsAtDateTime = GETDATE();

    DECLARE @IsValid    BIT          = 0,
            @ErrorCode  VARCHAR(50)  = 'NOT_FOUND',
            @Message    VARCHAR(500) = 'Ticket not found.';

    DECLARE @HeaderID           INT,
            @EventID            INT,
            @EventNo            VARCHAR(50),
            @EventName          NVARCHAR(400),
            @OutletCode         VARCHAR(5),
            @CurrentDDID        INT,
            @CurrentDate        DATE,
            @CurrentFromTime    TIME(7),
            @CurrentToTime      TIME(7),
            @IsComplete         BIT,
            @BookingStatusId    INT,
            @BookingStatus      VARCHAR(50),
            @CustomerName       NVARCHAR(500),
            @MobileNo           VARCHAR(20),
            @RetagCount         INT,
            @OriginalDDID       INT;

    DECLARE @TargetEventID   INT,
            @TargetEventNo   VARCHAR(50),
            @TargetEventName NVARCHAR(400),
            @IsCrossEvent    BIT = 0,
            @TargetDate      DATE,
            @TargetFromTime  TIME(7),
            @TargetToTime    TIME(7),
            @Missing         NVARCHAR(1000),
            @Short           NVARCHAR(1000);

    /*  Created up front: the result set below always reads from it, and the
        GOTOs must not be able to skip its creation.  */
    CREATE TABLE #Map
    (
        TransactionTicketDetailID INT           NOT NULL,
        CurrentTicketID           INT           NULL,
        TicketName                NVARCHAR(200) NULL,
        BookQty                   INT           NOT NULL,
        Amount                    DECIMAL(18,2) NOT NULL,
        TotalAmount               DECIMAL(18,2) NOT NULL,
        TargetTicketID            INT           NULL,
        TargetAmount              DECIMAL(18,2) NULL,
        TargetQty                 INT           NULL,
        TargetBookedQty           INT           NULL
    );

    SELECT  @HeaderID        = ETD.EventTransactionHeaderID,
            @EventID         = EH.ID,
            @EventNo         = EH.EventNo,
            @EventName       = EH.EventName,
            @OutletCode      = EH.OutletCode,
            @CurrentDDID     = EDD.ID,
            @CurrentDate     = EDD.[Date],
            @CurrentFromTime = EDD.FromTime,
            @CurrentToTime   = EDD.ToTime,
            @IsComplete      = ETD.IsComplete,
            @BookingStatusId = ETH.BookingStatusId,
            @BookingStatus   = LTRIM(RTRIM(ISNULL(RS.Status, ''))),
            @CustomerName    = LTRIM(RTRIM(ISNULL(ETH.Salutation, N'') + N' '
                                         + ISNULL(ETH.FirstName,  N'') + N' '
                                         + ISNULL(ETH.LastName,   N''))),
            @MobileNo        = ETH.MobileNo,
            @RetagCount      = ETD.RetagCount,
            @OriginalDDID    = ISNULL(ETD.OriginalEventDateDetailID, EDD.ID)
    FROM    dbo.EventTransactionDetail ETD
    INNER JOIN dbo.EventHeader            EH  ON EH.ID  = ETD.EventID
    INNER JOIN dbo.EventDateDetails       EDD ON EDD.ID = ETD.EventDateDetailID
    INNER JOIN dbo.EventTransactionHeader ETH ON ETH.ID = ETD.EventTransactionHeaderID
    LEFT  JOIN dbo.ReservationStatus      RS  ON RS.ID  = ETH.BookingStatusId
    WHERE   ETD.ID = @EventReservationID
      AND   EH.PropertyId = @PropertyId;

    IF @HeaderID IS NULL
    BEGIN
        IF EXISTS (SELECT 1 FROM dbo.EventTransactionDetail WHERE ID = @EventReservationID)
            SELECT @ErrorCode = 'PROPERTY_MISMATCH',
                   @Message   = 'Ticket does not belong to the logged property.';
        GOTO Done;
    END

    /* ---- source ticket eligibility, using the existing states --------------- */

    IF @IsComplete = 1
    BEGIN
        SELECT @ErrorCode = 'ALREADY_REDEEMED',
               @Message   = 'Ticket has already been redeemed / marked as attended and cannot be re-tagged.';
        GOTO Done;
    END

    IF @BookingStatus LIKE '%cancel%' OR @BookingStatus LIKE '%refund%'
       OR @BookingStatus LIKE '%void%' OR @BookingStatus LIKE '%reject%'
    BEGIN
        SELECT @ErrorCode = 'CANCELLED_OR_REFUNDED',
               @Message   = 'Ticket status is "' + @BookingStatus + '" and cannot be re-tagged.';
        GOTO Done;
    END

    IF @RequireConfirmedStatus = 1 AND ISNULL(@BookingStatusId, 0) <> 2
    BEGIN
        SELECT @ErrorCode = 'NOT_CONFIRMED',
               @Message   = 'Only a confirmed (paid) booking can be re-tagged. Current status: '
                            + CASE WHEN @BookingStatusId IS NULL THEN 'not set'
                                   ELSE @BookingStatus END + '.';
        GOTO Done;
    END

    IF @AllowFutureSource = 0
       AND DATEADD(SECOND, DATEDIFF(SECOND, 0, @CurrentFromTime),
                   CAST(@CurrentDate AS DATETIME)) > @AsAtDateTime
    BEGIN
        SELECT @ErrorCode = 'SOURCE_NOT_PAST',
               @Message   = 'The ticket is still valid for an upcoming occurrence and cannot be re-tagged.';
        GOTO Done;
    END

    /* ---- target occurrence -------------------------------------------------- */

    SELECT  @TargetEventID   = EDD.EventID,
            @TargetEventNo   = EH2.EventNo,
            @TargetEventName = EH2.EventName,
            @TargetDate      = EDD.[Date],
            @TargetFromTime  = EDD.FromTime,
            @TargetToTime    = EDD.ToTime
    FROM    dbo.EventDateDetails EDD
    INNER JOIN dbo.EventHeader   EH2 ON EH2.ID = EDD.EventID
    WHERE   EDD.ID = @TargetEventDateDetailID;

    IF @TargetEventID IS NULL
    BEGIN
        SELECT @ErrorCode = 'TARGET_NOT_FOUND',
               @Message   = 'Target event occurrence not found.';
        GOTO Done;
    END

    IF @TargetEventDateDetailID = @CurrentDDID
    BEGIN
        SELECT @ErrorCode = 'TARGET_SAME_AS_CURRENT',
               @Message   = 'The ticket is already assigned to that occurrence.';
        GOTO Done;
    END

    /*  A ticket may move to a different event, but only while it is still
        unused - the eligibility checks above (ALREADY_REDEEMED, CANCELLED_OR_
        REFUNDED, NOT_CONFIRMED) already ran and would have exited by GOTO Done,
        so reaching here means the ticket qualifies regardless of which event
        the target belongs to.  */
    SET @IsCrossEvent = CASE WHEN @TargetEventID <> @EventID THEN 1 ELSE 0 END;

    IF NOT EXISTS (SELECT 1 FROM dbo.EventHeader
                   WHERE ID = @TargetEventID AND PropertyId = @PropertyId
                     AND OutletCode = @OutletCode)
    BEGIN
        SELECT @ErrorCode = 'TARGET_PROPERTY_MISMATCH',
               @Message   = 'Target occurrence belongs to a different property / outlet.';
        GOTO Done;
    END

    IF DATEADD(SECOND, DATEDIFF(SECOND, 0, @TargetFromTime),
               CAST(@TargetDate AS DATETIME)) <= @AsAtDateTime
    BEGIN
        SELECT @ErrorCode = 'TARGET_NOT_FUTURE',
               @Message   = 'Target occurrence is in the past or already started. Pick a future occurrence.';
        GOTO Done;
    END

    /* ---- ticket type compatibility and allotment ---------------------------- */

    IF @IsCrossEvent = 0
    BEGIN
        /*  Same event: ticket types are matched by name, as before.  */
        ;WITH TgtTypes AS (
            SELECT  LTRIM(RTRIM(TicketName)) AS TicketName,
                    MIN(TicketID)            AS TargetTicketID,
                    MIN(Qty)                 AS TargetQty,
                    MIN(Amount)              AS TargetAmount
            FROM    dbo.EventWiseTicketDetail
            WHERE   EventDateDetailsID = @TargetEventDateDetailID
            GROUP BY LTRIM(RTRIM(TicketName))
        ),
        TgtBooked AS (
            SELECT  ETTD.TicketID, SUM(ETTD.BookQty) AS BookedQty
            FROM    dbo.EventTransactionTicketDetail ETTD
            INNER JOIN dbo.EventTransactionDetail    ETD ON ETD.ID = ETTD.EventTransactionDetailID
            WHERE   ETD.EventDateDetailID = @TargetEventDateDetailID
            GROUP BY ETTD.TicketID
        )
        INSERT INTO #Map (TransactionTicketDetailID, CurrentTicketID, TicketName, BookQty,
                          Amount, TotalAmount, TargetTicketID, TargetAmount, TargetQty, TargetBookedQty)
        SELECT  ETTD.ID,
                ETTD.TicketID,
                LTRIM(RTRIM(EWTD.TicketName)),
                ETTD.BookQty,
                ETTD.Amount,
                ETTD.TotalAmount,
                T.TargetTicketID,
                T.TargetAmount,
                T.TargetQty,
                ISNULL(B.BookedQty, 0)
        FROM    dbo.EventTransactionTicketDetail ETTD
        LEFT JOIN dbo.EventWiseTicketDetail      EWTD ON EWTD.TicketID = ETTD.TicketID
        LEFT JOIN TgtTypes                       T    ON T.TicketName  = LTRIM(RTRIM(EWTD.TicketName))
        LEFT JOIN TgtBooked                      B    ON B.TicketID    = T.TargetTicketID
        WHERE   ETTD.EventTransactionDetailID = @EventReservationID;
    END
    ELSE
    BEGIN
        /*  Different event: no name to match against - use the admin's chosen
            mapping instead, but never trust a target id blindly. A requested
            TargetTicketID only survives the join (and so avoids TICKET_TYPE_
            MISSING below) when it is genuinely a ticket type defined on the
            target occurrence.  */
        ;WITH RequestedMap AS (
            SELECT  TransactionTicketDetailID, TargetTicketID
            FROM    OPENJSON(ISNULL(@RequestedTicketMappingJson, N'[]'))
                    WITH (TransactionTicketDetailID INT '$.TransactionTicketDetailID',
                          TargetTicketID            INT '$.TargetTicketID')
        ),
        TgtBooked AS (
            SELECT  ETTD.TicketID, SUM(ETTD.BookQty) AS BookedQty
            FROM    dbo.EventTransactionTicketDetail ETTD
            INNER JOIN dbo.EventTransactionDetail    ETD ON ETD.ID = ETTD.EventTransactionDetailID
            WHERE   ETD.EventDateDetailID = @TargetEventDateDetailID
            GROUP BY ETTD.TicketID
        )
        INSERT INTO #Map (TransactionTicketDetailID, CurrentTicketID, TicketName, BookQty,
                          Amount, TotalAmount, TargetTicketID, TargetAmount, TargetQty, TargetBookedQty)
        SELECT  ETTD.ID,
                ETTD.TicketID,
                LTRIM(RTRIM(EWTD.TicketName)),
                ETTD.BookQty,
                ETTD.Amount,
                ETTD.TotalAmount,
                TT.TicketID,
                TT.Amount,
                TT.Qty,
                ISNULL(B.BookedQty, 0)
        FROM    dbo.EventTransactionTicketDetail ETTD
        LEFT JOIN dbo.EventWiseTicketDetail      EWTD ON EWTD.TicketID = ETTD.TicketID
        LEFT JOIN RequestedMap                   RM   ON RM.TransactionTicketDetailID = ETTD.ID
        LEFT JOIN dbo.EventWiseTicketDetail      TT   ON TT.TicketID = RM.TargetTicketID
                                                       AND TT.EventDateDetailsID = @TargetEventDateDetailID
        LEFT JOIN TgtBooked                      B    ON B.TicketID = TT.TicketID
        WHERE   ETTD.EventTransactionDetailID = @EventReservationID;
    END

    IF NOT EXISTS (SELECT 1 FROM #Map)
    BEGIN
        SELECT @ErrorCode = 'NO_TICKET_LINES',
               @Message   = 'The booking has no ticket lines to move.';
        GOTO Done;
    END

    SELECT  @Missing = STUFF((
                SELECT DISTINCT N', ' + ISNULL(M.TicketName, N'(unknown ticket type)')
                FROM   #Map M WHERE M.TargetTicketID IS NULL
                FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, N'');

    IF @Missing IS NOT NULL
    BEGIN
        IF @IsCrossEvent = 1
            SELECT @ErrorCode = 'TICKET_TYPE_MISSING',
                   @Message   = 'Choose a target ticket type for: ' + @Missing + '.';
        ELSE
            SELECT @ErrorCode = 'TICKET_TYPE_MISSING',
                   @Message   = 'The target occurrence does not offer: ' + @Missing + '.';
        GOTO Done;
    END

    /*  Grouped by the actual target ticket type id, not its name: within the
        same event that is equivalent (name matching is 1:1 by construction),
        but a cross-event mapping can legitimately send two differently-named
        source lines onto the SAME target type, and both must count against
        its one allotment.  */
    SELECT  @Short = STUFF((
                SELECT N', ' + G.Names + N' (need ' + CAST(G.MoveQty AS NVARCHAR(10))
                             + N', ' + CAST(G.RemainingQty AS NVARCHAR(10)) + N' left)'
                FROM (
                    SELECT  M.TargetTicketID,
                            MIN(M.TicketName)                              AS Names,
                            SUM(M.BookQty)                                  AS MoveQty,
                            MIN(M.TargetQty) - MIN(M.TargetBookedQty)       AS RemainingQty
                    FROM    #Map M
                    GROUP BY M.TargetTicketID
                ) G
                WHERE G.RemainingQty < G.MoveQty
                ORDER BY G.Names
                FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, N'');

    IF @Short IS NOT NULL
    BEGIN
        SELECT @ErrorCode = 'INSUFFICIENT_CAPACITY',
               @Message   = 'Not enough tickets left on the target occurrence: ' + @Short + '.';
        GOTO Done;
    END

    SELECT @IsValid = 1, @ErrorCode = 'OK', @Message = 'Ticket can be re-tagged.';

Done:

    SELECT  @IsValid                    AS IsValid,
            @ErrorCode                  AS ErrorCode,
            @Message                    AS [Message],

            @EventReservationID         AS EventReservationID,
            @HeaderID                   AS EventTransactionHeaderID,
            @MobileNo                   AS MobileNo,
            @CustomerName               AS CustomerName,

            @EventID                    AS EventID,
            @EventNo                    AS EventNo,
            @EventName                  AS EventName,
            @OutletCode                 AS OutletCode,
            @PropertyId                 AS PropertyId,

            @CurrentDDID                AS CurrentEventDateDetailID,
            @CurrentDate                AS CurrentEventDate,
            @CurrentFromTime            AS CurrentFromTime,
            @CurrentToTime              AS CurrentToTime,
            @OriginalDDID               AS OriginalEventDateDetailID,
            @RetagCount                 AS RetagCount,

            @TargetEventDateDetailID    AS TargetEventDateDetailID,
            @TargetDate                 AS TargetEventDate,
            @TargetFromTime             AS TargetFromTime,
            @TargetToTime               AS TargetToTime,
            @TargetEventID              AS TargetEventID,
            @TargetEventNo              AS TargetEventNo,
            @TargetEventName            AS TargetEventName,
            @IsCrossEvent               AS IsCrossEvent,

            @BookingStatusId            AS BookingStatusID,
            @BookingStatus              AS BookingStatus,
            @IsComplete                 AS IsComplete,

            (SELECT ISNULL(SUM(BookQty), 0)     FROM #Map)              AS TotalTickets,
            (SELECT ISNULL(SUM(TotalAmount), 0) FROM #Map)              AS TotalAmount,
            (SELECT ISNULL(SUM(BookQty * ISNULL(TargetAmount, 0)), 0)
             FROM #Map)                                                 AS TargetTotalAmount,
            (SELECT TransactionTicketDetailID, CurrentTicketID, TicketName,
                    BookQty, Amount, TotalAmount, TargetTicketID, TargetAmount,
                    TargetQty, TargetBookedQty
             FROM   #Map
             FOR JSON PATH)                                             AS TicketMappingJson;

    IF OBJECT_ID('tempdb..#Map') IS NOT NULL DROP TABLE #Map;
END

GO

