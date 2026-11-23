-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2024-12-11
-- Description:	 Report SP to get CompanyWise Item Total

-- [dbo].[SP_RPT_GetCompanyWiseItemTotal] '2025-04-25'

-- =============================================
create PROCEDURE [dbo].[SP_RPT_GetCompanyWiseItemTotal]
	@Date DATETIME
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#TempItems') IS NOT NULL
	DROP TABLE #TempItems

	CREATE TABLE #TempItems(CompanyName VARCHAR(MAX), StockItemCode VARCHAR(MAX),ItemName VARCHAR(MAX),
	 QuantityInHand decimal(18,8),CategoryName VARCHAR(MAX),SubCatName VARCHAR(MAX), ItemID INT,UnitID INT ,UnitName VARCHAR(MAX), ConvertedQuantityInHand decimal(18,8)
	 , AveragePrice decimal(18,8) , ConvertedAveragePrice decimal(18,8))

   INSERT INTO #TempItems( CompanyName, StockItemCode ,ItemName,QuantityInHand,CategoryName,SubCatName , ItemID,UnitID,UnitName,ConvertedQuantityInHand,AveragePrice,ConvertedAveragePrice )
	SELECT  CO.Name CompanyName,SH.StockItemCode,SH.Name ItemName,
	--	SUM(ISNULL(SD.QuantityInHand, 0)) AS QuantityInHand,
	sum([dbo].[GetBalance](@Date,SH.Id,SD.LocationID,0,0))  QuantityInHand,
	CA.Name CategoryName, SU.Name SubCatName,sh.Id ItemID,sd.MasterUnitID UnitID ,'' UnitName,0 ConvertedQuantityInHand 
	,([dbo].[GetAvaragePriceAsAtDate](@Date ,SH.Id, SD.LocationID ,0))   AveragePrice
	,0 ConvertedAveragePrice
	FROM StockItemHeaders SH
	INNER JOIN StockItemDetails SD ON SH.ID = SD.StockItemHeaderID
	inner JOIN Companies CO ON SH.CompanyId = CO.CompanyID
	INNER JOIN Categories CA ON SH.CategoryID = CA.Id
	INNER JOIN SubCategories SU ON SU.Id = SH.SubCategoryID
	--where StockItemCode='001'
	GROUP BY  CO.Name,SH.StockItemCode,SH.Name,CA.Name,SU.Name,sh.Id,sd.MasterUnitID,SD.LocationID 
	 
	ORDER BY SH.StockItemCode,SH.Name

	--select *
	--from #TempItems

	UPDATE TP
	SET TP.UnitID = SD.MasterUnitID
	,ConvertedQuantityInHand = [dbo].[FN_GetUnitConvertionRateWithQuantity](SD.PropertyID, TP.UnitID,SD.MasterUnitID,TP.QuantityInHand)
	,ConvertedAveragePrice = TP.AveragePrice *dbo.FN_GetUnitConvertionRate(SD.PropertyID,TP.UnitID,SD.MasterUnitID)
	FROM #TempItems TP
	INNER JOIN StockItemDetails SD ON TP.ItemID = SD.StockItemHeaderID
	WHERE SD.LocationID IN (SELECT  Id FROM Locations)-- WHERE DefaultLocation=1)


	


	 UPDATE TP
	 SET TP.UnitName = UN.Name
	 FROM #TempItems TP
	 INNER JOIN Units UN ON TP.UnitID = UN.Id


	--select *
	--from #TempItems
	
	 SELECT CompanyName,StockItemCode,	ItemName,	--SUM(QuantityInHand)QuantityInHand,	
	 CategoryName,SubCatName,ItemID,	UnitID,UnitName
	 ,ISNULL(ConvertedQuantityInHand,0) QuantityInHand,
	 ISNULL(ConvertedQuantityInHand,0) *ISNULL(ConvertedAveragePrice,0) VALUE
	 INTO #lastTemp
	 FROM #TempItems

	 select CompanyName,StockItemCode,ItemName,CategoryName,SubCatName,ItemID,	UnitID,UnitName,sum(QuantityInHand) QuantityInHand,sum(VALUE) VALUE
	,ISNULL(ISNULL(sum(VALUE),0) / NULLIF(sum(QuantityInHand),0), 0) AS AveragePrice
	 from #lastTemp
	 group by CompanyName,StockItemCode,ItemName,CategoryName,SubCatName,ItemID,	UnitID,UnitName

END

GO

