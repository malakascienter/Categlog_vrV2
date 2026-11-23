CREATE Procedure [dbo].[SP_FindExchangeRate] (@Id INT,@Exchange DECIMAL OUTPUT)
AS 




BEGIN TRY
BEGIN TRANSACTION


SELECT @Exchange=ExchangeRate from ProjectDetails where Id=@Id

COMMIT TRAN 
END TRY
BEGIN CATCH
	return CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN 
END CATCH

GO

