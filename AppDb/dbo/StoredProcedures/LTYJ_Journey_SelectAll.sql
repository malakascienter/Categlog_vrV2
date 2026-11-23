/*  The journey grid. Live counts come from LTYJ_Run rather than a maintained
    counter column, because a counter that drifts from its source is worse than
    no counter.                                                                  */
CREATE PROCEDURE dbo.LTYJ_Journey_SelectAll
    @PropertyId int,
    @Status     varchar(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT j.JourneyId,
           j.Name,
           j.Description,
           j.Status,
           j.CurrentVersionId,
           v.VersionNo,
           v.PublishedDate,
           ISNULL(r.ActiveCount, 0)    AS ActiveCount,
           ISNULL(r.TotalEntrants, 0)  AS TotalEntrants,
           ISNULL(r.CompletedCount, 0) AS CompletedCount,
           ISNULL(r.ExitedCount, 0)    AS ExitedCount,
           j.CreatedDate,
           j.ModifiedDate
    FROM   dbo.LTYJ_Journey AS j
    LEFT JOIN dbo.LTYJ_JourneyVersion AS v ON v.VersionId = j.CurrentVersionId
    OUTER APPLY (
        SELECT COUNT(*)                                                             AS TotalEntrants,
               SUM(CASE WHEN x.Status IN ('ACTIVE','WAITING') THEN 1 ELSE 0 END)    AS ActiveCount,
               SUM(CASE WHEN x.Status = 'COMPLETED' THEN 1 ELSE 0 END)              AS CompletedCount,
               SUM(CASE WHEN x.Status IN ('EXITED','CANCELLED') THEN 1 ELSE 0 END)  AS ExitedCount
        FROM   dbo.LTYJ_Run AS x
        WHERE  x.JourneyId = j.JourneyId
    ) AS r
    WHERE  j.PropertyId = @PropertyId
      AND  j.IsDeleted  = 0
      AND  (@Status IS NULL OR j.Status = @Status)
    ORDER BY j.Name;
END

GO

