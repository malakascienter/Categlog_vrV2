
-- =============================================  
-- Author:  Dilshan  
-- Create date: 2024-05-06 (YYYY-MM-DD)
-- =============================================  
CREATE  PROCEDURE [dbo].[Currency_M_Save]  
	@CurrCode  CHAR(3),  
	@CurrName VARCHAR(25), 
	@ConversionRate MONEY,  
	@AllowBalance BIT,  
	@AllowPayments BIT,  
	@AllowSignOn   BIT,  
	@SortOrder INT,
	@UserId INT,
	@PropertyId INT,
	@Operation VARCHAR(5),
	@EffectFrom DATE = NULL,
	@IsBaseCurrency BIT = 0,
	@BaseCurrencyId BIGINT = 0
AS  
BEGIN  TRY
	SET NOCOUNT ON;

    SET @EffectFrom = ISNULL(@EffectFrom, GETDATE());  


	DECLARE @Id INT	
	DECLARE @Remark NVARCHAR(250)
	DECLARE @NextCatgId INT	 
	IF @Operation ='I'  
	BEGIN 
		IF EXISTS (SELECT 1 FROm POS_CurrencyRates where PropertyId=@PropertyId AND (CurrCode=@CurrCode OR CurrName=@CurrName))         
		BEGIN  
			RAISERROR('Currency Code OR Description already exists',16,1)  
		END  
		ELSE 
		BEGIN 	
			

			INSERT INTO [dbo].[POS_CurrencyRates]
           ([CurrCode]
           ,[CurrName]
           ,[ConversionRate]
           ,[AllowBalance]
           ,[AllowPayments]
           ,[AllowSignOn]
           ,[SortOrder]
           ,[PropertyId]
           ,[CreatedUserId]
           ,[CreatedDateTime]
           ,[ModifiedUserId]
           ,[ModifiedDateTime]
		   ,IsUpload
		   ,EffectFrom
		   ,IsBaseCurrency
		   ,BaseCurrencyId
		   ,NewConversionRate)
		 VALUES
			   (@CurrCode
			   ,@CurrName
			   ,(CASE WHEN CONVERT(DATE,@EffectFrom) > CONVERT(DATE,GETDATE()) THEN 0 ELSE @ConversionRate END)
			   ,@AllowBalance
			   ,@AllowPayments
			   ,@AllowSignOn
			   ,@SortOrder
			   ,@PropertyId
			   ,@UserId
			   ,GETDATE()
			   ,@UserId
			   ,GETDATE()
			   ,0
			   ,@EffectFrom
			   ,@IsBaseCurrency
			   ,@BaseCurrencyId
			   ,(CASE WHEN CONVERT(DATE,@EffectFrom) > CONVERT(DATE,GETDATE()) THEN @ConversionRate ELSE @ConversionRate END)
			   )

			   	SET @Id = SCOPE_IDENTITY()
				-- Audit trail ----------------------------		
				EXEC HotelResWeb_AuditTail_WriteToLog 'POS_CurrencyRates',@Id,'POS','POSCRI','I',@UserId,'','','','','',@PropertyId
				-- End of Audit trail ---------------------
			 
			
		END     
	END    
	ELSE IF @Operation ='U'  
	BEGIN  
		

		
			IF NOT EXISTS( SELECT * FROM [POS_CurrencyRates]  WHERE [CurrCode] <> @CurrCode AND  CurrName=@CurrName AND PropertyId = @PropertyId  )
			BEGIN

					UPDATE [dbo].[POS_CurrencyRates]
					SET [CurrName] = @CurrName
						  ,[ConversionRate] = (CASE WHEN CONVERT(DATE,@EffectFrom) > CONVERT(DATE,GETDATE()) THEN [ConversionRate] ELSE @ConversionRate END)
						  ,[AllowBalance] = @AllowBalance
						  ,[AllowPayments] =@AllowPayments
						  ,[AllowSignOn] = @AllowSignOn
						  ,[SortOrder] = @SortOrder
						  ,[PropertyId] =@PropertyId
						  ,[ModifiedUserId] = @UserId
						  ,[ModifiedDateTime] = GETDATE()
						  ,IsUpload = 0
						  ,EffectFrom = @EffectFrom
						  ,IsBaseCurrency = @IsBaseCurrency
						  ,BaseCurrencyId = @BaseCurrencyId
					 WHERE [CurrCode] = @CurrCode AND PropertyId = @PropertyId 



					SELECT @Id = Id FROM POS_CurrencyRates  WHERE [CurrCode] = @CurrCode AND PropertyId = @PropertyId 
					-- Audit trail ----------------------------		
					EXEC HotelResWeb_AuditTail_WriteToLog 'POS_CurrencyRates',@Id,'POS','POSCRU','U',@UserId,'','','','','',@PropertyId
					-- End of Audit trail ---------------------

			END
			ELSE
			BEGIN

					RAISERROR('Description already exists',16,1)  

			END


		
	END 
	ELSE IF @Operation ='I_FO'  
	BEGIN 
		IF EXISTS (SELECT 1 FROm POS_CurrencyRates where PropertyId=@PropertyId AND (CurrCode=@CurrCode OR CurrName=@CurrName))         
		BEGIN  
					UPDATE [dbo].[POS_CurrencyRates]
					SET   [ConversionRate] = @ConversionRate						 
						  ,[ModifiedUserId] = @UserId
						  ,[ModifiedDateTime] = GETDATE()
						  ,IsUpload = 0
					 WHERE [CurrCode] = @CurrCode  AND PropertyId = @PropertyId 

					SELECT @Id = Id FROM POS_CurrencyRates  WHERE [CurrCode] = @CurrCode AND PropertyId = @PropertyId 
					-- Audit trail ----------------------------		
					EXEC HotelResWeb_AuditTail_WriteToLog 'POS_CurrencyRates',@Id,'POS','POSCRU','U',@UserId,'Update from Front office','','','','',@PropertyId
					-- End of Audit trail ---------------------
		END  
		ELSE 
		BEGIN 	
			

			INSERT INTO [dbo].[POS_CurrencyRates]
           ([CurrCode]
           ,[CurrName]
           ,[ConversionRate]
           ,[AllowBalance]
           ,[AllowPayments]
           ,[AllowSignOn]
           ,[SortOrder]
           ,[PropertyId]
           ,[CreatedUserId]
           ,[CreatedDateTime]
           ,[ModifiedUserId]
           ,[ModifiedDateTime]
		   ,IsUpload)
		 VALUES
			   (@CurrCode
			   ,@CurrName
			   ,@ConversionRate
			   ,@AllowBalance
			   ,@AllowPayments
			   ,@AllowSignOn
			   ,@SortOrder
			   ,@PropertyId
			   ,@UserId
			   ,GETDATE()
			   ,@UserId
			   ,GETDATE()
			   ,0)


			   	SET @Id = SCOPE_IDENTITY()
				-- Audit trail ----------------------------		
				EXEC HotelResWeb_AuditTail_WriteToLog 'POS_CurrencyRates',@Id,'POS','POSCRI','I',@UserId,'Insert from Front office','','','','',@PropertyId
				-- End of Audit trail ---------------------
			 
			
		END     
	END    
	ELSE IF @Operation ='U_FO'  
	BEGIN  
		

		
					UPDATE [dbo].[POS_CurrencyRates]
					SET   [ConversionRate] = @ConversionRate						 
						  ,[ModifiedUserId] = @UserId
						  ,[ModifiedDateTime] = GETDATE()
						  ,IsUpload = 0
					 WHERE [CurrCode] = @CurrCode AND PropertyId = @PropertyId 
 
					SELECT @Id = Id FROM POS_CurrencyRates  WHERE [CurrCode] = @CurrCode AND PropertyId = @PropertyId 
					-- Audit trail ----------------------------		
					EXEC HotelResWeb_AuditTail_WriteToLog 'POS_CurrencyRates',@Id,'POS','POSCRU','U',@UserId,'Update from Front office','','','','',@PropertyId
					-- End of Audit trail ---------------------

		
	END 	
	--EXEC Insert_Sync_MasterDataTransferStatus 'Category',@Active,@Code,@PropertyId
	EXEC Insert_Sync_MasterDataTransferStatus 'Currency',1,@CurrCode,@PropertyId
		
	END TRY 
BEGIN CATCH
ROLLBACK TRANSACTION
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())

	DECLARE  @ERRmsg VARCHAR(MAX) =ERROR_MESSAGE()
	RAISERROR(@ERRmsg,16,1)
END CATCH

GO

