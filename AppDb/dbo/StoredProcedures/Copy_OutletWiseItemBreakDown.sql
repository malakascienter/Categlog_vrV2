
CREATE PROCEDURE [dbo].[Copy_OutletWiseItemBreakDown]
	@MainMenuCode VARCHAR(10),
	@FromOutelet VARCHAR(5),
	@ToOutelet VARCHAR(5),
	@PropertyId INT
AS
BEGIN TRY
BEGIN TRANSACTION
	
	SET NOCOUNT ON;
	Delete FROM OutletWiseItemBreakDown where Outlet =  @ToOutelet AND PropertyId = @PropertyId

	INSERT INTO OutletWiseItemBreakDown (MainMenuCode, RecipeCode, Qty,Outlet,PropertyId)
    SELECT MainMenuCode, RecipeCode, Qty,@ToOutelet,@PropertyId
	FROM OutletWiseItemBreakDown
	WHERE Outlet = @FromOutelet and PropertyId =@PropertyId 

COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)	
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())
	RAISERROR('Record Not Save.',16,1)
END CATCH

GO

