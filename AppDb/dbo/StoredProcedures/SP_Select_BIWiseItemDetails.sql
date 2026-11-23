-- =============================================
-- Author:		Tharuka Sachintha
-- Create date: 2026-05-25
-- Description:	get BI item deltails

-- SP_Select_BIWiseItemDetails 11742

-- =============================================
CREATE   PROCEDURE [dbo].[SP_Select_BIWiseItemDetails]
	@StocktransactionHeaderID INT
AS
    BEGIN

		declare @Rate Decimal(18,2),@CurrencyId INT,
		        @SupplierID INT, @TemperatureApplicableAttributeId INT, @CompanyId INT, @LocationId INT, @OldTax BIT

		select @CompanyId = PropertyID, @LocationId = InvoiceLocationID
        
        from StockTransactionHeaders where Id=@StocktransactionHeaderID 


        SELECT @SupplierID = SupplierID
        FROM Companies
        WHERE CompanyID = @CompanyId

        SELECT @CurrencyId= CurrencyID
        FROM Suppliers
        WHERE ID = @SupplierID

		select top(1) @Rate=ExchangeRate from Currency where CurrencyId=@CurrencyId order by Date desc

		SELECT @TemperatureApplicableAttributeId = [TemperatureApplicableAttributeId] FROM CompanySettings WHERE CompanyId = @CompanyId

		
		--SELECT @SupplierID

          SELECT  
                BQ.BalanceQty ApprovedQuantity ,   --added by Isuru 2026-09-18 balance, not invoiced qty
                BQ.BalanceQty ReceivedQuantity ,   --added by Isuru 2026-09-18
                1 PoDetailID ,
                SD.Id ,
                StkIH.Name AS 'ItemText' ,
                SD.TxnUnitID AS 'UnitId' ,
                BQ.BalanceQty ApprovedQuantity ,   --added by Isuru 2026-09-18
                BQ.BalanceQty ReceivedQuantity ,   --added by Isuru 2026-09-18
                BQ.BalanceQty AS 'BalanceQuantity' ,  --added by Isuru 2026-09-18
                SD.SellingPrice UnitPrice ,
                0 DiscountValue ,
                0 DiscountPercentage ,
                BQ.BalanceQty * SD.SellingPrice AS 'ItemValue' ,   --added by Isuru 2026-09-18
                ( BQ.BalanceQty * SD.SellingPrice ) + ( BQ.BalanceQty * dbo.FN_GetStockItemWiseTotalTax(SD.StockItemID,SD.SellingPrice,@SupplierID,@LocationId) ) AS 'ItemTotal' ,   --added by Isuru 2026-09-18
                SD.Remarks AS 'ItemWiseRemarks' ,
                BQ.BalanceQty * dbo.FN_GetStockItemWiseTotalTax(SD.StockItemID,SD.SellingPrice,@SupplierID,@LocationId) AS 'TaxAmount' ,   --added by Isuru 2026-09-18
                0 AS 'IsDiscountGiven' ,
                StkIH.Id AS StockItemHeadersID ,
                SD.StockItemID ,
                StkIH.[IsExpiryDateApplicable],
				@CurrencyId CurrencyId,
				CM.Symbol,
				SU.IsForeign,
				ExchangeRate =@Rate,
				IWA.IsActive AS IsTemperatureApplicable,
				(SELECT [dbo].[Fun_GetItemLevelAccountName](@CompanyId,@LocationId,StkIH.Id)) AS AccName,
				0 AS TotalAddtionalCharge
				,UN.Name UnitName
                , SD.StockMasterAveragePrice OrginalUnitPrice

        FROM StockTransactionHeaders SH
        INNER JOIN StockTransactionDetails SD ON SH.ID = SD.StockTransactionHeaderID
        INNER JOIN StockItemHeaders StkIH ON StkIH.ID = SD.StockItemID
        INNER JOIN SupplierWiseItemDetails SW ON SW.StockItemID = SD.StockItemID AND SW.LocationId = SH.InvoiceLocationID AND SW.SupplierID = @SupplierID
        INNER JOIN Suppliers SU ON SU.ID = SW.SupplierID
        LEFT JOIN CurrencyMasters as CM ON CM.Id=SU.CurrencyId
        LEFT JOIN StockItemWiseAttributes IWA ON STKIH.Id = IWA.StockItemHeaderID 
	    AND IWA.StockItemAttributeID = @TemperatureApplicableAttributeId AND IWA.IsActive = 1
        INNER JOIN Units UN ON UN.Id = SD.TxnUnitID
        --added by Isuru 2026-09-18 what is still receivable on the invoice line: invoiced qty less what a 'BR' has already returned
        CROSS APPLY ( SELECT CAST(SD.Quantity - ISNULL(SD.ReturnQuantity, 0) AS DECIMAL(18, 6)) AS BalanceQty ) BQ
        WHERE SH.ID = @StocktransactionHeaderID
        AND SH.TransactionType = 'BI'
        --added by Isuru 2026-09-18 skip lines with nothing left, the same way SP_Select_POWiseItemDetails skips fully received PO lines
        AND BQ.BalanceQty > 0


    --    FROM    dbo.PoDetails PD
    --            INNER JOIN StockItemHeaders StkIH ON PD.StockItemID = StkIH.Id
    --            INNER JOIN PoHeaders PH ON PH.Id = PD.PoHeaderID
				--INNER JOIN Suppliers Sp ON PH.SupplierID =Sp.ID
				--LEFT JOIN CurrencyMasters as CM ON CM.Id=PH.CurrencyId
				--LEFT JOIN StockItemWiseAttributes IWA ON STKIH.Id = IWA.StockItemHeaderID 
				--AND IWA.StockItemAttributeID = @TemperatureApplicableAttributeId AND IWA.IsActive = 1
				--INNER JOIN Units UN ON UN.Id = PD.UnitID
    --    WHERE   PD.PoHeaderID = @PoHeaderID
    --            AND PH.DocumentStatus = 'P'
    --            AND ( PD.ApprovedQuantity - PD.ReceivedQuantity ) > 0


				---Added 9/3/2022-------------
				SELECT '' Name, 0 ChargeAmount ,0 AdditionalChargeID
				
				---Added 9/3/2022-------------

    END

GO

