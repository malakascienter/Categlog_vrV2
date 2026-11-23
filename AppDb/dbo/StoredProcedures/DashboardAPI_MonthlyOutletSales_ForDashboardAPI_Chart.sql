-- DashboardAPI_MonthlyOutletSales_ForDashboardAPI_Chart N'[{"Id":1}]'
CREATE PROCEDURE [dbo].[DashboardAPI_MonthlyOutletSales_ForDashboardAPI_Chart]
	@PropertiesJson	NVARCHAR(MAX)=NULL,
	@FromDate		DATETIME='',
	@ToDate			DATETIME='',
	@Year			INT=0,
	@Month			INT=0,
	@Date			DATETIME='',
	@Type			CHAR=''
AS
BEGIN
	
	DECLARE @SPName		NVARCHAR(500)='', @ChartType NVARCHAR(50)=''

	SET @SPName = 'DashboardAPI_MonthlyOutletSales_ForDashboardAPI_Chart'

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

	CREATE TABLE #tempYearsMonths
	(
		[Year]		INT,
		[Month]		INT,
		FromDate	DATE,
		ToDate		DATE
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

	DECLARE @From DATE
	SET @From =DATEADD(YEAR, DATEDIFF(YEAR, 0, @HotelDate), 0)

	DECLARE @To	DATE
	SET @To = DATEADD(MILLISECOND, -3, DATEADD(YEAR, DATEDIFF(YEAR, 0, @HotelDate) + 1, 0))

	
	CREATE TABLE #tempResults
	(
		MonthName NVARCHAR(50),
		Total INT,
		MonthId	INT
	)

	DECLARE @MonthName NVARCHAR(50) = ''
	DECLARE @Total INT = 0

	CREATE TABLE #tempOutletSales
	(
		Sales					MONEY,
		PropertyId				INT,
		ResMonth				INT,
		ResYear					INT
	)

	

	INSERT INTO #tempOutletSales
	(Sales,PropertyId,ResMonth,ResYear)
	SELECT  (Subtotal),PropertyId,MONTH(OrderDate),YEAR(OrderDate) FROM Categlog_vrV2..BillHeader
	--WHERE (OrderDate BETWEEN @From AND @To) AND PropertyId IN (SELECT Id FROM #tempProperties)

	

	
	CREATE TABLE #tempMonths
	(
		MonthName NVARCHAR(50),
		MonthId	INT
	)

	DECLARE @MonthId	INT=1

	WHILE @MonthId<= 12
	BEGIN

		INSERT INTO #tempMonths
		(MonthName,MonthId)
		VALUES(DATENAME(MONTH, DATEADD(MONTH, @MonthId, '2000-12-01')),@MonthId)

		SET @MonthId = @MonthId+1
	END

	--SELECT * FROM #tempMonths
	 

	INSERT INTO #tempResults (MonthName, Total,MonthId)
	SELECT  B.MonthName, ISNULL(SUM(A.Sales),0),B.MonthId
	FROM #tempMonths B
	LEFT JOIN #tempOutletSales A  ON B.MonthId=A.ResMonth AND A.ResYear = '2024'
	--WHERE  (B.MonthId <=@Month)
	GROUP BY B.MonthName,B.MonthId
	ORDER BY B.MonthId ASC



	insert into #tempChartResult
	(Series,[Value],Curve,[Type],Color)
	SELECT 'Sales',Total,'',@ChartType,'#85C1E9'
	FROM #tempResults 
	ORDER BY MonthId


	insert into #tempChartResult
	([Label],[Value],Curve)
	SELECT MonthName,MonthName,'' 	
	FROM #tempResults 
	ORDER BY MonthId

	declare @ChartTitle			nvarchar(MAX) = ''
	declare @ChartDisplayOrder	int
	declare @ChartPositionId		int
	declare @ChartSize			int

	SELECT * ,
	'Monthly Outlet Sales' as 'ChartTitle',
	1 as 'ChartDisplayOrder',
	1 as 'ChartPositionId',
	12 as 'ChartSize',
	@ChartType as 'ChartType',
	350 as 'ChartHeight',
	'true' as  'IsZoomEnable'
	FROM #tempChartResult

	DROP TABLE #tempChartResult

	DROP TABLE #tempYearsMonths
	DROP TABLE #tempResults
	DROP TABLE #tempMonths
	DROP TABLE #tempProperties
END

GO

