

CREATE PROCEDURE [dbo].[SP_Select_StockItemWiseTotalTaxAmount2]
@DiscountPercentage DECIMAL(18,6),
@DiscountValue DECIMAL(18,6),
@StockItemID INT,
@UnitPrice DECIMAL(18,6),
@supplierId int =null,
@LocationID int = 0 
AS
BEGIN

DECLARE @NetValue DECIMAL(18,6)

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
insert into @TaxBreakUp VALUES(0,0)
--select @StockItemID,@NetValue,@supplierId
insert into @TaxBreakUp

exec [SP_Select_StockItemWiseTaxAmount3] @StockItemID,@NetValue,@supplierId , @LocationID


 SELECT ROUND(SUM(TaxValue),6) AS 'ItemTaxAmount' 
 
from @TaxBreakUp


END
-- SELECT ROUND(sum(TaxValue),4 , 0) AS 'ItemTaxAmount' 
--[SP_Select_StockItemWiseTaxAmount] 458,250.25

GO

