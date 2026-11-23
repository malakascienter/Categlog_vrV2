-- exec [dbo].[SP_RPT_TotalInvoiceReport] 1,-999,'2023-01-01','2023-05-15'
CREATE PROCEDURE  [dbo].[SP_RPT_TotalInvoiceReport] (@CompanyId INT = 1, @LocationId INT = -999,@DateFrom DATE='2018-08-10', @DateTo DATE='2018-09-30')
AS
BEGIN
	SELECT   SH.TransactionDate,C.Name AS CatName,SIH.StockItemCode, SIH.name AS Item, SD.Quantity,CU.Name AS Currency,SD.UnitPrice AS GRNPrice,
	'' AS InvoicePrice, SD.Quantity * SI.CostPrice AS GRNValue, '' AS InvoiceValue, PH.PoNo, SH.DocumentNo,S.Code AS VendorCode, S.Name AS VendorName 
	,SH.InvoiceDate
	FROM StockTransactionHeaders SH
	INNER JOIN StockTransactionDetails SD ON SH.Id = SD.StockTransactionHeaderID
	INNER JOIN StockItemHeaders SIH ON SIH.Id = SD.StockItemID
	INNER JOIN Categories C ON C.ID = SIH.CategoryID
	INNER JOIN Suppliers  S On S.Id = SH.SupplierID
	INNER JOIN CurrencyMasters CU ON CU.Id = S.CurrencyID
	INNER JOIN SupplierWiseItemDetails SI ON SI.SupplierID = SH.SupplierID AND Si.CompanyId = SH.PropertyID
	AND SI.LocationId= SH.LocationID AND Si.StockItemID = SD.StockItemID
	LEFT JOIN POHeaders PH ON PH.Id = SH.ReferenceID
	WHERE SH.PropertyID = @CompanyId 
	AND SH.LocationID = CASE WHEN @LocationId = -999 THEN SH.LocationID  ELSE @LocationId END
	AND Sh.TransactionType = 'GR'
	AND SH.TransactionDate BETWEEN @DateFrom AND @dateTo
	ORDER BY SH.TransactionDate ASC
	END

GO

