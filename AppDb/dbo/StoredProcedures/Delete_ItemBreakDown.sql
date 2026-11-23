
CREATE PROCEDURE [dbo].[Delete_ItemBreakDown]
	@MainMenuCode VARCHAR(4),
	@PropertyId INT
AS
BEGIN TRY
BEGIN TRANSACTION
	
	SET NOCOUNT ON;
	Delete FROM ItemBreakDown where  MainMenuCode=@MainMenuCode AND PropertyId = @PropertyId

COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)	
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())
	RAISERROR('Record Not Save.',16,1)
END CATCH

GO

