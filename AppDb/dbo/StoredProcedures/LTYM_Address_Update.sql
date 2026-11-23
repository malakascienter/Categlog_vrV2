
CREATE   PROCEDURE [dbo].[LTYM_Address_Update]
    @MemberId     INT,
    @Id           INT,
    @Label        NVARCHAR(50),
    @AddressLine1 NVARCHAR(200),
    @AddressLine2 NVARCHAR(200) = NULL,
    @City         NVARCHAR(100) = NULL,
    @ProvinceId   INT = NULL,
    @CountryId    INT = NULL,
    @ContactNo    VARCHAR(15) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.LTYM_MemberAddresses
    SET    Label        = @Label,
           AddressLine1 = @AddressLine1,
           AddressLine2 = @AddressLine2,
           City         = @City,
           ProvinceId   = @ProvinceId,
           CountryId    = @CountryId,
           ContactNo    = @ContactNo,
           UpdatedAt    = SYSUTCDATETIME()
    WHERE  Id = @Id AND MemberId = @MemberId AND IsDeleted = 0;

    IF @@ROWCOUNT = 0
        THROW 52041, 'Address not found.', 1;
END

GO

