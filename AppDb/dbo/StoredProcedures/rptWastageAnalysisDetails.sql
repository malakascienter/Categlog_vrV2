-- =============================================
-- Author:		Nivesh
-- Create date: 2025-01-03
-- Description:	Wastage Analysis Report
-- =============================================
-- rptWastageAnalysis '1,8',-999,1,1, '2024-01-01','2025-01-30'

CREATE PROCEDURE [dbo].[rptWastageAnalysisDetails] 
	@LocationID VARCHAR(MAX),@CategoryId INT, @PeriodTypeID INT, @FromDate DATE, @ToDate DATE 
AS
BEGIN

	SET NOCOUNT ON;

	CREATE TABLE #LocationListTable(
		Id INT,
		LocationName VARCHAR(100)
	)

	INSERT INTO #LocationListTable 
 	SELECT Id, Name LocationName 
	FROM Locations
	WHERE Id IN (SELECT * FROM string_split(@LocationID,N','))

	 SELECT   CASE @PeriodTypeID  ------TIME INTERVAL
		WHEN 1 THEN CONVERT(VARCHAR, sh.TransactionDate, 103)
		WHEN 2 THEN CONCAT(CONVERT(VARCHAR,DATENAME(WEEK,sh.TransactionDate)),' WEEK ',CONVERT(VARCHAR,DATENAME(YEAR,sh.TransactionDate))	)
		WHEN 3 THEN CONCAT(CONVERT(VARCHAR,DATENAME(MONTH,sh.TransactionDate)),' - ',CONVERT(VARCHAR,DATENAME(YEAR,sh.TransactionDate))	)
		WHEN 4 THEN CONVERT(VARCHAR,DATENAME(YEAR,sh.TransactionDate))		
	END AS 'PERIOD', sd.unitprice*sd.quantity AS 'VALUE'
	 ,sh.DocumentNo, sh.TransactionDate, l.Name AS location, sh.ReferenceNo as InvoiceNo,si.StockItemCode, si.Name AS ItemName, ct.Name AS Category, sd.Remarks, sd.UnitPrice, sd.Quantity,sd.unitprice*sd.quantity AS total, u.Name AS unit, CASE WHEN Sd.DiscountPercentage>0 AND  sd.DiscountValue =0 THEN (UnitPrice *Sd.DiscountPercentage /100) * Quantity ELSE sd.DiscountValue END DiscountValue , St.TaxAmount,Companies.Name, Companies.Address1 AS compAdd1, Companies.Address2 AS compAdd2, Companies.Address3 AS compAdd3, Companies.Telephone1 AS compTel1, Companies.Email AS compEmail, Companies.WebAddress, CE.UserName AS Preaperduser,CONCAT( si.name, CASE WHEN (SELECT Temperature FROM StockItemWiseTemperature WHERE StockItemID=sd.StockItemID AND LocationID=sh.LocationID AND TransactionID=sd.StockTransactionHeaderID AND TransactionType='SR')IS NOT NULL THEN CONCAT (' Temp: ' , (SELECT Temperature FROM StockItemWiseTemperature WHERE StockItemID=sd.StockItemID AND LocationID=sh.LocationID AND TransactionID=sd.StockTransactionHeaderID AND TransactionType='SR') ) ELSE '' END,CASE WHEN (SELECT CONVERT(CHAR(10),EXPDate,103) FROM StockItemWiseEXPDateIns WHERE StockItemID=sd.StockItemID AND LocationID=sh.LocationID AND TransactionID=sd.StockTransactionHeaderID AND TransactionType='SR') IS NOT NULL THEN CONCAT(' Exp:',(SELECT CONVERT(CHAR(10),EXPDate,103) FROM StockItemWiseEXPDateIns WHERE StockItemID=sd.StockItemID AND LocationID=sh.LocationID AND TransactionID=sd.StockTransactionHeaderID AND TransactionType='SR')) ELSE '' END) AS ItemNameN
		FROM  StockTransactionHeaders AS sh 
			INNER JOIN StockTransactionDetails AS sd WITH (NOLOCK) ON sh.Id = sd.StockTransactionHeaderID 
			INNER JOIN Locations AS l WITH (NOLOCK) ON sh.LocationID = l.Id  
			INNER JOIN Units AS u WITH (NOLOCK) ON sd.TxnUnitID = u.Id
			INNER JOIN StockItemHeaders AS si WITH (NOLOCK) ON sd.StockItemID = si.Id 
			INNER JOIN Categories AS ct WITH (NOLOCK) ON si.CategoryID = ct.Id 
			INNER JOIN Companies WITH (NOLOCK) ON l.CompanyID = Companies.CompanyID
			INNER JOIN #LocationListTable LL on LL.Id = sh.LocationID
			LEFT OUTER JOIN StockTransactionwiseTaxes AS st WITH (NOLOCK) ON sd.Id = st.StockTransactionDetailID AND sd.StockItemID = st.StockItemID
			INNER JOIN CentralUsers CE WITH (NOLOCK) ON CE.Id = SH.UserProfileID
		WHERE	 sh.TransactionType='DN'AND sh.TransactionDate BETWEEN @FromDate AND @ToDate
		AND si.CategoryID = CASE WHEN @CategoryId = -999 THEN si.CategoryID ELSE @CategoryId END

		DROP TABLE #LocationListTable

END

GO

