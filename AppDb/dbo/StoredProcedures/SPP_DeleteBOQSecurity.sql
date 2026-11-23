CREATE PROCEDURE[dbo].[SPP_DeleteBOQSecurity]
 --DECLARE PARAMETERS

	@ID int,
	@status[int] OUTPUT
	
	

AS
	DECLARE @statusIN[int]
	SET @statusIN = 0;
BEGIN
BEGIN TRY
	BEGIN TRANSACTION

	
	delete  from BOQSecurityAcesses  where ID=@ID



	
	

		SET @statusIN = 1;
	
	 --ACTION 2 ENDS
	COMMIT TRAN -- Transaction Success!
	SET @status = @statusIN
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN --RollBack in case of Error
	SET @status = -1;
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

