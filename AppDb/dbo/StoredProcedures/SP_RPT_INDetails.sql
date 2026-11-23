CREATE PROCEDURE [dbo].[SP_RPT_INDetails](@CompanyId INT = 1, @LocationId INT = -999, @FromDate DATE, @ToDate DATE,@TxnType CHAR(2))
 
AS
BEGIN
	IF(@TxnType = 'IN')	
	BEGIN
		SELECT  D.Name AS DeptName, SC.Name AS SubCat, SUM(SD.Quantity * SD.UnitPrice) AS Value,'Issue Note' AS Txn
		FROM STocktransactionheaders  SH 
		INNER JOIN StockTransactionDetails SD ON SD.StockTransactionHeaderID = SH.Id
		INNER JOIN Departments D ON D.Id = SH.DepartmentID
		INNER JOIN StockItemHeaders H ON H.Id = SD.StockItemID
		INNER JOIN Categories C ON C. Id = H.CategoryID
		INNER JOIN SubCategories SC ON SC. Id = H.SubCategoryID
		WHERE SH.transactiontype = 'IN' AND SH.PropertyID = @CompanyId
		AND SH.LocationId = CASE WHEN @LocationId = -999 THEN SH.LocationId ELSE @LocationId END
		AND SH.TransactionDate BETWEEN @FromDate AND @ToDate  
		GROUP BY   D.Name  ,SC.Name
	END
	IF(@TxnType = 'TO')	
	BEGIN
		SELECT  L.Name AS DeptName, SC.Name AS SubCat, SUM(SD.Quantity * SD.UnitPrice) AS Value,'Transfer Note' AS Txn
		FROM STocktransactionheaders  SH 
		INNER JOIN StockTransactionDetails SD ON SD.StockTransactionHeaderID = SH.Id
		INNER JOIN Locations L ON L.Id = SH.TransferLocationID
		INNER JOIN StockItemHeaders H ON H.Id = SD.StockItemID
		INNER JOIN Categories C ON C. Id = H.CategoryID
		INNER JOIN SubCategories SC ON SC. Id = H.SubCategoryID
		WHERE SH.transactiontype = 'TO' AND SH.PropertyID = @CompanyId
		AND SH.LocationId = CASE WHEN @LocationId = -999 THEN SH.LocationId ELSE @LocationId END
		AND SH.TransactionDate BETWEEN @FromDate AND @ToDate  
		GROUP BY    L.Name  ,SC.Name
	END
	IF(@TxnType = 'DN')	
	BEGIN
		SELECT  L.Name AS DeptName, SC.Name AS SubCat, SUM(SD.Quantity * SD.UnitPrice) AS Value,'Damage Note' AS Txn
		FROM STocktransactionheaders  SH 
		INNER JOIN StockTransactionDetails SD ON SD.StockTransactionHeaderID = SH.Id
		INNER JOIN Locations L ON L.Id = SH.LocationID
		INNER JOIN StockItemHeaders H ON H.Id = SD.StockItemID
		INNER JOIN Categories C ON C. Id = H.CategoryID
		INNER JOIN SubCategories SC ON SC. Id = H.SubCategoryID
		WHERE SH.transactiontype = 'DN' AND SH.PropertyID = @CompanyId
		AND SH.LocationId = CASE WHEN @LocationId = -999 THEN SH.LocationId ELSE @LocationId END
		AND SH.TransactionDate BETWEEN @FromDate AND @ToDate  
		GROUP BY  L.Name  ,SC.Name
	END

END

GO

