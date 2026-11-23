CREATE PROCEDURE dbo.SP_DiscountLookup_Categories
    @PropertyId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT LTRIM(RTRIM(C.Code)) AS Code,
           C.Description        AS Name
      FROM dbo.Category C
     WHERE C.Active = 1
       AND C.PropertyId = @PropertyId
     ORDER BY C.Seq, C.Description;
END

GO

