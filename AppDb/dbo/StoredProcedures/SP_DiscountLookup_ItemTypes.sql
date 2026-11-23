CREATE PROCEDURE dbo.SP_DiscountLookup_ItemTypes
    @PropertyId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT LTRIM(RTRIM(T.Code)) AS Code,
           T.Name               AS Name
      FROM dbo.POSItemTypes T
     WHERE ISNULL(T.IsActive, 0) = 1
       AND T.PropertyId = @PropertyId
     ORDER BY T.Name;
END

GO

