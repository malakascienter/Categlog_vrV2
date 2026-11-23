
 
CREATE  PROCEDURE [dbo].[ButtonCategory_M_Save]     
	 @Id     INT,    
	 @ItemCode   VARCHAR(4),     
	 @ItemName   VARCHAR(50),     
	 @ButtonColor  VARCHAR(9),     
	 @IsActive   BIT,    
	 @UserId    INT,     
	 @Operation   CHAR(1),
	 @IsMainPage BIT,
	 @PreviousMenuCode VARCHAR(4),
	 @PropertyId INT,
	 @SeqNo INT



AS    
BEGIN  TRY
BEGIN TRANSACTION
  
	SET NOCOUNT ON; 

	DECLARE @Remark   NVARCHAR(250) ,@CategoryCode  NVARCHAR(10) 
	SET @CategoryCode = '00'
	   
	
	IF(@Operation = 'I')    
	BEGIN    	    
		IF EXISTS( SELECT ItemCode FROM MainMenu WHERE ItemCode = @ItemCode AND PropertyId=@PropertyId)  
		BEGIN
			RAISERROR ('Menu Item Code already exists.!',16,1)   
		END
		ELSE  
		BEGIN 
			-- audit trail	 
			EXEC [dbo].[AuditTrail_InsertToHistory] 'MainMenu',@Id
			-- end of audit trail	

			INSERT INTO MainMenu(ItemCode, [Description], Category, Price, NewPrice, ApperOnInv, PackingCharge, Seq, PrinterCode, PhotoName, DisplayText, ItemType, PrintCategory,     
			HAPPYMEAL, DelivaryStatus, DelivaryPrice, NewDelivaryPrice, Active, costprice, LimitToPayType, discountNotApplicable, mealdealitem, Setmenu, EFFECTdATE, isAddon,     
			PreviousMenuCode, TaxType,ChargeGroupId, IsModifier, IsHeading, IsInstruction, ActionTemplateID, Credits, KitchenDisplayName, ProcessTime, IsMainPage, ButtonColour, MenuType,     
			DefaultActionID, FullName, IsUpload, CreatedUserId, CreatedDateTime, IsCombo,isHighlight,HighlightColour,ItemCategory,IsHalfItem,IsOpenItem,ExecutivePrice,PropertyId,IsFraction,MiniBarCode)    
			
			VALUES(@ItemCode, @ItemName, @CategoryCode, 0, 0, @ItemName, 0, @SeqNo, '', '00', 1, 0, 5,     
			0, 1, 0, 0, @IsActive, 0, 0,  1, 0, 0, GETDATE(), 0, @PreviousMenuCode, '',0, 0, 0, 0, 0, 0, @ItemName, 0, @IsMainPage, @ButtonColor, '',     
			0, @ItemName, 0, @UserId, GETDATE(), 0,0,'',0,0,0,0,@PropertyId,0,'')    
			
			
			
			SET @Remark = 'MainMenu '+@ItemName+' created.';
			--update doc no  table---
			Update [dbo].[ButtonCategoryCode_DocNos] SET NextNo=NextNo+1 where PropertyId=@PropertyId
			--end of update doc no--
			
		END
	END    
	ELSE    
	BEGIN    
			-- audit trail	 
				EXEC [dbo].[AuditTrail_InsertToHistory] 'MainMenu',@Id
			-- end of audit trail	

			UPDATE MainMenu    
			SET     
			ItemCode = @ItemCode
			, [Description] = @ItemName
			, Category = @CategoryCode
			, Active = @IsActive
			, IsMainPage=@IsMainPage
			, ButtonColour = @ButtonColor
			, LastModifiedUserID = @UserId
			, LastModifiedDateTime = GETDATE()
			,PreviousMenuCode=@PreviousMenuCode
			,TaxType='VAT15'  
			,IsUpload=0
			,Seq = @SeqNo
			WHERE Id = @Id    AND PropertyId=@PropertyId


			-- audit trail				
			SET @Remark = 'MainMenu '+@ItemName+' updated.';
			EXEC [dbo].[AuditTrail_InsertTableChanges] 'MainMenu',@Id,@UserId,'U',@Remark
			-- end of audit trail	
	END    
COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())

	DECLARE  @ERRmsg VARCHAR(MAX) =ERROR_MESSAGE()
	RAISERROR(@ERRmsg,16,1)
END CATCH

GO

