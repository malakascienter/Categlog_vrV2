CREATE PROCEDURE [dbo].[DashboardAPI_Select_PropertyOccupancyDetails]
	@PropertiesJson		NVARCHAR(MAX)='',
	@FromDate			DATETIME='',
	@ToDate				DATETIME='',
	@Date				DATETIME='',
	@Year				INT=0,
	@Month				INT=0,
	@Type				CHAR=''
AS
BEGIN
	CREATE TABLE #tempProperties
	(
		Id			INT,
		Name		NVARCHAR(100)
	)

	INSERT INTO #tempProperties
	(Id,Name)
	SELECT CompanyID as Id,Name FROM Companies WITH(NOLOCK)

	CREATE TABLE #TempOccupancyDetails(
			Id		INT,
			Name	NVARCHAR(200),
			Date	NVARCHAR(20),
			Value	DECIMAL(18,2),
			PropertyId	INT,
			PropertyName		NVARCHAR(500),
			PropertyImage	NVARCHAR(MAX),
			Revenue			DECIMAL(18,2),
			Prefix			NVARCHAR(MAX),
			InfoButton		NVARCHAR(MAX)
	)

	DECLARE @PropertyId		INT=0
	DECLARE @PropertyName	NVARCHAR(500)=''
	DECLARE @PropertyImage	NVARCHAR(MAX)=''
	DECLARE @FrontOfficeBaseUrl	NVARCHAR(500)=''

	DECLARE @ImageSrc	NVARCHAR(MAX)='',@ButtonUrl	NVARCHAR(MAX)=''

	WHILE EXISTS(SELECT 1 FROM #tempProperties)
	BEGIN
		SELECT TOP 1 @PropertyId = Id FROM #tempProperties

		SELECT TOP 1 @PropertyName = Name FROM Companies WHERE CompanyID=@PropertyId
	
		--SELECT TOP 1 @PropertyImage = @FrontOfficeBaseUrl+Image FROM Properties WHERE Id=@PropertyId
		SELECT TOP 1 @PropertyImage = LogoURL FROM Companies WHERE CompanyID=@PropertyId

		DECLARE @Inhoused		DECIMAL(18,2)
		DECLARE @Reservation	DECIMAL(18,2)
		DECLARE @Occupancy		DECIMAL(18,2)
		DECLARE @TotalRooms		DECIMAL(18,2)
		DECLARE @OOORooms		DECIMAL(18,2)
		DECLARE @Prefix			NVARCHAR(MAX)
		DECLARE @HotelDate		DATETIME

		SELECT @HotelDate = CurrentDate 
		FROM Companies WITH (NOLOCK) 
		WHERE CompanyID=@PropertyId

		--select @HotelDate

		SELECT @Prefix = Code FROM Companies WITH(NOLOCK) WHERE CompanyID = @PropertyId

		SELECT @Reservation=0

		SELECT @Inhoused= 0

		SELECT @TotalRooms=0

		select @OOORooms=0



		SET @Occupancy = ((@Inhoused+@Reservation)/CASE WHEN (@TotalRooms-@OOORooms)=0 THEN 1 ELSE (@TotalRooms-@OOORooms) END)*100

		IF(@Occupancy IS NULL)
		BEGIN
		Set  @Occupancy = 0
		End

		--SET @PropertyImage = REPLACE(@PropertyImage,'"', '''')
		--SET @ImageSrc = '<img src="' + @PropertyImage + '" alt="Property Image" width=100/>';

		--SET @ImageSrc = REPLACE(@ImageSrc,'"', '''')
		--SELECT @ImageSrc

		--SET @ButtonUrl = '<a href="/dashboard/'+CONVERT(NVARCHAR(10),@PropertyId)+'" class="btn btn-sm bg-primary text-light" value="'+CONVERT(NVARCHAR(10),@PropertyId)+'"><i class="ri-arrow-right-line"></i></a>'
		--SET @ButtonUrl = REPLACE(@ButtonUrl,'"', '''')

		INSERT INTO #TempOccupancyDetails
		(Id,Name,Date,Value,PropertyId,PropertyName,PropertyImage,Revenue,Prefix,InfoButton)
		VALUES (1,'Daily Occupancy %',@HotelDate,@Occupancy,@PropertyId,@PropertyName,@PropertyImage,2005.00,@Prefix,@PropertyId)
	
		DELETE TOP (1) FROM #tempProperties
	END

	--	DECLARE @HotelDate2 NVARCHAR(MAX)=''

	--	SELECT @HotelDate2 = @HotelDate2 + ',"' + CAST(CONVERT(DATE,Date) AS NVARCHAR(MAX))+'"'
	--	FROM #TempOccupancyDetails
	--	SELECT  @HotelDate2 = STUFF(@HotelDate2, 1, 1, '')

	--	SET @HotelDate2 = '['+@HotelDate2+']'
	--	SET @HotelDate2 = JSON_QUERY(@HotelDate2)
	--	--SELECT @HotelDate2

	--	DECLARE @HotelDateJson NVARCHAR(MAX) ='{' +
	--		'"name": "Hotel Date",' +
	--		'"data": '+@HotelDate2+'' +
	--		'}'

	--	DECLARE @Occupancy2	NVARCHAR(MAX) = ''
	--	SELECT @Occupancy2 = @Occupancy2 + ',"' + CAST(Value AS NVARCHAR(MAX))+'"'
	--	FROM #TempOccupancyDetails
	--	SELECT  @Occupancy2 = STUFF(@Occupancy2, 1, 1, '')

	--	SET @Occupancy2 = '['+@Occupancy2+']'

	--	SET @Occupancy2 = JSON_QUERY(@Occupancy2)

	--	DECLARE @OccupancyJson NVARCHAR(MAX) ='{' +
	--		'"name": "Daily Occupancy",' +
	--		'"data": '+@Occupancy2+'' +
	--		'}'

	--	DECLARE @PropertyName2	NVARCHAR(MAX) = ''
	--	SELECT @PropertyName2 = @PropertyName2 + ',"' + PropertyName+'"'
	--	FROM #TempOccupancyDetails
	--	SELECT  @PropertyName2 = STUFF(@PropertyName2, 1, 1, '')

	--	SET @PropertyName2 = '['+@PropertyName2+']'

	--	SET @PropertyName2 = JSON_QUERY(@PropertyName2)

	--	DECLARE @PropertyNameJson NVARCHAR(MAX) ='{' +
	--		'"name": "Property Name",' +
	--		'"data": '+@PropertyName2+'' +
	--		'}'

	--	DECLARE @PropertyImage2	NVARCHAR(MAX) = ''
	--	SELECT @PropertyImage2 = @PropertyImage2 + ',"' + PropertyImage+'"'
	--	FROM #TempOccupancyDetails
	--	SELECT  @PropertyImage2 = STUFF(@PropertyImage2, 1, 1, '')

	--	SET @PropertyImage2 = '['+@PropertyImage2+']'

	--	SET @PropertyImage2 = JSON_QUERY(@PropertyImage2)

	--	DECLARE @PropertyImageJson NVARCHAR(MAX) ='{' +
	--		'"name": "Property Image",' +
	--		'"data": '+@PropertyImage2+'' +
	--		'}'


	--	DECLARE @Revenue2	NVARCHAR(MAX) = ''
	--	SELECT @Revenue2 = @Revenue2 + ',"' + CAST(Revenue AS NVARCHAR(MAX))+'"'
	--	FROM #TempOccupancyDetails
	--	SELECT  @Revenue2 = STUFF(@Revenue2, 1, 1, '')

	--	SET @Revenue2 = '['+@Revenue2+']'

	--	SET @Revenue2 = JSON_QUERY(@Revenue2)

	--	DECLARE @RevenueJson NVARCHAR(MAX) ='{' +
	--		'"name": "Daily Revenue",' +
	--		'"data": '+@Revenue2+'' +
	--		'}'


	--	DECLARE @InfoButton	NVARCHAR(MAX) = ''
	--	SELECT @InfoButton = @InfoButton + ',"' + InfoButton+'"'
	--	FROM #TempOccupancyDetails
	--	SELECT  @InfoButton = STUFF(@InfoButton, 1, 1, '')

	--	SET @InfoButton = '['+@InfoButton+']'

	--	SET @InfoButton = JSON_QUERY(@InfoButton)

	--	DECLARE @InfoButtonJson NVARCHAR(MAX) ='{' +
	--		'"name": "Info",' +
	--		'"data": '+@InfoButton+'' +
	--		'}'

	--	DECLARE @DataJson	NVARCHAR(MAX) = '['+@PropertyImage2+','+@PropertyName2+','+@HotelDate2+','+@Occupancy2+','+@Revenue2+','+@InfoButton+']'

	--	--SET @DataJson = JSON_QUERY(@DataJson)

	--	DECLARE @ResultJson NVARCHAR(MAX) ='{' +
	--	'"colnames": ["","","Hotel Date","Occupancy","Revenue",""],' +
	--	'"data": '+@DataJson+'' +
	--	'}'

	----select * from #TempOccupancyDetails

	--SELECT @ResultJson AS ResultJson,@DataJson AS DataJson

	SELECT
	(
	SELECT 
	Id,
	Name,
	CONVERT(DATE,Date) AS Date,
	CONVERT(DATE,Date) AS HotelDate,
	Value,
	PropertyId,
	PropertyName,
	PropertyImage,
	Prefix,
	InfoButton
	FROM #TempOccupancyDetails
	FOR JSON AUTO) AS ResultJson

	DROP TABLE #TempOccupancyDetails
	DROP TABLE #tempProperties

END

GO

