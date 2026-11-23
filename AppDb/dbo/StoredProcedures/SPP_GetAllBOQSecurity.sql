CREATE PROCEDURE[dbo].[SPP_GetAllBOQSecurity]
 --DECLARE PARAMETERS

	

AS
	
BEGIN
BEGIN TRY
	BEGIN TRANSACTION

	
	select * from BOQSecurityAcesses



	
	

		
	
	 --ACTION 2 ENDS
	COMMIT TRAN -- Transaction Success!
	
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN --RollBack in case of Error
	
		SELECT
		ERROR_NUMBER() AS ErrorNumber
		,ERROR_SEVERITY() AS ErrorSeverity
		,ERROR_STATE() AS ErrorState
		,ERROR_PROCEDURE() AS ErrorProcedure
		,ERROR_LINE() AS ErrorLine
	,ERROR_MESSAGE() AS ErrorMessage
END CATCH
END--SP ENDS

GO

