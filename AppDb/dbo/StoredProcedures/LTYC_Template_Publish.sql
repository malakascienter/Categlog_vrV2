/*  Make a draft sendable, and retire whatever it replaces.

    Content completeness is enforced HERE rather than on save, because this is the
    point at which a member can receive it. The requirements differ by channel and
    are not arbitrary:

      EMAIL  needs a subject and a body. An email with no subject line lands as
             "(no subject)" and is the first thing a spam filter notices.
      PUSH   needs a title and a body. Both are shown on the lock screen; a push
             with an empty body is a notification that says nothing.
      INAPP  needs a title, because LTYM_MemberNotifications renders the title in
             the list — a template with no subject produces a blank inbox row the
             member cannot act on or explain.
      SMS    needs body text only. There is no subject on an SMS.

    At most one PUBLISHED version per code, enforced by retiring the previous one
    in the same transaction. LTYC_Dispatch_Queue orders by VersionNo DESC, so two
    published versions would not error - it would silently pick one, which is
    worse than failing.                                                          */
CREATE PROCEDURE dbo.LTYC_Template_Publish
    @PropertyId int,
    @TemplateId int,
    @ActionBy   int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Code varchar(60), @Channel varchar(20), @Status varchar(20), @VersionNo int;
    DECLARE @Subject nvarchar(600), @BodyHtml nvarchar(max), @BodyText nvarchar(max);

    SELECT @Code = t.Code, @Channel = t.Channel, @Status = t.Status, @VersionNo = t.VersionNo,
           @Subject = t.Subject, @BodyHtml = t.BodyHtml, @BodyText = t.BodyText
    FROM   dbo.LTYC_Template AS t
    WHERE  t.TemplateId = @TemplateId AND t.PropertyId = @PropertyId AND t.IsDeleted = 0;

    IF (@Code IS NULL)
        THROW 50708, 'That template no longer exists.', 1;

    IF (@Status = 'PUBLISHED')
        THROW 50709, 'That version is already published.', 1;

    IF (@Status <> 'DRAFT')
        THROW 50710, 'Only a draft can be published.', 1;

    DECLARE @HasSubject bit = CASE WHEN NULLIF(LTRIM(RTRIM(ISNULL(@Subject, N''))), N'') IS NULL THEN 0 ELSE 1 END;
    DECLARE @HasBody    bit = CASE WHEN NULLIF(LTRIM(RTRIM(ISNULL(@BodyHtml, N''))), N'') IS NULL
                                    AND NULLIF(LTRIM(RTRIM(ISNULL(@BodyText, N''))), N'') IS NULL
                                   THEN 0 ELSE 1 END;
    DECLARE @HasText    bit = CASE WHEN NULLIF(LTRIM(RTRIM(ISNULL(@BodyText, N''))), N'') IS NULL THEN 0 ELSE 1 END;

    IF (@Channel = 'EMAIL')
    BEGIN
        IF (@HasSubject = 0) THROW 50711, 'An email template needs a subject line.', 1;
        IF (@HasBody    = 0) THROW 50712, 'An email template needs a body.', 1;
    END
    ELSE IF (@Channel = 'PUSH')
    BEGIN
        IF (@HasSubject = 0) THROW 50713, 'A push template needs a title. It is what the member sees first.', 1;
        IF (@HasText    = 0) THROW 50714, 'A push template needs body text.', 1;
    END
    ELSE IF (@Channel = 'INAPP')
    BEGIN
        IF (@HasSubject = 0) THROW 50715, 'An in-app template needs a title, or it shows as a blank row in the member inbox.', 1;
    END
    ELSE IF (@Channel = 'SMS')
    BEGIN
        IF (@HasText = 0) THROW 50716, 'An SMS template needs body text.', 1;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Retire the version this one replaces, in the same transaction, so there
        -- is never a moment with two published versions of one code.
        UPDATE dbo.LTYC_Template
        SET    Status = 'RETIRED', ModifiedBy = @ActionBy, ModifiedDate = SYSUTCDATETIME()
        WHERE  PropertyId = @PropertyId AND Code = @Code AND Channel = @Channel
          AND  Status = 'PUBLISHED' AND TemplateId <> @TemplateId AND IsDeleted = 0;

        UPDATE dbo.LTYC_Template
        SET    Status = 'PUBLISHED', IsActive = 1,
               ModifiedBy = @ActionBy, ModifiedDate = SYSUTCDATETIME()
        WHERE  TemplateId = @TemplateId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH

    SELECT TemplateId = @TemplateId, Code = @Code, VersionNo = @VersionNo, Status = 'PUBLISHED';
END

GO

