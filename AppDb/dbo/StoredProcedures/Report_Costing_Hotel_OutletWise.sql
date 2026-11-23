--Report_Costing_Hotel_OutletWise '02/05/2022' ,15,'60'
CREATE PROCEDURE [dbo].[Report_Costing_Hotel_OutletWise] 
	@FromDate	VARCHAR(10),
	@PropertyId INT,
	@CostingId INT
AS
BEGIN
SET NOCOUNT ON;
	SET DATEFORMAT DMY
	DECLARE @CurrMonthFirstDate DATETIME
	DECLARE @ReportDate DATETIME
	
	SET @CurrMonthFirstDate=(SELECT DATEADD(m, DATEDIFF(m, 0, CONVERT(datetime,@FromDate,103)), 0))
	SET @ReportDate =CONVERT(datetime,@FromDate,103)

	IF OBJECT_ID(N'tempdb..#Temp') IS NOT NULL
	BEGIN
	DROP TABLE #Temp
	END
	IF OBJECT_ID(N'tempdb..#TempRevnuToDate') IS NOT NULL
	BEGIN
	DROP TABLE #TempRevnuToDate
	END
	IF OBJECT_ID(N'tempdb..#TempRevnuMTD') IS NOT NULL
	BEGIN
	DROP TABLE #TempRevnuMTD
	END
	IF OBJECT_ID(N'tempdb..#TempFolioWisePostinBreakUP') IS NOT NULL
	BEGIN
	DROP TABLE #TempFolioWisePostinBreakUP
	END
	

	CREATE TABLE #TempFolioWisePostinBreakUP
	(
	ReservationHeaderId INT,
	[Date] datetime,
	[ChargeCodeId] INT,
	Name VARCHAR(100),
	PostingTypeId INT,
	[Amount] DECIMAL(18,4)

	)

	insert into #TempFolioWisePostinBreakUP(ReservationHeaderId,Date,ChargeCodeId,Name,PostingTypeId,Amount)
	SELECT 
	   F.[ReservationHeaderId]    
      ,F.[Date]
      ,F.[ChargeCodeId]
	  ,C.[Name]
      ,F.[PostingTypeId]
      ,F.[Amount] 	   
	   FROM HotelResWeb.dbo.FolioWisePostingBreakUp AS F
	   INNER JOIN HotelResWeb.dbo.[ChargeCodes] C ON C.Id=F.ChargeCodeId AND F.PropertyId =@PropertyId 
	   WHERE F.[Date] BETWEEN @CurrMonthFirstDate AND @ReportDate

	 CREATE TABLE #TempRevnuToDate(ChargeType VARCHAR(200),ChargeTypeId INT,	TodaySale DECIMAL(18,4))
	 CREATE TABLE #TempRevnuMTD	(ChargeType VARCHAR(200),ChargeTypeId INT,MTDSale DECIMAL(18,4))
	 CREATE TABLE #Temp	(ChargeType VARCHAR(200),TDS DECIMAL(18,4),MTD DECIMAL(18,4))
	
	INSERT INTO #TempRevnuToDate(ChargeType,ChargeTypeId,TodaySale)
	SELECT  Name,ChargeCodeId,SUM(Amount)AS ToTal from #TempFolioWisePostinBreakUP 
	where Date= CONVERT(DATE,@ReportDate,103) 
	AND ChargeCodeId in (SELECT ChargeTypeId from CostingTypeWiseChargeCodes where CostingId=@CostingId)
	group by ChargeCodeId,Name,ChargeCodeId 
	ORDER BY ChargeCodeId
	
	INSERT INTO #TempRevnuMTD(ChargeType,ChargeTypeId,MTDSale)
	SELECT Name,ChargeCodeId,SUM(Amount)AS ToTalMTD from #TempFolioWisePostinBreakUP 
	where 
	Date between CONVERT(DATE,@CurrMonthFirstDate,103)  and CONVERT(DATE,@ReportDate,103) 	
	and ChargeCodeId in (SELECT ChargeTypeId from CostingTypeWiseChargeCodes where CostingId=@CostingId)
	group by ChargeCodeId,Name,ChargeCodeId 
	ORDER BY ChargeCodeId
	

	INSERT INTO #Temp(ChargeType,TDS,MTD)
	SELECT 
	Y.ChargeType,
	0,
	Y.MTDSale
	FROM #TempRevnuMTD AS Y 
	

	INSERT INTO #Temp(ChargeType,TDS,MTD)
	SELECT 
	Y.ChargeType,	
	Y.TodaySale,
	0
	FROM #TempRevnuToDate AS Y 


	SELECT ChargeType,IsNULL(SUM(MTD),0.00) MTD,IsNULL(SUM(TDS),0.00) TDS
	FROM #Temp
	GROUP BY ChargeType


	IF OBJECT_ID(N'tempdb..#Temp') IS NOT NULL
	BEGIN
	DROP TABLE #Temp
	END
	IF OBJECT_ID(N'tempdb..#TempRevnuToDate') IS NOT NULL
	BEGIN
	DROP TABLE #TempRevnuToDate
	END
	IF OBJECT_ID(N'tempdb..#TempRevnuMTD') IS NOT NULL
	BEGIN
	DROP TABLE #TempRevnuMTD
	END
	IF OBJECT_ID(N'tempdb..#TempFolioWisePostinBreakUP') IS NOT NULL
	BEGIN
	DROP TABLE #TempFolioWisePostinBreakUP
	END
	


END

GO

