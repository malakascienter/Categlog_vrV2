
--[dbo].[SP_Select_StockItemWiseTotalTaxAmount] 346668,230.75
CREATE PROCEDURE [dbo].[SP_Select_StockItemWiseTotalTaxAmount]
@StockItemID INT,
@UnitPrice money
AS
BEGIN


--DECLARE @TaxBreakUp TABLE(
--TaxTypeId		INT,
--TaxValue		MONEY
--)

--insert into @TaxBreakUp
--exec [SP_Select_StockItemWiseTaxAmount] @StockItemID,@UnitPrice 


--SELECT ROUND(sum(TaxValue),2) AS 'ItemTaxAmount' 
--from @TaxBreakUp
DECLARE @TaxGroupId		INT


DECLARE @TaxGroupTable TABLE(
TaxGroupId		INT,
TaxTypeId		INT,
ChargeRate		MONEY
)

DECLARE @TaxBreakUp TABLE(
TaxTypeId		INT,
TaxValue		MONEY
)

SELECT @TaxGroupId = TaxGroupID FROM dbo.StockItemHeaders WHERE Id = @StockItemID

INSERT INTO @TaxGroupTable
SELECT TaxGroupId,TaxTypeId,ChargeRate
FROM dbo.TaxGroupDetails
WHERE TaxGroupId = @TaxGroupId AND IsActive = 1

DECLARE @TaxRate MONEY = 0 
DECLARE @TaxAmount MONEY = 0
DECLARE @TotalTaxAmount MONEY = 0
declare @TaxTypeId INT = 0

WHILE (SELECT COUNT(*) FROM @TaxGroupTable) > 0
BEGIN

	SELECT TOP 1 @TaxRate = ChargeRate,@TaxTypeId = TaxTypeId  
	FROM @TaxGroupTable 
	
	SET @TaxAmount = ROUND((((@UnitPrice)/100.0) * @TaxRate),2)
	
	insert into @TaxBreakUp 
	values(@TaxTypeId,@TaxAmount)
	
	delete from @TaxGroupTable
	where TaxTypeId = @TaxTypeId

END 


DECLARE @TaxTotal MONEY

SELECT @TaxTotal=SUM(TaxValue) from @TaxBreakUp

select ROUND(@TaxTotal,2)

END

GO

