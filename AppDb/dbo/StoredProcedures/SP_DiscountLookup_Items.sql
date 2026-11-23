CREATE PROCEDURE dbo.SP_DiscountLookup_Items
    @PropertyId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT LTRIM(RTRIM(M.ItemCode)) AS Code,
           M.Description            AS Name
      FROM dbo.MainMenu M
     WHERE M.Active = 1
       AND M.discountNotApplicable = 0
       AND M.PropertyId = @PropertyId
     ORDER BY M.Description;
END

GO

