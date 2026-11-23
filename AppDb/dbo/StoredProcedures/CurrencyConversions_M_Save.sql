
-- =============================================  
-- Author:  Dilshan  
-- Create date: 2024-05-06 (YYYY-MM-DD)
-- =============================================  
CREATE  PROCEDURE [dbo].[CurrencyConversions_M_Save]  
    @Id  INT,  
	@FromCurrencyID  INT,  
	@ToCurrencyID INT,  
	@Value MONEY,  
	@IsActive BIT,  
	@UserId INT,
	@PropertyId INT,
	@Operation VARCHAR(5),
	@EffectFrom DATE = NULL
AS  
BEGIN  TRY
	SET NOCOUNT ON;

    SET @EffectFrom = ISNULL(@EffectFrom, GETDATE());  

	IF @Operation ='I'  
	BEGIN 
		IF EXISTS (SELECT 1 FROm [POS_CurrencyConversions] where [CompanyId]=@PropertyId AND ( ([FromCurrencyID]=@FromCurrencyID AND [ToCurrencyID]=@ToCurrencyID) ) )         
		BEGIN  
			RAISERROR('Currency conversions already exists',16,1)  
		END  
		ELSE 
		BEGIN 	
			

			INSERT INTO [dbo].[POS_CurrencyConversions]
           ([FromCurrencyID]
           ,[ToCurrencyID]
           ,[Value]
           ,[IsActive]
           ,[CreatedUserID]
           ,[LastModUserID]
           ,[CreatedDate]
           ,[LastModDate]
           ,[CompanyId]
		   ,EffectFrom)
			VALUES
			(@FromCurrencyID
			,@ToCurrencyID
			,@Value
			,@IsActive
			,@UserId
			,@UserId
			,GETDATE()
			,GETDATE()
			,@PropertyId
			,@EffectFrom)

			SET @Id = SCOPE_IDENTITY()
			-- Audit trail ----------------------------		
			EXEC HotelResWeb_AuditTail_WriteToLog 'POS_CurrencyConversions',@Id,'POS','POSCRCI','I',@UserId,'','','','','',@PropertyId
			-- End of Audit trail ---------------------
			 
			
		END     
	END    
	ELSE IF @Operation ='U'  
	BEGIN  
		

		
			UPDATE [dbo].[POS_CurrencyConversions]
			SET 
				[Value] = @Value,
				[IsActive] = @IsActive,
				[LastModUserID] = @UserId,
				[LastModDate] = GETDATE(),
				EffectFrom = @EffectFrom
			WHERE 
				Id = @Id AND [CompanyId] = @PropertyId;

			EXEC HotelResWeb_AuditTail_WriteToLog 'POS_CurrencyConversions',@Id,'POS','POSCRCU','U',@UserId,'','','','','',@PropertyId
		
	END 
	
	--EXEC Insert_Sync_MasterDataTransferStatus 'Currency',1,@CurrCode,@PropertyId

	DECLARE @FromCurrCode VARCHAR(50), @ToCurrCode VARCHAR(50)

	SELECT @FromCurrCode = CurrCode  FROM POS_CurrencyRates WHERE Id = @FromCurrencyID
	SELECT @ToCurrCode = CurrCode  FROM POS_CurrencyRates WHERE Id = @ToCurrencyID

	INSERT INTO Sync_MasterDataTransferStatus(PropertyId,Code,Outlet,DataType,Active)
	SELECT @PropertyId,A.Code, B.code, 'Currency',@IsActive
	FROM (SELECT @ToCurrCode AS Code) A
	CROSS JOIN Location_Ref B WHERE B.Active = 1  AND BaseCurrencyCode = @FromCurrCode
		
	END TRY 
BEGIN CATCH
ROLLBACK TRANSACTION
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())

	DECLARE  @ERRmsg VARCHAR(MAX) =ERROR_MESSAGE()
	RAISERROR(@ERRmsg,16,1)
END CATCH

GO

