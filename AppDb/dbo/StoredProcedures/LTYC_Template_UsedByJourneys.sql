/*  Which journeys reference this template code, and whether any of them is live.

    Matched on CODE, not TemplateId, because that is what a send step stores —
    a step names a code and the queue picks the newest published version, so a
    step is bound to the code for as long as it exists.

    Channel is matched too. The queue matches on both, so an EMAIL step and a
    PUSH template sharing a code are not related and must not block each other.  */
CREATE PROCEDURE dbo.LTYC_Template_UsedByJourneys
    @PropertyId int,
    @Code       varchar(60),
    @Channel    varchar(20)
AS
BEGIN
    SET NOCOUNT ON;

    -- The node type a step of this channel would be.
    DECLARE @NodeType varchar(30) =
        CASE @Channel
            WHEN 'EMAIL' THEN 'SEND_EMAIL'
            WHEN 'PUSH'  THEN 'SEND_PUSH'
            WHEN 'INAPP' THEN 'SEND_INAPP'
            ELSE NULL
        END;

    SELECT j.JourneyId,
           j.Name,
           j.Status,
           v.VersionNo,
           VersionStatus = v.Status,
           n.NodeKey,
           StepLabel     = n.Label,
           /*  A journey that is ACTIVE on a PUBLISHED version is sending this
               content to members right now. Anything else references it but is
               not acting on it, which is a materially different situation and is
               reported separately rather than lumped together.                  */
           IsLive        = CASE WHEN j.Status = 'ACTIVE' AND v.Status = 'PUBLISHED'
                                THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END
    FROM   dbo.LTYJ_Node AS n
    INNER JOIN dbo.LTYJ_JourneyVersion AS v ON v.VersionId = n.VersionId
    INNER JOIN dbo.LTYJ_Journey        AS j ON j.JourneyId = v.JourneyId
    WHERE  j.PropertyId = @PropertyId
      AND  j.IsDeleted  = 0
      AND  n.NodeType   = @NodeType
      AND  ISJSON(n.ConfigJson) = 1
      AND  JSON_VALUE(n.ConfigJson, '$.templateCode') = @Code
    ORDER BY IsLive DESC, j.Name, v.VersionNo;
END

GO

