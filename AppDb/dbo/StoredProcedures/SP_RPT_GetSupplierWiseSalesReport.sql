-- =============================================
-- Author:		Isuru Pramodya
-- Create date:2024-01-24
-- Description:	Supplier Wise Sales Report
--  [dbo].[SP_RPT_GetSupplierWiseSalesReport] '12','2025/03/01','2025/03/31',1,458
 
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_GetSupplierWiseSalesReport]
@LocationID VARCHAR(MAX),
@FromDate DATE,
@ToDate DATE,
@PropertyID INT,
@SupplierID INT
AS
BEGIN
	SET NOCOUNT ON;

    SELECT DISTINCT SUP.SupplierID,SU.Name SupplierName,LO.Name LocationName,SH.StockItemCode,
	SH.Name ItemName
	,SUM(ID.Quantity) - SUM(ISNULL(RD.Quantity,0)) Quantity
	,AVG(ID.SellingPrice) SellingPrice
	,(SUM(ID.Quantity)*AVG(ID.SellingPrice)) Value
	,ISNULL([dbo].[FN_GetLastGRNPrice] (LO.Id,SH.Id),0) LastPurchasePrice,
	--[dbo].[FN_GetCurrentAveragePrice](ID.CompanyID,ID.LocationID,ID.ItemID) AS CostPrice,
	[dbo].[GetAvaragePriceAsAtDate](@ToDate ,SH.ID, LO.ID,1) AS CostPrice,
	--,SUP.CostPrice AS CostPrice
	ISNULL(([dbo].[FN_GetLastGRNPrice] (LO.Id,SH.Id)  * SUM(ID.Quantity- ID.ReturnQuantity)),0) PurchaseValue
	,(SUP.CostPrice * SUM(ID.Quantity)) CostPriceValue
	,PY.Description PaymentType, 
	CASE WHEN SU.IsConsigments=1 THEN 'Consigments' WHEN SU.IsConsigments=0 THEN  CONVERT(varchar,SU.CreditPeriod) END AS CreditPeriod
	,[dbo].[GetBalance_Retail] (@ToDate,SH.ID,LO.ID,0,0,@PropertyID) StockBalance
	,[dbo].[GetBalance_Retail] (@ToDate,SH.ID,LO.ID,0,1,@PropertyID) StockValue
	INTO #TempSalesStocks
	FROM POS_InvoiceHeader IH
	INNER JOIN POS_InvoiceDetail ID ON IH.InvHeaderID = ID.InvHeaderID
	INNER JOIN StockItemHeaders SH ON SH.Id = ID.ItemID
	INNER JOIN Locations LO ON LO.Id = IH.LocationID
	INNER JOIN SUPPLIERWISEITEMDETAILS SUP on sup.StockItemID = ID.ItemID and sup.LocationId=LO.Id
	INNER JOIN SUPPLIERS SU ON SU.ID = SUP.SupplierID
	INNER JOIN [eFinancials_Accounting].[dbo].[Destinity_Acc_PaymentTypes] PY ON SU.DefaultPaymentType =PY.Code
	LEFT JOIN POS_SalesReturnHeader RH ON RH.InvHeaderID = IH.InvHeaderID AND IH.LocationID = RH.LocationID AND IH.CompanyID = RH.CompanyID
	LEFT JOIN POS_SalesReturnDetail RD ON RD.ReturnHeaderID = RH.ReturnHeaderID AND ID.ItemID = RD.ItemID
	WHERE IH.LocationID IN (SELECT * FROM string_split(@LocationID,N','))  AND IH.BusinessDate BETWEEN @FromDate AND @ToDate AND IH.CompanyID =@PropertyID
	AND SUP.SupplierID = CASE WHEN @SupplierID = -999 THEN SUP.SupplierID  ELSE @SupplierID END
	GROUP BY SUP.SupplierID,SU.Name,LO.Name,SH.StockItemCode,
	SH.Name ,SH.Id,PY.Description, SU.CreditPeriod,LO.ID,SU.IsConsigments,SUP.CostPrice,ID.CompanyID,ID.LocationID,ID.ItemID


	SELECT DISTINCT SRT.SupplierID,SU.Name SupplierName,LO.Name LocationName,SH.StockItemCode, SH.Name ItemName,0 Quantity,SD.SellingPrice,0 Value
	,ISNULL([dbo].[FN_GetLastGRNPrice] (LO.Id,SH.Id),0) LastPurchasePrice,
	--SRT.CostPrice AS CostPrice,
	[dbo].[FN_GetCurrentAveragePrice](SH.CompanyId,SD.LocationID,SH.Id) AS CostPrice,
	0 PurchaseValue,0 CostPriceValue,PY.Description PaymentType,
	CASE WHEN SU.IsConsigments=1 THEN 'Consigments' WHEN SU.IsConsigments=0 THEN  CONVERT(varchar,SU.CreditPeriod) END AS CreditPeriod
	,[dbo].[GetBalance_Retail] (@ToDate,SH.ID,LO.ID,0,0,1) StockBalance
	,[dbo].[GetBalance_Retail] (@ToDate,SH.ID,LO.ID,0,1,1) StockValue
	INTO #TemoStockItems
	FROM StockItemHeaders SH
	INNER JOIN StockItemDetails SD ON SH.Id = SD.StockItemHeaderID
	INNER JOIN SupplierWiseItemDetails SRT ON SRT.StockItemID = SH.Id
	INNER JOIN Suppliers SU ON SU.ID = SRT.SUPPLIERID
	INNER JOIN LOCATIONS LO ON LO.ID = SD.LocationID
	INNER JOIN [eFinancials_Accounting].[dbo].[Destinity_Acc_PaymentTypes] PY ON SU.DefaultPaymentType =PY.Code
	WHERE SD.LocationID IN (SELECT * FROM string_split(@LocationID,N','))   AND SH.CompanyID =@PropertyID
	AND SU.ID = CASE WHEN @SupplierID = -999 THEN SU.ID  ELSE @SupplierID END
	GROUP BY  SRT.SupplierID,SU.Name ,LO.Name ,SH.StockItemCode, SH.Name ,SD.SellingPrice,
	SRT.CostPrice,PY.Description ,SH.Id, SU.IsConsigments,SU.CreditPeriod,LO.ID,SD.QuantityInHand,SH.CompanyId,SD.LocationID--,SH.Id

	SELECT *
	INTO #DIFFiTEMS
	FROM #TemoStockItems
	WHERE stockitemcode NOT IN (SELECT stockitemcode
			FROM #TempSalesStocks)
	
	SELECT *
	FROM (SELECT *
			FROM #TempSalesStocks
			union all
			SELECT *
			FROM #DIFFiTEMS) A
	order by ItemName ASC

	DROP TABLE #TempSalesStocks
	DROP TABLE #TemoStockItems
	DROP TABLE #DIFFiTEMS
END

GO

