CREATE PROCEDURE[dbo].[SPP_Save_BOQSecurity]
 --DECLARE PARAMETERS

	@Id int,
	@ProjectID int,
	@BOQID nvarchar(MAX),
	@UserID int,
	@Section int,
	@Work int,
	@Rate int,
	@IsAccess bit,
	@status[int] OUTPUT
	

AS
	DECLARE @statusIN[int]
	SET @statusIN = 0;
BEGIN
BEGIN TRY
	BEGIN TRANSACTION

	
	



	
	INSERT INTO BOQSecurityAcesses(
		[ProjectID],
		[BOQID],
		[UserID],
		[Section],
		[Work],
		[Rate],
		[IsAccess]
		
		)
		VALUES
		(
		@ProjectID,
		@BOQID,
		@UserID,
		@Section,
		@Work,
		@Rate,
		@IsAccess
		
		)
		

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

