/*  Insert or update a definition, and keep its segment-registry row in step.

    The registry row is the whole point: the moment a definition is saved with
    IsSegmentable, the field appears in the segment builder with the operators
    its type allows, and the compiler resolves it through the expression written
    here. Clearing IsSegmentable deactivates that row rather than deleting it, so
    a segment already built on the field keeps working and stops being offered
    for new ones.

    The expression interpolates the integer AttributeId and nothing else.        */
CREATE PROCEDURE dbo.LTYC_MemberAttribute_Save
    @AttributeId      int = NULL,
    @PropertyId       int,
    @AttributeCode    varchar(50),
    @DisplayName      nvarchar(200),
    @Description      nvarchar(1000) = NULL,
    @DataType         varchar(20),
    @InputType        varchar(20),
    @OptionsJson      nvarchar(max) = NULL,
    @IsRequired       bit = 0,
    @IsSegmentable    bit = 1,
    @IsPersonalisable bit = 0,
    @SortOrder        int = 100,
    @IsActive         bit = 1,
    @ActionBy         int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        SET @AttributeCode = LTRIM(RTRIM(ISNULL(@AttributeCode, '')));

        /*  The code becomes a personalisation token and part of a segment
            attribute code, so it is constrained to what both can carry -- and,
            because it is the one piece of this that ends up near generated SQL,
            it is checked before anything is written rather than escaped later.  */
        IF (@AttributeCode = '' OR @AttributeCode LIKE '%[^A-Za-z0-9_]%' OR @AttributeCode LIKE '[^A-Za-z]%')
        BEGIN
            THROW 50601, 'The attribute code must start with a letter and contain only letters, numbers and underscores.', 1;
        END

        IF (NULLIF(LTRIM(RTRIM(ISNULL(@DisplayName, ''))), '') IS NULL)
        BEGIN
            THROW 50602, 'A display name is required.', 1;
        END

        IF (@DataType NOT IN ('STRING', 'INT', 'DECIMAL', 'DATE', 'BOOL', 'ENUM'))
        BEGIN
            THROW 50603, 'That data type is not supported.', 1;
        END

        IF (@InputType NOT IN ('TEXT', 'TEXTAREA', 'NUMBER', 'DATE', 'CHECKBOX', 'SELECT', 'MULTISELECT'))
        BEGIN
            THROW 50604, 'That input type is not supported.', 1;
        END

        -- A chooser with nothing to choose from is a dead control.
        IF (@InputType IN ('SELECT', 'MULTISELECT')
            AND (NULLIF(LTRIM(RTRIM(ISNULL(@OptionsJson, ''))), '') IS NULL
                 OR ISJSON(@OptionsJson) <> 1
                 OR NOT EXISTS (SELECT 1 FROM OPENJSON(@OptionsJson))))
        BEGIN
            THROW 50605, 'A list field needs at least one option.', 1;
        END

        IF EXISTS (SELECT 1 FROM dbo.LTYC_MemberAttribute
                   WHERE PropertyId    = @PropertyId
                     AND AttributeCode = @AttributeCode
                     AND IsDeleted     = 0
                     AND (@AttributeId IS NULL OR AttributeId <> @AttributeId))
        BEGIN
            THROW 50606, 'Another attribute already uses that code.', 1;
        END

        IF (@AttributeId IS NULL OR @AttributeId = 0)
        BEGIN
            INSERT INTO dbo.LTYC_MemberAttribute
                (PropertyId, AttributeCode, DisplayName, Description, DataType, InputType,
                 OptionsJson, IsRequired, IsSegmentable, IsPersonalisable, SortOrder, IsActive, CreatedBy)
            VALUES
                (@PropertyId, @AttributeCode, @DisplayName, @Description, @DataType, @InputType,
                 @OptionsJson, @IsRequired, @IsSegmentable, @IsPersonalisable, @SortOrder, @IsActive, @ActionBy);

            SET @AttributeId = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.LTYC_MemberAttribute
                           WHERE AttributeId = @AttributeId AND PropertyId = @PropertyId AND IsDeleted = 0)
            BEGIN
                THROW 50607, 'This attribute no longer exists.', 1;
            END

            UPDATE dbo.LTYC_MemberAttribute
            SET    AttributeCode    = @AttributeCode,
                   DisplayName      = @DisplayName,
                   Description      = @Description,
                   DataType         = @DataType,
                   InputType        = @InputType,
                   OptionsJson      = @OptionsJson,
                   IsRequired       = @IsRequired,
                   IsSegmentable    = @IsSegmentable,
                   IsPersonalisable = @IsPersonalisable,
                   SortOrder        = @SortOrder,
                   IsActive         = @IsActive,
                   ModifiedBy       = @ActionBy,
                   ModifiedDate     = SYSUTCDATETIME()
            WHERE  AttributeId = @AttributeId;
        END

        EXEC dbo.LTYC_MemberAttribute_SyncRegistry @AttributeId = @AttributeId;

        COMMIT TRANSACTION;

        SELECT @AttributeId AS AttributeId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END

GO

