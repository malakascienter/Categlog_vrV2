--EXEC [dbo].[SP_GetInvoiceDetailsForReCall]  'SC00000871' 
CREATE PROCEDURE [dbo].[SP_GetInvoiceDetailsForReCall]
    @InvoiceNo VARCHAR(MAX)
    WITH RECOMPILE
AS
    BEGIN

	SELECT ROW_NUMBER() OVER(ORDER BY INH.ID) AS 'LineNo',IND.ID,SIH.Name,IND.AveragePrice,IND.UnitID MasterUnitID,((IND.UnitPrice*IND.DelievryQTY)+(IND.TaxValue)-(IND.ItemDiscountValue+IND.ItemDiscountPercentage)) SellingPrice,0 IsPriceEditable,SIH.StockItemCode,SIH.Barcode,(IND.DelievryQTY - IND.ReturnQty) Quantity,(((IND.UnitPrice*IND.DelievryQTY)+(IND.TaxValue)-(IND.ItemDiscountValue+IND.ItemDiscountPercentage))*(IND.DelievryQTY - IND.ReturnQty)) Value,IND.IsPercentageForDiscount,IND.ItemDiscountValue,IND.ItemDiscountPercentage,IND.ItemDiscountType
	FROM dbo.InvoiceHeaders INH
	INNER JOIN dbo.InvoiceDetails IND ON INH.ID = IND.InvoiceHeaderID
	INNER JOIN dbo.StockItemHeaders SIH ON SIH.Id = IND.ItemID 
	WHERE INH.InvoiceNo = @InvoiceNo

    END

GO

