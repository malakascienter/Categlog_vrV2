
CREATE PROCEDURE[dbo].[SP_Save_LaborMaster] --7,4,3,'192.168.0.0',1,1,'2018-04-05','2018-05-04',1
 --DECLARE PARAMETERS

	@Id int OUTPUT,
	@LaborUnitId int,
	@LaborTypeId int,
	@SupplierId int,
	@price decimal,
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
		IF EXISTS(SELECT* FROM LaborMasters WHERE  SupplierId =@SupplierId and LaborTypeId=@LaborTypeId and LaborUnitId = @LaborUnitId )
		BEGIN
		 --UPDATE THE RECORD
		 UPDATE LaborMasters SET
		[LaborUnitId] = @LaborUnitId,
		[LaborTypeId] = @LaborTypeId,
		[price] = @price,
		[SupplierId]=@SupplierId,
		[IPAddress] = @IPAddress,
		--[CreatedUserID] = @CreatedUserID,
		[LastModUserID] = @LastModUserID,
		--[CreatedDate] = @CreatedDate,
		[LastModDate] = @LastModDate
		WHERE [Id] = @Id
		SET @statusIN = 2
	END
	ELSE
	BEGIN
	--INSERT THE RECORD
	INSERT INTO LaborMasters(
		[LaborUnitId],
		[LaborTypeId],
		[price],
		[SupplierId],
		[IPAddress],
		[CreatedUserID],
		[LastModUserID],
		[CreatedDate],
		[LastModDate]
		)
		VALUES
		(
		@LaborUnitId,
		@LaborTypeId,
		@price,
		@SupplierId,
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
		DELETE LaborMasters WHERE [Id] = @Id
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

