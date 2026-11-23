--Report_Costing_Rev_OutletWise '02/05/2022' ,15,'60'
CREATE PROCEDURE [dbo].[Report_Costing_Rev_OutletWise] 
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
	IF OBJECT_ID(N'tempdb..#TempRevnuMTD') IS NOT NULL
	BEGIN
	DROP TABLE #TempRevnuMTD
	END
	IF OBJECT_ID(N'tempdb..#TempRevnuToDate') IS NOT NULL
	BEGIN
	DROP TABLE #TempRevnuToDate
	END
	IF OBJECT_ID(N'tempdb..#TempRev') IS NOT NULL
	BEGIN
	DROP TABLE #TempRev
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
	--PayCode varchar(4)
	)
	
	INSERT INTO #TempRev(OrderDate,PropertyId,OrderNo,Outlet,Qty,Rate,Amount,ItemCategory)
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
	FROM  BillTrans AS BT	
	INNER JOIN MainMenu AS M ON M.ItemCode=BT.MainMenuCode AND BT.PropertyId = M.PropertyId
	INNER JOIN ItemCategory AS IC ON IC.Id=M.ItemCategory	 AND IC.PropertyId = M.PropertyId
	--INNER JOIN PayTrans AS PT ON PT.OrderNo=BT.OrderNo AND PT.OrderDate = BT.OrderDate	 AND PT.Outlet = BT.Outlet AND PT.PropertyId = BT.PropertyId
	INNER JOIN CostingTypeWiseOutletWiseItemCategory AS X ON X.Code=BT.Outlet AND X.ItemCategoryId=M.ItemCategory AND BT.PropertyId = X.PropertyId
	WHere Bt.PropertyId=@PropertyId AND BT.OrderDate BETWEEN @CurrMonthFirstDate AND @ReportDate AND X.CostingId=@CostingId

	AND (BT.OrderNo NOT IN (
				SELECT	PayTrans.OrderNo
				FROM	PayTrans 
					INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
				WHERE	((NoValue = 1) AND OrderDate >= CONVERT(DATETIME,@CurrMonthFirstDate,103) 
		AND  OrderDate <= CONVERT(DATETIME,@ReportDate,103) )
					AND (PayTrans.PayCode <> 'BR')  
					AND PayTrans.PropertyId = @PropertyId)
					
				)
	
	
	
	
	CREATE TABLE #TempRevnuToDate(Outlet VARCHAR(4),Qty DECIMAL(18,2),Rate DECIMAL(18,2),Amount DECIMAL(18,2),ItemCategory VARCHAR(50),TodaySale DECIMAL(18,4))
	CREATE TABLE #TempRevnuMTD	(Outlet VARCHAR(4),Qty DECIMAL(18,2),Rate DECIMAL(18,2),Amount DECIMAL(18,2),ItemCategory VARCHAR(50),MTDSale DECIMAL(18,4))
	CREATE TABLE #Temp	(OutletName VARCHAR(50),Outlet VARCHAR(4),FTypes VARCHAR(50),TDS DECIMAL(18,2),MTD DECIMAL(18,2))
	

    INSERT INTO #TempRevnuToDate(Outlet,Qty,Rate,ItemCategory,TodaySale)
	SELECT  Outlet,Qty,Rate,ItemCategory,SUM(Amount)AS ToTal
	from #TempRev 
	where OrderDate= CONVERT(DATE,@ReportDate,103) 	
	group by Outlet,Qty,Rate,ItemCategory ORDER BY ItemCategory
	


	INSERT INTO #TempRevnuMTD(Outlet,Qty,Rate,ItemCategory,MTDSale)
	SELECT Outlet,Qty,Rate,ItemCategory,SUM(Amount)AS ToTalMTD from #TempRev 
	where OrderDate between CONVERT(DATE,@CurrMonthFirstDate,103)  and CONVERT(DATE,@ReportDate,103) 
	group by Outlet,Qty,Rate,ItemCategory ORDER BY ItemCategory


	
	

	--SELECT 
	--L.description,
	--M.Outlet,
	--ISNULL(SUM(T.TodaySale),0.00)AS ToDateSale,IsNULL(SUM(M.MTDSale),0.00) MTD
	--FROM #TempRevnuMTD AS M 
	--LEFT JOIN #TempRevnuToDate AS T  ON T.ItemCategory=M.ItemCategory AND T.Outlet = M.Outlet
	--INNER JOIN Location_Ref AS L ON L.code=M.Outlet
	--GROUP BY L.description,M.Outlet
	INSERT INTO #Temp(OutletName,Outlet,FTypes,TDS)
	SELECT 
	L.description,
	T.Outlet,
	IT.Name,
	ISNULL(SUM(T.TodaySale),0.00)AS ToDateSale
	FROM #TempRevnuToDate AS T 
	INNER JOIN Location_Ref AS L ON L.code=T.Outlet
	INNER JOIN ItemCategory IT ON IT.Id = T.ItemCategory 
	WHERE IT.PropertyId = @PropertyId 
	GROUP BY L.description,T.Outlet,IT.Name

	INSERT INTO #Temp(OutletName,Outlet,FTypes,MTD)
	SELECT 
	L.description,
	T.Outlet,
	IT.Name,
	ISNULL(SUM(T.MTDSale),0.00)AS MTD
	FROM #TempRevnuMTD AS T 
	INNER JOIN Location_Ref AS L ON L.code=T.Outlet
	INNER JOIN ItemCategory IT ON IT.Id = T.ItemCategory 
	WHERE IT.PropertyId = @PropertyId 
	GROUP BY L.description,T.Outlet,IT.Name


	SELECT OutletName,IsNULL(SUM(MTD),0.00) MTD,IsNULL(SUM(TDS),0.00) TDS
	FROM #Temp
	GROUP BY OutletName

	--SELECT OutletName,Outlet,FTypes,IsNULL(SUM(MTD),0.00) MTD,IsNULL(SUM(TDS),0.00) TDS
	--FROM #Temp
	--GROUP BY OutletName,Outlet,FTypes
	
	IF OBJECT_ID(N'tempdb..#Temp') IS NOT NULL
	BEGIN
	DROP TABLE #Temp
	END
	IF OBJECT_ID(N'tempdb..#TempRevnuMTD') IS NOT NULL
	BEGIN
	DROP TABLE #TempRevnuMTD
	END
	IF OBJECT_ID(N'tempdb..#TempRevnuToDate') IS NOT NULL
	BEGIN
	DROP TABLE #TempRevnuToDate
	END
	IF OBJECT_ID(N'tempdb..#TempRev') IS NOT NULL
	BEGIN
	DROP TABLE #TempRev
	END


END

GO

