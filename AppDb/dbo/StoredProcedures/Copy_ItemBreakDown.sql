-- =============================================
-- Author:		Chiraj
-- Create date: 2020-05-16
-- Description:	Save Item Breakown
-- =============================================
CREATE PROCEDURE [dbo].[Copy_ItemBreakDown]
	@MainMenuCode VARCHAR(10),
	@CopyMainMenuCode VARCHAR(10),
	@PropertyId INT
AS
BEGIN TRY
BEGIN TRANSACTION
	
	SET NOCOUNT ON;
	Delete FROM ItemBreakDown where  MainMenuCode=@MainMenuCode AND PropertyId = @PropertyId

	INSERT INTO ItemBreakDown (MainMenuCode, RecipeCode, Qty,PropertyId,IsUpload,SysDate,AdditionalCost)
    SELECT @MainMenuCode,RecipeCode,Qty,@PropertyId,0,GETDATE(),0
	FROM ItemBreakDown
	WHERE MainMenuCode = @CopyMainMenuCode AND PropertyId = @PropertyId

COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)	
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())
	RAISERROR('Record Not Save.',16,1)
END CATCH

GO

