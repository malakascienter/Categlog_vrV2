/*  Replace one member's custom answers.

    @ValuesJson is [{"attributeCode":"TasteProfile","value":"[\"Spicy\"]"}, ...].
    Keyed by CODE rather than by id, because that is what the member form holds
    and what survives an export/import between environments where ids differ.

    A blank value CLEARS the answer rather than storing an empty string, so
    "never told us" and "told us nothing" do not become two different states that
    a segment on IS_NULL would have to know about.

    Only attributes named in the payload are touched. A form that renders three
    fields cannot wipe a fourth it never showed.                                 */
CREATE PROCEDURE dbo.LTYC_MemberAttributeValue_Save
    @MemberId   int,
    @PropertyId int,
    @ValuesJson nvarchar(max) = N'[]',
    @ActionBy   int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM dbo.LTY_Member
                       WHERE MemberId = @MemberId AND PropertyId = @PropertyId)
        BEGIN
            THROW 50609, 'This member no longer exists.', 1;
        END

        IF (ISJSON(ISNULL(@ValuesJson, '')) <> 1)
        BEGIN
            THROW 50610, 'The attribute values could not be read.', 1;
        END

        DECLARE @Incoming TABLE (AttributeId int PRIMARY KEY, ValueText nvarchar(max) NULL);

        INSERT INTO @Incoming (AttributeId, ValueText)
        SELECT a.AttributeId,
               NULLIF(LTRIM(RTRIM(ISNULL(j.[value], ''))), '')
        FROM OPENJSON(@ValuesJson)
        WITH (
            attributeCode varchar(50)   '$.attributeCode',
            [value]       nvarchar(max) '$.value'
        ) AS j
        INNER JOIN dbo.LTYC_MemberAttribute AS a
            ON a.AttributeCode = j.attributeCode
           AND a.PropertyId    = @PropertyId
           AND a.IsDeleted     = 0
           AND a.IsActive      = 1;

        -- A required field cannot be left blank once it is being answered.
        IF EXISTS (SELECT 1
                   FROM @Incoming AS i
                   INNER JOIN dbo.LTYC_MemberAttribute AS a ON a.AttributeId = i.AttributeId
                   WHERE a.IsRequired = 1 AND i.ValueText IS NULL)
        BEGIN
            DECLARE @Missing nvarchar(200) =
                (SELECT TOP (1) a.DisplayName
                 FROM @Incoming AS i
                 INNER JOIN dbo.LTYC_MemberAttribute AS a ON a.AttributeId = i.AttributeId
                 WHERE a.IsRequired = 1 AND i.ValueText IS NULL);

            DECLARE @Message nvarchar(300) = @Missing + N' is required.';
            THROW 50611, @Message, 1;
        END

        DELETE v
        FROM   dbo.LTYC_MemberAttributeValue AS v
        INNER JOIN @Incoming AS i ON i.AttributeId = v.AttributeId
        WHERE  v.MemberId = @MemberId
          AND  i.ValueText IS NULL;

        MERGE dbo.LTYC_MemberAttributeValue AS t
        USING (SELECT AttributeId, ValueText FROM @Incoming WHERE ValueText IS NOT NULL) AS s
            ON t.MemberId = @MemberId AND t.AttributeId = s.AttributeId
        WHEN MATCHED THEN
            UPDATE SET ValueText = s.ValueText, ModifiedBy = @ActionBy, ModifiedDate = SYSUTCDATETIME()
        WHEN NOT MATCHED THEN
            INSERT (MemberId, AttributeId, PropertyId, ValueText, ModifiedBy)
            VALUES (@MemberId, s.AttributeId, @PropertyId, s.ValueText, @ActionBy);

        COMMIT TRANSACTION;

        SELECT @MemberId AS MemberId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END

GO

