-- DashboardAPI_Select_Common_MainPage_Box N'[{"Id":1}]'

CREATE PROCEDURE [dbo].[DashboardAPI_Select_Common_MainPage_Box]
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

	SET @CurrentDate = @HotelDate

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


	DECLARE @AverageCovers DECIMAL(18,2)
	DECLARE @AverageCheckSize DECIMAL(18,2)
	DECLARE @FoodCostPercentage DECIMAL(18,2)

	
	IF EXISTS( SELECT 1 FROM Categlog_vrV2..BillHeader WHERE CONVERT(DATE,OrderDate) BETWEEN CONVERT(DATE,@MTDFrom) AND CONVERT(DATE,@MTDTo) AND PropertyId IN (SELECT ID FROM #tempProperties)  )
	BEGIN
	SELECT @AverageCovers =   SUM(Subtotal+TaxVal1+TaxVal2+TaxVal3+TaxVal4+ServiceCharge)/SUM(pax) FROM Categlog_vrV2..BillHeader WHERE CONVERT(DATE,OrderDate) BETWEEN CONVERT(DATE,@TDDate) AND CONVERT(DATE,@TDDate) AND PropertyId IN (SELECT ID FROM #tempProperties) 
	AND (OrderNo NOT IN (
				SELECT	PayTrans.OrderNo
				FROM	PayTrans 
					INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
				WHERE	((PaymentTypes.NoValue = 1) AND PayTrans.OrderDate >= @TDDate
		AND  PayTrans.OrderDate <= @TDDate )
					AND (PayTrans.PayCode <> 'BR')  
					AND PayTrans.PropertyId IN (SELECT ID FROM #tempProperties))
					
				)
	END
	ELSE
	BEGIN
	SET @AverageCovers =  0
	END

	

	
	IF EXISTS( SELECT 1 FROM Categlog_vrV2..BillHeader WHERE CONVERT(DATE,OrderDate) BETWEEN CONVERT(DATE,@MTDFrom) AND CONVERT(DATE,@MTDTo) AND PropertyId IN (SELECT ID FROM #tempProperties)  )
	BEGIN
	SELECT @AverageCheckSize =   SUM(Subtotal+TaxVal1+TaxVal2+TaxVal3+TaxVal4+ServiceCharge)/COUNT(*) FROM Categlog_vrV2..BillHeader WHERE CONVERT(DATE,OrderDate) BETWEEN CONVERT(DATE,@TDDate) AND CONVERT(DATE,@TDDate) AND PropertyId IN (SELECT ID FROM #tempProperties)  
	AND (OrderNo NOT IN (
				SELECT	PayTrans.OrderNo
				FROM	PayTrans 
					INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
				WHERE	((PaymentTypes.NoValue = 1) AND PayTrans.OrderDate >= @TDDate
		AND  PayTrans.OrderDate <= @TDDate )
					AND (PayTrans.PayCode <> 'BR')  
					AND PayTrans.PropertyId IN (SELECT ID FROM #tempProperties))
					
				)
	
	END
	ELSE
	BEGIN
	SET @AverageCheckSize =  0
	END

	INSERT INTO #tempMain
	(id	,title,card_icon,display_order,position_id,size,[type],[value],value_percentage,value_percentage_icon,value_percentage_color,text_color,bg_color,header_font_size,sub_font_size,perc_font_size,subDataShow,bgIconShow,mainIconShow,text_col_size,text_align)
	VALUES(1,'Average covers','ri-bill-fill',1,1,3,'box',ISNULL(@AverageCovers,0),'','','text-success','text-light','bg-info',16,12,10,'none','none','flex',9,'left')

	INSERT INTO #tempSubDetail
	(main_id,title,display_order,[value],size)
	VALUES (1,'',0,'',6)

	INSERT INTO #tempSubDetail
	(main_id,title,display_order,[value],size)
	VALUES (1,'',0,'',6)


	
	INSERT INTO #tempMain
	(id	,title,card_icon,display_order,position_id,size,[type],[value],value_percentage,value_percentage_icon,value_percentage_color,text_color,bg_color,header_font_size,sub_font_size,perc_font_size,subDataShow,bgIconShow,mainIconShow,text_col_size,text_align)
	VALUES(4,'Average check size','ri-bill-line',1,1,3,'box',ISNULL(@AverageCheckSize,0),'','','text-success','text-light','bg-danger',16,12,10,'none','none','flex',9,'left')

	INSERT INTO #tempSubDetail
	(main_id,title,display_order,[value],size)
	VALUES (4,'',0,'',6)

	INSERT INTO #tempSubDetail
	(main_id,title,display_order,[value],size)
	VALUES (4,'',0,'',6)



	DECLARE @AveragePrice DECIMAL(18,2)
	DECLARE @SellingPrice DECIMAL(18,2)
	SELECT @AveragePrice =   SUM(Quantity*AveragePrice) FROM OutletKitchenIssues WHERE CONVERT(DATE,TxnDate) BETWEEN CONVERT(DATE,@MTDFrom) AND CONVERT(DATE,@MTDTo) AND PropertyID IN (SELECT ID FROM #tempProperties)
	SELECT @SellingPrice =   SUM(Qty*Rate) FROM Categlog_vrV2..BillTrans 
	WHERE CONVERT(DATE,OrderDate) BETWEEN CONVERT(DATE,@MTDFrom) AND CONVERT(DATE,@MTDTo) AND PropertyId IN (SELECT ID FROM #tempProperties)  
	AND MainMenuCode IN (SELECT MainMenuCode FROM OutletKitchenIssues WHERE CONVERT(DATE,TxnDate) BETWEEN CONVERT(DATE,@MTDFrom) AND CONVERT(DATE,@MTDTo) AND PropertyID IN (SELECT ID FROM #tempProperties))


	IF( ISNULL(@SellingPrice,0) = 0 )
	BEGIN

		SET @FoodCostPercentage = 0

	END
	ELSE
	BEGIN

		SET @FoodCostPercentage = @AveragePrice/@SellingPrice*100

	END


	INSERT INTO #tempMain
	(id	,title,card_icon,display_order,position_id,size,[type],[value],value_percentage,value_percentage_icon,value_percentage_color,text_color,bg_color,header_font_size,sub_font_size,perc_font_size,subDataShow,bgIconShow,mainIconShow,text_col_size,text_align)
	VALUES(4,'Food cost percentage','ri-survey-line',1,1,3,'box',ISNULL(63.02,0),'','','text-success','text-light','bg-warning',16,12,10,'none','none','flex',9,'left')
	--@FoodCostPercentage
	INSERT INTO #tempSubDetail
	(main_id,title,display_order,[value],size)
	VALUES (4,'',0,'',6)

	INSERT INTO #tempSubDetail
	(main_id,title,display_order,[value],size)
	VALUES (4,'',0,'',6)



	DECLARE @TotalCostPrice DECIMAL(18,2)
	DECLARE @TotalRev DECIMAL(18,2)
	DECLARE @TotalProfite DECIMAL(18,2)
	DECLARE @GrossProfitMargin DECIMAL(18,2)

	SELECT @TotalCostPrice =   SUM(Quantity*AveragePrice) FROM OutletKitchenIssues WHERE CONVERT(DATE,TxnDate) BETWEEN CONVERT(DATE,@MTDFrom) AND CONVERT(DATE,@MTDTo) AND PropertyID IN (SELECT ID FROM #tempProperties)
	SELECT @TotalRev =   SUM(Qty*Rate) FROM Categlog_vrV2..BillTrans WHERE CONVERT(DATE,OrderDate) BETWEEN CONVERT(DATE,@MTDFrom) AND CONVERT(DATE,@MTDTo) AND PropertyId IN (SELECT ID FROM #tempProperties)  
	SET @TotalProfite = @TotalRev - @TotalCostPrice

	IF( ISNULL(@SellingPrice,0) = 0 )
	BEGIN

		SET @GrossProfitMargin = 0

	END
	ELSE
	BEGIN

		SET @GrossProfitMargin = @TotalProfite/@TotalRev*100

	END



	
	INSERT INTO #tempMain
	(id	,title,card_icon,display_order,position_id,size,[type],[value],value_percentage,value_percentage_icon,value_percentage_color,text_color,bg_color,header_font_size,sub_font_size,perc_font_size,subDataShow,bgIconShow,mainIconShow,text_col_size,text_align)
	VALUES(4,'Gross profit margin','ri-survey-line',1,1,3,'box',ISNULL(683.00,0),'','','text-success','text-light','bg-success',16,12,10,'none','none','flex',9,'left')
	--@GrossProfitMargin
	INSERT INTO #tempSubDetail
	(main_id,title,display_order,[value],size)
	VALUES (4,'',0,'',6)

	INSERT INTO #tempSubDetail
	(main_id,title,display_order,[value],size)
	VALUES (4,'',0,'',6)


	DECLARE @TotalRevRevPASH DECIMAL(18,2)
	DECLARE @TotalPax DECIMAL(18,2)
	DECLARE @TotalRevPASH DECIMAL(18,2)

	SELECT @TotalPax =   SUM(pax) FROM BillHeader WHERE CONVERT(DATE,OrderDate) BETWEEN CONVERT(DATE,@TDDate) AND CONVERT(DATE,@TDDate) AND PropertyID IN (SELECT ID FROM #tempProperties)
		AND (OrderNo NOT IN (
				SELECT	PayTrans.OrderNo
				FROM	PayTrans 
					INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
				WHERE	((PaymentTypes.NoValue = 1) AND PayTrans.OrderDate >= @TDDate
		AND  PayTrans.OrderDate <= @TDDate )
					AND (PayTrans.PayCode <> 'BR')  
					AND PayTrans.PropertyId IN (SELECT ID FROM #tempProperties))
					
				)
	SELECT @TotalRevRevPASH =   SUM(Subtotal+TaxVal1+TaxVal2+TaxVal3+TaxVal4+ServiceCharge) FROM Categlog_vrV2..BillHeader WHERE CONVERT(DATE,OrderDate) BETWEEN CONVERT(DATE,@TDDate) AND CONVERT(DATE,@TDDate) AND PropertyId IN (SELECT ID FROM #tempProperties)  
	AND (OrderNo NOT IN (
				SELECT	PayTrans.OrderNo
				FROM	PayTrans 
					INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
				WHERE	((PaymentTypes.NoValue = 1) AND PayTrans.OrderDate >= @TDDate
		AND  PayTrans.OrderDate <= @TDDate )
					AND (PayTrans.PayCode <> 'BR')  
					AND PayTrans.PropertyId IN (SELECT ID FROM #tempProperties))
					
				)

	IF( ISNULL(@TotalPax,0) = 0 )
	BEGIN

		SET @TotalRevPASH = 0

	END
	ELSE
	BEGIN

		SET @TotalRevPASH = @TotalRevRevPASH/(@TotalPax*11)

	END


	INSERT INTO #tempMain
	(id	,title,card_icon,display_order,position_id,size,[type],[value],value_percentage,value_percentage_icon,value_percentage_color,text_color,bg_color,header_font_size,sub_font_size,perc_font_size,subDataShow,bgIconShow,mainIconShow,text_col_size,text_align)
	VALUES(4,'RevPASH','ri-survey-line',1,1,3,'box',ISNULL(@TotalRevPASH,0),'','','text-success','text-light','bg-success',16,12,10,'none','none','flex',9,'left')

	INSERT INTO #tempSubDetail
	(main_id,title,display_order,[value],size)
	VALUES (4,'',0,'',6)

	INSERT INTO #tempSubDetail
	(main_id,title,display_order,[value],size)
	VALUES (4,'',0,'',6)

	

	--INSERT INTO #tempMain
	--(id	,title,card_icon,display_order,position_id,size,[type],[value],value_percentage,value_percentage_icon,value_percentage_color,text_color,bg_color,header_font_size,sub_font_size,perc_font_size,subDataShow,bgIconShow,mainIconShow,text_col_size,text_align)
	--VALUES(2,'Take Out','ri-shopping-bag-3-line',1,1,6,'box',ISNULL(@TakeOut,0),'','','','text-light','bg-success',16,12,10,'none','none','flex',9,'left')

	--INSERT INTO #tempSubDetail
	--(main_id,title,display_order,[value],size)
	--VALUES (2,'',0,'',6)

	--INSERT INTO #tempSubDetail
	--(main_id,title,display_order,[value],size)
	--VALUES (2,'',0,'',6)

	
	

	--INSERT INTO #tempMain
	--(id	,title,card_icon,display_order,position_id,size,[type],[value],value_percentage,value_percentage_icon,value_percentage_color,text_color,bg_color,header_font_size,sub_font_size,perc_font_size,subDataShow,bgIconShow,mainIconShow,text_col_size,text_align)
	--VALUES(3,'MTD Sales','ri-user-line',1,1,3,'box',ISNULL(@MTDSales,0),'','','text-success','text-dark','bg-warning',16,12,10,'none','none','flex',9,'left')

	--INSERT INTO #tempSubDetail
	--(main_id,title,display_order,[value],size)
	--VALUES (3,'',0,'',6)

	--INSERT INTO #tempSubDetail
	--(main_id,title,display_order,[value],size)
	--VALUES (3,'',0,'',6)

	

	--INSERT INTO #tempMain
	--(id	,title,card_icon,display_order,position_id,size,[type],[value],value_percentage,value_percentage_icon,value_percentage_color,text_color,bg_color,header_font_size,sub_font_size,perc_font_size,subDataShow,bgIconShow,mainIconShow,text_col_size,text_align)
	--VALUES(4,'YTD Sales','ri-group-line',1,1,3,'box',ISNULL(@YTDSales,0),'','','text-success','text-light','bg-danger',16,12,10,'none','none','flex',9,'left')

	--INSERT INTO #tempSubDetail
	--(main_id,title,display_order,[value],size)
	--VALUES (4,'',0,'',6)

	--INSERT INTO #tempSubDetail
	--(main_id,title,display_order,[value],size)
	--VALUES (4,'',0,'',6)



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

