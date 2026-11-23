
CREATE FUNCTION [dbo].[FN_GetItemWiseTax]
(
	@StockItemID INT,
	@UnitPrice DECIMAL(18,6),
	@SupplierID INT,
	@locationID INT=0,
	@DiscountPercentage DECIMAL(18,6),
    @DiscountValue DECIMAL(18,6)
)
RETURNS  DECIMAL(18,6)
AS
BEGIN

	IF (@DiscountPercentage>0)
		BEGIN
			SET @UnitPrice = @UnitPrice- (@UnitPrice*@DiscountPercentage/100) 
		END
	ELSE
	BEGIN
		SET @UnitPrice = @UnitPrice-@DiscountValue
	END


	DECLARE @TaxGroupId		INT

	DECLARE @TaxGroupTable TABLE(
	TaxGroupId		INT,
	TaxTypeId		INT,
	ChargeRate		DECIMAL(18,6)
	)

	DECLARE @TaxBreakUp TABLE(
	TaxTypeId		INT,
	TaxValue		DECIMAL(18,6)
	)

	If @SupplierID is null 
	BEGIN
		SELECT @TaxGroupId = TaxGroupID FROM dbo.StockItemHeaders 
		WHERE Id = @StockItemID
	END 

	ELSE
	BEGIN
		SELECT @TaxGroupId = TaxGroupID FROM SupplierWiseItemDetails 
		WHERE StockItemID = @StockItemID AND SupplierID =@SupplierID AND LocationId = @locationID
	END 

	INSERT INTO @TaxGroupTable
	SELECT TaxGroupId,TaxTypeId,ChargeRate
	FROM dbo.TaxGroupDetails
	WHERE TaxGroupId = @TaxGroupId AND IsActive = 1
	--WHERE IsActive = 1


	DECLARE @TaxRate DECIMAL(18,6) = 0 
	DECLARE @TaxAmount DECIMAL(18,6) = 0
	DECLARE @TotalTaxAmount DECIMAL(18,6) = 0
	declare @TaxTypeId INT = 0


	WHILE (SELECT COUNT(*) FROM @TaxGroupTable) > 0
	BEGIN

		SELECT TOP 1 @TaxRate = ChargeRate,@TaxTypeId = TaxTypeId  
		FROM @TaxGroupTable 
	
		SET @TaxAmount =ROUND( (((@UnitPrice)/100.0) * @TaxRate),6)
	
		insert into @TaxBreakUp 
		values(@TaxTypeId,ROUND(@TaxAmount,6))
	
		delete from @TaxGroupTable
		where TaxTypeId = @TaxTypeId

	END 


	DECLARE @TaxTotal DECIMAL(18,6)

	

	RETURN (SELECT SUM(@TaxAmount) FROM @TaxBreakUp)

END

GO

