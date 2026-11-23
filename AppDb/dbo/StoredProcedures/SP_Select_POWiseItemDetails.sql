-- exec [dbo].[SP_Select_POWiseItemDetails] 6167

CREATE PROCEDURE [dbo].[SP_Select_POWiseItemDetails] @PoHeaderID INT
AS
    BEGIN

		declare @Rate Decimal(18,2),@CurrencyId INT,
		        @SupplierID INT, @TemperatureApplicableAttributeId INT, @CompanyId INT, @LocationId INT, @OldTax BIT
		

		select @CurrencyId=CurrencyId,@SupplierID=SupplierID,@CompanyId = PropertyID, @LocationId = LocationID from PoHeaders where Id=@PoHeaderID 
		select top(1) @Rate=ExchangeRate from Currency where CurrencyId=@CurrencyId order by Date desc

		SELECT @TemperatureApplicableAttributeId = [TemperatureApplicableAttributeId] FROM CompanySettings WHERE CompanyId = @CompanyId

		IF EXISTS (SELECT 1 FROM POHEADERS WHERE CREATEDDATE < '2023-12-31' AND ID = @PoHeaderID)
		BEGIN
		SET @OldTax = 1
		END
		ELSE
		BEGIN
		SET @OldTax = 0
		END

		--SELECT @SupplierID


        SELECT  PD.ApprovedQuantity ,
                PD.ReceivedQuantity ,
                PD.PoDetailID ,
                PD.Id ,
                StkIH.Name AS 'ItemText' ,
                PD.UnitID AS 'UnitId' ,
                PD.ApprovedQuantity ,
                PD.ReceivedQuantity ,
                ( PD.ApprovedQuantity - PD.ReceivedQuantity ) AS 'BalanceQuantity' ,
                PD.UnitPrice ,
                PD.DiscountValue ,
                PD.DiscountPercentage ,
               ( PD.ApprovedQuantity - PD.ReceivedQuantity ) * PD.UnitPrice AS 'ItemValue' ,
               ( PD.ApprovedQuantity - PD.ReceivedQuantity ) * PD.UnitPrice - (PD.DiscountValue* ( PD.ApprovedQuantity - PD.ReceivedQuantity ))-((PD.UnitPrice
                                                          * PD.DiscountPercentage
                                                          / 100)*(PD.ApprovedQuantity - PD.ReceivedQuantity))+ ( (PD.ApprovedQuantity-PD.ReceivedQuantity)
                  * dbo.FN_GetStockItemWiseTotalTax(PD.StockItemID,
                                                    ( PD.UnitPrice
                                                      - PD.DiscountValue
                                                      - ( (PD.UnitPrice
                                                          * PD.DiscountPercentage
                                                          / 100) ) ),@SupplierID,@LocationId) )   AS 'ItemTotal' ,
                PD.Remarks AS 'ItemWiseRemarks' ,
                CASE WHEN @OldTax = 0
				THEN
                ( (PD.ApprovedQuantity-PD.ReceivedQuantity)
                  * dbo.FN_GetStockItemWiseTotalTax(PD.StockItemID,
                                                    ( PD.UnitPrice
                                                      - PD.DiscountValue
                                                      - ( (PD.UnitPrice
                                                          * PD.DiscountPercentage
                                                          / 100) ) ),@SupplierID,@LocationId) )
				ELSE
				 ( (PD.ApprovedQuantity-PD.ReceivedQuantity)
                  * dbo.FN_GetStockItemWiseTotalTax_ForPOBased(PD.StockItemID,
                                                    ( PD.UnitPrice
                                                      - PD.DiscountValue
                                                      - ( (PD.UnitPrice
                                                          * PD.DiscountPercentage
                                                          / 100) ) ),@SupplierID,@PoHeaderID) )  END AS 'TaxAmount' ,
                CONVERT(BIT, CASE WHEN ISNULL(PD.DiscountValue, 0) > 0 THEN 1
                                  ELSE CASE WHEN ISNULL(PD.DiscountPercentage,
                                                        0) > 0 THEN 1
                                            ELSE 0
                                       END
                             END) AS 'IsDiscountGiven' ,
                StkIH.Id AS StockItemHeadersID ,
                PD.StockItemID ,
                StkIH.[IsExpiryDateApplicable],
				PH.CurrencyId,
				CM.Symbol,
				Sp.IsForeign,
				ExchangeRate =@Rate,
				IWA.IsActive AS IsTemperatureApplicable,
				(SELECT [dbo].[Fun_GetItemLevelAccountName](@CompanyId,@LocationId,StkIH.Id)) AS AccName,
				[dbo].[FN_GetPOwiseAdditionalChargesTotal](@PoHeaderID) AS TotalAddtionalCharge
				,UN.Name UnitName
                , PD.UnitPrice OrginalUnitPrice
        FROM    dbo.PoDetails PD
                INNER JOIN StockItemHeaders StkIH ON PD.StockItemID = StkIH.Id
                INNER JOIN PoHeaders PH ON PH.Id = PD.PoHeaderID
				INNER JOIN Suppliers Sp ON PH.SupplierID =Sp.ID
				LEFT JOIN CurrencyMasters as CM ON CM.Id=PH.CurrencyId
				LEFT JOIN StockItemWiseAttributes IWA ON STKIH.Id = IWA.StockItemHeaderID 
				AND IWA.StockItemAttributeID = @TemperatureApplicableAttributeId AND IWA.IsActive = 1
				INNER JOIN Units UN ON UN.Id = PD.UnitID
        WHERE   PD.PoHeaderID = @PoHeaderID
                AND PH.DocumentStatus = 'P'
                AND ( PD.ApprovedQuantity - PD.ReceivedQuantity ) > 0


				---Added 9/3/2022-------------
				SELECT AD.Name, ST.ChargeAmount ,ST.AdditionalChargeID
				FROM POwiseCharges ST
				INNER JOIN AdditionalChargesDetails AD ON AD.Id = ST.AdditionalChargeID
				WHERE POHeaderID = @PoHeaderID
				---Added 9/3/2022-------------

    END

GO

