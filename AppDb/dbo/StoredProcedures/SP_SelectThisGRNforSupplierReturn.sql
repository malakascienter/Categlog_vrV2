-- [dbo].[SP_SelectThisGRNforSupplierReturn] 9121

CREATE procedure [dbo].[SP_SelectThisGRNforSupplierReturn]   
(
	@StockTransactionHeaderID int
)

as

SELECT    c.TxnUnitID as UnitID
		, d.LocationID
		, d.SupplierID
		, c.Id AS StockTransactionDetailID
		, c.StockTransactionHeaderID
		, b.Name
		, u.Name AS unit
		, c.ReturnQuantity
		, c.Quantity
		, c.UnitPrice
		, c.StockItemID
		, b.StockItemCode
		, 0 as Qty
		, I.QuantityInHand
		, SUM(ISNULL (t.TaxAmount,0) / Quantity) UnitTax
		, CASE WHEN C.DiscountValue >0 THEN C.DiscountValue / c.Quantity ELSE C.UnitPrice * c.DiscountPercentage /100 END ItemDiscount
		--, c .DiscountPercentage  -- commented by Isuru 2025-07-23 for both value and precentage saving issue in SRN
		 ,0 DiscountPercentage 
		,b.IsExpiryDateApplicable
 FROM         StockTransactionDetails AS c INNER JOIN Units AS u ON c.TxnUnitID = u.Id 
											 INNER JOIN StockTransactionHeaders AS d ON c.StockTransactionHeaderID = d.Id
											 INNER JOIN StockItemHeaders AS b ON c.StockItemID = b.Id
											 INNER JOIN StockItemDetails AS I ON I.StockItemHeaderID = B.Id AND D.LocationID = I.LocationID --AND I.PropertyID = D.PropertyID
LEFT OUTER  join StockTransactionwiseTaxes t on c.Id = t.StockTransactionDetailID
WHERE     c.StockTransactionHeaderID=@StockTransactionHeaderID AND c.quantity >0
GROUP BY  c.TxnUnitID,d.LocationID,d.SupplierID,c.Id,
c.StockTransactionHeaderID, b.Name, u.Name, c.ReturnQuantity, c.Quantity, 
c.UnitPrice, c.StockItemID, b.StockItemCode, I.QuantityInHand, C.DiscountValue, c.DiscountPercentage,b.IsExpiryDateApplicable


--select * from StockTransactionwiseTaxes
--where StockTransactionDetailID = 20

GO

