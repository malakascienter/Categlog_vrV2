
  -- =============================================  
-- Author:  Ovanthi NapeVithanage  
-- Create date: July 24,2018  
-- Description: Waiter_M_Save  
-- =============================================  
CREATE PROCEDURE [dbo].[Waiter_M_Save]  
@Code   VARCHAR(8),  
@Name   VARCHAR(20),  
@CardNo   VARCHAR(50), 
@Active   BIT, 
@Operation  CHAR(1),
@PropertyId INT,
@UserId	INT,
@IsViewAllOrders BIT,
@IsCashier BIT
AS  
BEGIN  
BEGIN TRY

BEGIN TRANSACTION

	DECLARE @Id INT
	--DECLARE @WaiterWiseOutletsId INT
	DECLARE @Remark VARCHAR(250)	
	IF @Operation ='I'  
		BEGIN  
			IF EXISTS (SELECT * FROM Waiter WHERE Code=@Code AND PropertyId=@PropertyId)  
			BEGIN  
				RAISERROR('CODE ALREADY EXISTS',16,1)  
			END  
			ELSE IF EXISTS (SELECT * FROM Waiter WHERE CardNO=@CardNo AND PropertyId=@PropertyId)  
			BEGIN  
				RAISERROR('CARD NUMBER ALREADY ASSIGNED FOR ANOTHER WAITER',16,1)  
			END  
			ELSE  
			BEGIN 
				SELECT @Id = Id FROM Waiter WHERE Code = @Code AND PropertyId=@PropertyId
				-- audit trail	 
				EXEC [dbo].[AuditTrail_InsertToHistory] 'Waiter',@Id
				-- end of audit trail	 

				

				INSERT INTO Waiter(Code, Name,CardNo,Active,PropertyId,IsViewAllOrders,IsCashier,IsUpload,CreatedUserId,CreatedDateTime)  
				VALUES(@Code, @Name,@CardNo,@Active,@PropertyId,@IsViewAllOrders,@IsCashier,0,@UserId,GETDATE())

				SET @Id = SCOPE_IDENTITY()
				-- Audit trail ----------------------------		
				EXEC HotelResWeb_AuditTail_WriteToLog 'Waiter',@Id,'POS','POSWWI','I',@UserId,'','','','','',@PropertyId
				-- End of Audit trail ---------------------

				EXEC [AutoCodes_M_Update] 'WAITER', @PropertyId

				-- audit trail				
				SET @Remark = 'Waiter '+@Code+', '+@Name+' created.';
				EXEC [dbo].[AuditTrail_InsertTableChanges] 'Waiter',@Id,@UserId,'I',@Remark
				-- end of audit trail	   
			END  
	END   

	ELSE IF @Operation ='U'  
	BEGIN  
		IF EXISTS (SELECT * FROM [dbo].[Waiter] WHERE [Code]=@Code AND PropertyId=@PropertyId)  
		BEGIN

		DECLARE @CurrentCardNo   VARCHAR(50)
		SELECT @CurrentCardNo = CardNo FROM [Waiter] WHERE Code=@Code AND PropertyId=@PropertyId 

		IF( @CurrentCardNo <> @CardNo )
		BEGIN

			IF EXISTS (SELECT * FROM Waiter WHERE CardNO=@CardNo AND PropertyId=@PropertyId)  
			BEGIN  
				RAISERROR('CARD NUMBER ALREADY ASSIGNED FOR ANOTHER WAITER',16,1)  
			END   

		END


		  
		SELECT @Id = Id FROM Waiter WHERE Code = @Code
		-- audit trail	 
		EXEC [dbo].[AuditTrail_InsertToHistory] 'Waiter',@Id
		-- end of audit trail	 

			-- Audit trail ----------------------------		
			EXEC HotelResWeb_AuditTail_WriteToLog 'Waiter',@Id,'POS','POSWWU','U',@UserId,'','','','','',@PropertyId
			-- End of Audit trail ---------------------

			UPDATE [dbo].[Waiter] SET  
			Name = @Name,  
			CardNo=@CardNo,			
			Active=@Active,			
			PropertyId=@PropertyId,
			IsViewAllOrders = @IsViewAllOrders,
			IsCashier=@IsCashier,
			UpatedUserId=@UserId,
			UpdatedDateTime=GETDATE(),
			IsUpload=0
			WHERE Code=@Code AND PropertyId=@PropertyId 

			-- audit trail				
			SET @Remark = 'Waiter '+@Code+', '+@Name+' updated.';
			EXEC [dbo].[AuditTrail_InsertTableChanges] 'Waiter',@Id,@UserId,'I',@Remark
			-- end of audit trail	 
			    
		END
		ELSE 
		BEGIN  
			RAISERROR('NO RECORD FOUND',16,1)  
		END  
	END 
	
	EXEC Insert_Sync_MasterDataTransferStatus 'Waiter',@Active,@Code,@PropertyId
	
COMMIT TRANSACTION

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())

	DECLARE  @ERRmsg VARCHAR(MAX) =ERROR_MESSAGE()
	RAISERROR(@ERRmsg,16,1)  
END CATCH	
END

GO

