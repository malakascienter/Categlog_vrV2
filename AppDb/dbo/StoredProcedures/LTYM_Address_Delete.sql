
CREATE   PROCEDURE [dbo].[LTYM_Address_Delete]
    @MemberId INT,
    @Id       INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @WasDefault BIT =
            (SELECT TOP (1) IsDefault FROM dbo.LTYM_MemberAddresses
             WHERE Id = @Id AND MemberId = @MemberId AND IsDeleted = 0);

        UPDATE dbo.LTYM_MemberAddresses
        SET    IsDefault = 0,
               IsDeleted = 1,
               UpdatedAt = SYSUTCDATETIME()
        WHERE  Id = @Id AND MemberId = @MemberId AND IsDeleted = 0;

        IF @@ROWCOUNT = 0
            THROW 52041, 'Address not found.', 1;

        IF @WasDefault = 1
            UPDATE dbo.LTYM_MemberAddresses
            SET    IsDefault = 1
            WHERE  Id = (SELECT TOP (1) Id FROM dbo.LTYM_MemberAddresses
                         WHERE MemberId = @MemberId AND IsDeleted = 0
                         ORDER BY Id);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END

GO

