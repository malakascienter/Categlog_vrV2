
-- =============================================
-- Author:		Chiraj
-- Create date: 2020-10-7
-- Description:	Food Costing 
-- =============================================
--Report_FoodCosting_HotelRes '12/11/2020',1003,2
CREATE PROCEDURE [dbo].[Report_FoodCosting_HotelRes] 
	@FromDate	VARCHAR(10),
	@CostingId INT,
	@PropertyId INT
AS
BEGIN
SET NOCOUNT ON;
	SET DATEFORMAT DMY
	DECLARE @CurrMonthFirstDate DATETIME
	DECLARE @ReportDate DATETIME
	DECLARE @CurrYearFirstDate DATETIME
	
	SET @CurrMonthFirstDate=(SELECT DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0))
	--SET @ReportDate =(select GETDATE()-1) --modify 2020-11-12 requset by aruna
	SET @ReportDate =CONVERT(datetime,@FromDate,103)-1
	
	SET @CurrYearFirstDate= (select convert (date,DATEADD(YEAR,DATEDIFF(YEAR,0,GETDATE()),0)))

	--select @CurrMonthFirstDate,@ReportDate,@CurrYearFirstDate

	DECLARE @ServerIP NVARCHAR(MAX)
	DECLARE @DBName NVARCHAR(MAX)
	DECLARE @TableName NVARCHAR(MAX)
	DECLARE @Script NVARCHAR(max)

	SELECT @ServerIP=IPAddress,@DBName=HotelDataBase from [dbo].[Companies] WHERE CompanyID=@PropertyId
	SET @TableName='FolioWisePostingBreakUp'

	CREATE TABLE #TempFolioWisePostinBreakUP
	(
	ReservationHeaderId INT,
	[Date] datetime,
	[ChargeCodeId] INT,
	Name VARCHAR(100),
	PostingTypeId INT,
	[Amount] DECIMAL(18,4)

	)
	SET @Script='
	insert into #TempFolioWisePostinBreakUP(ReservationHeaderId,Date,ChargeCodeId,Name,PostingTypeId,Amount)
	SELECT 
	   F.[ReservationHeaderId]    
      ,F.[Date]
      ,F.[ChargeCodeId]
	  ,C.[Name]
      ,F.[PostingTypeId]
      ,F.[Amount] 	   
	   FROM['+@ServerIP+'].'+@DBName+'.dbo.'+@TableName+' AS F
	   INNER JOIN ['+@ServerIP+'].'+@DBName+'.dbo.[ChargeCodes] C ON C.Id=F.ChargeCodeId'
	   
	  
	  	   --AND F.Date between CONVERT(DATE,'+@CurrYearFirstDate+',103)  and CONVERT(DATE,'+@ReportDate+',103)'
	 exec sp_executesql @script
	 

	 CREATE TABLE #TempRevnuToDate(ChargeType VARCHAR(200),ChargeTypeId INT,	TodaySale DECIMAL(18,4))
	 CREATE TABLE #TempRevnuMTD	(ChargeType VARCHAR(200),ChargeTypeId INT,MTDSale DECIMAL(18,4))
	 CREATE TABLE #TempRevnuYTD	(ChargeType VARCHAR(200),ChargeTypeId INT,YTDSale DECIMAL(18,4))
	
	INSERT INTO #TempRevnuToDate(ChargeType,ChargeTypeId,TodaySale)
	SELECT  Name,ChargeCodeId,SUM(Amount)AS ToTal from #TempFolioWisePostinBreakUP 
	where Date= CONVERT(DATE,@ReportDate,103) 
	 and ChargeCodeId in (SELECT ChargeTypeId from CostingTypeWiseChargeCodes where CostingId=@CostingId)
	group by ChargeCodeId,Name,ChargeCodeId 
	ORDER BY ChargeCodeId
	
	INSERT INTO #TempRevnuMTD(ChargeType,ChargeTypeId,MTDSale)
	SELECT Name,ChargeCodeId,SUM(Amount)AS ToTalMTD from #TempFolioWisePostinBreakUP 
	where 
	Date between CONVERT(DATE,@CurrMonthFirstDate,103)  and CONVERT(DATE,@ReportDate,103) 
	and ChargeCodeId in (SELECT ChargeTypeId from CostingTypeWiseChargeCodes where CostingId=@CostingId)
	group by ChargeCodeId,Name,ChargeCodeId 
	ORDER BY ChargeCodeId
	
	INSERT INTO #TempRevnuYTD(ChargeType,ChargeTypeId,YTDSale)
	SELECT Name,ChargeCodeId,SUM(Amount) AS ToTalYTD from #TempFolioWisePostinBreakUP 
	where Date between CONVERT(DATE,@CurrYearFirstDate,103)  and CONVERT(DATE,@ReportDate,103) 
	and ChargeCodeId in (SELECT ChargeTypeId from CostingTypeWiseChargeCodes where CostingId=@CostingId)
	group by ChargeCodeId,Name,ChargeCodeId 
	ORDER BY ChargeCodeId	
	
	--select * from #TempRevnuYTD
	--select * from #TempRevnuMTD
	--select * from #TempRevnuToDate

	SELECT Y.ChargeType,Y.ChargeTypeId,ISNULL(T.TodaySale,0.00)AS ToDateSale,IsNULL(M.MTDSale,0.00) MTD,IsNull(Y.YTDSale,0.00)YTD
	FROM  #TempRevnuYTD AS Y 
	LEFT JOIN #TempRevnuMTD AS M ON Y.ChargeTypeId=M.ChargeTypeId
	LEFT JOIN #TempRevnuToDate AS T ON T.ChargeTypeId=Y.ChargeTypeId
	--INNER JOIN CostingTypeWiseChargeCodes AS CTC ON CTC.ChargeTypeId=Y.ChargeTypeId--
	--WHERE T.ChargeTypeId IN (SELECT ChargeTypeId from CostingTypeWiseChargeCodes where CostingId=@CostingId)-- select charge type s form seting table 
  
END

GO

