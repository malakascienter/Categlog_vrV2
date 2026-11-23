-- DashboardAPI_FoodCostAnalysis_Select_Dashboard N'[{"Id":1}]'

CREATE PROCEDURE [dbo].[DashboardAPI_FoodCostAnalysis_Select_Dashboard]
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

	DECLARE @Month1	INT = 1

	CREATE TABLE #tempTotalFoodCost
	(
		[Year]							INT,
		[Month]							INT,
		MonthName						NVARCHAR(50),
		TotalFDCost						DECIMAL(18,2),
		PropertyId						INT
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
		
		--SELECT @CurrenctYear

		

		WHILE @Month1<=12
		BEGIN
			SET @CurrenctMonth = @Month1

			INSERT INTO #tempTotalFoodCost
			([Year],[Month],MonthName,TotalFDCost,PropertyId)
			SELECT @CurrenctYear,@CurrenctMonth,DATENAME(MONTH, DATEADD(MONTH, @Month1, '2000-12-01')),0.0000,0


			SET @Month1 = @Month1+1

		END

	
		

	CREATE TABLE #tempTotalFoodCostUpdate
	(
		TotalFDCost					DECIMAL(18,2),
		ReservationYear					INT,
		ReservationMonth				INT,
		PropertyId						INT
	)
	INSERT INTO #tempTotalFoodCostUpdate
	(TotalFDCost,ReservationYear,ReservationMonth,PropertyId)
	SELECT SUM(A.Rate*A.Qty),B.[Year],B.[Month],A.PropertyId
	FROM Categlog_vrV2..BillTrans A WITH(NOLOCK)
	INNER JOIN #tempTotalFoodCost B ON B.[Year] = YEAR(A.OrderDate) AND B.[Month] = MONTH(A.OrderDate)
	WHERE A.PropertyId IN (SELECT Id FROM #tempProperties)
	GROUP BY B.[Year],B.[Month],A.PropertyId

	--SELECT * FROM #tempRoomRevenueUpdate

	UPDATE A
	SET 
	A.TotalFDCost = B.TotalFDCost,
	A.PropertyId = B.PropertyId
	FROM #tempTotalFoodCost A
	INNER JOIN #tempTotalFoodCostUpdate B  ON A.[Year] = B.ReservationYear
	AND A.[Month] = B.ReservationMonth

	--SELECT * FROM #tempRoomRevenue

	insert into #tempChartResult
	(Series,[Value],[Type],[Color])
	SELECT 'Food Cost',CAST(TotalFDCost AS NVARCHAR(MAX)),@ChartType,'#38C786'
	FROM #tempTotalFoodCost

	insert into #tempChartResult
	(Label,[Value])
	SELECT  MonthName,MonthName
	FROM #tempTotalFoodCost
	ORDER BY Year 

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
	DROP TABLE #tempTotalFoodCost
	DROP TABLE #tempTotalFoodCostUpdate


END

GO

