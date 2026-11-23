/*  Switch a template off without deleting it.

    Refused while a LIVE journey depends on it. Deactivating such a template does
    not stop the journey - the step still runs, the queue finds no publishable
    version, and every message fails with "No template resolved" until somebody
    notices. Refusing here turns a slow silent breakage into an immediate,
    readable no.

    A journey that merely references it in a draft or paused version is reported
    but does not block: nothing is being sent, and an author needs to be able to
    retire content that is no longer in use.                                      */
CREATE PROCEDURE dbo.LTYC_Template_SetActive
    @PropertyId int,
    @TemplateId int,
    @IsActive   bit,
    @ActionBy   int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Code varchar(60), @Channel varchar(20), @Status varchar(20);

    SELECT @Code = Code, @Channel = Channel, @Status = Status
    FROM   dbo.LTYC_Template
    WHERE  TemplateId = @TemplateId AND PropertyId = @PropertyId AND IsDeleted = 0;

    IF (@Code IS NULL)
        THROW 50717, 'That template no longer exists.', 1;

    IF (@IsActive = 0 AND @Status = 'PUBLISHED')
    BEGIN
        DECLARE @LiveJourneys int =
        (
            SELECT COUNT(DISTINCT j.JourneyId)
            FROM   dbo.LTYJ_Node AS n
            INNER JOIN dbo.LTYJ_JourneyVersion AS v ON v.VersionId = n.VersionId
            INNER JOIN dbo.LTYJ_Journey        AS j ON j.JourneyId = v.JourneyId
            WHERE  j.PropertyId = @PropertyId AND j.IsDeleted = 0
              AND  j.Status = 'ACTIVE' AND v.Status = 'PUBLISHED'
              AND  n.NodeType = CASE @Channel WHEN 'EMAIL' THEN 'SEND_EMAIL'
                                              WHEN 'PUSH'  THEN 'SEND_PUSH'
                                              WHEN 'INAPP' THEN 'SEND_INAPP' END
              AND  ISJSON(n.ConfigJson) = 1
              AND  JSON_VALUE(n.ConfigJson, '$.templateCode') = @Code
        );

        IF (@LiveJourneys > 0)
            THROW 50718, 'A live journey is sending this template. Pause the journey or point it at different content first.', 1;
    END

    UPDATE dbo.LTYC_Template
    SET    IsActive = @IsActive, ModifiedBy = @ActionBy, ModifiedDate = SYSUTCDATETIME()
    WHERE  TemplateId = @TemplateId;

    SELECT TemplateId = @TemplateId, IsActive = @IsActive;
END

GO

