CREATE PROCEDURE[dbo].[SPP_Update_SectionName]
 --DECLARE PARAMETERS

	@Id int,	
	@SectionID int,
	@SectionName VARCHAR(max),	
	@status[int] OUTPUT,
	
	@PropertyID INT

AS
	DECLARE @statusIN[int]
	SET @statusIN = 0;
BEGIN
BEGIN TRY
	BEGIN TRANSACTION
	DECLARE @BOQMAINID INT



	
	UPDATE BOQMainWorkAllocations
	SET Description=@SectionName
    WHERE BOQMainWorkAllocations.BOQID=@Id and Id=@SectionID

		SET @statusIN = 1;

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

