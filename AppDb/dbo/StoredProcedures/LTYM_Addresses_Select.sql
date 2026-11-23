
CREATE   PROCEDURE [dbo].[LTYM_Addresses_Select]
    @MemberId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT A.Id, A.Label, A.AddressLine1, A.AddressLine2, A.City,
           A.ProvinceId, P.Name        AS ProvinceName,
           A.CountryId,  C.CountryName AS CountryName,
           A.ContactNo, A.IsDefault, A.CreatedAt
    FROM   dbo.LTYM_MemberAddresses AS A
    LEFT JOIN dbo.Provinces AS P ON P.ID = A.ProvinceId
    LEFT JOIN dbo.Countries AS C ON C.Id = A.CountryId
    WHERE  A.MemberId = @MemberId AND A.IsDeleted = 0
    ORDER BY A.IsDefault DESC, A.Id;
END

GO

