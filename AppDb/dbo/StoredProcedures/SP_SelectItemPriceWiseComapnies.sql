--[dbo].[SP_SelectItemPriceWiseComapnies] 1108,2365,1022,1500
--go
create PROCEDURE [dbo].[SP_SelectItemPriceWiseComapnies](@SuppId INT ,@ItemId INT,@LocationId INT,@Price DECIMAL(18,6))
AS
BEGIN	
	DECLARE @ItemCode NVARCHAR(250)

	SELECT @ItemCode = StockItemCode  FROM StockItemHeaders WHERE Id = @ItemId

	SELECT  Id INTO #TempItems FROM StockItemHeaders WHERE StockItemCode = @ItemCode

	SELECT CompanyId 
	FROM SupplierWiseItemDetails S
	INNER JOIN #TempItems T ON T.Id = S.StockItemID
	WHERE  LocationId = @LocationId AND CostPrice = @Price AND SupplierID = @SuppId
END

GO

