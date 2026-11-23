
CREATE   PROCEDURE [dbo].[LTYM_Otp_Verify]
    @Recipient   VARCHAR(150),
    @Purpose     VARCHAR(20),
    @CodeHash    VARCHAR(128),
    @MaxAttempts INT = 5
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MemberId INT;

    UPDATE dbo.LTYM_OtpVerification
    SET    ConsumedAt = SYSUTCDATETIME(),
           @MemberId  = MemberId
    WHERE  Recipient    = @Recipient
      AND  Purpose      = @Purpose
      AND  CodeHash     = @CodeHash
      AND  ConsumedAt IS NULL
      AND  ExpiresAt    > SYSUTCDATETIME()
      AND  AttemptCount < @MaxAttempts;

    IF @@ROWCOUNT = 1
    BEGIN
        SELECT 1 AS Result, @MemberId AS MemberId;
        RETURN;
    END

    UPDATE T
    SET    AttemptCount = AttemptCount + 1
    FROM  (SELECT TOP (1) *
           FROM   dbo.LTYM_OtpVerification
           WHERE  Recipient = @Recipient AND Purpose = @Purpose AND ConsumedAt IS NULL
           ORDER BY Id DESC) AS T;

    SELECT CASE WHEN EXISTS (SELECT 1 FROM dbo.LTYM_OtpVerification
                             WHERE Recipient = @Recipient AND Purpose = @Purpose
                               AND ConsumedAt IS NULL AND AttemptCount >= @MaxAttempts)
                THEN -1 ELSE 0 END AS Result,
           CAST(NULL AS INT) AS MemberId;
END

GO

