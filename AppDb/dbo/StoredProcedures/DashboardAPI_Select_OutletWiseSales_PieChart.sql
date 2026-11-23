-- DashboardAPI_Select_OutletWiseSales_PieChart N'[{"Id":1}]'

CREATE PROCEDURE [dbo].[DashboardAPI_Select_OutletWiseSales_PieChart]
	@PropertiesJson		NVARCHAR(MAX),
	@Date				DATE='',
	@Year				INT=0,
	@Month				INT=0,
	@FromDate			DATETIME='',
	@ToDate				DATETIME='',
	@Type				CHAR=''
AS
BEGIN

	DECLARE @SPName		NVARCHAR(500)='', @ChartType NVARCHAR(50)=''

	SET @SPName = 'DashboardAPI_Select_OutletWiseSales_PieChart'

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

	DECLARE @PropertyId	INT
	SELECT @PropertyId = Id FROM #tempProperties

	DECLARE @HotelDate	DATE
	SELECT @HotelDate = CurrentDate 
	FROM Companies WITH (NOLOCK) 
	WHERE CompanyID IN (SELECT Id FROM #tempProperties)

	CREATE TABLE #tempOutletWiseSales
	(
		Sales	    Money,
		OutletCode	varchar(3),
		OutletName	varchar(50),
		OutletColorCode VARCHAR(200)
	)

	CREATE TABLE #tempChartResult
	(
		Id				INT IDENTITY(1,1),
		Series			NVARCHAR(50),
		[Label]			NVARCHAR(MAX),	
		[Value]			NVARCHAR(MAX),
		[Order]			INT DEFAULT(0),
		Color			NVARCHAR(MAX),
		[Type]			NVARCHAR(MAX) 
	)


	declare @MTDFrom datetime
	declare @MTDTo datetime

	set @MTDFrom = convert(datetime,convert(varchar(10),DATEADD(month, DATEDIFF(month, 0, @HotelDate), 0),103),103)
	set @MTDTo = convert(datetime,convert(varchar(10),@HotelDate,103),103)

	--SELECT @MTDFrom,@MTDTo

	IF(@PropertyId=0)
	BEGIN

		INSERT INTO #tempOutletWiseSales
		(Sales,OutletCode,OutletName,OutletColorCode)
		SELECT SUM(Subtotal+TaxVal1+TaxVal2+TaxVal3+TaxVal4+ServiceCharge), B.code,B.description,B.OutletColorCode
		FROM Categlog_vrV2..BillHeader A WITH(NOLOCK)
		INNER JOIN Categlog_vrV2..Location_Ref B WITH(NOLOCK) ON A.Outlet = B.code and a.PropertyId = b.PropertyId 
		--WHERE  A.OrderDate BETWEEN @MTDFrom AND @MTDTo
		GROUP BY B.code,B.description,B.OutletColorCode
	END
	ELSE
	BEGIN
		INSERT INTO #tempOutletWiseSales
		(Sales,OutletCode,OutletName,OutletColorCode)
		SELECT SUM(Subtotal+TaxVal1+TaxVal2+TaxVal3+TaxVal4+ServiceCharge), B.code,B.description,B.OutletColorCode
		FROM Categlog_vrV2..BillHeader A WITH(NOLOCK)
		INNER JOIN Categlog_vrV2..Location_Ref B WITH(NOLOCK) ON A.Outlet = B.code and a.PropertyId = b.PropertyId 
		--WHERE  A.OrderDate BETWEEN @MTDFrom AND @MTDTo AND A.PropertyId IN (SELECT Id FROM #tempProperties)
		GROUP BY B.code,B.description,B.OutletColorCode
	END

	INSERT INTO #tempChartResult
	(Series,[Value], [Type])
	SELECT A.OutletName,A.Sales,@ChartType
	FROM #tempOutletWiseSales A
	ORDER BY A.OutletName

	INSERT INTO #tempChartResult
	(Label,[Value])
	SELECT OutletName,OutletName
	FROM #tempOutletWiseSales A
	ORDER BY A.OutletName

	DECLARE @ChartTitle			NVARCHAR(MAX) = ''
	DECLARE @ChartDisplayOrder	INT
	DECLARE @ChartPositionId	INT
	DECLARE @ChartSize			INT

	SELECT * ,
	'Reservation Status' as 'ChartTitle',
	1 as 'ChartDisplayOrder',
	1 as 'ChartPositionId',
	12 as 'ChartSize',
	@ChartType as 'ChartType',
	350 as 'ChartHeight',
	'true' as  'IsZoomEnable'
	FROM #tempChartResult 

	DROP TABLE #tempChartResult
	DROP TABLE #tempProperties
	DROP TABLE #tempOutletWiseSales

END

GO

