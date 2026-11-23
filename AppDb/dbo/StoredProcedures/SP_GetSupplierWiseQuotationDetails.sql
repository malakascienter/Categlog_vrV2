-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-05-27
-- Description:	loading supplier wise quotation details
-- [dbo].[SP_GetSupplierWiseQuotationDetails]  9,160
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetSupplierWiseQuotationDetails] 
	@QuotationHeaderID INT,
	@SupplierID INT

AS
BEGIN
SET NOCOUNT ON;

	SELECT SH.StockItemCode,SH.Name ItemName,SU.Name SupplierName,SH.Id ItemID,UN.Name UnitName,rd.ApprovedQuantity Quantity,SQ.Price,
	SQ.TaxAmount, SQ.DiscountValue, SQ.DiscountPercentage, SQ.NetPrice, ISNULL(SQ.ChangeRemark,'') ChangeRemark, (SELECT TOP 1 TG.TaxGroupId,TG.TaxTypeId,ChargeRate,TD.Name FROM TaxGroupDetails  TG
		INNER JOIN TaxDetails TD ON TD.TaxTypeId = TG.TaxTypeId FOR JSON PATH) AS TaxDetails
	FROM SupplierQuotationUploadDetail SQ
	INNER JOIN Suppliers SU ON SU.ID = SQ.SupplierID
	INNER JOIN StockItemHeaders SH ON SH.Id = SQ.ItemID
	INNER JOIN QuotationRequestHeader QH ON QH.Id = SQ.QuotationHeaderID
	INNER JOIN RequestDetails RD ON RD.RequestHeaderID = QH.PurchaseRequestID AND SQ.ItemID = RD.StockItemID
	INNER JOIN Units UN ON UN.Id = RD.UnitID
	WHERE SQ.QuotationHeaderID = @QuotationHeaderID
	AND SQ.SupplierID = @SupplierID
	

   
END

GO

