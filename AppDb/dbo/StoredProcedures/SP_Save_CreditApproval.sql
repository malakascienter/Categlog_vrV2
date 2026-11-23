--SP_Save_CreditApproval 1,'',1,1212,'P',0,'',1,1,,,1,1,1,'',''
CREATE PROCEDURE[dbo].[SP_Save_CreditApproval]

    @Id int,
	@PropertyId int,
    @CRNumber nvarchar(max),
    @CustomerId int,
    @Amount decimal(18, 2),
    @DocumentStatus nvarchar(max),
    @IsApproved bit,
    @IPAddress nvarchar(max),
    @CreatedUserID int,
    @LastModUserID int,
    @CreatedDate  datetime,
    @LastModDate   datetime,
	@Action[int],
	@status[int] output,
	@NewId[int] output,
	@message NVARCHAR(200) OUTPUT,
	@CRID nvarchar(200) OUTPUT

	
AS
	DECLARE @statusIN[int]
	SET @statusIN = 0;
	SET  @NewId =0
	SET  @message = ''

BEGIN 
BEGIN TRY
	BEGIN TRANSACTION 
	declare @OrderHeaderID INT ,
	@TransactionTypeID INT,
	@LocationID INT
IF @Action =1
	BEGIN
		IF EXISTS(SELECT * FROM  CreditApprovals WHERE [Id] =@Id)
		BEGIN
		 --UPDATE THE RECORD
		  UPDATE CreditApprovals SET
		    [PropertyId] = @PropertyId,
			[CustomerId] =@CustomerId,
			[Amount]=@Amount,
			[DocumentStatus]=@DocumentStatus,
			[IsApproved]=@IsApproved,
			[IPAddress]=@IPAddress,
			[LastModUserID]=@LastModUserID,
			[LastModDate]=@LastModDate
			WHERE [Id] = @Id
		    SET @statusIN = 2


		END
	ELSE
	BEGIN
	DECLARE @Prefix VARCHAR(max),@Len INT,@Code VARCHAR(max)


   -- SELECT @Prefix=Prefix FROM dbo.Locations WHERE Id=1
 
	select @CRNumber= dbo.FN_GetNextDocumentNumber (@PropertyId,-99,'CR')

	IF @CRNumber IS NULL
    BEGIN
	INSERT INTO TransactionTypeWiseNextNumbers
	(PropertyID, LocationID, TransactionType, NextNumber, LengthOfFormatting)
	VALUES (1,-99,'CR',1,6)
	 select @CRNumber= dbo.FN_GetNextDocumentNumber (1,-99,'CR')
     END

	--SELECT LEN(@Prefix)

-- SELECT @Prefix=SUBSTRING(@Prefix,1,3)

--SET @CRNumber=@Prefix+'/'+@Code+'/'+@CRNumber
SET @CRNumber='CR'+@CRNumber

SET @CRID = @CRNumber


update TransactionTypeWiseNextNumbers
set NextNumber=NextNumber+1
where locationid=-99 and transactionType='CR'


	INSERT INTO CreditApprovals(
        [CRNumber],  
	    [PropertyId], 
		[CustomerId],
		[Amount],
		[DocumentStatus],
		[IsApproved],
		[IPAddress],
		[CreatedUserID],
		[LastModUserID],
		[CreatedDate],
		[LastModDate]
		)
		VALUES
		(
		@CRNumber,
		@PropertyId,
		@CustomerId,
		@Amount,
		@DocumentStatus,
		@IsApproved,
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
		DELETE [CreditApprovals] WHERE [Id] = @Id
	IF @@ROWCOUNT >0 
	BEGIN
		SET @statusIN = 3;
	END
	ELSE
	BEGIN
		SET @statusIN = -3;
	END
END --ACTIION -3 ENDS


SET @OrderHeaderID=@NewId 
SET @TransactionTypeID=49 
SET  @LocationID=-99
SET @PropertyId=1
exec dbo.SP_Insert_Approval_Level_For_Order  @PropertyID,@LocationID,@TransactionTypeID,@OrderHeaderID
SELECT  @PropertyID ,@LocationID,@TransactionTypeID,@OrderHeaderID

--SELECT * FROM ApprovalLogs WHERE TransactionHeaderID= 3026
--SP_InsertApprovalLevelForRequest 1,-99,49,3026

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

