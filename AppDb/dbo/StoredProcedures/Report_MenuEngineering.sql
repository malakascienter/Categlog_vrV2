--EXEC [Report_MenuEngineering] '01/04/2024','10/04/2024','DER,DIB,IRD,LOB,MRB,TUT',1
CREATE PROCEDURE [dbo].[Report_MenuEngineering](          
 @FromDate	VARCHAR(10),        
 @ToDate	VARCHAR(10),
 @Outlet    VARCHAR(MAX),
 @PropertyId VARCHAR(2)
)        
AS        
BEGIN         


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
		FROM            OutletKitchenIssues OKS
		 WHERE  OKS.TxnDate >= CONVERT(DATETIME,@FromDate,103) 
				AND OKS.TxnDate <= CONVERT(DATETIME,@ToDate,103) 
				AND OKS.OutletCode IN (SELECT * FROM STRING_SPLIT(@Outlet,','))  AND OKS.PropertyId=@PropertyId   
		GROUP BY OKS.MenuCode,OKS.PropertyID,OKS.OutletCode



		CREATE TABLE #TempMenuEngineering
		(
			ID INT IDENTITY(1,1),
			MenuName VARCHAR(200),
			Outlet   VARCHAR(50),
			SalesQty MONEY,
			SalesPrice MONEY,
			NetSales MONEY,
			CostPrice MONEY,
			CostValue MONEY,
			ProfitAtCost MONEY,
			GP MONEY
		)

		CREATE TABLE #TempSelectMenuEngineering
		(
			ID INT IDENTITY(1,1),
			GroupName VARCHAR(200),
			MenuName VARCHAR(200),
			Outlet   VARCHAR(50),
			SalesQty MONEY,
			SalesPrice MONEY,
			NetSales MONEY,
			CostPrice MONEY,
			CostValue MONEY,
			ProfitAtCost MONEY,
			GP MONEY,
			Seq INT
		)


	 INSERT INTO #TempMenuEngineering(MenuName,Outlet,SalesQty,SalesPrice,NetSales,CostPrice,CostValue,ProfitAtCost,GP)
	 SELECT Description,Outlet,SalesQty,SalesPrice,NetSales,CostPrice,CostValue,ProfitAtCost,GP FROM 
	 (
		 SELECT MM.Description,L.description AS Outlet,SUM(BT.Qty) AS SalesQty,BT.Rate AS SalesPrice,SUM(BT.Qty)*BT.Rate AS NetSales,TIC.CostPrice/ SUM(BT.Qty) AS CostPrice,TIC.CostPrice AS CostValue,(SUM(BT.Qty)*BT.Rate)-(TIC.CostPrice) AS ProfitAtCost,
		 ((SUM(BT.Qty)*BT.Rate)-(TIC.CostPrice))/(SUM(BT.Qty)*BT.Rate)*100 AS GP
		 FROM OutletKitchenIssues OK
		 INNER JOIN MainMenu MM ON OK.MenuCode = MM.ItemCode AND OK.PropertyID = MM.PropertyId
		 INNER JOIN Location_Ref L ON OK.OutletCode = L.code AND OK.PropertyID = L.PropertyId
		 INNER JOIN BillTrans BT ON OK.TxnDate = BT.OrderDate AND OK.OutletCode = BT.Outlet AND OK.PropertyID = BT.PropertyId AND OK.MenuCode = BT.MainMenuCode 
		 INNER JOIN #TempItemCost TIC ON TIC.MenuCode = OK.MenuCode AND TIC.PropertyID = OK.PropertyID AND TIC.OutletCode = OK.OutletCode
		 WHERE  OK.TxnDate >= CONVERT(DATETIME,@FromDate,103) 
				AND OK.TxnDate <= CONVERT(DATETIME,@ToDate,103) 
				AND OK.OutletCode IN (SELECT * FROM STRING_SPLIT(@Outlet,','))  AND OK.PropertyId=@PropertyId    AND BT.Qty > 0 AND BT.Rate > 0
		GROUP BY MM.Description,L.description ,BT.Rate,TIC.CostPrice
	) A
	ORDER BY SalesQty,GP,ProfitAtCost 




	DECLARE @GroupLength INT
	DECLARE @RowCount INT
	DECLARE @LoopCount INT = 1
	DECLARE @Seq INT
	DECLARE @GroupName VARCHAR(200)


	select @RowCount = count(*) from #TempMenuEngineering



	IF( @RowCount > 0 )
	BEGIN

	 SET @GroupLength = @RowCount/4

	END



WHILE exists( select * from #TempMenuEngineering )
BEGIN

	
	IF( @LoopCount = 1 )
	BEGIN

	 SET @GroupName = 'Dogs'
	 SET @Seq = 4

	END
	ELSE IF ( @LoopCount = 2 )
	BEGIN

	  SET @GroupName = 'Puzzles'
	   SET @Seq = 3

	END
	ELSE IF ( @LoopCount = 3 )
	BEGIN

	  SET @GroupName = 'Plow Horses'
	   SET @Seq = 2

	END
	ELSE IF ( @LoopCount = 4 )
	BEGIN

	  SET @GroupName = 'Stars'
	  SET @Seq = 1

	END

		insert into #TempSelectMenuEngineering(GroupName,MenuName,Outlet,SalesQty,SalesPrice,NetSales,CostPrice,CostValue,ProfitAtCost,GP,Seq)
		select top(@GroupLength) @GroupName,MenuName,Outlet,SalesQty,SalesPrice,NetSales,CostPrice,CostValue,ProfitAtCost,GP,@Seq from #TempMenuEngineering

		delete top(@GroupLength) from #TempMenuEngineering

		set @LoopCount = @LoopCount+1

END


	SELECT  *,MenuName AS Description FROM #TempSelectMenuEngineering where ProfitAtCost > 0  ORDER BY Seq ASC,SalesQty DESC,GP DESC,ProfitAtCost DESC



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


END;

GO

