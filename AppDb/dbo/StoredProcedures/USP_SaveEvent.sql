
CREATE PROCEDURE [dbo].[USP_SaveEvent]
    @Id INT = NULL,
    @EventNo VARCHAR(50),
    @EventName NVARCHAR(200),
    @Address NVARCHAR(500),
    @Remark VARCHAR(200),
    @OutletCode VARCHAR(5),
    @PropertyId INT,
    @IsActive BIT,
    @IsEventAvailable BIT = 1,
    @CoverPath VARCHAR(500),
    @ThumbnailPath VARCHAR(500),
    @EventDateDetailsJson NVARCHAR(MAX),
    @EventTicketDetailsJson NVARCHAR(MAX),
    @UserId INT,
    @Operation VARCHAR(10),
    @CreateDate DATETIME,
    @LastModifiedDate DATETIME,
    @CreateUser NVARCHAR(100),
    @LastModifiedUser NVARCHAR(100),
    @CoverPathByte IMAGE = NULL,
    @ThumbnailPathByte IMAGE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        /*  An event can never be scheduled across multiple days: reject up
            front, before the EventHeader row is touched. OPENJSON(NULL) / on
            an empty string returns zero rows, so a save with no date is not
            blocked here - that is the same "no date yet" case USP_SaveEvent
            already tolerates below. */
        IF @EventDateDetailsJson IS NOT NULL AND @EventDateDetailsJson <> ''
           AND (SELECT COUNT(*) FROM OPENJSON(@EventDateDetailsJson)) > 1
        BEGIN
            RAISERROR('An event can only have one date. Multiple event dates are not allowed.', 16, 1);
        END

        DECLARE @NewEventId INT;

        -- Save Event Header
        IF @Id IS NULL OR @Id = 0
        BEGIN
            EXEC [UpdateNextDocNo] 'EventNo', @PropertyId

            INSERT INTO [dbo].[EventHeader] (
                [EventNo], [EventName], [CreateDate], [CreateUser],
                [LastModifiedDate], [LastModifiedUser], [Address],
                [CoverPath], [ThubnailPath], [Remark], [OutletCode], [PropertyId],
                [IsEventAvailable], CoverBinary, ThubnailBinary
            )
            VALUES (
                @EventNo, @EventName, @CreateDate, @CreateUser,
                @LastModifiedDate, @LastModifiedUser, @Address,
                @CoverPath, @ThumbnailPath, @Remark, @OutletCode, @PropertyId,
                @IsEventAvailable, @CoverPathByte, @ThumbnailPathByte
            );

            SET @NewEventId = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            UPDATE [dbo].[EventHeader]
            SET
                [EventName] = @EventName,
                [LastModifiedDate] = @LastModifiedDate,
                [LastModifiedUser] = @LastModifiedUser,
                [Address] = @Address,
                [CoverPath] = (CASE WHEN @CoverPathByte IS NULL THEN [CoverPath] ELSE @CoverPath END),
                [ThubnailPath] = (CASE WHEN @ThumbnailPathByte IS NULL THEN [ThubnailPath] ELSE @ThumbnailPath END),
                [Remark] = @Remark,
                [OutletCode] = @OutletCode,
                [PropertyId] = @PropertyId,
                [IsEventAvailable] = @IsEventAvailable,
                CoverBinary = ISNULL(@CoverPathByte, CoverBinary),
                ThubnailBinary = ISNULL(@ThumbnailPathByte, ThubnailBinary)
            WHERE [ID] = @Id;

            SET @NewEventId = @Id;

            -- Delete existing details if updating
            DELETE FROM [dbo].[EventWiseTicketDetail] WHERE [EventID] = @NewEventId;
            DELETE FROM [dbo].[EventDateDetails] WHERE [EventID] = @NewEventId;
        END

        -- Save Event Date Details from JSON
        IF @EventDateDetailsJson IS NOT NULL AND @EventDateDetailsJson != ''
        BEGIN
            INSERT INTO [dbo].[EventDateDetails] (
                [EventID], [Date], [FromTime], [ToTime]
            )
            SELECT
                @NewEventId,
                TRY_CONVERT(DATE, [Date], 103),
                CAST([FromTime] AS TIME),
                CAST([ToTime] AS TIME)
            FROM OPENJSON(@EventDateDetailsJson)
            WITH (
                [Date] VARCHAR(10) '$.DateString',
                [FromTime] VARCHAR(8) '$.FromTimeString',
                [ToTime] VARCHAR(8) '$.ToTimeString'
            );
        END

        -- Save Event Ticket Details from JSON
        IF @EventTicketDetailsJson IS NOT NULL AND @EventTicketDetailsJson != ''
        BEGIN
            -- Get the DateDetail IDs for mapping
            ;WITH DateDetails AS (
                SELECT
                    ID,
                    ROW_NUMBER() OVER (ORDER BY ID) as RowNum
                FROM [dbo].[EventDateDetails]
                WHERE [EventID] = @NewEventId
            )
            INSERT INTO [dbo].[EventWiseTicketDetail] (
                [EventDateDetailsID], [EventID], [TicketName], [Amount], [Qty]
            )
            SELECT
                dd.ID,
                @NewEventId,
                t.[TicketName],
                t.[Amount],
                t.[Qty]
            FROM OPENJSON(@EventTicketDetailsJson)
            WITH (
                [TicketName] NVARCHAR(100) '$.TicketName',
                [Amount] DECIMAL(18,2) '$.Amount',
                [Qty] INT '$.Qty',
                [DateDetailIndex] INT '$.DateDetailIndex'
            ) t
            CROSS JOIN DateDetails dd
            --INNER JOIN DateDetails dd ON dd.RowNum = t.DateDetailIndex;
        END

        -- Return the saved event header
        SELECT
            [ID] as Id,
            [EventNo],
            [EventName],
            [Address],
            [Remark],
            [OutletCode],
            [PropertyId],
            [CoverPath],
            ThubnailPath as ThumbnailPath,
            [IsEventAvailable],
            [CreateDate],
            [CreateUser],
            [LastModifiedDate],
            [LastModifiedUser]
        FROM [dbo].[EventHeader]
        WHERE [ID] = @NewEventId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END

GO

