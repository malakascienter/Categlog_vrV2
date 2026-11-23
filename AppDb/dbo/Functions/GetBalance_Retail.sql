
CREATE FUNCTION  [dbo].[GetBalance_Retail](@date DATE = '2018/4/1' ,@StockItemID INT = 1, @LocationId INT = 1 ,@OpeningBalance bit =0, @byValue bit =0,@PropertyId INT) 
RETURNs DECIMAL(18,6) 
AS
begin

DECLARE @Balance AS DECIMAL(18,6)
DECLARE @IsRetail AS BIT
DECLARE @CurrentDate DATE
DECLARE @SalesQty MONEY
DECLARE @SalesReturnQty MONEY

SELECT @IsRetail = IsRetail FROM Companies WHERE CompanyID = @PropertyId

IF( @IsRetail = 0 )
BEGIN


	SELECT top (1) @Balance= ISNULL(D.NewQuantity * CASE WHEN @byValue=1 THEN D.NewAveragePrice ELSE  1 END ,0) 
	FROM dbo.StockTransactionDetails AS D
	INNER JOIN  dbo.StockTransactionHeaders AS H ON D.StockTransactionHeaderID = H.Id 
	INNER JOIN dbo.StockItemHeaders AS IH ON D.StockItemID = IH.Id
	INNER JOIN dbo.StockItemDetails AS ID ON IH.Id = ID.StockItemHeaderID AND  ID.LocationID = @LocationId -- AND IH.LocationId = ID.LocationID
	INNER JOIN dbo.Units AS U ON ID.MasterUnitID = U.Id
	WHERE IH.Id = @StockItemID AND H.LocationID = @LocationID AND H.TransactionDate <  CASE WHEN @OpeningBalance=1 THEN @Date ELSE DATEADD(D,1,@date) END 
	ORDER BY H.TransactionDate DESC,H.CreatedDate DESC  

END
ELSE
BEGIN
SELECT @CurrentDate = CurrentDate FROM Locations where id = @LocationID

IF( @CurrentDate <= @date )
BEGIN

SELECT @SalesQty = SUM(Quantity) FROM POS_InvoiceDetail WHERE BusinessDate = @CurrentDate AND ItemID = @StockItemID AND LocationID = @LocationId AND CompanyID = @PropertyId
SELECT @SalesReturnQty = SUM(Quantity) FROM POS_SalesReturnDetail WHERE BusinessDate = @CurrentDate AND ItemID = @StockItemId AND LocationID = @LocationID AND CompanyID = @propertyId
	
END
	
	set @SalesQty = ISNULL(@SalesQty,0)
	set @SalesReturnQty = ISNULL(@SalesReturnQty,0)

	SELECT top (1) @Balance= ISNULL((D.NewQuantity- @SalesQty+@SalesReturnQty) * CASE WHEN @byValue=1 THEN D.NewAveragePrice ELSE  1 END ,0) 
	FROM dbo.StockTransactionDetails AS D
	INNER JOIN  dbo.StockTransactionHeaders AS H ON D.StockTransactionHeaderID = H.Id 
	INNER JOIN dbo.StockItemHeaders AS IH ON D.StockItemID = IH.Id
	INNER JOIN dbo.StockItemDetails AS ID ON IH.Id = ID.StockItemHeaderID AND  ID.LocationID = @LocationId -- AND IH.LocationId = ID.LocationID
	INNER JOIN dbo.Units AS U ON ID.MasterUnitID = U.Id
	WHERE IH.Id = @StockItemID AND H.LocationID = @LocationID AND H.TransactionDate <  CASE WHEN @OpeningBalance=1 THEN @Date ELSE DATEADD(D,1,@date) END 
	ORDER BY H.TransactionDate DESC,H.CreatedDate DESC  


END


RETURN isnull(@Balance,0)


end

GO

