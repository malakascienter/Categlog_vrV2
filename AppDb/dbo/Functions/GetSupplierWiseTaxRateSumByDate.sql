--  [dbo].[GetSupplierWiseTaxRateSumByDate] 6038,306,'2023-12-31'
CREATE FUNCTION [dbo].[GetSupplierWiseTaxRateSumByDate](@StockItemID INT, @SupplierID INT,@TransactionDate DATE)
RETURNS MONEY
BEGIN
	DECLARE @TaxGroupID INT
	DECLARE @ChargeRate decimal(18, 4)
	SELECT @TaxGroupID =TaxGroupID FROM SupplierWiseItemDetails S
	WHERE StockItemID = @StockItemID AND SupplierID = @SupplierID 


	
IF( @TransactionDate < '2024-01-01' )
BEGIN

	SET @ChargeRate =  (SELECT SUM(ChargeRate) FROM TaxGroupDetails_History
	WHERE TaxGroupID=@TaxGroupID)

END
ELSE
BEGIN

	SET @ChargeRate =  (SELECT SUM(ChargeRate) FROM TaxGroupDetails
	WHERE TaxGroupID=@TaxGroupID)

END

RETURN ISNULL(@ChargeRate,0)
 
END

GO

