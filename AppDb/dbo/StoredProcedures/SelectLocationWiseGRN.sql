CREATE procedure [dbo].[SelectLocationWiseGRN] 
(
	@PropertyID int, @LocationID INT, @SupplierId INT=0
)
--  [dbo].[SelectLocationWiseGRN] 1,30,628
as

DECLARE @LimitDocumentLoading BIT, @GRNDocValidDates INT

	SELECT @LimitDocumentLoading =LimitDocumentLoading,@GRNDocValidDates =GRNDocValidDates
	FROM Companies
	WHERE CompanyID = @PropertyID



IF(@LimitDocumentLoading = 1)
BEGIN
SELECT    a.Id, a.DocumentNo, a.TransactionDate, a.LocationID, a.ReferenceNo, a.SupplierID, b.Name, Locations.Name AS LocationName,'0' as Qty,' ' as Remarks
FROM    StockTransactionHeaders AS a INNER JOIN Suppliers AS b ON a.SupplierID = b.ID INNER JOIN
StockTransactionDetails AS c ON a.Id = c.StockTransactionHeaderID INNER JOIN
 Locations ON a.LocationID = Locations.Id AND a.PropertyID = Locations.CompanyID
WHERE a.PropertyID=@PropertyID and(a.TransactionType = 'GR') AND (c.ReturnQuantity <> c.Quantity) AND (a.DocumentNo IS NOT NULL) and a.LocationID = @LocationID AND a.SupplierID=@SupplierId
AND a.CreatedDate >= dateadd(DAY, -@GRNDocValidDates, getdate()) --Added by Isuru 2023-08-28
GROUP BY a.Id, a.DocumentNo, a.TransactionDate, a.LocationID, a.ReferenceNo, a.SupplierID, b.Name, Locations.Name ORDER BY a.DocumentNo DESC
END
ELSE

BEGIN
SELECT    a.Id, a.DocumentNo, a.TransactionDate, a.LocationID, a.ReferenceNo, a.SupplierID, b.Name, Locations.Name AS LocationName
			,'0' as Qty,' ' as Remarks
FROM    StockTransactionHeaders AS a INNER JOIN Suppliers AS b ON a.SupplierID = b.ID INNER JOIN
StockTransactionDetails AS c ON a.Id = c.StockTransactionHeaderID INNER JOIN
 Locations ON a.LocationID = Locations.Id AND a.PropertyID = Locations.CompanyID
WHERE a.PropertyID=@PropertyID and(a.TransactionType = 'GR') AND (c.ReturnQuantity <> c.Quantity) AND (a.DocumentNo IS NOT NULL) and a.LocationID = @LocationID AND a.SupplierID=@SupplierId
GROUP BY a.Id, a.DocumentNo, a.TransactionDate, a.LocationID, a.ReferenceNo, a.SupplierID, b.Name, Locations.Name ORDER BY a.DocumentNo DESC
END

GO

