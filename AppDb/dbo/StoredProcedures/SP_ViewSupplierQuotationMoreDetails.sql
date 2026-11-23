CREATE PROCEDURE [dbo].[SP_ViewSupplierQuotationMoreDetails](@Id INT)

AS
BEGIN

	SELECT DISTINCT SQH.QuotationNo, ValidFrom, ValidTo, C.Name AS CompanyName, S.Name AS SupplierName, SQH.id,SQH.Remarks,
	SQH. LeadTimeExpireDays AS LeadTimeExpire, SH.Name AS ItemName, U.Name AS UnitNme, SQD.UnitPrice, T.Name AS TaxGroupName
	FROM [dbo].[SupplierQuotationHeader] SQH
	INNER JOIN [dbo].[SupplierQuotationDetails] SQD ON SQH.Id = SQD.[QuotationHeaderId]
	INNER JOIN dbo.Suppliers S ON S.ID = SQH.SupplierId
	INNER JOIN dbo.StockItemHeaders SH ON SH.Id = SQD.ItemId
	INNER JOIN dbo.Units U ON  U.Id = SQD.UnitId
	INNER JOIN QuotationWiseProperties QWP ON QWP.QuotationHeaderId = SQH.Id
	INNER JOIN Companies C On C.CompanyId = QWP.PropertyId AND  QWP.PropertyId = SQD.PropertyId
	left JOIN dbo.TaxGroups T ON T.TaxGroupId = SQD.TaxGroupId
	WHERE SQH.Id = @Id
 	


END

GO

