-- DashboardAPI_Select_PaxDetails N'[{"Id":1}]'

CREATE PROCEDURE [dbo].[DashboardAPI_Select_PaxDetails]
	@PropertiesJson	NVARCHAR(MAX)=NULL,
	@FromDate		DATETIME='',
	@ToDate			DATETIME='',
	@Year			INT=0,
	@Month			INT=0,
	@Date			DATETIME='',
	@Type			CHAR=''
AS
BEGIN
	DECLARE @CurrentDate	DATE

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

	DECLARE @FirstDayOfYear	DATE
	SELECT  @FirstDayOfYear =  DATEADD(yy, DATEDIFF(yy, 0, @CurrentDate), 0)

	

	CREATE TABLE #tempMain
	(
		id						INT,
		title					NVARCHAR(500),
		card_icon				NVARCHAR(500),
		display_order			INT,
		position_id				INT,
		size					INT,
		[type]					NVARCHAR(100),
		[value]					NVARCHAR(200),
		value_percentage		NVARCHAR(200),
		value_percentage_icon	NVARCHAR(200),
		value_percentage_color	NVARCHAR(200),
		text_color				NVARCHAR(200),
		bg_color				NVARCHAR(200),
		header_font_size		INT,
		sub_font_size			INT,
		perc_font_size			INT,
		subDataShow				NVARCHAR(50),
		bgIconShow				NVARCHAR(50),
		mainIconShow			NVARCHAR(50),
		text_col_size			INT,
		text_align				NVARCHAR(50)
	)

	CREATE TABLE #tempSubDetail
	(
		main_id					INT,
		title					NVARCHAR(500),
		display_order			INT,
		size					INT,
		[value]					NVARCHAR(200),
		header_font_size		INT,
		sub_font_size			INT
	)

	declare @TDDate	datetime

	declare @WTDFrom datetime
	declare @WTDTo datetime

	declare @MTDFrom datetime
	declare @MTDTo datetime

	declare @YTDFrom datetime
	declare @YTDTo datetime


	set @TDDate = convert(datetime,convert(varchar(10),dateadd(d,0,@CurrentDate),103),103)

	set @WTDFrom = DATEADD(WEEK, DATEDIFF(WEEK, 0, @CurrentDate), 0)
	set @WTDTo = convert(datetime,convert(varchar(10),@CurrentDate,103),103)

	set @MTDFrom = convert(datetime,convert(varchar(10),DATEADD(month, DATEDIFF(month, 0, @CurrentDate), 0),103),103)
	set @MTDTo = convert(datetime,convert(varchar(10),@CurrentDate,103),103)

	set @YTDFrom = convert(datetime,'01/01/' + convert(varchar(4),YEAR(@CurrentDate)),103)
	set @YTDTo = convert(datetime,convert(varchar(10),@CurrentDate,103),103)


	DECLARE @TodayPax INT
	DECLARE @WTDPax INT
	DECLARE @MTDPax INT
	DECLARE @YTDPax INT

	--select @TDDate,@WTDFrom,@WTDTo,@MTDFrom,@MTDTo,@YTDFrom,@YTDTo



	SELECT @TodayPax = SUM(pax) FROM Categlog_vrV2..BillHeader WHERE CONVERT(DATE,OrderDate) = CONVERT(DATE,@TDDate) AND PropertyId IN (SELECT ID FROM #tempProperties)
	SELECT @WTDPax = SUM(pax) FROM Categlog_vrV2..BillHeader WHERE CONVERT(DATE,OrderDate) BETWEEN CONVERT(DATE,@WTDFrom) AND CONVERT(DATE,@WTDTo) AND PropertyId IN (SELECT ID FROM #tempProperties)
	SELECT @MTDPax = SUM(pax) FROM Categlog_vrV2..BillHeader WHERE CONVERT(DATE,OrderDate) BETWEEN CONVERT(DATE,@MTDFrom) AND CONVERT(DATE,@MTDTo) AND PropertyId IN (SELECT ID FROM #tempProperties)
	SELECT @YTDPax = SUM(pax) FROM Categlog_vrV2..BillHeader WHERE CONVERT(DATE,OrderDate) BETWEEN CONVERT(DATE,@YTDFrom) AND CONVERT(DATE,@YTDTo) AND PropertyId IN (SELECT ID FROM #tempProperties)


	INSERT INTO #tempMain
	(id	,title,card_icon,display_order,position_id,size,[type],[value],value_percentage,value_percentage_icon,value_percentage_color,text_color,bg_color,header_font_size,sub_font_size,perc_font_size,subDataShow,bgIconShow,mainIconShow,text_col_size,text_align)
	VALUES(1,'Today Pax','ri-hotel-line',1,1,3,'box',ISNULL(@TodayPax,0),'','','text-success','text-light','bg-info',16,12,10,'none','none','flex',9,'left')

	INSERT INTO #tempSubDetail
	(main_id,title,display_order,[value],size)
	VALUES (1,'',0,'',6)

	INSERT INTO #tempSubDetail
	(main_id,title,display_order,[value],size)
	VALUES (1,'',0,'',6)

	

	INSERT INTO #tempMain
	(id	,title,card_icon,display_order,position_id,size,[type],[value],value_percentage,value_percentage_icon,value_percentage_color,text_color,bg_color,header_font_size,sub_font_size,perc_font_size,subDataShow,bgIconShow,mainIconShow,text_col_size,text_align)
	VALUES(2,'WTD Pax','ri-community-line',1,1,3,'box',ISNULL(@WTDPax,0),'','','','text-light','bg-success',16,12,10,'none','none','flex',9,'left')

	INSERT INTO #tempSubDetail
	(main_id,title,display_order,[value],size)
	VALUES (2,'',0,'',6)

	INSERT INTO #tempSubDetail
	(main_id,title,display_order,[value],size)
	VALUES (2,'',0,'',6)

	
	

	INSERT INTO #tempMain
	(id	,title,card_icon,display_order,position_id,size,[type],[value],value_percentage,value_percentage_icon,value_percentage_color,text_color,bg_color,header_font_size,sub_font_size,perc_font_size,subDataShow,bgIconShow,mainIconShow,text_col_size,text_align)
	VALUES(3,'MTD Pax','ri-user-line',1,1,3,'box',ISNULL(@MTDPax,0),'','','text-success','text-dark','bg-warning',16,12,10,'none','none','flex',9,'left')

	INSERT INTO #tempSubDetail
	(main_id,title,display_order,[value],size)
	VALUES (3,'',0,'',6)

	INSERT INTO #tempSubDetail
	(main_id,title,display_order,[value],size)
	VALUES (3,'',0,'',6)

	

	INSERT INTO #tempMain
	(id	,title,card_icon,display_order,position_id,size,[type],[value],value_percentage,value_percentage_icon,value_percentage_color,text_color,bg_color,header_font_size,sub_font_size,perc_font_size,subDataShow,bgIconShow,mainIconShow,text_col_size,text_align)
	VALUES(4,'YTD Pax','ri-group-line',1,1,3,'box',ISNULL(@YTDPax,0),'','','text-success','text-light','bg-danger',16,12,10,'none','none','flex',9,'left')

	INSERT INTO #tempSubDetail
	(main_id,title,display_order,[value],size)
	VALUES (4,'',0,'',6)

	INSERT INTO #tempSubDetail
	(main_id,title,display_order,[value],size)
	VALUES (4,'',0,'',6)



	SELECT
	(
		SELECT 
		[value] AS [value]
		,title AS title					
		,card_icon	 AS card_icon			
		,display_order AS display_order			
		,position_id AS position_id				
		,size	AS size				
		,[type]	 AS [type]			
		,value_percentage AS value_percentage		
		,value_percentage_icon	AS value_percentage_icon
		,value_percentage_color AS value_percentage_color	
		,text_color	 AS text_color			
		,bg_color AS bg_color				
		,header_font_size	AS header_font_size	
		,sub_font_size	AS sub_font_size		
		,perc_font_size AS perc_font_size	
		,subDataShow	AS	subDataShow			
		,bgIconShow		AS	bgIconShow		
		,mainIconShow	AS	mainIconShow	
		,text_col_size	AS	text_col_size	
		,text_align		AS	text_align,	
		(		SELECT *
				FROM #tempSubDetail B
				WHERE B.main_id = A.id
				FOR JSON AUTO 
		) AS 'sub_data'
		FROM #tempmain A FOR JSON AUTO
	)AS ResultJson


	DROP TABLE #tempProperties
	DROP TABLE #tempMain
	DROP TABLE #tempSubDetail
	
END

GO

