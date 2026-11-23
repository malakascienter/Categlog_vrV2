
-- =============================================    
-- Author:  Chamathka    
-- Create date: <Create Date,,>    
-- Description: <Description,,>    
-- =============================================    
CREATE  PROCEDURE [dbo].[MainMenu_M_Save]
	 @Id     INT,    
	 @CategoryCode  VARCHAR(3), --CATEGORY    
	 @ItemCode   VARCHAR(4), --ITEMCODE    
	 @ItemName   VARCHAR(50), --ITEMNAME    
	 @ShortName   VARCHAR(25), --APPERONINV    
	 @LongName   VARCHAR(MAX) NULL, --FULLNAME    
	 @KDSName   VARCHAR(50), --KDSNAME    
	 @ItemTypeCode  VARCHAR(1), --ITEMTYPE    
	 @KDSCategory  VARCHAR(1), --MENUTYPE    
	 @ProcessTime  INT,    
	 @ButtonColor  VARCHAR(9),    
	 @PackagingCharge MONEY,    
	 @CostPrice   MONEY,    
	 @SellingPrice  MONEY,    
	 @DeliveryPrice  MONEY,    
	 @EffectFrom   DATETIME,    
	 @IsModifier   BIT,    
	 @IsInstruction  BIT,    
	 @IsComboMeal  BIT,    
	 @IsActive   BIT,    
	 @UserId    INT,     
	 @Operation   CHAR(1),
	 --newly added to sp chiraj
	 @IsMainPage BIT,
	 @ActionTemplateID INT,
	 @DefaultActionID INT ,
	 @isHighlight BIT,
	 @HighlightColour VARCHAR(9),
	 @PreviousMenuCode VARCHAR(4),
	 @TaxType VARCHAR(6),
	 @ChargeGroupId INT,
	 @Credits INT,
	 @DiscountNotApplicable BIT,
	 @PrinterCodeList VARCHAR(MAX),
	 @ItemCategory INT,
	 @SetMenu BIT,
	 @HalfItem BIT,
	 @OpenItem BIT,
	 @ExecutivePrice DECIMAL(18,2),
	 @PropertyId INT,
	 @IsFraction BIT,
	 @MiniBarCode VARCHAR(5),
	 @IsFinalProduct BIT,
	 @IsEButlerItem BIT,
	 @IsShowInKiosk BIT,
	 @KioskCatId INT,
	 @IsKioskMainPage BIT,
	 @ItemChargeHeaderID INT,
	 @FiscalCode VARCHAR(MAX),
	 @SeqNo INT,
	 @CostPriceType VARCHAR(1),
	 @IsERPItem BIT,
	 @StockItemId BIGINT,
	 @ItemWiseOutlet		VARCHAR(MAX),
	 @ItemWiseBarCodeJson		VARCHAR(MAX),
	 @IsScanDineItem BIT,
	 @InvUnitId INT,
	 @InvProductionLocationId INT,
	 @InvDeliveryScheduleId INT,
	 @ItemChannelListJson VARCHAR(MAX),
	 @BrandId INT,
	 @IsSchedule BIT,
	 @ItemSpecialOrderTypeListJson VARCHAR(MAX) = N'null',
	 @KioskItemTypeId INT = 0
AS
BEGIN  TRY
BEGIN TRANSACTION
  
	SET NOCOUNT ON; 

	DECLARE @ClassificationWiseCategoryEnable BIT
	DECLARE @IsCentralMenuCodeEnable BIT
	SELECT @ClassificationWiseCategoryEnable = ClassificationWiseCategoryEnable,@IsCentralMenuCodeEnable = IsCentralMenuCodeEnable FROM Companies WHERE CompanyID = @PropertyId
	   
	DECLARE @NewSellingPrice MONEY = 0, @NewDeliveryPrice MONEY = 0,@Remark   NVARCHAR(250) 	
	Declare @QSR bIT
	DECLARE @ItemwiseprinterJson NVARCHAR(300)
	IF(CONVERT(VARCHAR(10),@EffectFrom,101) = CONVERT(VARCHAR(10),GETDATE(),101))    
	BEGIN    
		SELECT @NewSellingPrice = 0, @NewDeliveryPrice = 0    
	END    
	ELSE    
	BEGIN    
		SELECT @NewSellingPrice = @SellingPrice, @NewDeliveryPrice = @DeliveryPrice    
		--SELECT @SellingPrice = 0, @DeliveryPrice = 0    
	END    
	    
	IF(@Operation = 'I')    
	BEGIN    	    
		IF EXISTS( SELECT ItemCode FROM MainMenu WHERE ItemCode = @ItemCode AND PropertyId=@PropertyId)  
		BEGIN
			RAISERROR ('Menu Item Code already exists.!',16,1)   
		END
		ELSE IF( @ItemCode = @PreviousMenuCode)  
		BEGIN
			RAISERROR ('Previous menu item should not be a same item.!',16,1)   
		END
		ELSE  
		BEGIN 
			-- audit trail	 
			EXEC [dbo].[AuditTrail_InsertToHistory] 'MainMenu',@Id
			-- end of audit trail	

			 SET @FiscalCode = CONVERT(VARCHAR(MAX),(CONVERT(INT,[dbo].[GetNextDocNo]('FiscalNo',@PropertyId))))
		     EXEC [UpdateNextDocNo] 'FiscalNo',@PropertyId

			INSERT INTO MainMenu(ItemCode, [Description], Category, Price, NewPrice, ApperOnInv, PackingCharge, SubMenu, Seq, PrinterCode, PhotoName, DisplayText, ItemType, PrintCategory,     
			HAPPYMEAL, DelivaryStatus, DelivaryPrice, NewDelivaryPrice, Active, costprice, LimitToPayType, discountNotApplicable, mealdealitem, Setmenu, EFFECTdATE, isAddon,     
			PreviousMenuCode, TaxType,ChargeGroupId, IsModifier, IsHeading, IsInstruction, ActionTemplateID, Credits, KitchenDisplayName, ProcessTime, IsMainPage, ButtonColour, MenuType,     
			DefaultActionID, FullName, IsUpload, CreatedUserId, CreatedDateTime, IsCombo,isHighlight,HighlightColour,ItemCategory,IsHalfItem,IsOpenItem,ExecutivePrice,PropertyId,IsFraction,MiniBarCode,IsFinalProduct,IsEButlerItem,IsUploadToUberEat,
			IsShowInKiosk,KioskCatId,IsKioskMainPage,ItemChargeHeaderID,FiscalCode,CostPriceType,IsERPItem,StockItemId,IsScanDineItem,InvUnitId,InvProductionLocationId,InvDeliveryScheduleId,BrandId,IsSchedule,KioskItemTypeId)    
			
			VALUES(@ItemCode, @ItemName, @CategoryCode, @SellingPrice, @NewSellingPrice, @ShortName, @PackagingCharge, 0, @SeqNo, '', '00', 1, @ItemTypeCode, 5,     
			0, 1, @DeliveryPrice, @NewDeliveryPrice, @IsActive, @CostPrice, 0,  @DiscountNotApplicable, 0, @SetMenu, @EffectFrom, 0, @PreviousMenuCode, 'VAT15',@ChargeGroupId, @IsModifier, 0, @IsInstruction, @ActionTemplateID, @Credits, @KDSName, @ProcessTime, @IsMainPage, @ButtonColor, @KDSCategory,     
			@DefaultActionID, ISNULL(@LongName,''), 0, @UserId, GETDATE(), @IsComboMeal,@isHighlight,@HighlightColour,@ItemCategory,@HalfItem,@OpenItem,@ExecutivePrice,@PropertyId,@IsFraction,@MiniBarCode,@IsFinalProduct,@IsEButlerItem,0,
			@IsShowInKiosk,@KioskCatId,@IsKioskMainPage,@ItemChargeHeaderID,ISNULL(@FiscalCode,''),ISNULL(@CostPriceType,'S'),@IsERPItem,@StockItemId,@IsScanDineItem,@InvUnitId,@InvProductionLocationId,@InvDeliveryScheduleId,@BrandId,@IsSchedule,@KioskItemTypeId) 
			
			SET @Id = SCOPE_IDENTITY()
			-- Audit trail ----------------------------		
			EXEC HotelResWeb_AuditTail_WriteToLog 'MainMenu',@Id,'POS','POSMMI','I',@UserId,'','','','','',@PropertyId
			-- End of Audit trail ---------------------
			
			
			select	@QSR = QSRmode 
			from	BackendSettings
			
			IF(@QSR = 1)
			BEGIN
				
				SET @ItemwiseprinterJson =  '{"PrinterCodelst":'+@PrinterCodeList+'}'
				select @ItemwiseprinterJson
				EXEC MenuItemWise_Printers_Save @ItemCode,@ItemwiseprinterJson,@UserId,@PropertyId,0
			END

		

IF( @IsCentralMenuCodeEnable = 0 )
BEGIN


			IF( @ClassificationWiseCategoryEnable = 1 )
			BEGIN

				DECLARE @Classification01Id	INT
				SELECT @Classification01Id =  Classification01Id FROM Category WHERE Code = @CategoryCode AND PropertyId = @PropertyId
				UPDATE POS_Classification01 SET NextNo=NextNo+1 where Id = @Classification01Id

			END
			ELSE
			BEGIN

				--update doc no  table---
				Update [dbo].[MainMenuItemCode_DocNos] SET NextNo=NextNo+1 where Code=@CategoryCode AND PropertyId=@PropertyId
				--end of update doc no--

			END
END
ELSE
BEGIN

				UPDATE  Companies 
				SET NextMenuNo = NextMenuNo + 1
				WHERE CompanyID=@PropertyId

END 

			 DELETE FROM POS_OutletWiseMenuItems WHERE MenuCode = @ItemCode AND PropertyId =  @PropertyId

			 --INSERT INTO POS_OutletWiseMenuItems (OutletCode, MenuCode, IsUpload,CreatedUserId,CreatedDateTime,PropertyId)
			 --SELECT L.code,@ItemCode,0,@UserId,GETDATE(),@PropertyId 
			 --FROM Location_Ref L WHERE Active = 1

		
			IF( @ItemWiseOutlet <> N'null' )
			BEGIN

				INSERT INTO POS_OutletWiseMenuItems (OutletCode, MenuCode, IsUpload,CreatedUserId,CreatedDateTime,PropertyId)
				SELECT OutletCode,MenuCode,0,@UserId,GETDATE() ,@PropertyId
				FROM OpenJson(@ItemWiseOutlet)
				WITH 
				(
						OutletCode VARCHAR(5) '$.OutletCode',
						MenuCode VARCHAR(10) '$.MenuCode'
				) 

			END

		
			IF exists( SELECT * FROM Companies WHERE CompanyID = @PropertyId AND EnableItemWiseBarCode = 1 )
			BEGIN

						IF( @ItemWiseBarCodeJson <> N'null' )
						BEGIN

							IF EXISTS
							(
								SELECT * from [POS_ItemsBarCode] 
								WHERE PropertyId = @PropertyId AND BarCode 
								IN 
								(
									SELECT BarCode
									FROM OpenJson(@ItemWiseBarCodeJson)
									WITH 
									(
											BarCode VARCHAR(50) '$.BarCode'
									)
								)
							)  
							BEGIN 
								RAISERROR ('Menu Item bar code already exists.!',16,1)   
							END

				

							INSERT INTO [POS_ItemsBarCode] (BarCode, MenuCode, IsUpload,CreatedUserId,CreatedDateTime,PropertyId)
							SELECT BarCode,MenuItemCode,0,@UserId,GETDATE() ,@PropertyId
							FROM OpenJson(@ItemWiseBarCodeJson)
							WITH 
							(
									BarCode VARCHAR(50) '$.BarCode',
									MenuItemCode VARCHAR(10) '$.MenuItemCode'
							) 

						END
 

			END



			IF exists( SELECT * FROM Companies WHERE CompanyID = @PropertyId AND IsStockItemCreateInMenuCreation = 1 )
			BEGIN


				DECLARE @HeaderId INT,@ProductItemCode VARCHAR(MAX);

				EXEC [dbo].[SP_Geneate_StockItemWithMainMenu]
					@ItemName = @ItemName,
					@ShortName = @ItemName,
					@SellingPrice = 0,
					@UserId = @UserId,
					@PropertyId = @PropertyId,
					@UnitId = @InvUnitId,-- Master & Purchasing Unit
					@ProductionLocationId = @InvProductionLocationId,
					@InvDeliveryScheduleId = @InvDeliveryScheduleId,
					@headerid = @HeaderId OUTPUT,
					@ProductItemCode = @ProductItemCode OUTPUT;

				UPDATE MainMenu
				SET StockItemId = @HeaderId
				WHERE ItemCode = @ItemCode AND PropertyId = @PropertyId

				UPDATE StockItemHeaders
				SET ProductionLocationId = @InvProductionLocationId,
					DeliveryScheduleId = @InvDeliveryScheduleId
				WHERE Id = @HeaderId
 

			END


			DELETE FROM POS_MenuItemWiseOrderTypes WHERE MenuItemId = @Id AND PropertyId = @PropertyId


			IF( @ItemChannelListJson <> N'null' )
			BEGIN


				INSERT INTO POS_MenuItemWiseOrderTypes([MenuItemId], [MenuItemCode], [OrderTypeCode],PropertyId)
				SELECT @Id, @ItemCode, Code,@PropertyId
				FROM OPENJSON(@ItemChannelListJson)
				WITH
				(
					Code VARCHAR(10) '$.Code'
				)

			END
			DELETE FROM POS_MenuItemWiseSpecialOrderTypes WHERE MenuItemId = @Id AND PropertyId = @PropertyId

			IF( @ItemSpecialOrderTypeListJson <> N'null' )
			BEGIN

				INSERT INTO POS_MenuItemWiseSpecialOrderTypes([MenuItemId], [MenuItemCode], [OrderTypeId], PropertyId)
				SELECT @Id, @ItemCode, OrderTypeId, @PropertyId
				FROM OPENJSON(@ItemSpecialOrderTypeListJson)
				WITH
				(
					OrderTypeId INT '$.OrderTypeId'
				)

			END

			-- Output values
			--SELECT @HeaderId AS HeaderId, @ProductItemCode AS ProductItemCode;

			-- audit trail				
			SET @Remark = 'MainMenu '+@ItemName+' created.';
			--EXEC [dbo].[AuditTrail_InsertTableChanges] 'MainMenu',@Id,@UserId,'I',@Remark
			-- end of audit trail	

			

		END
	END    
	ELSE    
	BEGIN 
	
		IF( @ItemCode = @PreviousMenuCode)  
		BEGIN
			RAISERROR ('Previous menu item should not be a same item.!',16,1)   
		END
			-- audit trail	 
				EXEC [dbo].[AuditTrail_InsertToHistory] 'MainMenu',@Id
			-- end of audit trail	



			IF( ISNULL(@FiscalCode,'') = '' )
			BEGIN

				SET @FiscalCode = CONVERT(VARCHAR(MAX),(CONVERT(INT,[dbo].[GetNextDocNo]('FiscalNo',@PropertyId))))
				EXEC [UpdateNextDocNo] 'FiscalNo',@PropertyId

			END


			UPDATE MainMenu    
			SET     
			ItemCode = @ItemCode
			, [Description] = @ItemName
			, Category = @CategoryCode
			, Price = @SellingPrice
			, NewPrice = @NewSellingPrice
			, ApperOnInv = @ShortName
			, PackingCharge = @PackagingCharge
			--,PrinterCode=@PrinterCode
			, ItemType = @ItemTypeCode
			, DelivaryPrice = @DeliveryPrice
			, NewDelivaryPrice = @NewDeliveryPrice
			, Active = @IsActive
			, costprice = @CostPrice
			, EFFECTdATE = @EffectFrom
			, IsModifier = @IsModifier
			, IsInstruction = @IsInstruction
			, ActionTemplateID=@ActionTemplateID
			, Credits=@Credits
			, KitchenDisplayName = @KDSName
			, ProcessTime = @ProcessTime
			, IsMainPage=@IsMainPage
			, ButtonColour = @ButtonColor
			, MenuType = @KDSCategory
			, DefaultActionID=@DefaultActionID
			, FullName = ISNULL(@LongName,'')
			, LastModifiedUserID = @UserId
			, LastModifiedDateTime = GETDATE()
			, IsCombo = @IsComboMeal
			,isHighlight=@isHighlight
			,HighlightColour=@HighlightColour  
			,PreviousMenuCode=@PreviousMenuCode
			,TaxType='VAT15'  
			,discountNotApplicable=@DiscountNotApplicable
			,ItemCategory=@ItemCategory
			,ChargeGroupId=@ChargeGroupId
			,IsHalfItem=@HalfItem 
			,IsOpenItem=@OpenItem
			,ExecutivePrice=@ExecutivePrice
			,Setmenu=@SetMenu
			,IsUpload=0
			,IsFraction=@IsFraction
			,MiniBarCode = @MiniBarCode
			,IsFinalProduct = @IsFinalProduct
			,IsEButlerItem = @IsEButlerItem
			,IsUploadToUberEat = 0
			,IsShowInKiosk = @IsShowInKiosk
			,KioskCatId = @KioskCatId
			,IsKioskMainPage = @IsKioskMainPage
			,ItemChargeHeaderID = @ItemChargeHeaderID
			,FiscalCode = ISNULL(@FiscalCode,'')
			,Seq = @SeqNo
			,CostPriceType = ISNULL(@CostPriceType,CostPriceType)
			,IsERPItem = @IsERPItem
			,StockItemId = @StockItemId
			,IsScanDineItem = @IsScanDineItem
			,InvUnitId = @InvUnitId
			,InvProductionLocationId = @InvProductionLocationId
			,InvDeliveryScheduleId = @InvDeliveryScheduleId
			,BrandId = @BrandId
			,IsSchedule = @IsSchedule
			,KioskItemTypeId = @KioskItemTypeId
			WHERE Id = @Id    AND PropertyId=@PropertyId

			IF exists( SELECT * FROM Companies WHERE CompanyID = @PropertyId AND IsStockItemCreateInMenuCreation = 1 )
			BEGIN
					UPDATE StockItemHeaders
					SET ProductionLocationId = @InvProductionLocationId,
						DeliveryScheduleId = @InvDeliveryScheduleId
					WHERE Id = @StockItemId
			END

			-- Audit trail ----------------------------		
			EXEC HotelResWeb_AuditTail_WriteToLog 'MainMenu',@Id,'POS','POSMMU','U',@UserId,'','','','','',@PropertyId
			-- End of Audit trail ---------------------

			select	@QSR = QSRmode 
			from	BackendSettings

			IF(@QSR = 1)
			BEGIN
				
				SET @ItemwiseprinterJson =  '{"PrinterCodelst":'+@PrinterCodeList+'}'
				--select @ItemwiseprinterJson
				EXEC MenuItemWise_Printers_Save @ItemCode,@ItemwiseprinterJson,@UserId,@PropertyId,0
			END

			DELETE FROM POS_OutletWiseMenuItems WHERE MenuCode = @ItemCode AND PropertyId =  @PropertyId

	
			IF( @ItemWiseOutlet <> N'null' )
			BEGIN

						INSERT INTO POS_OutletWiseMenuItems (OutletCode, MenuCode, IsUpload,CreatedUserId,CreatedDateTime,PropertyId)
						SELECT OutletCode,MenuCode,0,@UserId,GETDATE() ,@PropertyId
						FROM OpenJson(@ItemWiseOutlet)
						WITH 
						(
								OutletCode VARCHAR(5) '$.OutletCode',
								MenuCode VARCHAR(10) '$.MenuCode'
						) 

			END



			IF exists( SELECT * FROM Companies WHERE CompanyID = @PropertyId AND EnableItemWiseBarCode = 1 )
			BEGIN

				DELETE FROM [POS_ItemsBarCode] WHERE MenuCode = @ItemCode AND PropertyId =  @PropertyId
				IF( @ItemWiseBarCodeJson <> N'null' )
				BEGIN

					IF EXISTS
					(
						SELECT * from [POS_ItemsBarCode] 
						WHERE PropertyId = @PropertyId AND  MenuCode <> @ItemCode AND BarCode 
						IN 
						(
							SELECT BarCode
							FROM OpenJson(@ItemWiseBarCodeJson)
							WITH 
							(
									BarCode VARCHAR(50) '$.BarCode'
							)
						)
					)  
					BEGIN
						RAISERROR ('Menu Item bar code already exists.!',16,1)   
					END

					INSERT INTO [POS_ItemsBarCode] (BarCode, MenuCode, IsUpload,CreatedUserId,CreatedDateTime,PropertyId)
					SELECT BarCode,MenuItemCode,0,@UserId,GETDATE() ,@PropertyId
					FROM OpenJson(@ItemWiseBarCodeJson)
					WITH 
					(
							BarCode VARCHAR(50) '$.BarCode',
							MenuItemCode VARCHAR(10) '$.MenuItemCode'
					) 

				END 

			END


			DELETE FROM POS_MenuItemWiseOrderTypes WHERE MenuItemId = @Id AND PropertyId = @PropertyId

			IF( @ItemChannelListJson <> N'null' )
			BEGIN

				INSERT INTO POS_MenuItemWiseOrderTypes([MenuItemId], [MenuItemCode], [OrderTypeCode],PropertyId)
				SELECT @Id, @ItemCode, Code,@PropertyId
				FROM OPENJSON(@ItemChannelListJson)
				WITH
				(
					Code VARCHAR(10) '$.Code'
				)

			END
			-- audit trail				
			DELETE FROM POS_MenuItemWiseSpecialOrderTypes WHERE MenuItemId = @Id AND PropertyId = @PropertyId

				IF( @ItemSpecialOrderTypeListJson <> N'null' )
				BEGIN

					INSERT INTO POS_MenuItemWiseSpecialOrderTypes([MenuItemId], [MenuItemCode], [OrderTypeId], PropertyId)
					SELECT @Id, @ItemCode, OrderTypeId, @PropertyId
					FROM OPENJSON(@ItemSpecialOrderTypeListJson)
					WITH
					(
						OrderTypeId INT '$.OrderTypeId'
					)

				END

				SET @Remark = 'MainMenu '+@ItemName+' updated.';
			EXEC [dbo].[AuditTrail_InsertTableChanges] 'MainMenu',@Id,@UserId,'U',@Remark
			-- end of audit trail	
	END  
	
	--EXEC Insert_Sync_MasterDataTransferStatus 'MainMenu',@IsActive,@ItemCode,@PropertyId

	DELETE FROM Sync_MasterDataTransferStatus WHERE DataType = 'MainMenu' AND PropertyId = @PropertyId AND Code = @ItemCode

	INSERT INTO Sync_MasterDataTransferStatus
	SELECT @PropertyId,mm.ItemCode, A.OutletCode, 'MainMenu',MM.Active
	FROM POS_OutletWiseMenuItems A 
	inner join MainMenu mm on a.MenuCode = mm.ItemCode 	AND A.PropertyId = MM.PropertyId
	INNER JOIN Location_Ref B ON B.code = A.OutletCode  AND B.PropertyId = A.PropertyId
	WHERE B.Active = 1 AND MM.PropertyId = @PropertyId AND A.PropertyId = @PropertyId AND B.PropertyId = @PropertyId AND MM.ItemCode = @ItemCode AND A.MenuCode = @ItemCode


	INSERT INTO Sync_MasterDataTransferStatus(PropertyId,Code,Outlet,DataType,Active)
	SELECT @PropertyId,@ItemCode AS Code, L.Code, 'MainMenu',0
	FROM Location_Ref L
	WHERE L.PropertyId = @PropertyId AND L.code NOT IN (SELECT A.OutletCode FROM POS_OutletWiseMenuItems A WHERE A.PropertyId = @PropertyId AND A.MenuCode = @ItemCode) 


COMMIT TRANSACTION
END TRY
BEGIN CATCH

    DECLARE @ERRmsg VARCHAR(MAX) = ERROR_MESSAGE();

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    INSERT INTO GEN_ErrTable
    (
        ErrorNumber,
        ErrorSeverity,
        ErrorState,
        ErrorProcedure,
        ErrorLine,
        ErrorMessage
    )
    VALUES
    (
        ERROR_NUMBER(),
        ERROR_SEVERITY(),
        ERROR_STATE(),
        ERROR_PROCEDURE(),
        ERROR_LINE(),
        ERROR_MESSAGE()
    );

    RAISERROR(@ERRmsg, 16, 1);

END CATCH

GO

