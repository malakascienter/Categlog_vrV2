
-- =============================================
-- Author:		<Thilini Fernando>
-- Create date: <04/03/2022> 
-- =============================================
--[dbo].[SP_SavePropertyWiseItems] '<ArrayOfPropertyWiseItemsModel xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><PropertyWiseItemsModel><ItemId>0</ItemId><Name>Item6</Name><StockItemCode>006</StockItemCode><IsHave>false</IsHave><CompanyId>0</CompanyId></PropertyWiseItemsModel><PropertyWiseItemsModel><ItemId>0</ItemId><Name>Item7</Name><StockItemCode>007</StockItemCode><IsHave>false</IsHave><CompanyId>0</CompanyId></PropertyWiseItemsModel></ArrayOfPropertyWiseItemsModel>',2
--go
CREATE PROCEDURE [dbo].[SP_SavePropertyWiseItems](@XMLData XML,@CompanyId INT)
AS
BEGIN
 
	BEGIN TRY
		BEGIN TRANSACTION
		DECLARE @iDocID INT,@ItemCode VARCHAR(200),@HeaderId INT
		  
		EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLData;
		 
		SELECT * INTO #TempData 
		FROM OPENXML(@iDocID,'/ArrayOfPropertyWiseItemsModel/PropertyWiseItemsModel',2)
		WITH   
		( Name VARCHAR(1000),
		  StockItemCode VARCHAR(200)	
		)
		 
		WHILE(SELECT COUNT (*) FROM #TempData )> 0
		BEGIN
			SELECT TOP(1) @ItemCode = StockItemCode FROM #TempData
 
			INSERT INTO StockItemHeaders
			SELECT TOP(1) @CompanyId,LocationId,StockItemCode,PLUCode,ReferanceCode,Barcode,Name,NameOnInvoice,ImageUrl,CategoryID,SubCategoryID,
			SupplierID,TaxGroupID,CostingMethod,Remarks,IsExpiryDateApplicable,IPAddress,CreatedUserID,LastModUserID,GETDATE(),GETDATE(),SubCategory2ID,IsPriceEditable,MaintainPriceHistory,Isbundle,BrandedItem,GenericItemCode
			FROM StockItemHeaders WHERE StockItemCode = @ItemCode	

			SET @HeaderId = SCOPE_IDENTITY();
 
			SELECT * INTO #TempLocations FROM Locations WHERE GroupName = 'MS' AND CompanyID = @CompanyId
 
			SELECT TOP(1) d.* INTO #TempDetails FROM StockItemDetails D
			INNER JOIN StockItemHeaders H ON H.id = D.StockItemHeaderID
			WHERE h.StockItemCode = @ItemCode

			INSERT INTO StockItemDetails
			SELECT   @CompanyId,@CompanyId,TL.Id,@HeaderId,d.MasterUnitID ,d.PurchasingUnitID,d.MinimumQuantity,d.MaximumQuantity,d.ReOrderLevel,
			d.ReOrderQuantity,d.ReOrderPeriod,0,0,0,0,0,1,1,0,@HeaderId,'',d.CreatedUserID,d.LastModUserID, GETDATE(),GETDATE(),null,0
			FROM #TempDetails d 
			CROSS JOIN #TempLocations TL
 
			DROP TABLE #TempLocations
			DROP TABLE #TempDetails
 
			DELETE TOP(1) FROM #TempData
		END
   
		COMMIT TRANSACTION
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

