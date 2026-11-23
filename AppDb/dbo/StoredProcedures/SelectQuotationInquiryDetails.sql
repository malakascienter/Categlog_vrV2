
create Procedure [dbo].[SelectQuotationInquiryDetails](@QuotationID INT )
AS

SELECT H.Name ItemName, U.Name UnitName, UnitPrice, t.Name Tax
FROM SupplierQuotationDetails QD
INNER JOIN StockItemHeaders H on H.Id= QD.ItemId
INNER JOIN Units U ON U.ID = QD.UnitId
INNER JOIN TaxGroups T on t.TaxGroupId = QD.TaxGroupId
WHERE QD.QuotationHeaderId =@QuotationID

GO

