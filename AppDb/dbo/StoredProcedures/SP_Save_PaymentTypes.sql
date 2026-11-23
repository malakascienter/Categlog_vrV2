-- SP_Save_PaymentTypes 0,'13','New CodeAAA',0,0,0,0,0,4168,4168,1,0,1,2,''

--select * from PaymentTypes
CREATE PROCEDURE[dbo].[SP_Save_PaymentTypes]
 --DECLARE PARAMETERS

	@Id int =-1,
	@PayCode char(2) = '-1-1',
	@Description varchar(20)= '-1-1',
	@IsECR bit = 0,
	@IsNeedPermission bit =0,
	@IsReturnCoupon bit =0,
	@Remarks bit =0,
	@DrawerOpen bit =0,
	@CreatedUserId int = -1,
	@UpdatedUserId int = -1,
	@Active bit = 0,
	@SortOrder int =0,
	@Action int=1,
	@Status[int] output,
	@IsCreditCard BIT,
	@IsCredit BIT,
	@message NVARCHAR(max) OUTPUT
AS
BEGIN
BEGIN TRY
	BEGIN TRANSACTION
IF @Action =1
	BEGIN
		IF EXISTS(SELECT* FROM PaymentTypes WHERE [PayCode] = @PayCode)

		BEGIN

		EXEC Inventry_AuditTail_WriteToLog 'PaymentTypes', @Id, 'INV', 'PAU', 'U', @UpdatedUserId,0, '', ''

		 --UPDATE THE RECORD
		 --EXEC InsertMasterFileChangeLog 'Payment Terms',@CreatedUserID,'U',@Name
		 UPDATE PaymentTypes SET
		[PayCode] = @PayCode,
		[Description] = @Description,
		[Active] = @Active,
		[SortOrder] = @SortOrder,
		[IsECR] =@IsECR,
		[Remarks] = @Remarks,
		[IsNeedPermission] = @IsNeedPermission,
		[DrawerOpen] = @DrawerOpen,
		[IsReturnCoupon] = @IsReturnCoupon,
		[CreatedUserId] = @CreatedUserId,
		[CreatedDateTime] = GETDATE(),
		[UpdatedUserId] = @UpdatedUserId,
		[UpdatedDateTime] = GETDATE(),--@UpdatedDateTime
		[IsCreditCard] = @IsCreditCard,
		[IsCredit] = @IsCredit
		WHERE [Id] = @Id

		SET @Status = 1

	END
	ELSE
	BEGIN
	--EXEC InsertMasterFileChangeLog 'Payment Terms',@CreatedUserID,'I',@Name
	--INSERT THE RECORD
	INSERT INTO PaymentTypes(
		[PayCode] ,
		[Description] ,
		[Active] ,
		[SortOrder] ,
		[Remarks] ,
		[IsNeedPermission] ,
		[DrawerOpen] ,
		[IsReturnCoupon] ,
		[CreatedUserId] ,
		[CreatedDateTime],
		[UpdatedUserId] ,
		[UpdatedDateTime] ,
		[Cash],
		[CreditCard],
		[NoValue],
		[Other],
		[Credit],
		[cheque],
		[Departmentcode],
		[VOUCHER],
		[IsStaffMeal],
		[IsFoodTesting],
		[IsECR],
		[IsCreditCard],
		[IsCredit]
		)
		VALUES
		(
		@PayCode,
		 @Description,
		 @Active,
		 @SortOrder,
		 @Remarks,
		 @IsNeedPermission,
		 @DrawerOpen,
		 @IsReturnCoupon,
		 @CreatedUserId,
		 GETDATE(),
		 @UpdatedUserId,
		 GETDATE(),
		 0,
		 0,
		 0,
		 0,
		 0,
		 0,
		 '',
		 0,
		 0,
		 0,
		 @IsECR,
		 @IsCreditCard,
		 @IsCredit
		)
		--SELECT SCOPE_IDENTITY() AS Id
		SET @Status = 2
		SET @Id = SCOPE_IDENTITY()

		EXEC Inventry_AuditTail_WriteToLog 'PaymentTypes', @Id, 'INV', 'PAI', 'I', @CreatedUserID,0, '', ''
	END

	

	END --ACTION 2 ENDS
ELSE IF @Action = 2
	BEGIN

			SELECT @Id = Id FROM PaymentTypes WHERE PayCode = @PayCode  
		------------------------------------------------------
			SELECT * INTO #temptable FROM (

			SELECT DISTINCT PayCode FROM POS_InvoicePayment WHERE PayCode = @PayCode

			) AS CheckPayType

			IF  NOT EXISTS (SELECT 1 FROM #temptable  WHERE PayCode = @PayCode)
			BEGIN
			EXEC Inventry_AuditTail_WriteToLog 'PaymentTypes', @Id, 'INV', 'PAD', 'D', '',0, '', ''
				DELETE [PaymentTypes] WHERE [Id] = @Id

				--EXEC Inventry_AuditTail_WriteToLog 'Locations', @Id, 'MEM', 'MU', 'D', @CreatedUserID,1, '', ''
			END
			ELSE
			BEGIN
				RAISERROR('Payment Type exist in transactions',16,1)
				ROLLBACK TRANSACTION
			END
			
			DROP TABLE #temptable
		------------------------------------------------------




	--DELETE THE RECORD
		--DELETE [PaymentTypes] WHERE [Id] = @Id
		SET @Status = 3

		
END --ACTIION -3 ENDS

DECLARE @PropertyID INT
SELECT CompanyID INTO #TempCompany FROM Companies where IsActive = 1  AND IsRetail = 1
WHILE EXISTS( SELECT * FROM #TempCompany )
BEGIN

SELECT TOP(1) @PropertyID = CompanyID FROM #TempCompany

		Declare @LocationJson VARCHAR(MAX)
		SET @LocationJson = (SELECT  Id AS LocationID FROM Locations WHERE IsActive = 1 AND CompanyID = @PropertyID AND IsSalesLocation = 1 FOR JSON PATH,INCLUDE_NULL_VALUES)
		EXEC RT_SYNC_DATA_INSERT @PropertyID,@Id,'0','PaymentType',1,0,@LocationJson

DELETE TOP(1) FROM #TempCompany

END

	COMMIT TRAN -- Transaction Success!
END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);

	END CATCH
END

GO

