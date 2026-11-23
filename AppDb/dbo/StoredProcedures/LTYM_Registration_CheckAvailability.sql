
CREATE   PROCEDURE dbo.LTYM_Registration_CheckAvailability
    @TelNo      VARCHAR(15),
    @Email      VARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;


    -- PropertyId is not part of this module's interface; the portal is single-property.
    DECLARE @PropertyId INT = dbo.LTYM_fn_DefaultPropertyId();
    DECLARE @TelAlt VARCHAR(15) = dbo.LTYM_fn_TelNoAlternate(@TelNo);

    SELECT
        CAST(CASE WHEN EXISTS (SELECT 1 FROM dbo.LTY_Member M
                               WHERE M.PropertyId = @PropertyId
                                 AND M.IsActive   = 1
                                 AND M.PrimaryMobileNo IN (@TelNo, @TelAlt))
             THEN 1 ELSE 0 END AS BIT) AS IsExistingMember,
        CAST(CASE WHEN EXISTS (SELECT 1 FROM dbo.LTYM_MemberCredentials WHERE Email = @Email)
             THEN 1 ELSE 0 END AS BIT) AS EmailTaken;
END

GO

