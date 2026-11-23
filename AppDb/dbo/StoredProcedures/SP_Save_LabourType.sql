
CREATE PROCEDURE[dbo].[SP_Save_LabourType] --7,4,3,2400,'192.168.0.0',1,1,'2018-04-05','2018-05-04',1
 --DECLARE PARAMETERS

	@Id int OUTPUT,
	@LabourCode nvarchar(max),
	@LabourName nvarchar(max),
	@IPAddress nvarchar(max),
	@CreatedUserID int,
	@LastModUserID int,
	@CreatedDate datetime,
	@LastModDate datetime,
	@Action[int]
	--@statusOut[int] output

AS
	DECLARE @statusIN[int]
	SET @statusIN = 0;
BEGIN
BEGIN TRY
	BEGIN TRANSACTION
IF @Action =1
	BEGIN
		IF EXISTS(SELECT* FROM LabourTypes WHERE  [Id] = @Id)
		BEGIN
		 --UPDATE THE RECORD
		 UPDATE LabourTypes SET
		[LabourCode] = @LabourCode,
		[LabourName] = @LabourName,
		[IPAddress] = @IPAddress,
		[CreatedUserID] = @CreatedUserID,
		[LastModUserID] = @LastModUserID,
		[CreatedDate] = @CreatedDate,
		[LastModDate] = @LastModDate
		WHERE [Id] = @Id
		SET @statusIN = 2
	END
	ELSE
	BEGIN
	--INSERT THE RECORD
	INSERT INTO LabourTypes(
		[LabourCode],
		[LabourName],
		[IPAddress],
		[CreatedUserID],
		[LastModUserID],
		[CreatedDate],
		[LastModDate]
		)
		VALUES
		(
		@LabourCode,
		@LabourName,
		@IPAddress,
		@CreatedUserID,
		@LastModUserID,
		@CreatedDate,
		@LastModDate
		)
		SELECT SCOPE_IDENTITY() AS ID
		SET @statusIN = 1;
	END
	END --ACTION 2 ENDS
ELSE IF @Action = 2
	BEGIN
		DELETE LabourTypes WHERE [Id] = @Id
	IF @@ROWCOUNT >0 
	BEGIN
		SET @statusIN = 3;
	END
	ELSE
	BEGIN
		SET @statusIN = -3;
	END
END --ACTIION -3 ENDS
	COMMIT TRAN -- Transaction Success!
	--SET @status = @statusIN
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN --RollBack in case of Error
	--SET @status = -1;
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

