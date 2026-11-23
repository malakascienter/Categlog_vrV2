
CREATE   PROCEDURE [dbo].[LTYM_Address_SetDefault]
    @MemberId INT,
    @Id       INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM dbo.LTYM_MemberAddresses
                       WHERE Id = @Id AND MemberId = @MemberId AND IsDeleted = 0)
            THROW 52041, 'Address not found.', 1;

        UPDATE dbo.LTYM_MemberAddresses
        SET    IsDefault = CASE WHEN Id = @Id THEN 1 ELSE 0 END,
               UpdatedAt = SYSUTCDATETIME()
        WHERE  MemberId = @MemberId AND IsDeleted = 0;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END

GO

