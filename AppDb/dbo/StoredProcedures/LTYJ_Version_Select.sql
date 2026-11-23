/*  The frozen definition a run executes against.

    Returns GraphJson rather than the node and edge rows: the engine reads the
    snapshot taken at publish, so an edit to the draft cannot change what a member
    already in flight is following. The worker caches this by VersionId, which is
    safe precisely because a published version is immutable.                      */
CREATE PROCEDURE dbo.LTYJ_Version_Select
    @VersionId int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT v.VersionId,
           v.JourneyId,
           v.PropertyId,
           v.VersionNo,
           v.Status,
           v.GraphJson,
           v.TriggerJson,
           v.ExitRulesJson,
           v.ReEntryPolicy,
           v.ReEntryPeriodDays,
           j.Name        AS JourneyName,
           j.Status      AS JourneyStatus
    FROM   dbo.LTYJ_JourneyVersion AS v
    INNER JOIN dbo.LTYJ_Journey    AS j ON j.JourneyId = v.JourneyId
    WHERE  v.VersionId = @VersionId;
END

GO

