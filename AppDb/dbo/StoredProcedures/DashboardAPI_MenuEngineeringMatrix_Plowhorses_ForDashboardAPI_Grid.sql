
-- DashboardAPI_MenuEngineeringMatrix_Plowhorses_ForDashboardAPI_Grid @PropertiesJson = N'[{"Id":1}]'
CREATE PROCEDURE [dbo].[DashboardAPI_MenuEngineeringMatrix_Plowhorses_ForDashboardAPI_Grid]
	@PropertiesJson	NVARCHAR(MAX)=NULL,
	@FromDate		DATETIME='',
	@ToDate			DATETIME='',
	@Year			INT=0,
	@Month			INT=0,
	@Date			DATETIME='',
	@Type			CHAR=''
AS
BEGIN

	CREATE TABLE #tempProperties
	(
		Id		INT
	)

	INSERT INTO #tempProperties
		(Id)
		SELECT Id
		FROM
		OPENJSON(@PropertiesJson)
		WITH
		(
			Id INT '$.Id'
		)

	
	DECLARE @HotelDate	DATE
	SELECT @HotelDate = CurrentDate 
	FROM Companies WITH (NOLOCK) 
	WHERE CompanyID IN (SELECT Id FROM #tempProperties)

	DECLARE @From DATE
	SET @From =DATEADD(YEAR, DATEDIFF(YEAR, 0, @HotelDate), 0)

	DECLARE @To	DATE
	SET @To = DATEADD(MILLISECOND, -3, DATEADD(YEAR, DATEDIFF(YEAR, 0, @HotelDate) + 1, 0))


	IF OBJECT_ID(N'tempdb..#TempItemCost') IS NOT NULL
	BEGIN
	DROP TABLE #TempItemCost
	END
	IF OBJECT_ID(N'tempdb..#TempMenuEngineering') IS NOT NULL
	BEGIN
	DROP TABLE #TempMenuEngineering
	END
	IF OBJECT_ID(N'tempdb..#TempSelectMenuEngineering') IS NOT NULL
	BEGIN
	DROP TABLE #TempSelectMenuEngineering
	END



		SELECT        SUM(Quantity * AveragePrice) AS CostPrice,MenuCode,OKS.PropertyID,OKS.OutletCode
		INTO #TempItemCost
		FROM            Categlog_vrV2..OutletKitchenIssues OKS
		 WHERE  OKS.TxnDate >= CONVERT(DATETIME,@From,103) 
				AND OKS.TxnDate <= CONVERT(DATETIME,@To,103) 
				AND OKS.PropertyId IN (SELECT Id FROM #tempProperties)
		GROUP BY OKS.MenuCode,OKS.PropertyID,OKS.OutletCode



		CREATE TABLE #TempMenuEngineering
								(
									ID INT IDENTITY(1,1),
									ItemCode VARCHAR(10),
									MenuName VARCHAR(200),
									Outlet   VARCHAR(50),
									SalesQty MONEY,
									SalesPrice MONEY,
									NetSales MONEY,
									CostPrice MONEY,
									CostValue MONEY,
									ProfitAtCost MONEY,
									GP MONEY,
									Category VARCHAR(5),
									PropertyId INT,
									ProfitabilityThreshold MONEY,
									PopularityThreshold MONEY
								)

								CREATE TABLE #TempSelectMenuEngineering
								(
									ID INT IDENTITY(1,1),
									GroupName VARCHAR(200),
									ItemCode VARCHAR(10),
									MenuName VARCHAR(200),
									Outlet   VARCHAR(50),
									SalesQty MONEY,
									SalesPrice MONEY,
									NetSales MONEY,
									CostPrice MONEY,
									CostValue MONEY,
									ProfitAtCost MONEY,
									GP MONEY,
									Seq INT,
									Category VARCHAR(5),
									PropertyId INT,
									ProfitabilityThreshold MONEY,
									PopularityThreshold MONEY
								)


							 INSERT INTO #TempMenuEngineering(ItemCode,MenuName,Outlet,SalesQty,SalesPrice,NetSales,CostPrice,CostValue,ProfitAtCost,GP,PropertyId,Category,ProfitabilityThreshold,PopularityThreshold)
							 SELECT ItemCode,Description,Outlet,SalesQty,SalesPrice,NetSales,CostPrice,CostValue,ProfitAtCost,GP,PropertyId,Category,ProfitabilityThreshold,PopularityThreshold FROM 
							 (
								 SELECT MM.ItemCode, MM.Description,L.description AS Outlet,SUM(BT.Qty) AS SalesQty,BT.Rate AS SalesPrice,SUM(BT.Qty)*BT.Rate AS NetSales,TIC.CostPrice/ SUM(BT.Qty) AS CostPrice,TIC.CostPrice AS CostValue,(SUM(BT.Qty)*BT.Rate)-(TIC.CostPrice) AS ProfitAtCost,
								 ((SUM(BT.Qty)*BT.Rate)-(TIC.CostPrice))/(SUM(BT.Qty)*BT.Rate)*100 AS GP,OK.PropertyId,CC.Code AS Category,CC.ProfitabilityThreshold,CC.PopularityThreshold
								 FROM Categlog_vrV2..OutletKitchenIssues OK
								 INNER JOIN Categlog_vrV2..MainMenu MM ON OK.MenuCode = MM.ItemCode AND OK.PropertyID = MM.PropertyId
								 INNER JOIN Categlog_vrV2..Category CC ON MM.Category = CC.Code AND MM.PropertyID = CC.PropertyId
								 INNER JOIN Categlog_vrV2..Location_Ref L ON OK.OutletCode = L.code AND OK.PropertyID = L.PropertyId
								 INNER JOIN Categlog_vrV2..BillTrans BT ON OK.TxnDate = BT.OrderDate AND OK.OutletCode = BT.Outlet AND OK.PropertyID = BT.PropertyId AND OK.MenuCode = BT.MainMenuCode 
								 INNER JOIN #TempItemCost TIC ON TIC.MenuCode = OK.MenuCode AND TIC.PropertyID = OK.PropertyID AND TIC.OutletCode = OK.OutletCode
								 WHERE  OK.TxnDate >= CONVERT(DATETIME,@From,103) 
										AND OK.TxnDate <= CONVERT(DATETIME,@To,103) 
										AND OK.PropertyId IN (SELECT Id FROM #tempProperties) and BT.Qty > 0 and bt.Rate > 0
								GROUP BY MM.ItemCode,MM.Description,L.description ,BT.Rate,TIC.CostPrice,OK.PropertyId,CC.Code,CC.ProfitabilityThreshold,CC.PopularityThreshold
							) A
							ORDER BY SalesQty,GP,ProfitAtCost 




							DECLARE @GroupLength INT
							DECLARE @RowCount INT
							DECLARE @LoopCount INT = 1
							DECLARE @Seq INT
							DECLARE @GroupName VARCHAR(200)

							 SET @GroupName = 'Plow Horses'
							 SET @Seq = 1
							
							insert into #TempSelectMenuEngineering(GroupName,ItemCode,MenuName,Outlet,SalesQty,SalesPrice,NetSales,CostPrice,CostValue,ProfitAtCost,GP,Seq)
							select  @GroupName,ItemCode,MenuName,'',AVG(SalesQty),AVG(SalesPrice),AVG(NetSales),AVG(CostPrice),AVG(CostValue),AVG(ProfitAtCost),AVG(GP),@Seq from #TempMenuEngineering WHERE PopularityThreshold  < SalesQty AND GP < ProfitabilityThreshold AND SalesQty > 0 AND GP > 0
							GROUP BY ItemCode,MenuName


	--SELECT
	--(
	--	SELECT  GroupName,MenuName,Outlet,SalesQty,SalesPrice,NetSales,CostPrice,CostValue,ProfitAtCost,GP,Seq FROM #TempSelectMenuEngineering ORDER BY Seq ASC,SalesQty DESC,GP DESC,ProfitAtCost DESC
	--	FOR JSON AUTO
	--) AS ResultJson

	CREATE TABLE #tempChartResult
	(
		Id				INT IDENTITY(1,1),
		Series			NVARCHAR(50),
		[Label]			NVARCHAR(MAX),	
		[Value]			NVARCHAR(MAX),
		[Order]			INT DEFAULT(0),
		Color			NVARCHAR(MAX),
		[Type]			NVARCHAR(MAX) DEFAULT('bar'),
		Colspan			INT,
		TextAlign		NVARCHAR(10),
		RowId			INT
	)

	INSERT INTO #tempChartResult
	(Series,[Value], [Type],Color,Colspan,RowId,Label,TextAlign)
	SELECT 'Item',CAST(A.MenuName AS NVARCHAR(MAX)),'bar','#38C786',1,1,'','left'
	FROM #TempSelectMenuEngineering A 
	ORDER BY Seq ASC,SalesQty DESC,GP DESC,ProfitAtCost DESC

	INSERT INTO #tempChartResult
	(Series,[Value], [Type],Color,Colspan,RowId,Label,TextAlign)
	SELECT 'Value',CAST(A.NetSales AS NVARCHAR(MAX)),'bar','#38C786',1,1,A.MenuName,'right'
	FROM #TempSelectMenuEngineering A
	ORDER BY Seq ASC,SalesQty DESC,GP DESC,ProfitAtCost DESC

	INSERT INTO #tempChartResult
	(Series,[Value], [Type],Color,Colspan,RowId,Label,TextAlign)
	SELECT 'Qty',CAST(A.SalesQty AS NVARCHAR(MAX)),'bar','#38C786',1,1,A.MenuName,'right'
	FROM #TempSelectMenuEngineering A
	ORDER BY Seq ASC,SalesQty DESC,GP DESC,ProfitAtCost DESC

	INSERT INTO #tempChartResult
	(Series,[Value], [Type],Color,Colspan,RowId,Label,TextAlign)
	SELECT 'Cost',CAST(A.CostPrice AS NVARCHAR(MAX)),'bar','#38C786',1,1,A.MenuName,'right'
	FROM #TempSelectMenuEngineering A
	ORDER BY Seq ASC,SalesQty DESC,GP DESC,ProfitAtCost DESC

	INSERT INTO #tempChartResult
	(Series,[Value], [Type],Color,Colspan,RowId,Label,TextAlign)
	SELECT 'GP',CAST(A.GP AS NVARCHAR(MAX)),'bar','#38C786',1,1,A.MenuName,'right'
	FROM #TempSelectMenuEngineering A
	ORDER BY Seq ASC,SalesQty DESC,GP DESC,ProfitAtCost DESC

	DECLARE @ChartTitle			NVARCHAR(MAX) = ''
	DECLARE @ChartDisplayOrder	INT
	DECLARE @ChartPositionId	INT
	DECLARE @ChartSize			INT
	DECLARE @ChartType			NVARCHAR(MAX) = 'bar'

	SELECT * ,
	1 as 'ChartDisplayOrder',
	1 as 'ChartPositionId',
	12 as 'ChartSize',
	'bar' as 'ChartType',
	350 as 'ChartHeight',
	'true' as  'IsZoomEnable'
	FROM #tempChartResult



	IF OBJECT_ID(N'tempdb..#TempItemCost') IS NOT NULL
	BEGIN
	DROP TABLE #TempItemCost
	END
	IF OBJECT_ID(N'tempdb..#TempMenuEngineering') IS NOT NULL
	BEGIN
	DROP TABLE #TempMenuEngineering
	END
	IF OBJECT_ID(N'tempdb..#TempSelectMenuEngineering') IS NOT NULL
	BEGIN
	DROP TABLE #TempSelectMenuEngineering
	END
	IF OBJECT_ID(N'tempdb..#tempChartResult') IS NOT NULL
	BEGIN
	DROP TABLE #tempChartResult
	END

	
	
END

GO

