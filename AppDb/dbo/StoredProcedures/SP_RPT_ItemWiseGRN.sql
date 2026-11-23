-- =============================================
-- Author:		<Thilini Fernando>
-- Create date: <28/02/2022> 
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_ItemWiseGRN](@CompanyId INT, @LocationId INT ,@FromDate DATE,@ToDate DATE)
AS
BEGIN
	SELECT h.name as Item,sh.DocumentNo,sh.TransactionDate,sh.ReferenceNo  AS InvoiceNo,sh.InvoiceDate, S.Name AS Supplier,
	U.Name AS UOM, sd.Quantity,sd.UnitPrice, sd.Quantity * sd.UnitPrice AS Value, l.Name AS Location
	FROM StockTransactionDetails sd
	INNER JOIN StockTransactionHeaders sh ON sd.StockTransactionHeaderID = sh.Id
	INNER JOIN StockItemHeaders h ON h.Id = sd.StockItemID  
	INNER JOIN Locations l ON l.Id = sh.LocationID
	INNER JOIN Suppliers S On S.ID = sh.SupplierID
	INNER JOIN Units U ON U.Id = sd.TxnUnitID
	LEFT JOIN  StockTransactionwiseTaxes ST ON ST.StockTransactionDetailID = sd.Id
	WHERE sh.PropertyID = CASE WHEN @CompanyId = -999 THEN sh.PropertyID ELSE @CompanyId END  
	AND sh.LocationID = CASE WHEN @LocationId = -999 THEN sh.LocationID ELSE @LocationId END
	AND sh.TransactionType = 'GR' AND sh.TransactionDate BETWEEN @FromDate AND @ToDate

END

GO

