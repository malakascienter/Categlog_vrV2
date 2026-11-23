CREATE PROCEDURE [dbo].[Discount_SelectTiers]
    @PropertyId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT t.TierId, t.TierName
    FROM dbo.LTY_Tier t
    WHERE t.IsActive = 1
      AND (@PropertyId IS NULL OR t.PropertyId = @PropertyId)
    ORDER BY t.SortOrder, t.TierName;
END

GO

