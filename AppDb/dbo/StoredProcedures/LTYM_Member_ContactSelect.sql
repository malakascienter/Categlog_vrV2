
CREATE   PROCEDURE dbo.LTYM_Member_ContactSelect
    @MemberId   INT
AS
BEGIN
    SET NOCOUNT ON;


    -- PropertyId is not part of this module's interface; it comes from the member row.
    DECLARE @PropertyId INT = (SELECT TOP (1) PropertyId FROM dbo.LTY_Member WHERE MemberId = @MemberId);
    SELECT TOP (1)
           M.MemberId,
           M.FirstName,
           M.LastName,
           M.Email,
           M.PrimaryMobileNo AS ContactNo
    FROM   dbo.LTY_Member AS M
    WHERE  M.MemberId   = @MemberId
      AND  M.PropertyId = @PropertyId;
END

GO

