-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2026-02-13
-- Description:	CUSDEC AnalysisReport

-- [dbo].[RPT_CUSDEC_StockAnalysisReport] -999,-999,-999,-999,-999,-999,'05',9212,1

-- =============================================
CREATE PROCEDURE [dbo].[RPT_CUSDEC_StockAnalysisReport]
	--@FromDate DATE,
	--@ToDate DATE,
	@StockItemID INT = -999,
	@ProvinceID INT = -999,
	@DistrictID INT = -999,
	@DivisaonalSectorID INT = -999,
	@DepartmentID INT = -999,
	@SupplierID INT = -999,
	@AnalysisScopeType CHAR(2) = '01',
	@UserID INT,
	@PropertyID INT
AS
BEGIN
	SET NOCOUNT ON;


	IF OBJECT_ID('tempdb..#UserLocation') IS NOT NULL
	DROP TABLE #UserLocation
	CREATE TABLE #UserLocation (LocationID INT )


	CREATE TABLE #TempStockAnalysis (ItemID INT,StockItemCode VARCHAR(MAX),ItemName VARCHAR(MAX),QuantityInHand DECIMAL(18,8),AveragePrice DECIMAL(18,8)
	,LocationName VARCHAR(MAX),LocationID INT,SupplierID INT,SupplierName VARCHAR(MAX),GRNQty DECIMAL(18,8)
	,TOQty DECIMAL(18,8),TIQty DECIMAL(18,8),CUSDECNO NVARCHAR(MAX),SelectedCUSDECID INT,TransferLocationName VARCHAR(MAX),TransferLocationID INT)

	INSERT INTO #UserLocation( LocationID )
	SELECT [LocationID] FROM UserWise_Location
	WHERE UserID= @UserID

	INSERT INTO #TempStockAnalysis(ItemID,StockItemCode,ItemName)
	SELECT DISTINCT SIH.Id ItemID, SIH.StockItemCode,SIH.Name ItemName
		
	FROM StockItemHeaders SIH
	INNER JOIN StockItemDetails STD WITH (NOLOCK) ON SIH.ID = STD.StockItemHeaderID
	INNER JOIN Locations LO WITH (NOLOCK) ON LO.ID = STD.LocationID
	INNER JOIN #UserLocation ULO WITH (NOLOCK) ON ULO.LocationID = LO.Id
	WHERE SIH.ID = CASE WHEN @StockItemID = -999 THEN SIH.Id ELSE @StockItemID END
	AND SIH.CompanyId = @PropertyID

	--SELECT *
	--FROM #TempStockAnalysis TM

	SELECT LO.Name GRNLocation,LO.ID GRNLocationID,SU.ID SupplierID,SU.Name SupplierName,STD.Quantity GRNQty,STD.UnitPrice GRNPrice,STH.ReferenceNo CUSDECNo
	,STH.ID CUSDECID
	,STD.StockItemID,CU.CountryName,LO.ProviceID,LO.DistrictID
	INTO #GRNList
	FROM #TempStockAnalysis TM
	INNER JOIN StockTransactionDetails STD WITH (NOLOCK) ON TM.ItemID = STD.StockItemID
	INNER JOIN StockTransactionHeaders STH WITH (NOLOCK) ON STH.ID = STD.StockTransactionHeaderID
	INNER JOIN Suppliers SU WITH (NOLOCK) ON SU.ID = STH.SupplierID
	INNER JOIN Locations LO WITH (NOLOCK) ON STH.LocationID = LO.Id
	INNER JOIN Countries CU WITH (NOLOCK) ON SU.CountryID = CU.Id
	WHERE STH.TransactionType = 'GR'


	SELECT STD.Quantity TOQty,STD.UnitPrice TOPrice,GR.CUSDECNo,LO.Name TOLocationName,LO2.Name TransferLocationName,GR.GRNLocation
	,STD.StockItemID,STD.SelectedCUSDECID,LO.ID TOLocationID, LO2.Id TransferLocationID,LO2.ProviceID,LO2.DistrictID
	INTO #TOList
	FROM #TempStockAnalysis TM
	INNER JOIN StockTransactionDetails STD WITH (NOLOCK) ON TM.ItemID = STD.StockItemID
	INNER JOIN StockTransactionHeaders STH WITH (NOLOCK) ON STH.ID = STD.StockTransactionHeaderID
	INNER JOIN Locations LO WITH (NOLOCK) ON STH.LocationID = LO.Id
	INNER JOIN Locations LO2 WITH (NOLOCK) ON LO2.ID = STH.TransferLocationID
	INNER JOIN #GRNList GR ON STD.SelectedCUSDECID = GR.CUSDECID
	WHERE STH.TransactionType = 'TO' 
		

	SELECT TM.ItemID,TM.StockItemCode,TM.ItemName,GR.GRNLocation,GR.SupplierID,GR.CountryName,GR.SupplierName,GR.CUSDECNo,GR.GRNQty,GR.GRNPrice,GR.CUSDECNo GRCUSDECNo
	,TR.TOQty,TR.TOPrice,TR.TOLocationName,TR.TransferLocationName,TR.CUSDECNo TOCUSDECNo
	,GR.GRNLocationID,TR.TOLocationID,TR.TransferLocationID,GR.ProviceID GRProviceID,GR.DistrictID GRDistrictID
	,TR.ProviceID TOProviceID,TR.DistrictID TODistrictID
	INTO #FinalSelectTable
	FROM #TempStockAnalysis TM
	INNER JOIN #GRNList GR ON GR.StockItemID = TM.ItemID
	INNER JOIN #TOList TR ON TR.StockItemID = TM.ItemID AND GR.CUSDECID = TR.SelectedCUSDECID


	IF(@AnalysisScopeType = '01') -- Item wise
	BEGIN
		SELECT ItemID,StockItemCode,ItemName,GRNLocation,SupplierID,CountryName,SupplierName,CUSDECNo,SUM(GRNQty) GRNQty,AVG(GRNPrice) GRNPrice, GRCUSDECNo
		,SUM(TOQty) TOQty,AVG(TOPrice) TOPrice,TOLocationName,TransferLocationName, TOCUSDECNo
		,GRNLocationID,TOLocationID,TransferLocationID
		FROM #FinalSelectTable
		WHERE ItemID = CASE WHEN @StockItemID = -999 THEN ItemID ELSE @StockItemID END
		GROUP BY ItemID,StockItemCode,ItemName,GRNLocation,SupplierID,CountryName,SupplierName,CUSDECNo, GRCUSDECNo
		,TOLocationName,TransferLocationName, TOCUSDECNo
		,GRNLocationID,TOLocationID,TransferLocationID
	END


	IF(@AnalysisScopeType = '02') -- Donor wise
	BEGIN
		SELECT ItemID,StockItemCode,ItemName,GRNLocation,SupplierID,CountryName,SupplierName,CUSDECNo,SUM(GRNQty) GRNQty,AVG(GRNPrice) GRNPrice, GRCUSDECNo
		,SUM(TOQty) TOQty,AVG(TOPrice) TOPrice,TOLocationName,TransferLocationName, TOCUSDECNo
		,GRNLocationID,TOLocationID,TransferLocationID
		FROM #FinalSelectTable
		WHERE ItemID = CASE WHEN @StockItemID = -999 THEN ItemID ELSE @StockItemID END
		AND SupplierID = CASE WHEN @SupplierID = -999 THEN SupplierID ELSE @SupplierID END
		GROUP BY ItemID,StockItemCode,ItemName,GRNLocation,SupplierID,CountryName,SupplierName,CUSDECNo, GRCUSDECNo
		,TOLocationName,TransferLocationName, TOCUSDECNo
		,GRNLocationID,TOLocationID,TransferLocationID

	END
		
	IF(@AnalysisScopeType = '03') -- Province Wise
	BEGIN
		SELECT ItemID,StockItemCode,ItemName,GRNLocation,SupplierID,CountryName,SupplierName,CUSDECNo,SUM(GRNQty) GRNQty,AVG(GRNPrice) GRNPrice, GRCUSDECNo
		,SUM(TOQty) TOQty,AVG(TOPrice) TOPrice,TOLocationName,TransferLocationName, TOCUSDECNo
		,GRNLocationID,TOLocationID,TransferLocationID
		FROM #FinalSelectTable
		WHERE 
		(ISNULL(GRProviceID,-999) = CASE WHEN @ProvinceID = -999 THEN ISNULL(GRProviceID,-999) ELSE @ProvinceID END OR
		ISNULL(TOProviceID,-999) = CASE WHEN @ProvinceID = -999 THEN ISNULL(TOProviceID,-999) ELSE @ProvinceID END)

		GROUP BY ItemID,StockItemCode,ItemName,GRNLocation,SupplierID,CountryName,SupplierName,CUSDECNo, GRCUSDECNo
		,TOLocationName,TransferLocationName, TOCUSDECNo
		,GRNLocationID,TOLocationID,TransferLocationID

	END

	IF(@AnalysisScopeType = '04') -- District Wise
	BEGIN
		SELECT ItemID,StockItemCode,ItemName,GRNLocation,SupplierID,CountryName,SupplierName,CUSDECNo,SUM(GRNQty) GRNQty,AVG(GRNPrice) GRNPrice, GRCUSDECNo
		,SUM(TOQty) TOQty,AVG(TOPrice) TOPrice,TOLocationName,TransferLocationName, TOCUSDECNo
		,GRNLocationID,TOLocationID,TransferLocationID
		FROM #FinalSelectTable FT
		WHERE (
		ISNULL(GRDistrictID,-999) = CASE WHEN @DistrictID = -999 THEN ISNULL(GRDistrictID,-999) ELSE @DistrictID END OR
		ISNULL(TODistrictID,-999) = CASE WHEN @DistrictID = -999 THEN ISNULL(TODistrictID,-999) ELSE @DistrictID END)
		GROUP BY ItemID,StockItemCode,ItemName,GRNLocation,SupplierID,CountryName,SupplierName,CUSDECNo, GRCUSDECNo
		,TOLocationName,TransferLocationName, TOCUSDECNo
		,GRNLocationID,TOLocationID,TransferLocationID

	END
	
	IF(@AnalysisScopeType = '05') -- Divisional Official wise
	BEGIN
		SELECT ItemID,StockItemCode,ItemName,GRNLocation,SupplierID,CountryName,SupplierName,CUSDECNo,SUM(GRNQty) GRNQty,AVG(GRNPrice) GRNPrice, GRCUSDECNo
		,SUM(TOQty) TOQty,AVG(TOPrice) TOPrice,TOLocationName,TransferLocationName, TOCUSDECNo
		,GRNLocationID,TOLocationID,TransferLocationID
		FROM #FinalSelectTable FT
		INNER JOIN Locations LO ON LO.ID = FT.TOLocationID
		WHERE ISNULL(LO.IsDistrict,0) = 0
		AND LO.ID = CASE WHEN @DivisaonalSectorID = -999 THEN LO.ID ELSE @DivisaonalSectorID END
		GROUP BY ItemID,StockItemCode,ItemName,GRNLocation,SupplierID,CountryName,SupplierName,CUSDECNo, GRCUSDECNo
		,TOLocationName,TransferLocationName, TOCUSDECNo
		,GRNLocationID,TOLocationID,TransferLocationID

	END		
	
END

GO

