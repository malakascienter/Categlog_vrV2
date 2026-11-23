-- =============================================
-- Author:		chiraj
-- Create date: 2010-10-14
-- Description:	Report_FoodCosting_Rev_Restaurant
-- =============================================
--Report_FoodCosting_Rev_Restaurant  2,1003
Create PROCEDURE [dbo].[Report_FoodCosting_Rev_Restaurant] 
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
	
	SET @CurrMonthFirstDate=(SELECT DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0))
	--SET @ReportDate =(select GETDATE()-1) removed by request aruna 2020-11-12
	SET  @ReportDate =CONVERT(DATETIME,@FromDate,103)-1
	SET @CurrYearFirstDate= (select convert (date,DATEADD(YEAR,DATEDIFF(YEAR,0,GETDATE()),0)))


	DECLARE @VarOutletCode varchar(4)
	DECLARE @VarItemcategoryId INT
	
	SELECT @VarOutletCode=OutletCode,@VarItemcategoryId=ItemCategoryId FROM OutletWiseItemCategories where PropertyId=@PropertyId

	--select * from OutletWiseItemCategories
	CREATE TABLE #TempRev(
	OrderDate DATETIME,
	PropertyId INT,
	OrderNo VARCHAR(20),
	Outlet VARCHAR(4),
	Qty DECIMAL(18,2),
	Rate Decimal(18,2),
	Amount DECIMAL(18,2),
	ItemCategory VARCHAR(50),	
	PayCode varchar(4)
	)
	
	INSERT INTO #TempRev(OrderDate,PropertyId,OrderNo,Outlet,Qty,Rate,Amount,ItemCategory,PayCode)
	SELECT 
	BT.OrderDate,
	BT.PropertyId
	,BT.OrderNo
	,BT.Outlet
	,BT.Qty
	,BT.Rate
	,BT.NetAmount	
	,M.ItemCategory
	,PT.PayCode	
	FROM  BillTrans AS BT
	INNER JOIN MainMenu AS M ON M.ItemCode=BT.MainMenuCode
	INNER JOIN ItemCategory AS IC ON IC.Id=M.ItemCategory	
	INNER JOIN PayTrans AS PT ON PT.OrderNo=BT.OrderNo 
	INNER JOIN CostingTypeWiseOutletWiseItemCategory AS X ON X.Code=BT.Outlet AND X.ItemCategoryId=M.ItemCategory
	WHere Bt.PropertyId=@PropertyId AND X.CostingId=@CostingId
	
--select * from #TempRev	
	
	CREATE TABLE #TempRevnuToDate(Outlet VARCHAR(4),Qty DECIMAL(18,2),Rate DECIMAL(18,2),Amount DECIMAL(18,2),ItemCategory VARCHAR(50),TodaySale DECIMAL(18,4))
	CREATE TABLE #TempRevnuMTD	(Outlet VARCHAR(4),Qty DECIMAL(18,2),Rate DECIMAL(18,2),Amount DECIMAL(18,2),ItemCategory VARCHAR(50),MTDSale DECIMAL(18,4))
	CREATE TABLE #TempRevnuYTD	(Outlet VARCHAR(4),Qty DECIMAL(18,2),Rate DECIMAL(18,2),Amount DECIMAL(18,2),ItemCategory VARCHAR(50),YTDSale DECIMAL(18,4))
	
    INSERT INTO #TempRevnuToDate(Outlet,Qty,Rate,ItemCategory,TodaySale)
	SELECT  Outlet,Qty,Rate,ItemCategory,SUM(Amount)AS ToTal
	from #TempRev 
	where OrderDate= CONVERT(DATE,@ReportDate,103) 	
	group by Outlet,Qty,Rate,ItemCategory ORDER BY ItemCategory
	
	--select * from #TempRevnuToDate

	INSERT INTO #TempRevnuMTD(Outlet,Qty,Rate,ItemCategory,MTDSale)
	SELECT Outlet,Qty,Rate,ItemCategory,SUM(Amount)AS ToTalMTD from #TempRev 
	where OrderDate between CONVERT(DATE,@CurrMonthFirstDate,103)  and CONVERT(DATE,@ReportDate,103) 
	group by Outlet,Qty,Rate,ItemCategory ORDER BY ItemCategory
	
	--select * from #TempRevnuMTD

	INSERT INTO #TempRevnuYTD(Outlet,Qty,Rate,ItemCategory,YTDSale)
	SELECT Outlet,Qty,Rate,ItemCategory,SUM(Amount) AS ToTalYTD from #TempRev 
	where OrderDate between CONVERT(DATE,@CurrYearFirstDate,103)  and CONVERT(DATE,@ReportDate,103) 
	group by Outlet,Qty,Rate,ItemCategory ORDER BY ItemCategory


	--select * from #TempRevnuYTD

	SELECT 
	L.description,
	--y.Outlet,
	--Y.Qty,
	--Y.Rate,
	--Y.ItemCategory,
	ISNULL(SUM(T.TodaySale),0.00)AS ToDateSale,IsNULL(SUM(M.MTDSale),0.00) MTD,IsNull(SUM(Y.YTDSale),0.00)YTD
	FROM #TempRevnuYTD AS Y
	LEFT JOIN #TempRevnuMTD AS M ON Y.ItemCategory=M.ItemCategory
	LEFT JOIN #TempRevnuToDate AS T  ON T.ItemCategory=Y.ItemCategory
	INNER JOIN Location_Ref AS L ON L.code=Y.Outlet
	--INNER JOIN CostingTypeWiseOutletWiseItemCategory AS X ON X.Code=Y.Outlet AND X.ItemCategoryId=Y.ItemCategory 
	--WHERE y.
	GROUP BY L.description
END

GO

