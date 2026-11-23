-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2024-01-04
-- Description:	Calculate Taxes for PO Based GRN
-- =============================================
CREATE FUNCTION [dbo].[FN_GetStockItemWiseTotalTax_ForPOBased]
(
	@StockItemID INT,
    @UnitPrice DECIMAL(18,6),
	@SupplierID INT =NULL ,
	@POHeaderID INT
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
		WHERE StockItemID = @StockItemID AND SupplierID =@SupplierID
	END 

DECLARE @PODate		    DATE

IF( ISNULL(@POHeaderID,0) <> 0 )
BEGIN

	SELECT @PODate = CreatedDate FROM PoHeaders WHERE Id = ISNULL(@POHeaderID,0)
 
	IF( @PODate < '2024-01-01' )
	BEGIN

		INSERT INTO @TaxGroupTable
		SELECT TaxGroupId,TaxTypeId,ChargeRate
		FROM dbo.TaxGroupDetails_History
		WHERE TaxGroupId = @TaxGroupId AND IsActive = 1
		--WHERE IsActive = 1

	END
	ELSE
	BEGIN

		INSERT INTO @TaxGroupTable
		SELECT TaxGroupId,TaxTypeId,ChargeRate
		FROM dbo.TaxGroupDetails
		WHERE TaxGroupId = @TaxGroupId AND IsActive = 1
		--WHERE IsActive = 1

	END


END
ELSE
BEGIN

	INSERT INTO @TaxGroupTable
	SELECT TaxGroupId,TaxTypeId,ChargeRate
	FROM dbo.TaxGroupDetails
	WHERE TaxGroupId = @TaxGroupId AND IsActive = 1
	--WHERE IsActive = 1

END



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

	SELECT @TaxTotal = TaxValue FROM @TaxBreakUp

	RETURN @TaxTotal

END

GO

