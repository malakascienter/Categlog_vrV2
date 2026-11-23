CREATE PROCEDURE dbo.LTYJ_Journey_Versions
    @JourneyId  int,
    @PropertyId int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT v.VersionId,
           v.VersionNo,
           v.Status,
           v.PublishedDate,
           v.RetiredDate,
           v.CreatedDate,
           (SELECT COUNT(*) FROM dbo.LTYJ_Node WHERE VersionId = v.VersionId) AS NodeCount,
           -- Runs still executing against this version, which is why a retired
           -- version cannot simply be discarded.
           (SELECT COUNT(*) FROM dbo.LTYJ_Run
            WHERE VersionId = v.VersionId AND Status IN ('ACTIVE','WAITING'))  AS LiveRunCount,
           (SELECT COUNT(*) FROM dbo.LTYJ_Run WHERE VersionId = v.VersionId)   AS TotalRunCount
    FROM   dbo.LTYJ_JourneyVersion AS v
    INNER JOIN dbo.LTYJ_Journey    AS j ON j.JourneyId = v.JourneyId
    WHERE  v.JourneyId = @JourneyId AND j.PropertyId = @PropertyId
    ORDER BY v.VersionNo DESC;
END

GO

