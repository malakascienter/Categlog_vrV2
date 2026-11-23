
CREATE   PROCEDURE [dbo].[LTYM_MemberCredentials_SelectEmailByMemberId]
    @MemberId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Email
    FROM   dbo.LTYM_MemberCredentials
    WHERE  MemberId = @MemberId;
END

GO

