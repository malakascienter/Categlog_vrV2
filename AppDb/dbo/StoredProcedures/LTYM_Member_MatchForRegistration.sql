
CREATE   PROCEDURE dbo.LTYM_Member_MatchForRegistration
    @Identifier VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;


    -- PropertyId is not part of this module's interface; the portal is single-property.
    DECLARE @PropertyId INT = dbo.LTYM_fn_DefaultPropertyId();
    DECLARE @TelAlt VARCHAR(15) = dbo.LTYM_fn_TelNoAlternate(@Identifier);

    SELECT TOP (1)
           M.MemberId,
           M.MembershipCode                       AS MembershipNo,
           M.FirstName,
           M.LastName,
           M.Email,
           M.PrimaryMobileNo                      AS ContactNo,
           CAST(CASE WHEN MC.MemberId IS NULL THEN 0 ELSE 1 END AS BIT) AS HasCredentials
    FROM   dbo.LTY_Member AS M
    LEFT JOIN dbo.LTYM_MemberCredentials AS MC ON MC.MemberId = M.MemberId
    WHERE  M.PropertyId = @PropertyId
      AND  M.IsActive   = 1
      AND (M.MembershipCode  = @Identifier
           OR M.PrimaryMobileNo = @Identifier
           OR (@TelAlt IS NOT NULL AND M.PrimaryMobileNo = @TelAlt))
    ORDER BY M.MemberId;
END

GO

