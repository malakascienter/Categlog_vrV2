
CREATE PROCEDURE [dbo].[MaaluWiseMenu_M_Select]
    @PropertyId INT,
    @AggType    INT,
    @Outlet     VARCHAR(5)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT AM.Id,
           AM.MenuCode,
           MM.Description AS MenuName,
           AM.AggregatorId,
           A.Aggregator   AS AggregatorName,
           AM.Outlet,
           AM.BrandID,
           MM.IsUploadToMaalu
    FROM [dbo].[AggregatorWiseMenuItem] AM
    INNER JOIN [dbo].[POS_Aggregators] A
        ON AM.AggregatorId = A.ID AND AM.PropertyId = A.PropertyId
    INNER JOIN [dbo].[MainMenu] MM
        ON MM.ItemCode = AM.MenuCode AND MM.PropertyId = AM.PropertyId
    WHERE AM.PropertyId   = @PropertyId
      AND AM.AggregatorId = @AggType
      AND AM.Outlet       = @Outlet;
END

GO

