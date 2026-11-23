/*  Soft delete one version, or the whole code.

    Refused when ANY journey references the code — not only a live one. A draft
    journey that names a deleted template would validate as broken the moment
    somebody tried to publish it, with an error about content that no longer
    exists and no way to see what it used to be.

    Soft, so history survives: LTYC_Dispatch rows carry TemplateId, and a hard
    delete would leave sent messages pointing at nothing.                        */
CREATE PROCEDURE dbo.LTYC_Template_Delete
    @PropertyId  int,
    @TemplateId  int = NULL,
    @Code        varchar(60) = NULL,
    @Channel     varchar(20) = NULL,
    @ActionBy    int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF (@TemplateId IS NULL AND NULLIF(LTRIM(RTRIM(ISNULL(@Code, ''))), '') IS NULL)
        THROW 50719, 'Pass either a template id or a code.', 1;

    IF (@TemplateId IS NOT NULL)
        SELECT @Code = Code, @Channel = Channel
        FROM   dbo.LTYC_Template
        WHERE  TemplateId = @TemplateId AND PropertyId = @PropertyId AND IsDeleted = 0;

    IF (@Code IS NULL)
        THROW 50720, 'That template no longer exists.', 1;

    DECLARE @Referencing int =
    (
        SELECT COUNT(DISTINCT j.JourneyId)
        FROM   dbo.LTYJ_Node AS n
        INNER JOIN dbo.LTYJ_JourneyVersion AS v ON v.VersionId = n.VersionId
        INNER JOIN dbo.LTYJ_Journey        AS j ON j.JourneyId = v.JourneyId
        WHERE  j.PropertyId = @PropertyId AND j.IsDeleted = 0
          AND  ISJSON(n.ConfigJson) = 1
          AND  JSON_VALUE(n.ConfigJson, '$.templateCode') = @Code
    );

    IF (@Referencing > 0)
        THROW 50721, 'Journeys still reference this template. Change those steps first.', 1;

    /*  A specific version, or the whole code. Deleting one version of a code that
        journeys do not use is the normal way to discard an abandoned draft.      */
    UPDATE dbo.LTYC_Template
    SET    IsDeleted = 1, IsActive = 0, ModifiedBy = @ActionBy, ModifiedDate = SYSUTCDATETIME()
    WHERE  PropertyId = @PropertyId
      AND  IsDeleted = 0
      AND  ((@TemplateId IS NOT NULL AND TemplateId = @TemplateId)
            OR (@TemplateId IS NULL AND Code = @Code AND (@Channel IS NULL OR Channel = @Channel)));

    SELECT Deleted = @@ROWCOUNT;
END

GO

