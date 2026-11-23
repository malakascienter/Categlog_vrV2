-- =============================================
-- Author:		Nivesh
-- Create date: 2024-03-12
-- Description:	Stock Master Log View
-- =============================================
--  AuditTrailTableLogHistory_StockMaster 1199,1
--  AuditTrailTableLogHistory_StockMaster 1201,1
CREATE PROCEDURE [dbo].[AuditTrailTableLogHistory_StockMaster] 
	@StockItemID	INT,
	@PropertyID INT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
	
	IF NOT EXISTS(SELECT 1 FROM HotelResWeb_AuditTail.sys.tables WHERE name = 'StockItemHeaders_History' OR name = 'StockItemDetails_History')
	BEGIN
		RAISERROR('Log table not exists',16,1)
		RETURN
	END
	
	SELECT *
	INTO #TempGetAuditTrailID
	FROM (
	SELECT AuditTrailID
	FROM [HotelResWeb_AuditTail]..StockItemHeaders_History
	WHERE ID =@StockItemID
	UNION 
	SELECT AuditTrailID
	FROM [HotelResWeb_AuditTail]..StockItemDetails_History
	WHERE STOCKITEMHEADERID=@StockItemID
	) AS S
	ORDER BY S.AuditTrailID ASC

	SELECT dh.AuditTrailID, atm.DatabaseName, atm.TableName, 
		
		atd.FieldName,
		CASE WHEN atm.TableName = 'StockItemDetails' AND  atd.FieldName = 'MasterUnitID' THEN (SELECT TOP 1 name from units where id =atd.OldValue)
		WHEN atm.TableName = 'StockItemHeaders' AND  atd.FieldName = 'CategoryID' THEN (SELECT TOP 1 name from Categories where id =atd.OldValue)
		WHEN atm.TableName = 'StockItemHeaders' AND  atd.FieldName = 'SubCategoryID' THEN (SELECT TOP 1 name from SubCategories where id =atd.OldValue)
		WHEN atm.TableName = 'StockItemHeaders' AND  atd.FieldName = 'SubCategory2ID' THEN (SELECT TOP 1 Description from SubCategories02 where id =atd.OldValue)
		WHEN atm.TableName = 'StockItemHeaders' AND  atd.FieldName = 'TaxGroupID' THEN (SELECT TOP 1 name from TaxGroups where TaxGroupId =atd.OldValue)
		WHEN atm.TableName = 'StockItemHeaders' AND  atd.FieldName = 'IsPriceEditable' THEN CASE WHEN atd.OldValue= 0 THEN 'FALSE' ELSE 'TRUE' END
		WHEN atm.TableName = 'StockItemHeaders' AND  atd.FieldName = 'BrandedItem' THEN CASE WHEN atd.OldValue= 0 THEN 'FALSE' ELSE 'TRUE' END
		WHEN atm.TableName = 'StockItemHeaders' AND  atd.FieldName = 'IsSellingItem' THEN CASE WHEN atd.OldValue= 0 THEN 'FALSE' ELSE 'TRUE' END
		WHEN atm.TableName = 'StockItemHeaders' AND  atd.FieldName = 'IsOpenPrice' THEN CASE WHEN atd.OldValue= 0 THEN 'FALSE' ELSE 'TRUE' END
		WHEN atm.TableName = 'StockItemHeaders' AND  atd.FieldName = 'IsAllowReturnItem' THEN CASE WHEN atd.OldValue= 0 THEN 'FALSE' ELSE 'TRUE' END
		WHEN atm.TableName = 'StockItemHeaders' AND  atd.FieldName = 'IsSerialNo' THEN CASE WHEN atd.OldValue= 0 THEN 'FALSE' ELSE 'TRUE' END
		WHEN atm.TableName = 'StockItemHeaders' AND  atd.FieldName = 'IsFractionItem' THEN CASE WHEN atd.OldValue= 0 THEN 'FALSE' ELSE 'TRUE' END
		WHEN atm.TableName = 'StockItemHeaders' AND  atd.FieldName = 'IsAllowDiscount' THEN CASE WHEN atd.OldValue= 0 THEN 'FALSE' ELSE 'TRUE' END
		WHEN atm.TableName = 'StockItemHeaders' AND  atd.FieldName = 'IsMultipleBarcode' THEN CASE WHEN atd.OldValue= 0 THEN 'FALSE' ELSE 'TRUE' END
		WHEN atm.TableName = 'StockItemHeaders' AND  atd.FieldName = 'IsMultiplePrices' THEN CASE WHEN atd.OldValue= 0 THEN 'FALSE' ELSE 'TRUE' END
		WHEN atm.TableName = 'StockItemHeaders' AND  atd.FieldName = 'Isbundle' THEN CASE WHEN atd.OldValue= 0 THEN 'FALSE' ELSE 'TRUE' END
		WHEN atm.TableName = 'StockItemHeaders' AND  atd.FieldName = 'IsExpiryDateApplicable' THEN CASE WHEN atd.OldValue= 0 THEN 'FALSE' ELSE 'TRUE' END
		ELSE atd.OldValue END OldValue,

		CASE WHEN atm.TableName = 'StockItemDetails' AND  atd.FieldName = 'MasterUnitID' THEN (SELECT TOP 1 name from units where id =atd.NewValue) 
		WHEN atm.TableName = 'StockItemHeaders' AND  atd.FieldName = 'CategoryID' THEN (SELECT TOP 1 name from Categories where id =atd.NewValue) 
		WHEN atm.TableName = 'StockItemHeaders' AND  atd.FieldName = 'SubCategoryID' THEN (SELECT TOP 1 name from SubCategories where id =atd.NewValue) 
		WHEN atm.TableName = 'StockItemHeaders' AND  atd.FieldName = 'SubCategory2ID' THEN (SELECT TOP 1 Description from SubCategories02 where id =atd.NewValue) 
		WHEN atm.TableName = 'StockItemHeaders' AND  atd.FieldName = 'TaxGroupID' THEN (SELECT TOP 1 name from TaxGroups where TaxGroupId =atd.NewValue) 
		WHEN atm.TableName = 'StockItemHeaders' AND  atd.FieldName = 'IsPriceEditable' THEN CASE WHEN atd.NewValue= 0 THEN 'FALSE' ELSE 'TRUE' END 
		WHEN atm.TableName = 'StockItemHeaders' AND  atd.FieldName = 'BrandedItem' THEN CASE WHEN atd.NewValue= 0 THEN 'FALSE' ELSE 'TRUE' END
		WHEN atm.TableName = 'StockItemHeaders' AND  atd.FieldName = 'IsSellingItem' THEN CASE WHEN atd.NewValue= 0 THEN 'FALSE' ELSE 'TRUE' END
		WHEN atm.TableName = 'StockItemHeaders' AND  atd.FieldName = 'IsOpenPrice' THEN CASE WHEN atd.NewValue= 0 THEN 'FALSE' ELSE 'TRUE' END
		WHEN atm.TableName = 'StockItemHeaders' AND  atd.FieldName = 'IsAllowReturnItem' THEN CASE WHEN atd.NewValue= 0 THEN 'FALSE' ELSE 'TRUE' END
		WHEN atm.TableName = 'StockItemHeaders' AND  atd.FieldName = 'IsSerialNo' THEN CASE WHEN atd.NewValue= 0 THEN 'FALSE' ELSE 'TRUE' END
		WHEN atm.TableName = 'StockItemHeaders' AND  atd.FieldName = 'IsFractionItem' THEN CASE WHEN atd.NewValue= 0 THEN 'FALSE' ELSE 'TRUE' END
		WHEN atm.TableName = 'StockItemHeaders' AND  atd.FieldName = 'IsAllowDiscount' THEN CASE WHEN atd.NewValue= 0 THEN 'FALSE' ELSE 'TRUE' END
		WHEN atm.TableName = 'StockItemHeaders' AND  atd.FieldName = 'IsMultipleBarcode' THEN CASE WHEN atd.NewValue= 0 THEN 'FALSE' ELSE 'TRUE' END
		WHEN atm.TableName = 'StockItemHeaders' AND  atd.FieldName = 'IsMultiplePrices' THEN CASE WHEN atd.NewValue= 0 THEN 'FALSE' ELSE 'TRUE' END
		WHEN atm.TableName = 'StockItemHeaders' AND  atd.FieldName = 'Isbundle' THEN CASE WHEN atd.NewValue= 0 THEN 'FALSE' ELSE 'TRUE' END
		WHEN atm.TableName = 'StockItemHeaders' AND  atd.FieldName = 'IsExpiryDateApplicable' THEN CASE WHEN atd.NewValue= 0 THEN 'FALSE' ELSE 'TRUE' END

		ELSE atd.NewValue END NewValue

		, atm.LogDate 
		, atm.UserID, atm.PropertyID, CASE WHEN atm.Action ='I' THEN 'Created'   WHEN atm.Action ='U' THEN 'Updated'  WHEN atm.Action ='D' THEN 'Deleted' END Action,
		ROW_NUMBER() OVER (PARTITION BY dh.AuditTrailID ORDER BY CASE WHEN atd.FieldName = 'LastModDate' and atm.TableName ='StockItemHeaders' THEN 0 ELSE 1 END, dh.AuditTrailID) AS RowNum,
		COUNT(*) OVER (PARTITION BY dh.AuditTrailID) AS allRowCount,
		ROW_NUMBER() OVER (PARTITION BY atm.TableName ORDER BY atm.TableName) AS RowNum2 INTO #TempStockItem
	FROM #TempGetAuditTrailID DH
	INNER JOIN [HotelResWeb_AuditTail]..AuditTrailMaster ATM ON DH.AuditTrailID = ATM.TrailID
	LEFT  JOIN [HotelResWeb_AuditTail]..AuditTrailDetail ATD ON ATD.TrailID =ATM.TrailID
	WHERE ATM.Action <> 'D' AND atm.PropertyID =@PropertyID
	AND (Atm.Action = 'U' AND(atd.FieldName IS NOT NULL AND atd.OldValue IS NOT NULL AND atd.NewValue IS NOT NULL)) OR (Atm.Action = 'I' )
	--AND atd.OldValue <> atd.NewValue
	ORDER BY  atm.LogDate  --ASC,DH.AuditTrailID ASC,atm.TableName ASC

	--select * from #TempStockItem

	SELECT  DISTINCT 
	t2.AuditTrailID
	,t2.DatabaseName,t2.TableName,t2.LogDate, t2.UserID LastModUserID,[dbo].[GET_User](t2.UserID) LastModifiedUserName, t2.PropertyID, t2.Action		
	,(SELECT * FROM(SELECT *, CASE WHEN TableName ='StockItemDetails' THEN
	(SELECT * FROM (
    SELECT DISTINCT
        TSD.Id AS Id,
        TSD.LocationID,
        CASE WHEN TSD.LocationID IS NULL OR TSD.LocationID=0 THEN '' ELSE (SELECT TOP 1 NAME FROM Locations WHERE ID =TSD.LocationID) END AS LocationName,
        TSD.StockItemHeaderID,
        TSD.MasterUnitID,
        CASE WHEN TSD.MasterUnitID IS NULL OR TSD.MasterUnitID =0 THEN '' ELSE (SELECT TOP 1 NAME FROM UNITS WHERE ID =TSD.MasterUnitID) END AS MasterUnitName,
        TSD.PurchasingUnitID,
        CASE WHEN TSD.PurchasingUnitID IS NULL OR TSD.PurchasingUnitID =0 THEN '' ELSE (SELECT TOP 1 NAME FROM UNITS WHERE ID =TSD.PurchasingUnitID) END AS PurchasingUnitName,
        TSD.MinimumQuantity,
        TSD.MaximumQuantity,
        TSD.ReOrderLevel,
        TSD.ReOrderQuantity,
        TSD.PurchaseAccountID,
        TSD.CostOfSalesAccountID,
        TSD.AveragePrice,
        TSD.IsActive,
        TSD.ReportingUnitID,
        TSD.IPAddress,
        TSD.CreatedUserID,
        TSD.LastModUserID,
        TSD.SellingPrice,
        TSD.WholesalePrice,
        TSD.StockItemId,
        (SELECT TOP 1 TSH.Name FROM [HotelResWeb_AuditTail]..StockItemHeaders_History TSH WHERE TSD.StockItemId = TSH.id) AS StockItemName,
        (SELECT TOP 1 TSH.StockItemCode FROM [HotelResWeb_AuditTail]..StockItemHeaders_History TSH WHERE TSD.StockItemId = TSH.id) AS StockItemCode
		FROM [HotelResWeb_AuditTail]..StockItemDetails_History TSD 
		WHERE StockItemHeaderID = @StockItemID 
		) AS UnitConvertion FOR JSON PATH)   ELSE NULL END AS StockItemDetail
	FROM #TempStockItem WHERE (action ='Created' OR (RowNum <>1 AND action ='Updated')) AND ((TableName ='StockItemDetails') OR TableName ='StockItemHeaders') AND OldValue <> NewValue
	) AS UnitConvertion  WHERE UnitConvertion.AuditTrailID = t2.AuditTrailID
	FOR JSON PATH ) AS AuditTrailData ,
	--SupplierWiseItem
	CASE WHEN t2.TableName ='StockItemHeaders' THEN
	(SELECT * FROM (
	SELECT DISTINCT  (select top 1 name from Categlog_vrV2..Suppliers where id =SH.SupplierID )as SupplierName ,
	(select top 1 name from Categlog_vrV2..Locations where id =SH.LocationId )as LocationName , 
	(select top 1 name from Categlog_vrV2..Units where id =SH.PurchaseUnitID )as Unit , 
	(select top 1 name from Categlog_vrV2..TaxGroups where TaxGroupID =SH.TaxGroupID )as TaxGroup ,
	SH.CostPrice,CAST(SH.AuditLoggedTxnDateTime AS DATE) Date,  
	ATM.Action
	
	FROM HotelResWeb_AuditTail..SupplierWiseItemDetails_History SH
	INNER JOIN HotelResWeb_AuditTail..AuditTrailMaster ATM ON ATM.TrailID = SH.AuditTrailID
	WHERE SH.StockItemID = @StockItemID and CAST(SH.AuditLoggedTxnDateTime AS DATE) = CAST(t2.LogDate AS DATE) AND ATM.Action <> 'D'
    ) AS UnitConvertion FOR JSON PATH)   ELSE NULL END AS SupplierWiseItemJson
	,--StockItemDetails
	CASE WHEN t2.TableName ='StockItemHeaders' and t2.Action='Updated' THEN
	(SELECT * FROM (
	SELECT (Select top 1 name from Categlog_vrV2..Locations where id = SH.LocationID) as LocationName,ReOrderLevel, ReOrderQuantity,(select top 1 name from Categlog_vrV2..Units where id =MasterUnitID) as Unit , 
	CAST(AuditLoggedTxnDateTime AS DATE) Date,  FORMAT(AuditLoggedTxnDateTime, 'HH:mm:ss') AS TIME,
	ROW_NUMBER() OVER (PARTITION BY (Select top 1 name from Categlog_vrV2..Locations where id = SH.LocationID) ORDER BY AuditLoggedTxnDateTime DESC) AS RowNumber
	
	FROM [HotelResWeb_AuditTail]..StockItemDetails_History SH
	WHERE 
	STOCKITEMHEADERID=@StockItemID
	and CAST(SH.AuditLoggedTxnDateTime AS DATE) = CAST(t2.LogDate AS DATE)
    ) AS UnitConvertion FOR JSON PATH)
	WHEN t2.TableName ='StockItemHeaders' and t2.Action='Created' THEN
	(SELECT * FROM (
	SELECT (Select top 1 name from Categlog_vrV2..Locations where id = SH.LocationID) as LocationName,ReOrderLevel, ReOrderQuantity,(select top 1 name from Categlog_vrV2..Units where id =MasterUnitID) as Unit , 
	CAST(AuditLoggedTxnDateTime AS DATE) Date,  FORMAT(AuditLoggedTxnDateTime, 'HH:mm:ss') AS TIME,
	ROW_NUMBER() OVER (PARTITION BY (Select top 1 name from Categlog_vrV2..Locations where id = SH.LocationID) ORDER BY AuditLoggedTxnDateTime) AS RowNumber
	
	FROM [HotelResWeb_AuditTail]..StockItemDetails_History SH
	WHERE 
	STOCKITEMHEADERID=@StockItemID
	and CAST(SH.AuditLoggedTxnDateTime AS DATE) = CAST(t2.LogDate AS DATE)
    ) AS UnitConvertion FOR JSON PATH)
	
	ELSE NULL END AS StockItemDetailsJson
	,0 as IsStock,
	0 as  IsSuppWise,
	0 as  IsViewDetail
	FROM #TempStockItem t2 WHERE 
	(action ='Created' OR (RowNum <>1 AND action ='Updated')) AND ((TableName ='StockItemDetails' AND RowNum2=1) OR TableName ='StockItemHeaders') or (TableName ='StockItemDetails' AND  action ='Updated')
	ORDER BY LogDate DESC




	DROP TABLE #TempGetAuditTrailID

	DROP TABLE #TempStockItem
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT>0
			DECLARE @ErrorMessage NVARCHAR(4000);  
			DECLARE @ErrorSeverity INT;  
			DECLARE @ErrorState INT;  

			SELECT   
			@ErrorMessage = ERROR_MESSAGE(),  
			@ErrorSeverity = ERROR_SEVERITY(),  
			@ErrorState = ERROR_STATE(); 
			RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
	END CATCH;

END

GO

