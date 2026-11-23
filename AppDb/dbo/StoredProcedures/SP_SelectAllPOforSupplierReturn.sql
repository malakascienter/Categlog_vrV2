CREATE procedure [dbo].[SP_SelectAllPOforSupplierReturn] 
(
	@PropertyID int
)

as

SELECT     a.Id, a.DocumentNo, a.TransactionDate, a.LocationID, a.ReferenceNo, a.SupplierID, b.Name, Locations.Name AS LocationName
			,'0' as Qty,' ' as Remarks
FROM    StockTransactionHeaders AS a INNER JOIN Suppliers AS b ON a.SupplierID = b.ID INNER JOIN
StockTransactionDetails AS c ON a.Id = c.StockTransactionHeaderID INNER JOIN
 Locations ON a.LocationID = Locations.Id AND a.PropertyID = Locations.CompanyID
WHERE a.PropertyID=@PropertyID and(a.TransactionType = 'GR') AND (c.ReturnQuantity <> c.Quantity) AND (a.DocumentNo IS NOT NULL)
GROUP BY a.Id, a.DocumentNo, a.TransactionDate, a.LocationID, a.ReferenceNo, a.SupplierID, b.Name, Locations.Name ORDER BY a.DocumentNo DESC

GO

