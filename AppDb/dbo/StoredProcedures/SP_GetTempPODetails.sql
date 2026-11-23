-- =============================================
-- Author:		Nivesh
-- Create date: 2024-10-07
-- Description:	GetTempPODetails
-- =============================================
-- SP_GetTempPODetails 7

CREATE PROCEDURE [dbo].[SP_GetTempPODetails]
	@HeaderID INT
AS
BEGIN

	SET NOCOUNT ON;

	BEGIN TRY 

		with temptable as (
		SELECT 
		pot.Id,pot.PoHeaderID,pot.PoDetailID,pot.StockItemID,
		(isnull((select sd.PurchaseUnitID from SupplierWiseItemDetails sd where sd.StockItemID = pot.StockItemID and sd.LocationID = pht.LocationID and sd.CompanyId = pht.PropertyID
		and sd.SupplierID = pht.SupplierID),pot.UnitID)) UnitID,
		(isnull((select sd.CostPrice from SupplierWiseItemDetails sd where sd.StockItemID = pot.StockItemID and sd.LocationID = pht.LocationID and sd.CompanyId = pht.PropertyID
		and sd.SupplierID = pht.SupplierID),pot.UnitPrice)) UnitPrice
		,pot.RequestedQuantity,pot.ApprovedQuantity,pot.ReceivedQuantity,
		pot.Remarks,pot.DiscountValue,pot.DiscountPercentage,pot.IPAddress,pot.CreatedUserID,pot.LastModUserID,pot.CreatedDate,pot.LastModDate,
		pot.TaxValue,pot.TBPHeaderId,pot.StockName,pot.UnitName,
		pot.CurrentStock,
		pot.ItemTotal
		 from PoDetails_temp pot 
		 inner join PoHeaders_Temp pht on pot.PoHeaderID = pht.Id
		 INNER JOIN 
		 SupplierWiseItemDetails sd on sd.StockItemID = pot.StockItemID and sd.LocationID = pht.LocationID and sd.CompanyId = pht.PropertyID
		and sd.SupplierID = pht.SupplierID
		 where pot.poheaderid = @HeaderID
		)
		SELECT PHT.*,(SELECT 
		TT.Id,TT.PoHeaderID,TT.PoDetailID,TT.StockItemID,TT.UnitID,TT.UnitPrice,TT.RequestedQuantity,TT.ApprovedQuantity,TT.ReceivedQuantity,TT.Remarks,TT.DiscountValue,TT.DiscountPercentage
		,TT.IPAddress,TT.CreatedUserID,TT.LastModUserID,TT.CreatedDate,TT.LastModDate,
		ISNULL(dbo.FN_GetStockItemWiseTotalTax(
                                                  TT.StockItemID,
                                                  (TT.UnitPrice - TT.DiscountValue - (TT.UnitPrice * (TT.DiscountPercentage / 100)))
                                              ,PHT.SupplierID,pht.LocationID),TT.TaxValue) TaxValue
		
		,TT.TBPHeaderId,TT.StockName,TT.UnitName,TT.CurrentStock,
		((TT.UnitPrice*TT.RequestedQuantity)- (TT.DiscountValue*TT.RequestedQuantity) - ((TT.UnitPrice*TT.RequestedQuantity) * (TT.DiscountPercentage / 100)))
		ItemTotal
		 from temptable TT
		where  TT.poheaderid = @HeaderID
					
					FOR JSON PATH
					) AS DetaListJson, 
					(SELECT POwiseChangesID,POHeaderID,AdditionalChargeID Id,ChargeAmount Amount
					FROM POwiseCharges_Temp WHERE POHeaderID = @HeaderID 
					FOR JSON PATH) AS AdditionalChargesJson 
		FROM PoHeaders_Temp PHT
		WHERE Id = @HeaderID;

	END TRY
	BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000);  
			DECLARE @ErrorSeverity INT;  
			DECLARE @ErrorState INT;  

			SELECT   
			@ErrorMessage = ERROR_MESSAGE(),  
			@ErrorSeverity = ERROR_SEVERITY(),  
			@ErrorState = ERROR_STATE(); 
			RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
	END CATCH;
END

GO

