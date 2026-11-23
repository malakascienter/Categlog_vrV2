--EXEC POS_GetInvoiceDetailsForCancel 'SC00000632'
CREATE PROCEDURE [dbo].[POS_GetInvoiceDetailsForCancel] 
    @InvoiceNo VARCHAR(MAX)
    WITH RECOMPILE
AS
    BEGIN
		SELECT IH.ID,IH.InvoiceNo,IH.GrossTotal,IH.NetTotal,(IH.ItemDiscountTotal+IH.TotalDiscount) TotalDiscount,
		ID.ItemID,ID.QTY,(ID.UnitPrice+ID.TaxValue) Value,ID.ItemDiscountValue,
		SIH.Name,SIH.StockItemCode
		FROM dbo.InvoiceHeaders IH
		INNER JOIN dbo.InvoiceDetails ID ON IH.ID = ID.InvoiceHeaderID
		INNER JOIN dbo.StockItemHeaders SIH ON SIH.Id = ID.ItemID
		INNER JOIN dbo.StockItemDetails SID ON SID.StockItemHeaderID = SIH.Id AND SID.LocationID = IH.Location
		WHERE IH.InvoiceNo = @InvoiceNo 
    END

GO

