--exec [Dayend_Update_StaderCostPrice] 1,'2024-06-04'
CREATE PROCEDURE [dbo].[Dayend_Update_StaderCostPrice]
	@PropertyId INT,
	@OrderDate DATE
AS
BEGIN
	
	SET NOCOUNT ON;

	IF OBJECT_ID(N'tempdb..#TempTranItemList') IS NOT NULL
	BEGIN
	DROP TABLE #TempTranItemList
	END

	CREATE TABLE #TempTranItemList
	(
		MainMenuCode VARCHAR(12) NOT NULL,
		PropertyId INT NOT NULL,
		OrderDate DATE NOT NULL
	)

	
	CREATE TABLE #TempCostItemList
	(
		ItemCode VARCHAR(12) NOT NULL,
		Cost MONEY NOT NULL,
		PropertyId INT NOT NULL,
	)

	INSERT INTO #TempTranItemList (MainMenuCode,PropertyId,OrderDate)
	SELECT BT.MainMenuCode,BT.PropertyId,BT.OrderDate
	FROM BillTrans BT 
	INNER JOIN MainMenu MM ON MM.ItemCode = BT.MainMenuCode AND MM.PropertyId = BT.PropertyId
	WHERE	BT.PropertyId =  @PropertyId AND CONVERT(DATE, BT.OrderDate) =  CONVERT(DATE,@OrderDate) AND MM.CostPriceType = 'R'
	GROUP BY BT.MainMenuCode,BT.PropertyId,BT.OrderDate


	INSERT INTO #TempCostItemList (ItemCode,Cost,PropertyId)
	SELECT  MM.ItemCode,SUM(SD.AveragePrice*IB.Qty*RD.Qty) AS Cost,MM.PropertyId
	FROM	RecipeDetails AS RD 
			INNER JOIN RecipeHeader AS RH ON RD.RecipeCode = RH.RecipeCode AND RD.PropertyId = RH.PropertyId 
			INNER JOIN ItemBreakDown AS IB ON RH.RecipeCode = IB.RecipeCode AND IB.PropertyId = RH.PropertyId 
			INNER JOIN #TempTranItemList AS BT ON IB.MainMenuCode = BT.MainMenuCode AND BT.PropertyId = IB.PropertyId 
			INNER JOIN MainMenu MM ON MM.ItemCode = BT.MainMenuCode AND MM.PropertyId = BT.PropertyId
			INNER JOIN StockItemDetails AS SD ON RD.StockItemCode = SD.StockItemHeaderID AND SD.PropertyID = BT.PropertyId 
			INNER JOIN Locations L ON SD.LocationID = L.Id
	WHERE	BT.PropertyId =  @PropertyId AND CONVERT(DATE, BT.OrderDate) =  CONVERT(DATE,@OrderDate) AND L.GroupName = 'RC' AND MM.CostPriceType = 'R'
	GROUP BY  MM.ItemCode,MM.PropertyId
	--select * from #TempCostItemList
	UPDATE MM
	SET MM.costprice = (C.Cost)
	FROM MainMenu MM INNER JOIN #TempCostItemList C ON MM.ItemCode = C.ItemCode AND MM.PropertyId = C.PropertyId


	DECLARE @ItemCode VARCHAR(10)
	WHILE EXISTS( SELECT * FROM #TempTranItemList )
	BEGIN

	 SELECT TOP(1) @ItemCode = MainMenuCode FROM #TempTranItemList

	 EXEC Insert_Sync_MasterDataTransferStatus 'MainMenu',1,@ItemCode,@PropertyId

	 DELETE TOP(1) FROM  #TempTranItemList

	END


	IF OBJECT_ID(N'tempdb..#TempTranItemList') IS NOT NULL
	BEGIN
	DROP TABLE #TempTranItemList
	END
   
END

GO

