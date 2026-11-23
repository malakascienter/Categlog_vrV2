CREATE PROCEDURE [dbo].[SP_Select_StockItemWiseTaxAmount] 
@StockItemID INT,
@UnitPrice DECIMAL(18,6),
@SupplierID INT=null,
@LocationID INT =0 --@LocationID added by Isuru 2024-12-10
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


DECLARE @TaxGroupTable TABLE(
TaxGroupId		INT,
TaxTypeId		INT,
ChargeRate		DECIMAL(18,6)
)

DECLARE @TaxBreakUp TABLE
(
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
	WHERE StockItemID = @StockItemID AND SupplierID =@SupplierID  AND LocationId = @LocationID
END 


INSERT INTO @TaxGroupTable
SELECT TaxGroupId,TaxTypeId,ChargeRate
FROM dbo.TaxGroupDetails
WHERE TaxGroupId = @TaxGroupId AND IsActive = 1

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

SELECT * FROM @TaxBreakUp
--SELECT @TaxTotal=SUM(TaxValue) from @TaxBreakUp
--SELECT  ROUND(@TaxTotal,2)
END



--select [dbo].[FN_GetStockItemWiseTotalTax]( 402,1622.93)

--select 248.41+33.11

GO

