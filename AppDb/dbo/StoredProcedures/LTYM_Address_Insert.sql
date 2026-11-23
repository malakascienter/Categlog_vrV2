
CREATE   PROCEDURE [dbo].[LTYM_Address_Insert]
    @MemberId     INT,
    @Label        NVARCHAR(50),
    @AddressLine1 NVARCHAR(200),
    @AddressLine2 NVARCHAR(200) = NULL,
    @City         NVARCHAR(100) = NULL,
    @ProvinceId   INT = NULL,
    @CountryId    INT = NULL,
    @ContactNo    VARCHAR(15) = NULL,
    @IsDefault    BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM dbo.LTYM_MemberAddresses WHERE MemberId = @MemberId AND IsDeleted = 0)
            SET @IsDefault = 1;

        IF @IsDefault = 1
            UPDATE dbo.LTYM_MemberAddresses
            SET    IsDefault = 0
            WHERE  MemberId = @MemberId AND IsDeleted = 0;

        INSERT INTO dbo.LTYM_MemberAddresses
              (MemberId, Label, AddressLine1, AddressLine2, City, ProvinceId, CountryId, ContactNo, IsDefault)
        VALUES (@MemberId, @Label, @AddressLine1, @AddressLine2, @City, @ProvinceId, @CountryId, @ContactNo, @IsDefault);

        DECLARE @Id INT = SCOPE_IDENTITY();

        COMMIT TRANSACTION;

        SELECT @Id AS Id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END

GO

