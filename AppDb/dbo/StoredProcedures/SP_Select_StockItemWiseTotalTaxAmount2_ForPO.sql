
/**
EXEC [dbo].[SP_Select_StockItemWiseTotalTaxAmount2_ForPO] 0,0,6038,780,306,59

EXEC [dbo].[SP_Select_StockItemWiseTotalTaxAmount2] 0,0,6038,780,306

**/
CREATE PROCEDURE [dbo].[SP_Select_StockItemWiseTotalTaxAmount2_ForPO]
@DiscountPercentage DECIMAL(18,6),
@DiscountValue DECIMAL(18,6),
@StockItemID INT,
@UnitPrice DECIMAL(18,6),
@supplierId int =null,
@POHeaderID int,
@LocationID int = 0 
AS
BEGIN

DECLARE @NetValue DECIMAL(18,6), @OldTax BIT

IF EXISTS (SELECT 1 FROM POHEADERS WHERE CREATEDDATE < '2023-12-31' AND ID = @PoHeaderID)
BEGIN
	SET @OldTax = 1
END
ELSE
BEGIN
	SET @OldTax = 0
END

IF (@DiscountPercentage>0)
	BEGIN
		SET @NetValue = @UnitPrice- (@UnitPrice*@DiscountPercentage/100) 
	END
ELSE
	BEGIN
		SET @NetValue = @UnitPrice-@DiscountValue
	END

DECLARE @TaxBreakUp TABLE(
TaxTypeId		INT,
TaxValue		DECIMAL(18,6)
)

IF(@OldTax = 1)
BEGIN

insert into @TaxBreakUp VALUES(0,0)
--select @StockItemID,@NetValue,@supplierId
insert into @TaxBreakUp

exec [SP_Select_StockItemWiseTaxAmount3ForPO] @StockItemID,@NetValue,@supplierId,@PoheaderID


 SELECT ROUND(SUM(TaxValue),6) AS 'ItemTaxAmount' 
 
from @TaxBreakUp
END
ELSE
BEGIN


insert into @TaxBreakUp VALUES(0,0)
--select @StockItemID,@NetValue,@supplierId
insert into @TaxBreakUp

exec [SP_Select_StockItemWiseTaxAmount3] @StockItemID,@NetValue,@supplierId , @LocationID


 SELECT ROUND(SUM(TaxValue),6) AS 'ItemTaxAmount' 
 
from @TaxBreakUp


END
END
-- SELECT ROUND(sum(TaxValue),4 , 0) AS 'ItemTaxAmount' 
--[SP_Select_StockItemWiseTaxAmount] 458,250.25

GO

