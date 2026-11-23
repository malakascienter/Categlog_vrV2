
CREATE   PROCEDURE [dbo].[LTYM_Notifications_SelectPaged]
    @MemberId   INT,
    @UnreadOnly BIT = 0,
    @Page       INT = 1,
    @PageSize   INT = 20
AS
BEGIN
    SET NOCOUNT ON;

    IF @Page < 1 SET @Page = 1;
    IF @PageSize < 1 OR @PageSize > 100 SET @PageSize = 20;

    SELECT N.Id, N.Title, N.Body, N.Type, N.IsRead, N.CreatedAt
    FROM   dbo.LTYM_MemberNotifications AS N
    WHERE  N.MemberId  = @MemberId
      AND  N.IsDeleted = 0
      AND (@UnreadOnly = 0 OR N.IsRead = 0)
    ORDER BY N.Id DESC
    OFFSET (@Page - 1) * @PageSize ROWS FETCH NEXT @PageSize ROWS ONLY;

    SELECT COUNT(*)
    FROM   dbo.LTYM_MemberNotifications AS N
    WHERE  N.MemberId  = @MemberId
      AND  N.IsDeleted = 0
      AND (@UnreadOnly = 0 OR N.IsRead = 0);
END

GO

