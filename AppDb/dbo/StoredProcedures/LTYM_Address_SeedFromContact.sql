
CREATE   PROCEDURE [dbo].[LTYM_Address_SeedFromContact]
    @MemberId   INT
AS
BEGIN
    SET NOCOUNT ON;


    -- PropertyId is not part of this module's interface; the portal is single-property.
    DECLARE @PropertyId INT = dbo.LTYM_fn_DefaultPropertyId();
    IF EXISTS (SELECT 1 FROM dbo.LTYM_MemberAddresses WHERE MemberId = @MemberId AND IsDeleted = 0)
        RETURN;

    INSERT INTO dbo.LTYM_MemberAddresses
          (MemberId, Label, AddressLine1, AddressLine2, City, ProvinceId, CountryId, ContactNo, IsDefault)
    SELECT M.MemberId,
           N'Home',
           LEFT(COALESCE(NULLIF(E.AddressLine1, N''), NULLIF(M.Address, ''), ''), 200),
           E.AddressLine2,
           E.City,
           E.ProvinceId,
           E.CountryId,
           M.PrimaryMobileNo,
           1
    FROM   dbo.LTY_Member AS M
    LEFT JOIN dbo.LTYM_MemberProfileExt AS E ON E.MemberId = M.MemberId
    WHERE  M.MemberId   = @MemberId
      AND  M.PropertyId = @PropertyId
      AND  COALESCE(NULLIF(E.AddressLine1, N''), NULLIF(M.Address, '')) IS NOT NULL;
END

GO

