-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2026-08-21
-- Description:	Load Property Wise Retails Sales

-- [dbo].[SP_EmailReport_RetailSales] 
-- =============================================
CREATE   PROCEDURE [dbo].[SP_EmailReport_RetailSales] 
AS
BEGIN
SET DATEFORMAT DMY
	DECLARE @ReportDate DATETIME, @MonthFirstDate DATETIME, @YearFirstDate DATETIME
	SET @ReportDate = CONVERT(DATE,(SELECT DATEADD(DAY,-1,CONVERT(DATE,GETDATE()))))
	--SET @ReportDate = CONVERT(DATE,'02/03/2020')
	SET @MonthFirstDate = CONVERT(DATE,(SELECT DATEADD(S,1,DATEADD(mm, DATEDIFF(m,0,@ReportDate),0))))


IF( GETDATE() < CONVERT(DATE,(SELECT dateadd(year, (CONVERT(VARCHAR(10),(SELECT YEAR(GETDATE()))) - year(FinancialYearFromDate)), FinancialYearFromDate) FROM BackendSettings)) )
BEGIN


	 SET @YearFirstDate =  DATEADD(YEAR,-1,CONVERT(DATE,(SELECT dateadd(year, (CONVERT(VARCHAR(10),(SELECT YEAR(GETDATE()))) - year(FinancialYearFromDate)), FinancialYearFromDate) FROM BackendSettings)))

END
ELSE
BEGIN

	SET @YearFirstDate =  CONVERT(DATE,(SELECT dateadd(year, (CONVERT(VARCHAR(10),(SELECT YEAR(GETDATE()))) - year(FinancialYearFromDate)), FinancialYearFromDate) FROM BackendSettings))-- CONVERT(DATE,(SELECT FinancialYearFromDate FROM FBSettings))
 
END

	PRINT @MonthFirstDate
	PRINT @ReportDate
	PRINT @YearFirstDate
	SET NOCOUNT ON;


SELECT Brand, ReportDate,LineOrder,Restaurant,
	SUM(ToDayBillCount) AS ToDayBillCount,
	CASE WHEN IsFC = 1 THEN '$' + FORMAT(SUM(ToDaySales),'#,##') ELSE FORMAT(SUM(ToDaySales),'#,##') END AS ToDaySales,
	CASE WHEN SUM(ToDayBillCount) = 0 THEN '0.00' ELSE FORMAT(SUM(ToDaySales)/SUM(ToDayBillCount),'#,##') END AS ToDayATV,

	SUM(MonthToDateBillCount) AS MonthToDateBillCount,
	CASE WHEN IsFC = 1 THEN '$' + FORMAT(SUM(MonthToDateSales),'#,##') ELSE FORMAT(SUM(MonthToDateSales),'#,##') END AS MonthToDateSales,
	CASE WHEN SUM(MonthToDateBillCount) = 0 THEN '0.00' ELSE FORMAT(SUM(MonthToDateSales)/SUM(MonthToDateBillCount),'#,##') END AS MonthToDateATV,

	SUM(YearToDateBillCount) AS YearToDateBillCount,
	CASE WHEN IsFC = 1 THEN '$' + FORMAT(SUM(YearToDateSales),'#,##') ELSE FORMAT(SUM(YearToDateSales),'#,##') END AS YearToDateSales,
	CASE WHEN SUM(YearToDateBillCount) = 0 THEN '0.00' ELSE FORMAT(SUM(YearToDateSales)/SUM(YearToDateBillCount),'#,##') END AS YearToDateATV

	--Burger King-------------------------------------------------------------------------------------------------------------------------------
	FROM(
	SELECT	BH.CompanyID AS Brand,@ReportDate AS ReportDate,0 AS LineOrder,C.Name AS Restaurant, 
			COUNT(BH.InvoiceNo) AS ToDayBillCount
			,ISNULL(SUM(BH.NetAmount),0) AS ToDaySales,
			0 AS MonthToDateBillCount, 0.00 AS MonthToDateSales ,0 AS IsFC, 
			0 AS YearToDateBillCount, 0.00 AS YearToDateSales
	FROM	POS_InvoiceHeader	AS BH 
	INNER JOIN LOCATIONS AS LR on LR.Id = BH.LocationID  AND BH.CompanyID = LR.CompanyID
	INNER JOIN Companies C ON BH.CompanyID = C.CompanyID
	WHERE	BH.BusinessDate = @ReportDate 
	GROUP BY BH.CompanyID,C.Name
	UNION ALL
	SELECT	BH.CompanyID AS Brand, @ReportDate AS ReportDate,0 AS LineOrder,C.Name AS Restaurant, 
			0 AS ToDayBillCount, 0 AS ToDaySales,
			COUNT(BH.InvoiceNo) AS MonthToDateBillCount
			,ISNULL(SUM(BH.NetAmount),0)  AS MonthToDateSales , 0 AS IsFC,
			0 AS YearToDateBillCount, 0.00 AS YearToDateSales
	FROM	POS_InvoiceHeader	AS BH 
	INNER JOIN LOCATIONS AS LR on LR.Id = BH.LocationID  AND BH.CompanyID = LR.CompanyID
	INNER JOIN Companies C ON BH.CompanyID = C.CompanyID
	WHERE	BH.BusinessDate BETWEEN @MonthFirstDate AND @ReportDate 
	GROUP BY BH.CompanyID,C.Name
	UNION ALL
	SELECT	BH.CompanyID AS Brand, @ReportDate AS ReportDate,0 AS LineOrder,C.Name AS Restaurant, 
			0 AS ToDayBillCount, 0 AS ToDaySales,
			0 AS MonthToDateBillCount, 0.00 AS MonthToDateSales , 0 AS IsFC,
			COUNT(BH.InvoiceNo) AS YearToDateBillCount
			,ISNULL(SUM(BH.NetAmount),0)  AS YearToDateSales
	FROM	POS_InvoiceHeader	AS BH 
	INNER JOIN LOCATIONS AS LR on LR.Id = BH.LocationID  AND BH.CompanyID = LR.CompanyID
	INNER JOIN Companies C ON BH.CompanyID = C.CompanyID
	WHERE	BH.BusinessDate BETWEEN @YearFirstDate AND @ReportDate 
	GROUP BY BH.CompanyID,C.Name

	
	)A
	--------------------------------------------------------------------------------------------------------------------------------------------
	GROUP BY Brand, ReportDate,LineOrder,Restaurant,IsFC
	ORDER BY LineOrder
END

GO

