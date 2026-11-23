

--[dbo].[SP_Select_StockItemWiseTaxAmount2] 458,125.25
CREATE PROCEDURE [dbo].[SP_Select_StockItemWiseTaxAmount2] 
@StockItemID INT,
@UnitPrice money
AS
BEGIN

--DECLARE @TaxGroupId		INT


--DECLARE @TaxGroupTable TABLE(
--TaxGroupId		INT,
--TaxTypeId		INT,
--ChargeRate		MONEY
--)

--DECLARE @TaxBreakUp TABLE(
--TaxTypeId		INT,
--TaxValue		MONEY
--)

--SELECT @TaxGroupId = TaxGroupID FROM dbo.StockItemHeaders WHERE Id = @StockItemID

--INSERT INTO @TaxGroupTable
--SELECT TaxGroupId,TaxTypeId,ChargeRate
--FROM dbo.TaxGroupDetails
--WHERE TaxGroupId = @TaxGroupId AND IsActive = 1

--DECLARE @TaxRate MONEY = 0 
--DECLARE @TaxAmount MONEY = 0
--DECLARE @TotalTaxAmount MONEY = 0
--declare @TaxTypeId INT = 0

--WHILE (SELECT COUNT(*) FROM @TaxGroupTable) > 0
--BEGIN

--	SELECT TOP 1 @TaxRate = ChargeRate,@TaxTypeId = TaxTypeId  
--	FROM @TaxGroupTable 
	
--	SET @TaxAmount = (((@UnitPrice)/100.0) * @TaxRate)
	
--	insert into @TaxBreakUp 
	
--	values(@TaxTypeId,ROUND(@TaxAmount,2))
	
--	delete from @TaxGroupTable
--	where TaxTypeId = @TaxTypeId

--END 

--SELECT * from @TaxBreakUp
DECLARE @TaxGroupId		INT


--DECLARE @TaxGroupTable TABLE(
--TaxGroupId		INT,
--TaxTypeId		INT,
--ChargeRate		MONEY
--)

DECLARE @TaxGroupTable TABLE(
TaxTypeId		INT,
SortSequence	INT,
Rate		MONEY
)

DECLARE @TaxBreakUp TABLE(
TaxTypeId		INT,
TaxValue		MONEY
)

SELECT @TaxGroupId = TaxGroupID FROM dbo.StockItemHeaders WHERE Id = @StockItemID

--INSERT INTO @TaxGroupTable
--SELECT TaxGroupId,TaxTypeId,ChargeRate
--FROM dbo.TaxGroupDetails
--WHERE TaxGroupId = @TaxGroupId AND IsActive = 1
INSERT INTO @TaxGroupTable
SELECT TD.TaxTypeId ,  TGD.SortSequance, TD.Rate
FROM TaxGroupDetails TGD INNER JOIN  TaxDetails TD
ON TGD.TaxTypeId = TD.TaxTypeId
WHERE TaxGroupId = @TaxGroupId
ORDER BY TGD.SortSequance 



DECLARE @TaxRate MONEY = 0 
DECLARE @TaxAmount MONEY = 0
DECLARE @TaxTypeAmount MONEY = 0
declare @TaxTypeId INT = 0


DECLARE @TaxTotal MONEY = @UnitPrice

--WHILE (SELECT COUNT(*) FROM @TaxGroupTable) > 0
--BEGIN

--	SELECT TOP 1 @TaxRate = ChargeRate,@TaxTypeId = TaxTypeId  
--	FROM @TaxGroupTable 
	
--	SET @TaxAmount = (((@UnitPrice)/100.0) * @TaxRate)
	
--	insert into @TaxBreakUp 
--	values(@TaxTypeId,@TaxAmount)
	
--	delete from @TaxGroupTable
--	where TaxTypeId = @TaxTypeId

--END 


WHILE (SELECT COUNT(*) FROM @TaxGroupTable) > 0
BEGIN

	SELECT TOP 1 @TaxRate = Rate,@TaxTypeId = TaxTypeId  
	FROM @TaxGroupTable 
	ORDER BY SortSequence
	
	SET @TaxAmount = ROUND(((@TaxTotal * @TaxRate)/100),2)
	SET @TaxTotal = @TaxTotal + @TaxAmount
	
	insert into @TaxBreakUp 
	values(@TaxTypeId,@TaxAmount)
	
	delete from @TaxGroupTable
	where TaxTypeId = @TaxTypeId

END




SELECT * FROM @TaxBreakUp
--SELECT @TaxTotal=SUM(TaxValue) from @TaxBreakUp
--SELECT  ROUND(@TaxTotal,2)
END



--select [dbo].[FN_GetStockItemWiseTotalTax]( 402,1622.93)

--select 248.41+33.11

GO

