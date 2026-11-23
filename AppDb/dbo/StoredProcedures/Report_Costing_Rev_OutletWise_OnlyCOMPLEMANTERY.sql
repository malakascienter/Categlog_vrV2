--Report_Costing_Rev_OutletWise_OnlyCOMPLEMANTERY '02/05/2022' ,15,'60'
CREATE PROCEDURE [dbo].[Report_Costing_Rev_OutletWise_OnlyCOMPLEMANTERY] 
	@FromDate VARCHAR(20),
	@PropertyId INT,
	@CostingId INT
AS
BEGIN
	
	SET NOCOUNT ON;
	SET DATEFORMAT DMY
	DECLARE @CurrMonthFirstDate DATETIME
	DECLARE @ReportDate DATETIME
	DECLARE @CurrYearFirstDate DATETIME
	
	SET @CurrMonthFirstDate=(SELECT DATEADD(m, DATEDIFF(m, 0, CONVERT(datetime,@FromDate,103)), 0))
	SET  @ReportDate =CONVERT(DATETIME,@FromDate,103)

	IF OBJECT_ID(N'tempdb..#Temp') IS NOT NULL
	BEGIN
	DROP TABLE #Temp
	END
	IF OBJECT_ID(N'tempdb..#TempRevnuToDate') IS NOT NULL
	BEGIN
	DROP TABLE #TempRevnuToDate
	END
	IF OBJECT_ID(N'tempdb..#TempRevnuMTD') IS NOT NULL
	BEGIN
	DROP TABLE #TempRevnuMTD
	END
	IF OBJECT_ID(N'tempdb..#TempRev') IS NOT NULL
	BEGIN
	DROP TABLE #TempRev
	END
	IF OBJECT_ID(N'tempdb..#TempComOrder') IS NOT NULL
	BEGIN
	DROP TABLE #TempComOrder
	END


	DECLARE @VarOutletCode varchar(4)
	DECLARE @VarItemcategoryId INT
	
	SELECT @VarOutletCode=OutletCode,@VarItemcategoryId=ItemCategoryId FROM OutletWiseItemCategories where PropertyId=@PropertyId

	CREATE TABLE #TempRev(
	OrderDate DATETIME,
	PropertyId INT,
	OrderNo VARCHAR(20),
	Outlet VARCHAR(4),
	Qty DECIMAL(18,2),
	Rate Decimal(18,2),
	Amount DECIMAL(18,2),
	ItemCategory VARCHAR(50),	
	--PayCode varchar(4),
	CompType varchar(50)
	)

	CREATE TABLE #TempComOrder(
	OrderDate DATETIME,
	PropertyId INT,
	OrderNo VARCHAR(20),
	Outlet VARCHAR(4),	
	)


	INSERT INTO #TempComOrder (Orderdate,PropertyId,OrderNo,Outlet)
	SELECT	PayTrans.OrderDate,PayTrans.PropertyId,PayTrans.OrderNo,PayTrans.Outlet
				FROM	PayTrans 
					INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
				WHERE	((NoValue = 1 ) AND OrderDate >= CONVERT(DATETIME,@CurrMonthFirstDate,103) 
		AND  OrderDate <= CONVERT(DATETIME,@ReportDate,103) )
					AND (PayTrans.PayCode <> 'BR')  
					AND PayTrans.PropertyId = @PropertyId
					GROUP BY PayTrans.OrderDate,PayTrans.PropertyId,PayTrans.OrderNo,PayTrans.Outlet


	
	INSERT INTO #TempRev(OrderDate,PropertyId,OrderNo,Outlet,Qty,Rate,Amount,ItemCategory,CompType)
	SELECT 
	BT.OrderDate,
	BT.PropertyId
	,BT.OrderNo
	,BT.Outlet
	,BT.Qty
	,BT.Rate
	,BT.NetAmount	
	,M.ItemCategory
	--,PT.PayCode	
	,CASE WHEN BH.ComplimentaryID <> 0 THEN 'Complimentary'
		  WHEN BH.MemberID <> 0 THEN 'Executive'
		  ELSE ''
	 END AS CompType
	FROM  BillTrans AS BT	
	INNER JOIN BillHeader BH ON BT.OrderNo = BH.OrderNo AND BT.Outlet = BH.Outlet AND BT.OrderDate = BH.OrderDate
	AND BT.PropertyId = BH.PropertyId
	INNER JOIN MainMenu AS M ON M.ItemCode=BT.MainMenuCode AND M.PropertyId = BT.PropertyId
	INNER JOIN ItemCategory AS IC ON IC.Id=M.ItemCategory	AND M.PropertyId = IC.PropertyId
	--INNER JOIN PayTrans AS PT ON PT.OrderNo=BT.OrderNo AND PT.OrderDate = BT.OrderDate	 AND PT.Outlet = BT.Outlet AND PT.PropertyId = BT.PropertyId
	INNER JOIN CostingTypeWiseOutletWiseItemCategory AS X ON X.Code=BT.Outlet AND X.ItemCategoryId=M.ItemCategory  AND BT.PropertyId = X.PropertyId
	INNER JOIN #TempComOrder TPP ON BH.OrderNo = TPP.OrderNo AND BH.OrderDate = TPP.OrderDate AND BH.PropertyId = TPP.PropertyId AND BH.Outlet = TPP.Outlet
	WHere Bt.PropertyId=@PropertyId AND BT.OrderDate BETWEEN @CurrMonthFirstDate AND @ReportDate AND X.CostingId=@CostingId
	--AND (BT.OrderNo IN (
	--			SELECT	PayTrans.OrderNo
	--			FROM	PayTrans 
	--				INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
	--			WHERE	((NoValue = 1 ) AND OrderDate >= CONVERT(DATETIME,@CurrMonthFirstDate,103) 
	--	AND  OrderDate <= CONVERT(DATETIME,@ReportDate,103) )
	--				AND (PayTrans.PayCode <> 'BR')  
	--				AND PayTrans.PropertyId = @PropertyId)
					
	--			)
	
	
	
	
	CREATE TABLE #TempRevnuToDate(Outlet VARCHAR(4),Qty DECIMAL(18,2),Rate DECIMAL(18,2),Amount DECIMAL(18,2),ItemCategory VARCHAR(50),TodaySale DECIMAL(18,4),CompType varchar(50))
	CREATE TABLE #TempRevnuMTD	(Outlet VARCHAR(4),Qty DECIMAL(18,2),Rate DECIMAL(18,2),Amount DECIMAL(18,2),ItemCategory VARCHAR(50),MTDSale DECIMAL(18,4),CompType varchar(50))
	CREATE TABLE #Temp	(OutletName VARCHAR(50),Outlet VARCHAR(4),FoodCat VARCHAR(50),TDS DECIMAL(18,2),MTD DECIMAL(18,2),CompType varchar(50))
	

    INSERT INTO #TempRevnuToDate(Outlet,Qty,Rate,ItemCategory,TodaySale,CompType)
	SELECT  Outlet,Qty,Rate,ItemCategory,SUM(Amount)AS ToTal,CompType
	from #TempRev 
	where OrderDate= CONVERT(DATE,@ReportDate,103) 	
	group by Outlet,Qty,Rate,ItemCategory,CompType ORDER BY ItemCategory
	


	INSERT INTO #TempRevnuMTD(Outlet,Qty,Rate,ItemCategory,MTDSale,CompType)
	SELECT Outlet,Qty,Rate,ItemCategory,SUM(Amount)AS ToTalMTD ,CompType
	from #TempRev 
	where OrderDate between CONVERT(DATE,@CurrMonthFirstDate,103)  and CONVERT(DATE,@ReportDate,103) 
	group by Outlet,Qty,Rate,ItemCategory,CompType ORDER BY ItemCategory


	
	

	--SELECT 
	--L.description,
	--M.Outlet,
	--ISNULL(SUM(T.TodaySale),0.00)AS ToDateSale,IsNULL(SUM(M.MTDSale),0.00) MTD
	--FROM #TempRevnuMTD AS M 
	--LEFT JOIN #TempRevnuToDate AS T  ON T.ItemCategory=M.ItemCategory AND T.Outlet = M.Outlet
	--INNER JOIN Location_Ref AS L ON L.code=M.Outlet
	--GROUP BY L.description,M.Outlet
	INSERT INTO #Temp(OutletName,Outlet,FoodCat,TDS,CompType)
	SELECT 
	L.description,
	T.Outlet,
	IT.Name,
	ISNULL(SUM(T.TodaySale),0.00)AS ToDateSale,
	T.CompType
	FROM #TempRevnuToDate AS T 
	INNER JOIN Location_Ref AS L ON L.code=T.Outlet
	INNER JOIN ItemCategory IT ON IT.Id = T.ItemCategory 
	WHERE IT.PropertyId = @PropertyId 
	GROUP BY L.description,T.Outlet,IT.Name,T.CompType

	INSERT INTO #Temp(OutletName,Outlet,FoodCat,MTD,CompType)
	SELECT 
	L.description,
	T.Outlet,
	IT.Name,
	ISNULL(SUM(T.MTDSale),0.00)AS MTD,
	T.CompType
	FROM #TempRevnuMTD AS T 
	INNER JOIN Location_Ref AS L ON L.code=T.Outlet
	INNER JOIN ItemCategory IT ON IT.Id = T.ItemCategory 
	WHERE IT.PropertyId = @PropertyId 
	GROUP BY L.description,T.Outlet,IT.Name,T.CompType


	SELECT T.OutletName,T.Outlet AS OutletCode,T.FoodCat as Type,T.CompType AS CompType,IsNULL(SUM(T.MTD),0.00) MTD,IsNULL(SUM(T.TDS),0.00) TDS
	FROM #Temp T 
	GROUP BY OutletName,Outlet,FoodCat,T.CompType

	
	IF OBJECT_ID(N'tempdb..#Temp') IS NOT NULL
	BEGIN
	DROP TABLE #Temp
	END
	IF OBJECT_ID(N'tempdb..#TempRevnuToDate') IS NOT NULL
	BEGIN
	DROP TABLE #TempRevnuToDate
	END
	IF OBJECT_ID(N'tempdb..#TempRevnuMTD') IS NOT NULL
	BEGIN
	DROP TABLE #TempRevnuMTD
	END
	IF OBJECT_ID(N'tempdb..#TempRev') IS NOT NULL
	BEGIN
	DROP TABLE #TempRev
	END
	IF OBJECT_ID(N'tempdb..#TempComOrder') IS NOT NULL
	BEGIN
	DROP TABLE #TempComOrder
	END
	

END

GO

