
CREATE FUNCTION  CheckForTransaction(@StockItemID INT, @LocationID INT)
RETURNS BIT
AS
BEGIN

	IF EXISTS(	SELECT TOP 1 StockTransactionHeaderID 
				FROM	StockTransactionDetails D 
				INNER JOIN StockTransactionHeaders H on D.StockTransactionHeaderID = H.ID 
				where H.LocationID= @LocationID AND D.StockItemID= @StockItemID )
	RETURN 0;


	IF EXISTS(	SELECT TOP 1 H.ID 
				FROM	RequestHeaders H 
				INNER JOIN RequestDetails D on D.RequestHeaderID = H.ID 
				where H.LocationID =@LocationID AND D.StockItemID = @StockItemID )
	RETURN 0;


	RETURN 1;
END

GO

