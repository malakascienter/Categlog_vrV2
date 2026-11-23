-- DashboardAPI_OutletWiseSales_Grid @PropertiesJson = N'[{"Id":1}]'
CREATE PROCEDURE [dbo].[DashboardAPI_OutletWiseSales_Grid]
	@PropertiesJson	NVARCHAR(MAX)=NULL,
	@FromDate		DATETIME='',
	@ToDate			DATETIME='',
	@Year			INT=0,
	@Month			INT=0,
	@Date			DATETIME='',
	@Type			CHAR=''
AS
BEGIN


	IF OBJECT_ID(N'tempdb..#tempChartResult') IS NOT NULL
	BEGIN
	DROP TABLE #tempChartResult
	END

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

	
	DECLARE @HotelDate	DATE
	SELECT @HotelDate = CurrentDate 
	FROM Companies WITH (NOLOCK) 
	WHERE CompanyID IN (SELECT Id FROM #tempProperties)


	
	declare @MTDFrom datetime
	declare @MTDTo datetime

	set @MTDFrom = convert(datetime,convert(varchar(10),DATEADD(month, DATEDIFF(month, 0, @HotelDate), 0),103),103)
	set @MTDTo = convert(datetime,convert(varchar(10),@HotelDate,103),103)


		SELECT SUM(Subtotal+TaxVal1+TaxVal2+TaxVal3+TaxVal4+ServiceCharge) AS Sales, B.code,B.description
		INTO #tempOutletWiseSales
		FROM Categlog_vrV2..BillHeader A WITH(NOLOCK)
		INNER JOIN Categlog_vrV2..Location_Ref B WITH(NOLOCK) ON A.Outlet = B.code and a.PropertyId = b.PropertyId 
		--WHERE  A.OrderDate BETWEEN @MTDFrom AND @MTDTo
		GROUP BY B.code,B.description


	--SELECT
	--(
	--	SELECT * FROM #tempOutletWiseSales
	--	FOR JSON AUTO
	--) AS ResultJson



	CREATE TABLE #tempChartResult
	(
		Id				INT IDENTITY(1,1),
		Series			NVARCHAR(50),
		[Label]			NVARCHAR(MAX),	
		[Value]			NVARCHAR(MAX),
		[Order]			INT DEFAULT(0),
		Color			NVARCHAR(MAX),
		[Type]			NVARCHAR(MAX) DEFAULT('bar'),
		Colspan			INT,
		TextAlign		NVARCHAR(10),
		RowId			INT
	)


	
	INSERT INTO #tempChartResult
	(Series,[Value], [Type],Color,Colspan,RowId,Label,TextAlign)
	SELECT 'Sales Outlet',CAST(A.description AS NVARCHAR(MAX)),'bar','#38C786',1,1,'','right'
	FROM #tempOutletWiseSales A 
	ORDER BY A.description

	INSERT INTO #tempChartResult
	(Series,[Value], [Type],Color,Colspan,RowId,Label,TextAlign)
	SELECT 'MTD Value',CAST(A.Sales AS NVARCHAR(MAX)),'bar','#38C786',1,1,A.description,'right'
	FROM #tempOutletWiseSales A
	ORDER BY A.description


	SELECT * ,
	1 as 'ChartDisplayOrder',
	1 as 'ChartPositionId',
	12 as 'ChartSize',
	'bar' as 'ChartType',
	350 as 'ChartHeight',
	'true' as  'IsZoomEnable'
	FROM #tempChartResult


	IF OBJECT_ID(N'tempdb..#tempChartResult') IS NOT NULL
	BEGIN
	DROP TABLE #tempChartResult
	END
	
END

GO

