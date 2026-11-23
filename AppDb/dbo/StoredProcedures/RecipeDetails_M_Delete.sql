-- =============================================
-- Author:		Chiraj
-- Create date: 2019-2-13
-- Description:	DCelete recipe details by recipe code and item code
-- =============================================
CREATE PROCEDURE [dbo].[RecipeDetails_M_Delete] 
	@RecipeCode VARCHAR(6),
	@ItemCode VARCHAR(16),
	@UserId	INT,
	@PropertyId INT
AS
BEGIN TRY
	IF EXISTS(SELECT 1 FROM RecipeDetails 	WHERE RecipeCode=@RecipeCode and StockItemCode=@ItemCode AND PropertyId=@PropertyId)
	BEGIN
		DELETE FROM RecipeDetails WHERE RecipeCode=@RecipeCode and 	StockItemCode=@ItemCode AND PropertyId=@PropertyId
	END
	ELSE
	BEGIN
		RAISERROR('Record not Exists',16,1)
	END
    
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())

	DECLARE  @ERRmsg VARCHAR(MAX) =ERROR_MESSAGE()
	RAISERROR(@ERRmsg,16,1)
END CATCH

GO

