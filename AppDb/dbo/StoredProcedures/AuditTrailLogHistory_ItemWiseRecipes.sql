
CREATE PROCEDURE [dbo].[AuditTrailLogHistory_ItemWiseRecipes]
    @StockItemId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM HotelResWeb_AuditTail.sys.tables WHERE name = 'Inv_ItemWiseRecipes_History')
    BEGIN
        -- Nothing logged yet for recipe mappings on this server
        SELECT CAST(NULL AS BIGINT) AS AuditTrailID WHERE 1 = 0;
        RETURN;
    END

    DECLARE @ThisDatabase NVARCHAR(250) = '[' + DB_NAME() + ']';

    SELECT
        M.TrailID AS AuditTrailID,
        M.LogDate,
        M.Action,
        CASE M.Action WHEN 'I' THEN 'Added' WHEN 'U' THEN 'Changed' WHEN 'D' THEN 'Removed' ELSE M.Action END AS ActionName,
        ISNULL(NULLIF(M.Username, ''), [dbo].[GET_User](M.UserID)) AS UserName,
        H.Id AS MappingId,
        H.RecipeId,
        RH.RecipeCode,
        RH.RecipeName,
        H.LocationId,
        CASE WHEN ISNULL(H.LocationId, 0) <= 0 THEN 'All' ELSE L.Name END AS LocationName,
        H.Quantity,
        U.Name  AS UnitName,
        PU.Name AS ProductionUnitName,
        STUFF((
            SELECT '; '
                 + CASE D.FieldName
                       WHEN 'UnitId'           THEN 'Unit: '            + ISNULL(UO.Name, ISNULL(D.OldValue, '')) + ' -> ' + ISNULL(UN.Name, ISNULL(D.NewValue, ''))
                       WHEN 'ProductionUnitID' THEN 'Production unit: ' + ISNULL(UO.Name, ISNULL(D.OldValue, '')) + ' -> ' + ISNULL(UN.Name, ISNULL(D.NewValue, ''))
                       WHEN 'Quantity'         THEN 'Quantity: '        + ISNULL(CONVERT(VARCHAR(50), CAST(TRY_CONVERT(DECIMAL(18,6), D.OldValue) AS FLOAT)), ISNULL(D.OldValue, ''))
                                                                + ' -> ' + ISNULL(CONVERT(VARCHAR(50), CAST(TRY_CONVERT(DECIMAL(18,6), D.NewValue) AS FLOAT)), ISNULL(D.NewValue, ''))
                       ELSE D.FieldName + ': ' + ISNULL(D.OldValue, '') + ' -> ' + ISNULL(D.NewValue, '')
                   END
            FROM HotelResWeb_AuditTail.dbo.AuditTrailDetail D
            LEFT JOIN Units UO ON D.FieldName IN ('UnitId', 'ProductionUnitID') AND UO.Id = TRY_CONVERT(INT, D.OldValue)
            LEFT JOIN Units UN ON D.FieldName IN ('UnitId', 'ProductionUnitID') AND UN.Id = TRY_CONVERT(INT, D.NewValue)
            WHERE D.TrailID = M.TrailID
              AND D.FieldName NOT IN ('Id', 'CreatedUserID', 'CreatedDate', 'LastModUserID', 'LastModDate')
            ORDER BY D.MasterDetailId
            FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS Changes
    FROM HotelResWeb_AuditTail.dbo.Inv_ItemWiseRecipes_History H
    INNER JOIN HotelResWeb_AuditTail.dbo.AuditTrailMaster M ON M.TrailID = H.AuditTrailID
    LEFT JOIN Inv_RecipeHeader RH ON RH.Id = H.RecipeId
    LEFT JOIN Locations L         ON L.ID = H.LocationId
    LEFT JOIN Units U             ON U.Id = H.UnitId
    LEFT JOIN Units PU            ON PU.Id = H.ProductionUnitID
    WHERE H.StockItemId = @StockItemId
      AND M.TableName = 'Inv_ItemWiseRecipes'
      AND M.DatabaseName = @ThisDatabase
    ORDER BY M.LogDate DESC, M.TrailID DESC;
END

GO

