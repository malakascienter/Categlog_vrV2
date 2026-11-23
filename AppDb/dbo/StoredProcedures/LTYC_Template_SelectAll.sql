/*  The template grid: one row per code, describing the code rather than a version.

    A code is the unit an author thinks about and the unit a journey references, so
    the grid shows the live version and the draft alongside each other. Listing
    every version instead would put five rows on screen for one piece of content
    and make "is this sendable" a question you had to work out.                  */
CREATE PROCEDURE dbo.LTYC_Template_SelectAll
    @PropertyId int,
    @Channel    varchar(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT t.Code,
           t.Channel,
           -- The newest version's name, so a rename in the draft is visible.
           Name             = MAX(CASE WHEN t.VersionNo = mx.MaxVersion THEN t.Name END),
           LatestVersionNo  = mx.MaxVersion,
           PublishedVersion = MAX(CASE WHEN t.Status = 'PUBLISHED' THEN t.VersionNo END),
           DraftVersion     = MAX(CASE WHEN t.Status = 'DRAFT'     THEN t.VersionNo END),
           -- The id an editor should open: the draft if there is one, else the
           -- published version. Matches what GetJourney does.
           EditTemplateId   = COALESCE(
                                MAX(CASE WHEN t.Status = 'DRAFT'     THEN t.TemplateId END),
                                MAX(CASE WHEN t.Status = 'PUBLISHED' THEN t.TemplateId END),
                                MAX(t.TemplateId)),
           IsActive         = MAX(CASE WHEN t.VersionNo = mx.MaxVersion THEN CONVERT(int, t.IsActive) END),
           /*  Sendable means exactly what the queue requires: a PUBLISHED and
               active version exists. Anything else, however complete it looks in
               the editor, cannot reach a member.                                */
           IsSendable       = CAST(MAX(CASE WHEN t.Status = 'PUBLISHED' AND t.IsActive = 1
                                            THEN 1 ELSE 0 END) AS bit),
           VersionCount     = COUNT(*),
           LastModifiedAt   = MAX(ISNULL(t.ModifiedDate, t.CreatedDate)),
           -- How many journey steps name this code, so an author can see whether
           -- anything depends on it before touching it.
           UsedByStepCount  = (SELECT COUNT(*)
                               FROM   dbo.LTYJ_Node AS n
                               INNER JOIN dbo.LTYJ_JourneyVersion AS v ON v.VersionId = n.VersionId
                               INNER JOIN dbo.LTYJ_Journey AS j ON j.JourneyId = v.JourneyId
                               WHERE  j.PropertyId = @PropertyId AND j.IsDeleted = 0
                                 AND  ISJSON(n.ConfigJson) = 1
                                 AND  JSON_VALUE(n.ConfigJson, '$.templateCode') = t.Code)
    FROM   dbo.LTYC_Template AS t
    CROSS APPLY (SELECT MAX(t2.VersionNo) AS MaxVersion
                 FROM   dbo.LTYC_Template AS t2
                 WHERE  t2.PropertyId = t.PropertyId AND t2.Code = t.Code
                   AND  t2.Channel = t.Channel AND t2.IsDeleted = 0) AS mx
    WHERE  t.PropertyId = @PropertyId
      AND  t.IsDeleted  = 0
      AND  (@Channel IS NULL OR t.Channel = @Channel)
    GROUP BY t.Code, t.Channel, mx.MaxVersion
    ORDER BY t.Channel, t.Code;
END

GO

