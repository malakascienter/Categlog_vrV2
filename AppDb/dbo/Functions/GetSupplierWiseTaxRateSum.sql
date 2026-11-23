
CREATE FUNCTION  GetSupplierWiseTaxRateSum(@StockItemID INT, @SupplierID INT)
RETURNS MONEY
BEGIN
	DECLARE @TaxGroupID INT

	SELECT @TaxGroupID =TaxGroupID FROM SupplierWiseItemDetails S
	WHERE StockItemID = @StockItemID AND SupplierID = @SupplierID 


	RETURN (SELECT SUM(ChargeRate) FROM TaxGroupDetails
	WHERE TaxGroupID=@TaxGroupID)



 
END

GO

