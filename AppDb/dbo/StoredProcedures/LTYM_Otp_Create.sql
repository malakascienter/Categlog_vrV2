
CREATE   PROCEDURE [dbo].[LTYM_Otp_Create]
    @MemberId  INT = NULL,
    @Channel   VARCHAR(10),
    @Recipient VARCHAR(150),
    @CodeHash  VARCHAR(128),
    @Purpose   VARCHAR(20),
    @ExpiresAt DATETIME2(0)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE dbo.LTYM_OtpVerification
        SET    ConsumedAt = SYSUTCDATETIME()
        WHERE  Recipient = @Recipient AND Purpose = @Purpose AND ConsumedAt IS NULL;

        INSERT INTO dbo.LTYM_OtpVerification (MemberId, Channel, Recipient, CodeHash, Purpose, ExpiresAt)
        VALUES (@MemberId, @Channel, @Recipient, @CodeHash, @Purpose, @ExpiresAt);

        COMMIT TRANSACTION;

        SELECT SCOPE_IDENTITY() AS Id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END

GO

