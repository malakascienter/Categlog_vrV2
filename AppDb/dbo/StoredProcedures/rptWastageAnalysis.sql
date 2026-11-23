-- =============================================
-- Author:		Nivesh
-- Create date: 2025-01-03
-- Description:	Wastage Analysis Report
-- =============================================
-- rptWastageAnalysis '1,8',6,1,1, '2024-01-01','2025-01-30'

-- rptWastageAnalysis '1,8',-999,1,1, '2024-01-01','2025-01-30'

CREATE PROCEDURE [dbo].[rptWastageAnalysis] 
	@LocationID VARCHAR(MAX),@CategoryId INT, @PeriodTypeID INT , @ValueTypeID INT, @FromDate DATE, @ToDate DATE 
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

	;WITH TempTable AS (
	 SELECT   CASE @PeriodTypeID  ------TIME INTERVAL
		WHEN 1 THEN CONVERT(VARCHAR, sh.TransactionDate, 103)
		WHEN 2 THEN CONCAT(CONVERT(VARCHAR,DATENAME(WEEK,sh.TransactionDate)),' WEEK ',CONVERT(VARCHAR,DATENAME(YEAR,sh.TransactionDate))	)
		WHEN 3 THEN CONCAT(CONVERT(VARCHAR,DATENAME(MONTH,sh.TransactionDate)),' - ',CONVERT(VARCHAR,DATENAME(YEAR,sh.TransactionDate))	)
		WHEN 4 THEN CONVERT(VARCHAR,DATENAME(YEAR,sh.TransactionDate))		
	END AS 'PERIOD',
	CASE  
	WHEN @ValueTypeID = 1 THEN sd.unitprice*sd.quantity
	WHEN @ValueTypeID = 2 THEN sd.unitprice*sd.quantity
	WHEN @ValueTypeID = 3 THEN sd.quantity
	END AS 'VALUE'
	 ,l.Name AS location,  ct.Name AS Category,
	 		Companies.Name, Companies.Address1 AS compAdd1, Companies.Address2 AS compAdd2, 
						Companies.Address3 AS compAdd3, Companies.Telephone1 AS compTel1, Companies.Email AS compEmail, Companies.WebAddress, CE.UserName AS Preaperduser
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
	)
	SELECT 
		PERIOD,
		SUM(VALUE) VALUE,
		location,
		Category ,
		Name,
		compAdd1,
		compAdd2,
		compAdd3,
		compTel1,
		compEmail,
		WebAddress,
		Preaperduser
	FROM TempTable
	GROUP BY PERIOD,location,Category,Name,compAdd1,compAdd2,compAdd3,compTel1,compEmail,WebAddress,Preaperduser
	ORDER BY PERIOD
	
	DROP TABLE #LocationListTable

END

GO

