
/*** ***************************************************************************************************** ****/
-- This procedure was Auto Genarated By A tool created by S.G. Asanga Chandrakumara
-- ON9/28/2017 11:14:21 AM
/*** ***************************************************************************************************** ****/

/*
-----------------------------------------------------
INPUTS
-----------------------------------------------------
- WHEN SAVE ADD ALL OTHER COLUMNS AS DEFAULT
- PASS @Action =1 TO INSERT OR UPDATE
- PASS @Action =2 TO DELETE
-----------------------------------------------------
OUTPUTS
-----------------------------------------------------
@status RETURNS 1 WHEN RECORD INSERTED AND NO ERRORS
@status RETURNS 2 WHEN RECORD UPDATED AND NO ERRORS
@status RETURNS 3 WHEN MORE THAN ONE RECORD DELETED AND NO ERRORS
@status RETURNS -3 WHEN DELETED SUCCESS BUT NO EFFECTED NO OF RECORDS
@status RETURNS -1 WHEN ANY KIND OF ERROR OCCURED
TO INSERT A RECORD PASS A NEGATIVE)VALUE TO @ID
*/
CREATE PROCEDURE[dbo].[SP_Save_SupplierPaymentAgreements]
 --DECLARE PARAMETERS

	@Id int,
	@Description nvarchar(max),
	@Creditperiod int,
	@AdvanceRatio real,
	@OnDeliverRatio real,
	@PayMethodID int,
	@BillingFrequency int,
	@IsActive bit,
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
		IF EXISTS(SELECT* FROM SupplierPaymentAgreements WHERE  [Id] = @Id)
		BEGIN
		EXEC Inventry_AuditTail_WriteToLog 'SupplierPaymentAgreements', @Id, 'INV', 'SPAU', 'U', @LastModUserID,1, '', ''
		 --UPDATE THE RECORD
		 UPDATE SupplierPaymentAgreements SET
		[Description] = @Description,
		[Creditperiod] = @Creditperiod,
		[AdvanceRatio] = @AdvanceRatio,
		[OnDeliverRatio] = @OnDeliverRatio,
		[PayMethodID] = @PayMethodID,
		[BillingFrequency] = @BillingFrequency,
		[IsActive] = @IsActive,
		[IPAddress] = @IPAddress,
		[LastModUserID] = @LastModUserID,
		[LastModDate] = @LastModDate
		WHERE [Id] = @Id
		SET @statusIN = 2

		----------newly added 06.02.2024 
			IF(@LastModUserID = 0)
		BEGIN
			--SET @ErrorMsg2  =  'User ID Invalid, Please Log Again'
			--RAISERROR ( @ErrorMsg2, 16, 1 ); 
			RAISERROR('User ID Invalid, Please Log In Again',16,1)
			ROLLBACK TRANSACTION
		END

-----------------------------
	END




	ELSE
	BEGIN
	--INSERT THE RECORD
	INSERT INTO SupplierPaymentAgreements(
		[Description],
		[Creditperiod],
		[AdvanceRatio],
		[OnDeliverRatio],
		[PayMethodID],
		[BillingFrequency],
		[IsActive],
		[IPAddress],
		[CreatedUserID],
		[LastModUserID],
		[CreatedDate],
		[LastModDate]
		)
		VALUES
		(
		@Description,
		@Creditperiod,
		@AdvanceRatio,
		@OnDeliverRatio,
		@PayMethodID,
		@BillingFrequency,
		@IsActive,
		@IPAddress,
		@CreatedUserID,
		@LastModUserID,
		GETDATE(),
		GETDATE()
		)
		SELECT SCOPE_IDENTITY() AS ID
		SET @NewId = SCOPE_IDENTITY()
		SET @statusIN = 1;
		EXEC Inventry_AuditTail_WriteToLog 'SupplierPaymentAgreements', @NewId, 'INV', 'SPAI', 'I', @CreatedUserID,1, '', ''
	END

			----newly added 24.01.2024 
			IF(@CreatedUserID = 0)
		BEGIN
			--SET @ErrorMsg2  =  'User ID Invalid, Please Log Again'
			--RAISERROR ( @ErrorMsg2, 16, 1 ); 
			RAISERROR('User ID Invalid, Please Log In Again',16,1)
			ROLLBACK TRANSACTION
		END

-----------------------------

	END --ACTION 2 ENDS
ELSE IF @Action = 2
	BEGIN
		EXEC Inventry_AuditTail_WriteToLog 'SupplierPaymentAgreements', @Id, 'INV', 'SPAD', 'D', @CreatedUserID,1, '', ''
		DELETE [SupplierPaymentAgreements] WHERE [Id] = @Id
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
--SET @message = CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
	SET @Message = 'Error Occured: ' + ERROR_MESSAGE() 
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN --RollBack in case of Error
END CATCH
END--SP ENDS

GO

