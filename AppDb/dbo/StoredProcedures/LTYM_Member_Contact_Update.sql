
CREATE   PROCEDURE [dbo].[LTYM_Member_Contact_Update]
    @MemberId     INT,
    @Email        VARCHAR(150),
    @ContactNo    VARCHAR(15),
    @AddressLine1 NVARCHAR(200) = NULL,
    @AddressLine2 NVARCHAR(200) = NULL,
    @City         NVARCHAR(100) = NULL,
    @ProvinceId   INT = NULL,
    @CountryId    INT = NULL,
    @ModifyBy     INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    -- PropertyId is not part of this module's interface; it comes from the member row.
    DECLARE @PropertyId INT = (SELECT TOP (1) PropertyId FROM dbo.LTY_Member WHERE MemberId = @MemberId);
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @TelAlt VARCHAR(15) = dbo.LTYM_fn_TelNoAlternate(@ContactNo);

        IF EXISTS (SELECT 1 FROM dbo.LTY_Member
                   WHERE PropertyId = @PropertyId
                     AND MemberId  <> @MemberId
                     AND PrimaryMobileNo IN (@ContactNo, @TelAlt))
            THROW 52021, 'This mobile number is already registered to another member.', 1;

        DECLARE @Composed VARCHAR(MAX) =
            NULLIF(LTRIM(RTRIM(CONCAT(
                ISNULL(@AddressLine1, ''),
                CASE WHEN NULLIF(@AddressLine2, '') IS NOT NULL THEN ', ' + @AddressLine2 ELSE '' END,
                CASE WHEN NULLIF(@City, '')         IS NOT NULL THEN ', ' + @City         ELSE '' END))), '');

        UPDATE dbo.LTY_Member
        SET    Email           = @Email,
               PrimaryMobileNo = @ContactNo,
               Address         = ISNULL(@Composed, Address),
               ModifyBy        = @ModifyBy,
               ModifyDate      = GETDATE()
        WHERE  MemberId   = @MemberId
          AND  PropertyId = @PropertyId;

        IF @@ROWCOUNT = 0
            THROW 52020, 'Member not found.', 1;

        IF EXISTS (SELECT 1 FROM dbo.LTYM_MemberProfileExt WHERE MemberId = @MemberId)
            UPDATE dbo.LTYM_MemberProfileExt
            SET    AddressLine1 = @AddressLine1,
                   AddressLine2 = @AddressLine2,
                   City         = @City,
                   ProvinceId   = @ProvinceId,
                   CountryId    = @CountryId,
                   UpdatedAt    = SYSUTCDATETIME()
            WHERE  MemberId     = @MemberId;
        ELSE
            INSERT INTO dbo.LTYM_MemberProfileExt (MemberId, AddressLine1, AddressLine2, City, ProvinceId, CountryId)
            VALUES (@MemberId, @AddressLine1, @AddressLine2, @City, @ProvinceId, @CountryId);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END

GO

