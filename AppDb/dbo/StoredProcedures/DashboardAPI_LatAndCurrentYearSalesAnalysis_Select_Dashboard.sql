-- DashboardAPI_LatAndCurrentYearSalesAnalysis_Select_Dashboard N'[{"Id":1}]'

CREATE PROCEDURE [dbo].[DashboardAPI_LatAndCurrentYearSalesAnalysis_Select_Dashboard]
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

	SET @SPName = 'DashboardAPI_FoodCostAnalysis_Select_Dashboard'

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

	DECLARE @CurrenctMonth	INT
	DECLARE @CurrenctYear	INT
	DECLARE @LastYear	INT

	DECLARE @Month1	INT = 1

	CREATE TABLE #tempTotalSales
	(
		[Year]							INT,
		[Month]							INT,
		MonthName						NVARCHAR(50),
		TotalSales					DECIMAL(18,2),
		PropertyId						INT,
		Sort						    INT
	)


	CREATE TABLE #tempMonth
	(
		
		[Month]							INT,
		MonthName						NVARCHAR(50),
		Sort						    INT
	)

	

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

		DECLARE @HotelDate	DATE
	SELECT @HotelDate = CurrentDate 
	FROM Companies WITH (NOLOCK) 
	WHERE CompanyID IN (SELECT Id FROM #tempProperties)


	SET @CurrenctYear = YEAR(@HotelDate)
	SET @LastYear = YEAR(dateadd(year, -1, @HotelDate))
		
		--SELECT @CurrenctYear

		

		WHILE @Month1<=12
		BEGIN
			SET @CurrenctMonth = @Month1

			INSERT INTO #tempTotalSales
			([Year],[Month],MonthName,TotalSales,PropertyId,Sort)
			SELECT @CurrenctYear,@CurrenctMonth,DATENAME(MONTH, DATEADD(MONTH, @Month1, '2000-12-01')),0.0000,0,@Month1

			INSERT INTO #tempTotalSales
			([Year],[Month],MonthName,TotalSales,PropertyId,Sort)
			SELECT @LastYear,@CurrenctMonth,DATENAME(MONTH, DATEADD(MONTH, @Month1, '2000-12-01')),0.0000,0,@Month1


			INSERT INTO #tempMonth
			([Month],MonthName,Sort)
			SELECT @CurrenctMonth,DATENAME(MONTH, DATEADD(MONTH, @Month1, '2000-12-01')),@Month1


			SET @Month1 = @Month1+1

		END

	
		

	CREATE TABLE #tempTotalSalesUpdate
	(
		TotalSales					DECIMAL(18,2),
		SalesYear					INT,
		SalesMonth				INT,
		PropertyId						INT
	)
	INSERT INTO #tempTotalSalesUpdate
	(TotalSales,SalesYear,SalesMonth,PropertyId)
	SELECT SUM(A.Rate*A.Qty),B.[Year],B.[Month],A.PropertyId
	FROM Categlog_vrV2..BillTrans A WITH(NOLOCK)
	INNER JOIN #tempTotalSales B ON B.[Year] = YEAR(A.OrderDate) AND B.[Month] = MONTH(A.OrderDate)
	WHERE A.PropertyId IN (SELECT Id FROM #tempProperties) and  B.Year = @CurrenctYear
	GROUP BY B.[Year],B.[Month],A.PropertyId

	--SELECT * FROM #tempRoomRevenueUpdate

	UPDATE A
	SET 
	A.TotalSales = B.TotalSales,
	A.PropertyId = B.PropertyId
	FROM #tempTotalSales A
	INNER JOIN #tempTotalSalesUpdate B  ON A.[Year] = B.SalesYear
	AND A.[Month] = B.SalesMonth
	WHERE A.[Year] = @CurrenctYear

	--SELECT * FROM #tempRoomRevenue

	insert into #tempChartResult
	(Series,[Value],[Type],[Color])
	SELECT 'Current Year',CAST(TotalSales AS NVARCHAR(MAX)),@ChartType,'#38C786'
	FROM #tempTotalSales
	WHERE [Year] = @CurrenctYear
	ORDER BY Sort



	INSERT INTO #tempTotalSalesUpdate
	(TotalSales,SalesYear,SalesMonth,PropertyId)
	SELECT SUM(A.Rate*A.Qty),B.[Year],B.[Month],A.PropertyId
	FROM Categlog_vrV2..BillTrans A WITH(NOLOCK)
	INNER JOIN #tempTotalSales B ON B.[Year] = YEAR(A.OrderDate) AND B.[Month] = MONTH(A.OrderDate)
	WHERE A.PropertyId IN (SELECT Id FROM #tempProperties) and  B.Year = @LastYear
	GROUP BY B.[Year],B.[Month],A.PropertyId

	--SELECT * FROM #tempRoomRevenueUpdate

	UPDATE A
	SET 
	A.TotalSales = B.TotalSales,
	A.PropertyId = B.PropertyId
	FROM #tempTotalSales A
	INNER JOIN #tempTotalSalesUpdate B  ON A.[Year] = B.SalesYear
	AND A.[Month] = B.SalesMonth
	WHERE A.[Year] = @LastYear

	--SELECT * FROM #tempRoomRevenue

	insert into #tempChartResult
	(Series,[Value],[Type],[Color])
	SELECT 'Last Year',CAST(TotalSales AS NVARCHAR(MAX)),@ChartType,'#85C1E9'
	FROM #tempTotalSales
	WHERE [Year] = @LastYear
	ORDER BY Sort


	insert into #tempChartResult
	(Label,[Value])
	select MonthName,MonthName 
	FROM #tempMonth
	ORDER BY Sort

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
	DROP TABLE #tempTotalSales
	DROP TABLE #tempTotalSalesUpdate


END

GO

