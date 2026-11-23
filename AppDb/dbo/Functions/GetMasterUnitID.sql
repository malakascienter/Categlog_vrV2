

CREATE FUNCTION   [dbo].[GetMasterUnitID] (@LocationID INT,@stockItemID INT)
RETURNS INT
AS
BEGIN


	RETURN (SELECT MasterUnitID FROM dbo.StockItemDetails
	WHERE StockItemHeaderID= @stockItemID AND LocationID = @LocationID)

END

GO

