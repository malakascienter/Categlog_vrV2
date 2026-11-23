-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2024-09-12
-- Description:	Get PO details for PO Recall
-- [dbo].[GetPODetailsForReCall] 8339
-- =============================================
CREATE PROCEDURE [dbo].[GetPODetailsForReCall]
	@HeaderID INT
AS
BEGIN
	SET NOCOUNT ON;

    	SELECT  PH.Id,PD.StockItemID,SH.Name StockName,sh.CategoryID,C.Name CategoryName,PD.UnitID,U.Name UnitName,SD.MasterUnitID,PD.RequestedQuantity Quantity,1 IsActive,SD.AveragePrice UnitPrice,SW.CostPrice,SH.StockItemCode
		,PH.Remarks, PD.Remarks ItemRemarks,ph.SupplierReferenceNo,pd.DiscountValue,pd.DiscountPercentage,SD.QuantityInHand,
		PH.TotalDiscount,PH.TaxTotal,PH.GrossTotal,PH.NetTotal,
		PD.TaxValue Tax,
		ISNULL(PWC.ChargeAmount,0) AdditionalCharge
		FROM PoHeaders PH
		INNER JOIN PoDetails PD ON PH.Id = PD.PoHeaderID
		LEFT JOIN POwiseCharges PWC ON PWC.POHeaderID = PH.Id
		INNER JOIN StockItemHeaders SH ON SH.Id = PD.StockItemID
		INNER JOIN StockItemDetails SD ON SD.StockItemHeaderID = SH.Id AND SD.LocationID = PH.LocationID
		INNER JOIN Categories C ON C.Id = SH.CategoryID
		INNER JOIN Units U ON U.Id = PD.UnitID
		INNER JOIN SupplierWiseItemDetails SW ON SW.StockItemID = PD.StockItemID AND SW.LocationId = PH.LocationID AND PH.SupplierID = SW.SupplierID AND SW.CompanyId = PH.PropertyID
		WHERE PH.Id = @HeaderID 

END

GO

