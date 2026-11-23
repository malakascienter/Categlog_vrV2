

CREATE FUNCTION  [dbo].[FN_GetStockItemWiseTotalTaxR4]
(
	@StockItemID INT,
    @UnitPrice money
)
RETURNS MONEY 
AS
BEGIN
DECLARE @TaxGroupId		INT


DECLARE @TaxGroupTable TABLE(
TaxGroupId		INT,
TaxTypeId		INT,
ChargeRate		money
)

DECLARE @TaxBreakUp TABLE(
TaxTypeId		INT,
TaxValue		money
)

SELECT @TaxGroupId = TaxGroupID FROM dbo.StockItemHeaders WHERE Id = @StockItemID

INSERT INTO @TaxGroupTable
SELECT TaxGroupId,TaxTypeId,ChargeRate
FROM dbo.TaxGroupDetails
WHERE TaxGroupId = @TaxGroupId AND IsActive = 1

DECLARE @TaxRate money = 0 
DECLARE @TaxAmount money = 0
DECLARE @TotalTaxAmount money = 0
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


DECLARE @TaxTotal money

SELECT @TaxTotal=SUM(TaxValue) from @TaxBreakUp

RETURN ROUND(@TaxTotal,4)

END

GO

