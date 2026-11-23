-- =============================================
-- Create date: 2026-10-09
-- Description: Day End Validation Modes - Deletes one mode from the Day End Validation Modes screen

-- EXEC dbo.SP_DayEnd_DeleteValidationMode 4, 1

-- =============================================

CREATE   PROCEDURE dbo.SP_DayEnd_DeleteValidationMode
    @Id     INT,
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Code NVARCHAR(100), @IsSystem BIT, @LocationCount INT;

    SELECT @Code = LTRIM(RTRIM(Code)), @IsSystem = ISNULL(IsSystem, 0)
    FROM   dbo.DayEnd_ValidationModes
    WHERE  Id = @Id;

    IF @Code IS NULL
    BEGIN
        RAISERROR('Validation mode not found. It may have been deleted already.', 16, 1);
        RETURN;
    END

    IF @IsSystem = 1
    BEGIN
        RAISERROR('The system mode %s can''t be deleted.', 16, 1, @Code);
        RETURN;
    END

    SELECT @LocationCount = COUNT(*)
    FROM   dbo.Locations
    WHERE  LTRIM(RTRIM(DayEndValidationMode)) = @Code;

    IF @LocationCount > 0
    BEGIN
        RAISERROR('Can''t delete %s: %d location(s) use this mode. Change their mode first.', 16, 1, @Code, @LocationCount);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        DELETE FROM dbo.DayEnd_ValidationModeDetails WHERE ValidationModeID = @Id;
        DELETE FROM dbo.DayEnd_ValidationModes WHERE Id = @Id;

        EXEC dbo.InsertMasterFileChangeLog 'Day End Validation Mode', @UserID, 'D', @Code;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE(),
                @ErrorSeverity INT = ERROR_SEVERITY(),
                @ErrorState INT = ERROR_STATE();
        RAISERROR(N'%s', @ErrorSeverity, @ErrorState, @ErrorMessage);
    END CATCH
END

GO

