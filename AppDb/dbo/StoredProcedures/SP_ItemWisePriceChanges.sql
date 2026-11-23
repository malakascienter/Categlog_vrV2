-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2024-08-07
-- Description:	Select Item Wise Price Change Log
-- [dbo].[SP_ItemWisePriceChanges] 59,4,1,-999
-- =============================================
CREATE PROCEDURE [dbo].[SP_ItemWisePriceChanges]
	@ItemID INT,
	@LocationID INT,
	@PropertyID INT,
	@IsALL VARCHAR(5)
AS
BEGIN
	SET NOCOUNT ON;


	IF(@IsALL = -999)
	BEGIN
		SELECT ID, StockItemID,LocationID,PropertyID,SellingPrice,IsActive,CONVERT(VARCHAR,BusinessDate) BusinessDate
		FROM SellingPrice_ChangeLog
		WHERE StockItemID = @ItemID AND PropertyID = @PropertyID AND LocationID = @LocationID
		ORDER BY BusinessDate 
	END
	ELSE
	BEGIN
		SELECT ID, StockItemID,LocationID,PropertyID,SellingPrice,IsActive,CONVERT(VARCHAR,BusinessDate) BusinessDate
		FROM SellingPrice_ChangeLog
		WHERE StockItemID = @ItemID AND PropertyID = @PropertyID AND LocationID = @LocationID AND IsActive=1
		ORDER BY BusinessDate 
	END
    
END

GO

