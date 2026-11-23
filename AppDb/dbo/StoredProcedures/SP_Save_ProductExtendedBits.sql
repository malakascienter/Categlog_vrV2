CREATE PROCEDURE[dbo].[SP_Save_ProductExtendedBits]
 --DECLARE PARAMETERS

	@Id int,
	@StockHeaderId int,
	@ExtendedId int,
	@Value bit,
    @IPAddress nvarchar(max),
	@CreatedUserID int,
	@LastModUserID int,             
	@CreatedDate datetime,
	@LastModDate datetime,
	@Action[int],
	@status[int] output,
	@NewId[int] output,
	@message NVARCHAR(max) OUTPUT

	

AS
	DECLARE @statusIN[int]
	SET @statusIN = 0;
	SET  @NewId =0
	SET  @message = ''
BEGIN
BEGIN TRY
	BEGIN TRANSACTION
IF @Action =1
	BEGIN
		IF EXISTS(SELECT* FROM ProductExtendedBits WHERE  [Id] = @Id)
		BEGIN
	
		 --UPDATE THE RECORD
		 UPDATE ProductExtendedBits SET
		
		[IPAddress] = @IPAddress,
		[CreatedUserID] =@CreatedUserID,
		[LastModUserID] = @LastModUserID,
		[CreatedDate] = @CreatedDate,
		[LastModDate] = @LastModDate
        WHERE [Id] = @Id
		SET @statusIN = 2
	END
	ELSE
	BEGIN
	--INSERT THE RECORD
	INSERT INTO ProductExtendedBits(
		[StockHeaderId],
		[ExtendedId],
		[Value],
		[IPAddress],
		[CreatedUserID],
		[LastModUserID],
		[CreatedDate],
		[LastModDate]
		)
		VALUES
		(
		@StockHeaderId,
		@ExtendedId,
		@Value,
		@IPAddress,
		@CreatedUserID,
		@LastModUserID,
		@CreatedDate,
		@LastModDate
		)
		SELECT SCOPE_IDENTITY() AS ID
		SET @NewId = SCOPE_IDENTITY()
		SET @statusIN = 1;
	END
	END --ACTION 2 ENDS
ELSE IF @Action = 2
	BEGIN
		DELETE [ProductExtendedBits] WHERE [Id] = @Id
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
	SET @status = @statusIN
END TRY
BEGIN CATCH
	SET @status = -1;
SET @message = CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN --RollBack in case of Error
END CATCH
END--SP ENDS

GO

