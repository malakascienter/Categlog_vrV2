
-- [SalesSummaryBoxes_Dashboard]  '11/12/2018','001'
CREATE PROCEDURE [dbo].[SalesSummaryBoxes_OutletWise_Dashboard] 
(
	@PropertyId INT,
	@Outlet VARCHAR(3),
	@CurrDate DATE,
	@UserId INT = 0
)
AS
BEGIN

	set dateformat dmy

	--SET @Date = '2018-01-09'
	--SET @Outlet = '001'

	IF OBJECT_ID(N'tempdb..#TempLocation') IS NOT NULL
	BEGIN
	DROP TABLE #TempLocation
	END

	SELECT L.*
	INTO #TempLocation
	FROM Location_Ref L INNER JOIN UserWiseOutlet UO ON L.code = UO.OutletCode AND L.PropertyId = UO.PropertyId
	WHERE L.PropertyId = @PropertyId AND UO.PropertyId = @PropertyId AND UO.UserId = @UserId

	
	DECLARE @YearToDateStart DATETIME
	DECLARE @MonthToDateStart DATETIME
	DECLARE @WeekToDateStart DATETIME
	DECLARE @CurrentDateStart DATETIME	

	SELECT @YearToDateStart = DATEADD(year, DATEDIFF(year, 0, CONVERT(DATE,@CurrDate)), 0)
	SELECT @MonthToDateStart = DATEADD(month, DATEDIFF(month, 0,CONVERT(DATE,@CurrDate)), 0)
	SELECT @WeekToDateStart = DATEADD(WEEK, DATEDIFF(WEEK, 0, CONVERT(DATE,@CurrDate)), 0)

	SELECT ((Subtotal + ServiceCharge+ TaxVal1+ TaxVal2+ TaxVal3+ TaxVal4) ) AS Sales, OrderDate,L.code AS OutletCode,l.description as OutletName
	INTO #tempSummaryTbl
	FROM BillHeader BH INNER JOIN #TempLocation L ON BH.PropertyId = L.PropertyId AND BH.Outlet = L.code
	WHERE BH.PropertyId=@PropertyId AND (CONVERT(DATE,BH.OrderDate) BETWEEN @YearToDateStart AND GETDATE()) --AND BH.Outlet = @Outlet

	SELECT (SELECT SUM(Sales) FROM #tempSummaryTbl WHERE CONVERT(DATE,OrderDate) = CONVERT(DATE,GETDATE())) AS 'Value', 'CD' AS 'Name', CONCAT(CONVERT(NVARCHAR(150),GETDATE(),103),' ',CONVERT(NVARCHAR(150),GETDATE(),24)) AS 'AsAtDateTime'
	UNION
	SELECT (SELECT SUM(Sales) FROM #tempSummaryTbl WHERE CONVERT(DATE,OrderDate) BETWEEN @WeekToDateStart AND GETDATE()) AS 'Value', 'WTD' AS 'Name', CONVERT(NVARCHAR(10),@WeekToDateStart,103)+' - Today' AS 'AsAtDateTime'
	UNION
	SELECT (SELECT SUM(Sales) FROM #tempSummaryTbl WHERE CONVERT(DATE,OrderDate) BETWEEN @MonthToDateStart AND GETDATE()) AS 'Value', 'MTD' AS 'Name', CONVERT(NVARCHAR(10),@MonthToDateStart,103)+' - Today' AS 'AsAtDateTime'
	UNION
	SELECT (SELECT SUM(Sales) FROM #tempSummaryTbl) AS 'Value', 'YTD' AS 'Name', CONVERT(NVARCHAR(10), @YearToDateStart,103)+' - Today' AS 'AsAtDateTime'
	
	DROP TABLE #tempSummaryTbl

END

GO

