/*  The mapping, joined to the registry so a mapping pointing at a field that is
    no longer syncable is visible rather than silently exporting.                */
CREATE PROCEDURE dbo.LTYC_BrazeAttributeMap_Select
    @PropertyId int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT m.MapId,
           m.AttributeCode,
           m.BrazeAttributeName,
           m.DataType,
           m.IsActive,
           m.SortOrder,
           a.DisplayName,
           ISNULL(a.IsBrazeSyncable, 0) AS IsSyncable
    FROM   dbo.LTYC_BrazeAttributeMap AS m
    LEFT JOIN dbo.LTYC_SegmentAttribute AS a ON a.AttributeCode = m.AttributeCode
    WHERE  m.PropertyId = @PropertyId
    ORDER BY m.SortOrder, m.AttributeCode;
END

GO

