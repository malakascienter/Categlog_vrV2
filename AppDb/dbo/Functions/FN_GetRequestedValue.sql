


CREATE FUNCTION   [dbo].[FN_GetRequestedValue]
(
	@TxnType INT, @TxnHeaderId INT
)
RETURNS MONEY
AS
BEGIN

	DECLARE @RequestedValue MONEY
	IF(@TxnType = 2)
		SELECT @RequestedValue = SUM(RequestedQuantity * UnitPrice) FROM dbo.PoDetails WHERE PoHeaderID = @TxnHeaderId GROUP BY PoHeaderID 
	ELSE
		SELECT @RequestedValue = SUM(RequestedQuantity * UnitPrice) FROM dbo.RequestDetails WHERE RequestHeaderID = @TxnHeaderId GROUP BY RequestHeaderID 

	RETURN @RequestedValue

END

GO

