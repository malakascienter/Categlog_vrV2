
 ----=============================================
 ----Author:		Chiraj
 ----Create date: 2018-07-23
 ----Description:	Save Payment Types
 ----=============================================
CREATE  PROCEDURE [dbo].[PaymentTypes_M_Save] 
@Operation CHAR(1),
@PayCode CHAR(2),
@Description VARCHAR(20),
@Cash BIT ,
@CreditCard BIT,
@NoValue BIT ,
@IsECR BIT,
@IsEwallet BIT,
@IsRoomPosting BIT,
--@Other BIT=0,
@Remarks BIT,
@DrawerOpen BIT,
@Credit BIT,
--@Frimi BIT=0,
@Active BIT,
@VOUCHER BIT, 
--@IsStaffMeal BIT=0,
--@IsFoodTesting BIT,
@IsAdvance BIT,
@UserId	INT,
@PropertyId INT,
@OutletJson VARCHAR(MAX),
@IsShowOnMultiCurrency INT
AS
BEGIN
	SET NOCOUNT OFF;
	
	 
	DECLARE @Id	INT
	DECLARE @Remark VARCHAR(250)

	--SET @PayCodeval=(SELECT  case when @PayCode>0 and @PayCode<100 then RIGHT('0' + CAST(@PayCode AS VARCHAR), 2) else NULL END)

	
IF( @OutletJson != 'null' )
BEGIN

SELECT * 
	INTO #TempOutlet
	FROM OPENJSON(@OutletJson)  
	WITH 
	(		
		Outlet   VARCHAR(5) '$.Code'
		
	) 

END






	IF @Operation ='I'	
	BEGIN
		
		IF EXISTS (SELECT 1 FROM PaymentTypes WHERE PropertyId=@PropertyId AND (PayCode=@PayCode or Description=@Description))
		BEGIN				
			RAISERROR('Cannot insert duplicate Code or Description for payment types.',16,1)
		END
		ELSE IF EXISTS (SELECT 1 FROM PaymentTypes WHERE Cash=1 AND PropertyId=@PropertyId) AND @Cash=1	
		BEGIN 		
			RAISERROR('You can have only one Payment Type for Cash',16,1) 
		END	
		 --if @credit=1 then check is there are any credit value exists			
		ELSE IF @IsECR=1 AND EXISTS(SELECT IsECR FROM PaymentTypes WHERE IsECR=1 AND PropertyId=@PropertyId)
		BEGIN
			RAISERROR('You can have only one Payment Type for ECR',16,1)
		END
		ELSE IF @IsRoomPosting=1 AND EXISTS(SELECT IsRoomPosting FROM PaymentTypes WHERE IsRoomPosting=1 AND PropertyId=@PropertyId)
		BEGIN
			RAISERROR('You can have only one Payment Type for RoomPosting',16,1)
		END
		ELSE
		BEGIN 
			INSERT INTO PaymentTypes
			(PayCode, Description, Cash, CreditCard, NoValue, Other, Remarks, DrawerOpen, Credit, AccCode, CusCode, cheque, Active, Departmentcode, VOUCHER, IsStaffMeal, IsFoodTesting,FriMi,IsEWallet,IsRoomPosting,IsECR,IsAdvance,PropertyId,IsUpload,CreatedUserId,CreatedDateTime,IsShowOnMultiCurrency)
			VALUES(@PayCode,@Description,@Cash,@CreditCard,@NoValue,0,@Remarks,@DrawerOpen,@Credit,'','','0',@Active,'',@VOUCHER,0,0,0,@IsEwallet,@IsRoomPosting,@IsECR,@IsAdvance,@PropertyId,0,@UserId,GETDATE(),@IsShowOnMultiCurrency)
				
			SELECT @Id = Id FROM PaymentTypes WHERE  PropertyId=@PropertyId AND (PayCode=@PayCode or Description=@Description)	

			-- Audit trail ----------------------------		
			EXEC HotelResWeb_AuditTail_WriteToLog 'PaymentTypes',@Id,'POS','POSPTI','I',@UserId,'','','','','',@PropertyId
			-- End of Audit trail ---------------------
			
			DELETE FROM [dbo].[POS_OutletWisePaymentTypes]
			WHERE PayCode = @PayCode

			IF( @OutletJson != 'null' )
			BEGIN
			
			
					INSERT INTO [dbo].[POS_OutletWisePaymentTypes]
				   ([PropertyId]
				   ,[PayCode]
				   ,[Outlet]
				   ,[IsUpload]
				   ,[CreatedUserId]
				   ,[CreatedDateTime])
					SELECT
				    @PropertyId
				   ,@PayCode
				   ,Outlet
				   ,0
				   ,@UserId
				   ,GETDATE()
				   FROM #TempOutlet
			
			END


				
				--audit trail	 
			EXEC [dbo].[AuditTrail_InsertToHistory] 'PaymentTypes',@Id
				--end of audit trail

				--audit trail				
			SET @Remark = 'Payment types '+@PayCode+', '+@Description+' created.';
			EXEC [dbo].[AuditTrail_InsertTableChanges] 'PaymentTypes',@Id,@UserId,'I',@Remark
				--end of audit trail		

		END
		END
	ELSE IF @Operation ='U'
	BEGIN
		
		--IF EXISTS (SELECT 1 FROM PaymentTypes WHERE Cash=1 AND PayCode != @PayCode AND @Cash=1 AND PropertyId=@PropertyId) --AND @Cash=1	
		--BEGIN 		
		--	RAISERROR('You can have only one Payment Type for Cash',16,1) 
		--END	
		-- --if @credit=1 then check is there are any credit value exists			
		--ELSE IF @IsECR=1 AND EXISTS(SELECT IsECR FROM PaymentTypes WHERE IsECR=1 AND PropertyId=@PropertyId)
		--BEGIN
		--	RAISERROR('You can have only one Payment Type for ECR',16,1)
		--END
		--ELSE IF @IsRoomPosting=1 AND EXISTS(SELECT IsRoomPosting FROM PaymentTypes WHERE IsRoomPosting=1 AND PropertyId=@PropertyId)
		--BEGIN
		--	RAISERROR('You can have only one Payment Type for RoomPosting',16,1)
		--END
		--ELSE
		--BEGIN
			SELECT @Id = Id FROM PaymentTypes WHERE PropertyId=@PropertyId AND (PayCode=@PayCode or Description=@Description)
			 --audit trail	 
			EXEC [dbo].[AuditTrail_InsertToHistory] 'PaymentTypes',@Id
			 --end of audit trail

			 -- Audit trail ----------------------------		
			EXEC HotelResWeb_AuditTail_WriteToLog 'PaymentTypes',@Id,'POS','POSPTU','U',@UserId,'','','','','',@PropertyId
			-- End of Audit trail ---------------------
			

			UPDATE PaymentTypes 
			SET
			--PayCode=@PayCode,
			Description=@Description,
			Cash=@Cash,
			CreditCard=@CreditCard,
			NoValue=@NoValue,
			--Other=@Other,
			Remarks=@Remarks, 
			DrawerOpen=@DrawerOpen, 
			Credit=@Credit,
			--Frimi=@Frimi,
			Active=@Active,
			VOUCHER=@VOUCHER,
			--IsStaffMeal=@IsStaffMeal,
			UpdatedUserId=@UserId,
			UpdatedDateTime=GETDATE(),
			IsEWallet=@IsEwallet,
			IsRoomPosting=@IsRoomPosting,
			IsECR=@IsECR,
			IsAdvance=@IsAdvance,
			IsUpload=0,
			IsShowOnMultiCurrency = @IsShowOnMultiCurrency
			WHERE PayCode=@PayCode AND PropertyId=@PropertyId
			--WHERE PayCode='BR' AND PropertyId=3

			DELETE FROM [dbo].[POS_OutletWisePaymentTypes]
			WHERE PayCode = @PayCode

			
			IF( @OutletJson != 'null' )
			BEGIN
			
			
						INSERT INTO [dbo].[POS_OutletWisePaymentTypes]
					   ([PropertyId]
					   ,[PayCode]
					   ,[Outlet]
					   ,[IsUpload]
					   ,[UpdatedUserId]
					   ,[UpdatedDateTime])
						SELECT
						@PropertyId
					   ,@PayCode
					   ,Outlet
					   ,0
					   ,@UserId
					   ,GETDATE()
					   FROM #TempOutlet
			
			END


		


			 --audit trail				
			SET @Remark = 'Payment types '+@PayCode+', '+@Description+' updated.';
			EXEC [dbo].[AuditTrail_InsertTableChanges] 'PaymentTypes',@Id,@UserId,'U',@Remark
			 --end of audit trail		
		--END	
	END 	 

	EXEC Insert_Sync_MasterDataTransferStatus 'PaymentTypes',@Active,@PayCode,@PropertyId
END

GO

