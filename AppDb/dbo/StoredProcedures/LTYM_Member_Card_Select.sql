
CREATE   PROCEDURE [dbo].[LTYM_Member_Card_Select]
    @MemberId   INT
AS
BEGIN
    SET NOCOUNT ON;


    -- PropertyId is not part of this module's interface; it comes from the member row.
    DECLARE @PropertyId INT = (SELECT TOP (1) PropertyId FROM dbo.LTY_Member WHERE MemberId = @MemberId);
    SELECT TOP (1)
           M.MemberId,
           M.MembershipCode    AS MembershipNo,
           E.CardNo,
           M.FirstName,
           M.LastName,
           M.CreatedDate       AS MemberSince,
           M.IsActive,
           T.TierName          AS Tier,
           M.PrimaryMobileNo   AS ContactNo
    FROM   dbo.LTY_Member AS M
    LEFT JOIN dbo.LTYM_MemberProfileExt AS E ON E.MemberId = M.MemberId
    LEFT JOIN dbo.LTY_Tier AS T ON T.TierId = M.TierId AND T.PropertyId = M.PropertyId
    WHERE  M.MemberId   = @MemberId
      AND  M.PropertyId = @PropertyId;
END

GO

