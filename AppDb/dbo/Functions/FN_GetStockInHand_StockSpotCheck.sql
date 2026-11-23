
/**
-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2024-09-9
-- Description:	Calculate Qty in Hand with Recipe issues
-- =============================================

**/
CREATE FUNCTION  [dbo].[FN_GetStockInHand_StockSpotCheck](@propertyId int, @LocationID int , @StockItemId int)
returns  DECIMAL(18,6) 
begin

declare @QuantityInHand DECIMAL(18,6), @RecipeIssueQy DECIMAL(18,8) =0,@DirectIssueQy DECIMAL(18,8) = 0,@RetailIssueQy DECIMAL(18,8) = 0

-- 1. Recipe Consumption
SELECT  @RecipeIssueQy = SUM(RD.Qty * IB.Qty * BT.Qty)
FROM	RecipeDetails AS RD INNER JOIN RecipeHeader AS RH ON RD.RecipeCode = RH.RecipeCode AND RD.PropertyId = RH.PropertyId 
INNER JOIN ItemBreakDown AS IB ON RH.RecipeCode = IB.RecipeCode AND IB.PropertyId = RH.PropertyId 
INNER JOIN BillTrans AS BT ON IB.MainMenuCode = BT.MainMenuCode AND BT.PropertyId = IB.PropertyId 
INNER JOIN Location_Ref AS LR ON BT.Outlet = LR.code AND LR.PropertyId = BT.PropertyId 
INNER JOIN StockItemDetails AS SD ON RD.StockItemCode = SD.StockItemHeaderID AND SD.PropertyID = BT.PropertyId AND SD.LocationID = LR.StockLocationID
INNER JOIN STOCKITEMHEADERS SH ON SH.ID = SD.StockItemHeaderID
WHERE	BT.PropertyId = CASE WHEN @PropertyID = -999 THEN BT.PropertyId ELSE @PropertyID END 
AND CONVERT(DATE, BT.OrderDate) =  CONVERT(DATE,GETDATE()) 
AND SH.ID = @StockItemId AND LR.StockLocationID = @LocationID

-- 2. One-to-One Mapping Consumption
SELECT @DirectIssueQy = SUM(BT.Qty)
FROM BillTrans BT
INNER JOIN MainMenu MM 
    ON BT.MainMenuCode = MM.ItemCode AND BT.PropertyId = MM.PropertyId
INNER JOIN Location_Ref LR 
    ON BT.Outlet = LR.code AND LR.PropertyId = BT.PropertyId 
INNER JOIN StockItemDetails SD 
    ON MM.StockItemId = SD.StockItemHeaderID 
    AND MM.PropertyID = SD.PropertyId 
    AND SD.LocationID = LR.StockLocationID
INNER JOIN STOCKITEMHEADERS SH 
    ON SH.ID = SD.StockItemHeaderID
WHERE BT.PropertyId = CASE WHEN @PropertyID = -999 THEN BT.PropertyId ELSE @PropertyID END
AND CONVERT(DATE, BT.OrderDate) = CONVERT(DATE, GETDATE())
AND SH.ID = @StockItemId
AND LR.StockLocationID = @LocationID


-- 3. Retail / POS Consumption
SELECT @RetailIssueQy = ISNULL(SUM(Quantity),0) - ISNULL(SUM(ReturnQuantity),0)
FROM POS_InvoiceDetail PD
INNER JOIN StockItemHeaders SH 
    ON PD.ItemID = SH.Id
INNER JOIN Locations LO 
    ON LO.Id = PD.LocationID 
WHERE PD.BusinessDate = CONVERT(DATE, GETDATE())
AND LO.ID = CASE WHEN @LocationID = -999 THEN LO.Id ELSE @LocationID END
AND SH.Id = CASE WHEN @StockItemID = -999 THEN SH.Id ELSE @StockItemID END
AND PD.CompanyID = CASE WHEN @PropertyID = -999 THEN PD.CompanyID ELSE @PropertyID END

-- Final Total Consumption
SET @RecipeIssueQy = ISNULL(@RecipeIssueQy,0)  + ISNULL(@DirectIssueQy,0)  + ISNULL(@RetailIssueQy,0)

select @QuantityInHand= QuantityInHand - ISNULL(@RecipeIssueQy,0)
from dbo.StockItemDetails
where LocationID =@locationID and StockItemId=@StockItemId

return isnull(@QuantityInHand,0)

end

GO

