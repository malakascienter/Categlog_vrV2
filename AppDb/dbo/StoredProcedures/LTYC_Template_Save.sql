/*  Create a template, or save the draft of an existing one.

    Three cases, and the third is the one that matters:

      - No code exists yet          -> version 1, DRAFT
      - A DRAFT exists              -> update it in place
      - Only PUBLISHED exists       -> create the NEXT version as a DRAFT

    The third case is why a published body can never change under a journey that
    is already sending it. The author does not have to know that: they press Save
    and a new draft appears, exactly as the journey builder behaves.

    Content is NOT validated here. A half-written draft must be saveable — an
    author who cannot save until the copy is finished loses work. Publishing is
    where completeness is enforced.                                              */
CREATE PROCEDURE dbo.LTYC_Template_Save
    @PropertyId int,
    @Code       varchar(60),
    @Name       nvarchar(300),
    @Channel    varchar(20),
    @Subject    nvarchar(600)   = NULL,
    @BodyHtml   nvarchar(max)   = NULL,
    @BodyText   nvarchar(max)   = NULL,
    @BlocksJson nvarchar(max)   = NULL,
    @ImageUrl   nvarchar(1000)  = NULL,
    @CtaLabel   nvarchar(200)   = NULL,
    @CtaUrl     nvarchar(1000)  = NULL,
    @DeepLink   nvarchar(1000)  = NULL,
    @ActionBy   int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @Code = UPPER(LTRIM(RTRIM(ISNULL(@Code, ''))));

    IF (NULLIF(@Code, '') IS NULL)
        THROW 50703, 'A template code is required.', 1;

    /*  Codes are upper-cased and restricted, because a send step stores one as
        free text and a code with a space or a quote in it is a code somebody will
        mistype for ever.                                                        */
    IF (@Code LIKE '%[^A-Z0-9_]%')
        THROW 50704, 'A template code may contain only letters, numbers and underscores.', 1;

    IF (NULLIF(LTRIM(RTRIM(ISNULL(@Name, N''))), N'') IS NULL)
        THROW 50705, 'A template name is required.', 1;

    IF (@Channel NOT IN ('EMAIL','PUSH','INAPP','SMS'))
        THROW 50706, 'Channel must be EMAIL, PUSH, INAPP or SMS.', 1;

    IF (@BlocksJson IS NOT NULL AND ISJSON(@BlocksJson) = 0)
        THROW 50707, 'The content blocks could not be read as JSON.', 1;

    DECLARE @TemplateId int;
    DECLARE @VersionNo  int;

    -- An existing draft for this code and channel, if there is one.
    SELECT TOP (1) @TemplateId = t.TemplateId, @VersionNo = t.VersionNo
    FROM   dbo.LTYC_Template AS t
    WHERE  t.PropertyId = @PropertyId AND t.Code = @Code AND t.Channel = @Channel
      AND  t.Status = 'DRAFT' AND t.IsDeleted = 0
    ORDER BY t.VersionNo DESC;

    IF (@TemplateId IS NOT NULL)
    BEGIN
        UPDATE dbo.LTYC_Template
        SET    Name = @Name, Subject = @Subject, BodyHtml = @BodyHtml, BodyText = @BodyText,
               BlocksJson = @BlocksJson, ImageUrl = @ImageUrl, CtaLabel = @CtaLabel,
               CtaUrl = @CtaUrl, DeepLink = @DeepLink,
               ModifiedBy = @ActionBy, ModifiedDate = SYSUTCDATETIME()
        WHERE  TemplateId = @TemplateId;
    END
    ELSE
    BEGIN
        /*  MAX over every version including deleted ones. Reusing a version
            number a deleted row still holds would collide with the unique key on
            (PropertyId, Code, VersionNo), and the author would see a constraint
            error for something they did not do.                                 */
        SELECT @VersionNo = ISNULL(MAX(t.VersionNo), 0) + 1
        FROM   dbo.LTYC_Template AS t
        WHERE  t.PropertyId = @PropertyId AND t.Code = @Code AND t.Channel = @Channel;

        INSERT INTO dbo.LTYC_Template
              (PropertyId, Code, Name, Channel, VersionNo, Status, Subject, BodyHtml, BodyText,
               BlocksJson, ImageUrl, CtaLabel, CtaUrl, DeepLink, IsActive, IsDeleted, CreatedBy)
        VALUES(@PropertyId, @Code, @Name, @Channel, @VersionNo, 'DRAFT', @Subject, @BodyHtml, @BodyText,
               @BlocksJson, @ImageUrl, @CtaLabel, @CtaUrl, @DeepLink, 1, 0, @ActionBy);

        SET @TemplateId = SCOPE_IDENTITY();
    END

    SELECT TemplateId = @TemplateId, VersionNo = @VersionNo, Code = @Code, Status = 'DRAFT';
END

GO

