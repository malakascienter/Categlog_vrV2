-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- [dbo].[SP_GetAllOrderDetailsByIdForInv] 2
CREATE PROCEDURE [dbo].[SP_GetAllOrderDetailsByIdForInv] @OrderHeaderID INT
AS
    BEGIN 


	DECLARE @Cost DECIMAL(27,7)
        SELECT  OD.ProductID AS ItemID ,
                OD.OrderQty - OD.BalanceQty AS QTY ,
                OD.UnitID ,
                OD.SellingPrice AS UnitPrice ,
                OD.OrderQty - OD.BalanceQty AS DelievryQTY ,
                0 AS ReturnQty ,
                0 AS AveragePrice ,
             --   0 AS CostPrice 
			 CASE WHEN OD.IsPercentageForDiscount=1
			 THEN OD.SellingPrice-((OD.ItemDiscountRate/100)*OD.SellingPrice)
			 ELSE 
			 OD.SellingPrice-OD.ItemDiscountValue
			 END AS CostPrice              
			 ,
                SD.TaxGroupID ,
                --OD.TaxValue ,
				dbo.FN_GetStockItemWiseTotalTax(OD.ProductID ,(CASE WHEN OD.IsPercentageForDiscount=1
			 THEN OD.SellingPrice-((OD.ItemDiscountRate/100)*OD.SellingPrice)
			 ELSE 
			 OD.SellingPrice-OD.ItemDiscountValue
			 END)) AS TaxValue,
                0 AS SerialNo ,
                OD.ItemDiscountValue ,
                OD.ItemDiscountRate AS ItemDiscountPercentage ,
                OD.ItemDiscountRate ,
                0 AS WarrentyPeriod ,
                OD.IsPercentageForDiscount ,
                SD.Name AS ItemName ,
                U.Name AS UnitName ,
                0 AS MasterUnitID ,
                STD.QuantityInHand AS AvailableQTY ,
                SD.IsPriceEditable AS PriceEditable ,
                STD.SellingPrice AS TaxInclusivePrice ,
                CASE WHEN OD.IsPercentageForDiscount=1
			 THEN ((OD.ItemDiscountRate/100)*STD.SellingPrice)
			 ELSE 
			OD.ItemDiscountValue
			 END AS TaxCostPrice ,
                0 AS TaxForSellPrice
        FROM    dbo.OrderDetails OD
                INNER JOIN dbo.StockItemHeaders SD ON SD.Id = OD.ProductID
                INNER JOIN dbo.Units U ON U.Id = OD.UnitID
                INNER JOIN dbo.OrderHeaders OH ON OH.Id = OD.OrderHeaderID
				INNER JOIN dbo.StockItemDetails STD ON STD.StockItemHeaderID=OD.ProductID AND STD.LocationID=OH.LocationID
        WHERE   OD.OrderHeaderID = @OrderHeaderID
                AND OH.IsCancel = 0
                AND OH.IsApproved = 1
                AND OD.BalanceQty < OD.OrderQty
 
 
--SELECT *,SD.Name AS productName,U.Name AS UnitName FROM dbo.OrderDetails OD INNER JOIN dbo.StockItemHeaders SD ON SD.Id=OD.ProductID INNER JOIN
--dbo.Units U ON U.Id=OD.UnitID WHERE OD.OrderHeaderID=@OrderHeaderID 
--SELECT * FROM dbo.OrderDetails where OrderHeaderID=2021 
    END

GO

