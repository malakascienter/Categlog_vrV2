CREATE PROCEDURE [dbo].[SP_Select_StockItemWiseTaxAmountByPODate] 
@StockItemID INT,
@UnitPrice MONEY,
@SupplierID INT=null,
@PODate DATE
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
ChargeRate		MONEY
)

DECLARE @TaxBreakUp TABLE
(
	TaxTypeId		INT,
	TaxValue		MONEY
)


If @SupplierID is null 
BEGIN
	SELECT @TaxGroupId = TaxGroupID FROM dbo.StockItemHeaders 
	WHERE Id = @StockItemID
END 

ELSE
BEGIN
	SELECT @TaxGroupId = TaxGroupID FROM SupplierWiseItemDetails 
	WHERE StockItemID = @StockItemID AND SupplierID =@SupplierID
END 


IF( @PODate < '2024-01-01' )
BEGIN


	INSERT INTO @TaxGroupTable
	SELECT TaxGroupId,TaxTypeId,ChargeRate
	FROM dbo.TaxGroupDetails_History
	WHERE TaxGroupId = @TaxGroupId AND IsActive = 1 

END
ELSE
BEGIN


	INSERT INTO @TaxGroupTable
	SELECT TaxGroupId,TaxTypeId,ChargeRate
	FROM dbo.TaxGroupDetails
	WHERE TaxGroupId = @TaxGroupId AND IsActive = 1 

END


DECLARE @TaxRate MONEY = 0 
DECLARE @TaxAmount MONEY = 0
DECLARE @TotalTaxAmount MONEY = 0
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


DECLARE @TaxTotal MONEY

SELECT * FROM @TaxBreakUp
--SELECT @TaxTotal=SUM(TaxValue) from @TaxBreakUp
--SELECT  ROUND(@TaxTotal,2)
END



--select [dbo].[FN_GetStockItemWiseTotalTax]( 402,1622.93)

--select 248.41+33.11

GO

