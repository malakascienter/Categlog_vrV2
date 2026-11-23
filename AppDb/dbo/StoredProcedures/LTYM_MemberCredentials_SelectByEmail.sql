
CREATE   PROCEDURE [dbo].[LTYM_MemberCredentials_SelectByEmail]
    @Email      VARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;


    -- PropertyId is not part of this module's interface; the portal is single-property.
    DECLARE @PropertyId INT = dbo.LTYM_fn_DefaultPropertyId();
    SELECT MC.Id,
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
    FROM   dbo.LTYM_MemberCredentials AS MC
    INNER JOIN dbo.LTY_Member AS M ON M.MemberId = MC.MemberId
    LEFT  JOIN dbo.LTY_Tier   AS T ON T.TierId   = M.TierId AND T.PropertyId = M.PropertyId
    WHERE  MC.Email     = @Email
      AND  M.PropertyId = @PropertyId;
END

GO

