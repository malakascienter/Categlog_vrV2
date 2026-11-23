CREATE PROCEDURE [dbo].[USP_DeleteEvent]
    @EventNo VARCHAR(50),
    @UserId INT,
	@PropertyId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @EventId INT = (SELECT [ID] FROM [dbo].[EventHeader] WHERE [EventNo] = @EventNo);

        IF @EventId IS NOT NULL
        BEGIN
            -- Delete ticket details
            DELETE FROM [dbo].[EventWiseTicketDetail] WHERE [EventID] = @EventId;
            
            -- Delete date details
            DELETE FROM [dbo].[EventDateDetails] WHERE [EventID] = @EventId;
            
            -- Delete event header
            DELETE FROM [dbo].[EventHeader] WHERE [ID] = @EventId;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END

GO

