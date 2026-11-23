CREATE PROCEDURE dbo.SP_DiscountLookup_Members
    @PropertyId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CAST(M.MemberID AS VARCHAR(20)) AS Code,
           M.MemberName                    AS Name
      FROM dbo.POS_ExecutiveMember M
     WHERE M.Active = 1
       AND M.PropertyId = @PropertyId
     ORDER BY M.MemberName;
END

GO

