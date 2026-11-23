
CREATE   PROCEDURE [dbo].[LTYM_MemberCredentials_RecordLoginAttempt]
    @Id             INT,
    @Succeeded      BIT,
    @MaxAttempts    INT = 5,
    @LockoutMinutes INT = 15
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.LTYM_MemberCredentials
    SET    FailedAttempts = CASE WHEN @Succeeded = 1 THEN 0 ELSE FailedAttempts + 1 END,
           LockoutEnd     = CASE WHEN @Succeeded = 1 THEN NULL
                                 WHEN FailedAttempts + 1 >= @MaxAttempts
                                     THEN DATEADD(MINUTE, @LockoutMinutes, SYSUTCDATETIME())
                                 ELSE LockoutEnd END,
           UpdatedAt      = SYSUTCDATETIME()
    WHERE  Id = @Id;
END

GO

