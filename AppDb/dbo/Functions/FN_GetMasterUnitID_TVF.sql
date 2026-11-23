CREATE FUNCTION dbo.FN_GetMasterUnitID_TVF
(
    @PropertyId INT,
    @LocationID INT,
    @StockItemId INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT MasterUnitID
    FROM dbo.StockItemDetails
    WHERE LocationID = @LocationID
      AND StockItemHeaderID = @StockItemId
);

GO

