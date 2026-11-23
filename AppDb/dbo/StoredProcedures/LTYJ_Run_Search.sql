/*  The operational view: which members are in this journey, and where.

    Paged, with the total as a second result set, matching the QueryPagedAsync
    shape the Member Portal uses.                                                */
CREATE PROCEDURE dbo.LTYJ_Run_Search
    @JourneyId  int,
    @PropertyId int,
    @Status     varchar(20) = NULL,
    @NodeKey    varchar(50) = NULL,
    @Page       int = 1,
    @PageSize   int = 25
AS
BEGIN
    SET NOCOUNT ON;

    IF (@Page < 1) SET @Page = 1;
    IF (@PageSize < 1 OR @PageSize > 200) SET @PageSize = 25;

    SELECT r.RunId,
           r.MemberId,
           m.MembershipCode,
           CONCAT(m.FirstName, ' ', m.LastName) AS MemberName,
           r.Status,
           r.CurrentNodeKey,
           r.NextRunAt,
           r.EnteredAt,
           r.EndedAt,
           r.ExitReason,
           r.AttemptCount,
           r.LastError,
           r.VersionId
    FROM   dbo.LTYJ_Run AS r
    LEFT JOIN dbo.LTY_Member AS m ON m.MemberId = r.MemberId
    WHERE  r.JourneyId  = @JourneyId
      AND  r.PropertyId = @PropertyId
      AND  (@Status  IS NULL OR r.Status = @Status)
      AND  (@NodeKey IS NULL OR r.CurrentNodeKey = @NodeKey)
    ORDER BY r.EnteredAt DESC, r.RunId DESC
    OFFSET (@Page - 1) * @PageSize ROWS FETCH NEXT @PageSize ROWS ONLY;

    SELECT COUNT(*)
    FROM   dbo.LTYJ_Run AS r
    WHERE  r.JourneyId  = @JourneyId
      AND  r.PropertyId = @PropertyId
      AND  (@Status  IS NULL OR r.Status = @Status)
      AND  (@NodeKey IS NULL OR r.CurrentNodeKey = @NodeKey);
END

GO

