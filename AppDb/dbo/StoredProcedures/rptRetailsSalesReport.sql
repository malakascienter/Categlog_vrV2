-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2026-02-06
-- Description:	Loading Sales Report Print Copy
-- =============================================
--	EXEC rptRetailsSalesReport 554383,35,2

create PROCEDURE [dbo].[rptRetailsSalesReport]
	@InvoiceHeaderID int,
	@LocationID	 int,
	@PropertyId INT
AS
BEGIN
	
	SET NOCOUNT ON;


	SELECT LO.Name Location,PH.BusinessDate OrderDate,ph.InsertDateTime,ph.InvoiceNo,PD.ItemID,SH.StockItemCode,SH.Name ItemName,PD.SellingPrice,PD.Quantity,
	CASE WHEN PD.DiscountValue=0 THEN  SUM(PD.Quantity) * PD.SellingPrice * PD.DiscountPercentage /100 ELSE  PD.DiscountValue END Discount
	--,PH.ChargeAmount
	,(pd.SellingPrice * pd.Quantity) Value
	,PH.NetAmount
	FROM POS_InvoiceHeader PH
	INNER JOIN POS_InvoiceDetail PD ON PH.InvHeaderID = PD.InvHeaderID AND PH.LocationID = PD.LocationID AND PH.CompanyID = PD.CompanyID
	INNER JOIN Locations LO ON LO.ID = PH.LocationID
	INNER JOIN StockItemHeaders SH ON SH.Id = PD.ItemID
	WHERE CONCAT(PH.InvHeaderID,PH.LocationID) = @InvoiceHeaderID
	--AND PH.CompanyID = @PropertyId
	--AND PH.LocationID = @LocationID
	GROUP BY LO.Name,PH.BusinessDate,ph.InsertDateTime,ph.InvoiceNo,PD.ItemID,SH.StockItemCode,SH.Name,PD.SellingPrice,PD.Quantity
    ,PD.SellingPrice,PD.DiscountValue,PD.DiscountPercentage--,PH.ChargeAmount
	,PH.NetAmount
END

GO

