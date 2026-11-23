
CREATE PROCEDURE [dbo].[ReportHalfHourlySales_Dashboard]
(	
	@Date		varchar(10),	
	@Outlet		varchar(3) = 'HOF',
	@PropertyId INT,
	@UserId INT  = 0
)
AS
BEGIN

	SET NOCOUNT ON;
	set dateformat dmy 

	--SET @Date = '2018-01-09'
	--SET @Outlet = '001'

	IF OBJECT_ID(N'tempdb..#TempLocation') IS NOT NULL
	BEGIN
	DROP TABLE #TempLocation
	END

	SELECT L.*
	INTO #TempLocation
	FROM Location_Ref L INNER JOIN UserWiseOutlet UO ON L.code = UO.OutletCode AND L.PropertyId = UO.PropertyId
	WHERE L.PropertyId = @PropertyId AND UO.PropertyId = @PropertyId AND UO.UserId = @UserId

	select Orderdate,OrdTime, count(*) OrdCount, sum(GrossSale) GrossSale, sum(Discount) Discount, sum(Tax) Tax, sum(NetSale) NetSale   
	INTO #tempTbl
	from(
	select orderdate,OrderNo, OrdTime, GrossSale , Discount, Tax , NetSale  
	from
	(
			select  B.orderdate, B.OrderNo,cast(datepart(HOUR,B.ordertime) as varchar) + ':'+ case when datepart(MINUTE,B.ordertime)>30 then '30' else '00' end OrdTime,
			B.Subtotal  NetSale , B.Discount,B.TaxVal1+ B.TaxVal2+ B.TaxVal3+ B.TaxVal4 Tax , (B.Subtotal  + (B.TaxVal1+ B.TaxVal2+ B.TaxVal3+ B.TaxVal4)) GrossSale 	
			from BillHeader B INNER JOIN #TempLocation T ON B.Outlet = T.code AND B.PropertyId = T.PropertyId
			where B.PropertyId=@PropertyId --AND (@Outlet = 'HOF' OR Outlet=@Outlet) 
			and B.orderdate>=convert(datetime,@Date,103) and B.orderdate<=convert(datetime,@Date,103) 
	) Sales
	)GSales group by Orderdate, OrdTime order by Orderdate,OrdTime


	SELECT ISNULL(Orderdate,@Date) AS Orderdate,CONVERT(DATETIME,A.OrdTime) AS OrdTime, ISNULL(OrdCount,0) AS OrdCount, ISNULL(GrossSale,0) AS GrossSale,ISNULL(Discount,0) AS Discount,  ISNULL(Tax,0) AS Tax, ISNULL(NetSale,0) NetSale
	FROM #tempTbl AS A
	--RIGHT JOIN SalesHalfHours AS B ON CONVERT(TIME,A.OrdTime) = CONVERT(TIME,B.Time)
	ORDER BY CONVERT(TIME,A.OrdTime) ASC

	DROP TABLE #tempTbl

	--EXEC [ReportHalfHourlySales] '30/08/2018','001'
	


	IF OBJECT_ID(N'tempdb..#TempLocation') IS NOT NULL
	BEGIN
	DROP TABLE #TempLocation
	END




END

GO

