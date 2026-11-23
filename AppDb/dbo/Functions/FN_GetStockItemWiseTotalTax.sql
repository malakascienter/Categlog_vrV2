
CREATE FUNCTION  [dbo].[FN_GetStockItemWiseTotalTax]
(
	@StockItemID INT,
    @UnitPrice DECIMAL(18,6),
	@SupplierID INT =NULL,
	@LocationId INT = NULL
    
)
RETURNS DECIMAL(18,6) 
AS
BEGIN
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
		WHERE StockItemID = @StockItemID AND SupplierID =@SupplierID AND LocationId= @LocationId
	END 

 

INSERT INTO @TaxGroupTable
SELECT TaxGroupId,TaxTypeId,ChargeRate
FROM dbo.TaxGroupDetails
WHERE TaxGroupId = @TaxGroupId --AND IsActive = 1

DECLARE @TaxRate DECIMAL(18,6) = 0 
DECLARE @TaxAmount DECIMAL(18,6) = 0
DECLARE @TotalTaxAmount DECIMAL(18,6) = 0
declare @TaxTypeId INT = 0

WHILE (SELECT COUNT(*) FROM @TaxGroupTable) > 0
BEGIN

	SELECT TOP 1 @TaxRate = ChargeRate,@TaxTypeId = TaxTypeId  
	FROM @TaxGroupTable 
	
	SET @TaxAmount = (((@UnitPrice)/100.0) * @TaxRate)
	
	insert into @TaxBreakUp 
	values(@TaxTypeId,@TaxAmount)
	
	delete from @TaxGroupTable
	where TaxTypeId = @TaxTypeId

END 


DECLARE @TaxTotal DECIMAL(18,6)

SELECT @TaxTotal=SUM(TaxValue) from @TaxBreakUp

RETURN ROUND(@TaxTotal,6)

END

GO

