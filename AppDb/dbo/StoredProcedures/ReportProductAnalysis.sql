
CREATE PROCEDURE [dbo].[ReportProductAnalysis] (@StartDate varchar(10), @EndDate varchar(10),@Outlet char(3))
AS
BEGIN

	SET NOCOUNT ON;
	--set dateformat dmy

	SELECT	OrderNo, MainMenuCode, Qty,Rate, OrderDate, Outlet, ItemSeq INTO #Temp
	FROM	BillTrans
	WHERE	Rate > 0 AND OrderDate >= convert(datetime,@StartDate,103) and OrderDate <= convert(datetime,@EndDate ,103) AND Outlet = @Outlet

	SELECT OrderNo, MainMenuCode, Qty, Rate, OrderDate, Outlet, ItemSeq  INTO #Temp1
	FROM #Temp 
	WHERE OrderNo + LTRIM(RTRIM(MainMenuCode)) + CAST (CONVERT(DATE,OrderDate)AS VARCHAR(12)) + Outlet + CAST (ItemSeq AS VARCHAR(15)) NOT IN 
	(SELECT OrderNo + LEFT(MainMenuCode,3) + CAST (CONVERT(DATE,OrderDate) AS VARCHAR(12)) + Outlet + CAST (ItemSeq AS VARCHAR(15)) FROM #Temp WHERE LEN(MainMenuCode) > 3)


	--SELECT #Temp.OrderNo, #Temp.MainMenuCode, #Temp.Qty,#Temp.Rate, #Temp.OrderDate, #Temp.Outlet, #Temp.ItemSeq  INTO #Temp1
	--FROM #Temp INNER JOIN (
	--	SELECT LEFT(MainMenuCode,3) AS MainMenuCode, Qty,Rate,OrderDate,Outlet,ItemSeq FROM #Temp WHERE LEN(MainMenuCode) > 3) A
	--	ON #Temp.MainMenuCode = A.MainMenuCode AND #Temp.Outlet = A.Outlet AND #Temp.OrderDate = A.OrderDate AND #Temp.ItemSeq = A.ItemSeq
	
	--WHERE MainMenuCode NOT IN (SELECT LEFT(MainMenuCode,3)  FROM #Temp WHERE LEN(MainMenuCode) > 3)

	UPDATE #Temp1 SET MainMenuCode = LEFT(MainMenuCode,3)

	--UPDATE #Temp SET #Temp.Rate = A.Rate ,#Temp.Qty = A.Qty
	--FROM #Temp INNER JOIN (
	--SELECT LEFT(MainMenuCode,3) AS MainMenuCode, Qty,Rate,OrderDate,Outlet,ItemSeq FROM #Temp WHERE LEN(MainMenuCode) > 3) A
	--ON #Temp.MainMenuCode = A.MainMenuCode AND #Temp.Outlet = A.Outlet AND #Temp.OrderDate = A.OrderDate AND #Temp.ItemSeq = A.ItemSeq
	--WHERE #Temp.Rate = 0

	--DELETE FROM #Temp WHERE LEN(MainMenuCode) > 3


	select * from(
	select ItemCode, CatDescription, ItemDescription, sum(Qty) Qty, MAX(SellPrice) AS SellPrice, sum(Qty*SellPrice) TotSales   from (
	select BT.MainMenuCode AS ItemCode, CT.Description CatDescription, Mn.Description AS ItemDescription, BT.Qty,
	 BT.Rate AS SellPrice
	from BillHeader BH inner join #Temp1 BT on BH.orderno =BT.OrderNo and BH.outlet=BT.Outlet AND BH.OrderDate =BT.OrderDate
	inner join MainMenu MN on BT.MainMenuCode = MN.ItemCode inner join --SubMenu SM on BT.MainMenuCode = SM.MainMenuCode and BT.SubMenuCode = SM.SubMenuCode inner join
	Category CT on MN.Category = CT.Code where BH.OrderDate >= convert(datetime,@StartDate,103) and BH.OrderDate <= convert(datetime,@EndDate ,103) AND BH.Outlet = @Outlet AND LEN(BT.MainMenuCode) = 3
	) DT group by ItemCode, ItemDescription, CatDescription) ItemWise
	cross join
	(select sum(Subtotal + TaxVal + Discount) GrossSale, sum(TaxVal) TaxVal, sum(Discount) Discount, sum(Subtotal + TaxVal) NetSale     
	,count(*) TicketCount,sum(Subtotal+Discount+ TaxVal)/count(*) TicketAvg from (
	select Subtotal,Discount,TaxVal1+  TaxVal2+ TaxVal3+ TaxVal4 TaxVal from BillHeader  where  orderdate>= convert(datetime,@StartDate,103)  and orderdate<= convert(datetime,@EndDate ,103) AND Outlet = @Outlet ) SumVal ) ss

END

GO

