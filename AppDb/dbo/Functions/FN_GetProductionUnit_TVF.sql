CREATE FUNCTION dbo.FN_GetProductionUnit_TVF
(
    @StockItemId INT,
    @LocationID INT,
    @propertyId INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT  
        ISNULL(R.ProductionUnitID, 0) AS UnitID,
        U.Name AS UnitName
    FROM
    (
        SELECT TOP (1) ProductionUnitID
        FROM Inv_ItemWiseRecipes
        WHERE StockItemId = @StockItemId
        AND LocationId = CASE WHEN @LocationID = -999 THEN LocationId ELSE @LocationID END
        AND CompanyId = @propertyId
    ) R
    LEFT JOIN Units U ON U.ID = R.ProductionUnitID
);

GO

