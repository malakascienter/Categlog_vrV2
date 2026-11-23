
CREATE PROCEDURE [dbo].[Save_ItemBreakDown_OneByOne]
	@MainMenuCode VARCHAR(10),
	@RecipeCode NVARCHAR(20),
	@Qty MONEY,
	@PropertyId INT
AS
BEGIN TRY
BEGIN TRANSACTION
	
	SET NOCOUNT ON;

	IF EXISTS(SELECT 1 FROM ItemBreakDown WHERE MainMenuCode = @MainMenuCode AND RecipeCode = @RecipeCode AND PropertyId = @PropertyId)
	BEGIN
		RAISERROR('This Recipe for Menu Item is already added', 16, 1)
	END
	ELSE
	BEGIN
		
		INSERT INTO ItemBreakDown (MainMenuCode, RecipeCode, Qty,PropertyId,IsUpload,SysDate,AdditionalCost)
		VALUES( @MainMenuCode,@RecipeCode,@Qty,@PropertyId,0,GETDATE(),0)
		
	END

	

	
COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)	
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())
	DECLARE @ErrorMsg VARCHAR(MAX) 
	SET @ErrorMsg = ERROR_MESSAGE()
	RAISERROR(@ErrorMsg,16,1)
END CATCH

GO

