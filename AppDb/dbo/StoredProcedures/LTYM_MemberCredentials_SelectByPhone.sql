
CREATE   PROCEDURE [dbo].[LTYM_MemberCredentials_SelectByPhone]
    @ContactNo  VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;


    -- PropertyId is not part of this module's interface; the portal is single-property.
    DECLARE @PropertyId INT = dbo.LTYM_fn_DefaultPropertyId();
    DECLARE @TelAlt VARCHAR(15) = dbo.LTYM_fn_TelNoAlternate(@ContactNo);

    SELECT TOP (1)
           MC.Id,
           MC.MemberId,
           MC.Email,
           MC.PasswordHash,
           MC.IsVerified,
           MC.FailedAttempts,
           MC.LockoutEnd,
           M.MembershipCode AS MembershipNo,
           M.FirstName,
           M.LastName,
           M.TierId         AS CategoryId,
           T.TierName       AS CategoryName
    FROM   dbo.LTY_Member AS M
    INNER JOIN dbo.LTYM_MemberCredentials AS MC ON MC.MemberId = M.MemberId
    LEFT  JOIN dbo.LTY_Tier AS T ON T.TierId = M.TierId AND T.PropertyId = M.PropertyId
    WHERE  M.PropertyId = @PropertyId
      AND  M.PrimaryMobileNo IN (@ContactNo, @TelAlt)
    ORDER BY MC.Id;
END

GO

