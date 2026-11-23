-- DashboardAPI_Last7DaysSalesAnalysis_Select_Dashboard N'[{"Id":1}]'

CREATE PROCEDURE [dbo].[DashboardAPI_Last7DaysSalesAnalysis_Select_Dashboard]
	@PropertiesJson		NVARCHAR(MAX)=NULL,
	@Date				DATE='',
	@Year				INT=0,
	@Month				INT=0,
	@FromDate			DATETIME='',
	@ToDate				DATETIME='',
	@Type				CHAR=''
AS
BEGIN



	DECLARE @SPName		NVARCHAR(500)='', @ChartType NVARCHAR(50)=''
	
	SET @SPName = 'DashboardAPI_Last7DaysSalesAnalysis_Select_Dashboard'
	
	SELECT @ChartType = ChartType FROM DashboardAPI_CommonFormat WITH(NOLOCK)
	WHERE SPName=@SPName
	
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
	
	
	
	
	declare @stardate datetime
	declare @LastFromdate datetime
	declare @avgSale money
	declare @dDate varchar(10)
	declare @dn int
	
	
	DECLARE @HotelDate	DATE
	SELECT @HotelDate = CurrentDate 
	FROM Companies WITH (NOLOCK) 
	WHERE CompanyID IN (SELECT Id FROM #tempProperties)
	
	
	set @LastFromdate = DATEADD(D,-7,@HotelDate)
	set @stardate= DATEADD(YEAR, DATEDIFF(YEAR, 0, @LastFromdate), 0)
	
	
	Declare @Runningday datetime
	DECLARE @I INT
	
	set @I=1
	set @Runningday=dateadd(D,-1,@HotelDate)
	
	print @HotelDate
	print @LastFromdate
	print @stardate
	print @Runningday
	
	Declare @t Table
	(
	Sales money,
	lastAvgSales money,
	MonthName1 varchar(12),
	dn int
	)
	
	
	
	WHILE @I <= 7
	BEGIN
	--print @Runningday
	insert into @t 
	select round(Sum(SubTotal+TaxVal1+TaxVal2+TaxVal3+TaxVal4+TDL),2),0,DATENAME (dw,OrderDate),0 
	from BillHeader a 
	--inner join Location_Ref_DashboardRest AS L ON L.code=a.outlet where L.PropertyId=@BrandID and 
	--(@OutletCode = 'HOF' OR Outlet = @OutletCode)  
	where OrderDate=@Runningday 
	group by OrderDate
	
	if @@ROWCOUNT=0
	begin
	insert into @t select 0,0,DATENAME (dw,@Runningday) ,0
	end 
	
	set @I=@I+1
	set @Runningday = DATEADD(D,-1,@Runningday)
	end
	
	
	--select * from @t
	--select @stardate
	
	select AVG(sales) as Sales, DATENAME (dw,OrderDate) as dName, 
	case DATENAME (dw,OrderDate)
	when 'monday' then 1
	when 'tuesday' then 2
	when 'wednesday' then 3
	when 'thursday' then 4
	when 'friday' then 5
	when 'saturday' then 6
	when 'sunday' then 7
	end as dn
	into #temp1
	from (
	select
	sum(SubTotal+TaxVal1+TaxVal2+TaxVal3+TaxVal4-Discount+TDL) as Sales ,OrderDate
	
	
	from 
	BillHeader a 
	--inner join Location_Ref_DashboardRest AS L ON L.code=a.outlet where L.PropertyId=@BrandID and 
	where
	OrderDate>=@stardate and OrderDate <= @HotelDate --and (@OutletCode = 'HOF' OR Outlet = @OutletCode) 
	group by OrderDate
	) as a group by DATENAME (dw,OrderDate)
	
	
	select @avgSale = Sales, @dDate = dName, @dn = dn from #temp1
	while @@rowcount > 0
	begin
	
	update @t set lastAvgSales = @avgsale, dn = @dn where MonthName1 = @dDate 
	
	delete from #temp1 where dName = @dDate 
	select @avgSale = Sales, @dDate = dName, @dn = dn from #temp1
	end


	--select * from @t order by dn 

	CREATE TABLE #tempChartResult
	(
		Id				INT IDENTITY(1,1),
		Series			NVARCHAR(50),
		[Label]			NVARCHAR(MAX),	
		[Value]			NVARCHAR(MAX),
		[Order]			INT DEFAULT(0),
		Curve			NVARCHAR(MAX),
		Color			NVARCHAR(MAX),
		[Type]			NVARCHAR(MAX) 
	)

	

	insert into #tempChartResult
	(Series,[Value],[Type],[Color])
	SELECT 'Sales',CAST(Sales AS NVARCHAR(MAX)),@ChartType,'#85C1E9'
	FROM @t
	ORDER BY dn ASC


	insert into #tempChartResult
	(Series,[Value],[Type],[Color])
	SELECT 'YTD Average',CAST(lastAvgSales AS NVARCHAR(MAX)),@ChartType,'#77848E'
	FROM @t
	ORDER BY dn ASC


	insert into #tempChartResult
	(Label,[Value])
	select MonthName1,MonthName1 
	FROM @t
	ORDER BY dn ASC

	declare @ChartTitle			nvarchar(MAX) = ''
	declare @ChartDisplayOrder	int
	declare @ChartPositionId		int
	declare @ChartSize			int
	declare @ChartHeight		int
	declare @IsZoomEnable		nvarchar(MAX)='false'

	SELECT * ,
	'Food Cost Analysis' as 'ChartTitle',
	1 as 'ChartDisplayOrder',
	1 as 'ChartPositionId',
	12 as 'ChartSize',
	@ChartType as 'ChartType',
	350 as 'ChartHeight',
	'true' as  'IsZoomEnable'
	FROM #tempChartResult

	DROP TABLE #tempChartResult
	DROP TABLE #tempProperties


END

GO

