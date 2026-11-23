CREATE PROCEDURE dbo.LTYC_ContentBlock_Save
    @PropertyId       int,
    @BlockId          int = 0,
    @Code             varchar(60),
    @Name             nvarchar(300),
    @BlockType        varchar(30),
    @BodyHtml         nvarchar(max),
    @ParamsSchemaJson nvarchar(max) = NULL,
    @IsActive         bit = 1,
    @ActionBy         int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @Code = UPPER(LTRIM(RTRIM(ISNULL(@Code, ''))));

    IF (NULLIF(@Code, '') IS NULL)
        THROW 50722, 'A block code is required.', 1;

    IF (@Code LIKE '%[^A-Z0-9_]%')
        THROW 50723, 'A block code may contain only letters, numbers and underscores.', 1;

    IF (NULLIF(LTRIM(RTRIM(ISNULL(@BodyHtml, N''))), N'') IS NULL)
        THROW 50724, 'A block needs content.', 1;

    IF (@ParamsSchemaJson IS NOT NULL AND ISJSON(@ParamsSchemaJson) = 0)
        THROW 50725, 'The block parameters could not be read as JSON.', 1;

    IF (@BlockId > 0)
    BEGIN
        UPDATE dbo.LTYC_ContentBlock
        SET    Code = @Code, Name = @Name, BlockType = @BlockType, BodyHtml = @BodyHtml,
               ParamsSchemaJson = @ParamsSchemaJson, IsActive = @IsActive,
               ModifiedBy = @ActionBy, ModifiedDate = SYSUTCDATETIME()
        WHERE  BlockId = @BlockId AND PropertyId = @PropertyId;
    END
    ELSE
    BEGIN
        -- Re-saving an existing code updates it rather than failing: a caller
        -- doing so means "make it so", not "error".
        IF EXISTS (SELECT 1 FROM dbo.LTYC_ContentBlock
                   WHERE PropertyId = @PropertyId AND Code = @Code AND IsDeleted = 0)
        BEGIN
            UPDATE dbo.LTYC_ContentBlock
            SET    Name = @Name, BlockType = @BlockType, BodyHtml = @BodyHtml,
                   ParamsSchemaJson = @ParamsSchemaJson, IsActive = @IsActive,
                   ModifiedBy = @ActionBy, ModifiedDate = SYSUTCDATETIME()
            WHERE  PropertyId = @PropertyId AND Code = @Code AND IsDeleted = 0;

            SET @BlockId = (SELECT TOP (1) BlockId FROM dbo.LTYC_ContentBlock
                            WHERE PropertyId = @PropertyId AND Code = @Code AND IsDeleted = 0);
        END
        ELSE IF EXISTS (SELECT 1 FROM dbo.LTYC_ContentBlock
                        WHERE PropertyId = @PropertyId AND Code = @Code AND IsDeleted = 1)
        BEGIN
            /*  A soft-deleted row still holds this code, and
                UQ_LTYC_ContentBlock_Property_Code is unique on (PropertyId, Code)
                with NO IsDeleted filter — so inserting would fail with a raw
                constraint violation, and the author would see the database's own
                error text for having reused a code they deleted.

                Revived rather than duplicated, and no schema change is needed for
                it. Recreating a deleted block plainly means "bring it back", and
                the identity is preserved so anything that referenced the BlockId
                still resolves.                                                   */
            UPDATE dbo.LTYC_ContentBlock
            SET    Name = @Name, BlockType = @BlockType, BodyHtml = @BodyHtml,
                   ParamsSchemaJson = @ParamsSchemaJson, IsActive = @IsActive,
                   IsDeleted = 0, ModifiedBy = @ActionBy, ModifiedDate = SYSUTCDATETIME()
            WHERE  PropertyId = @PropertyId AND Code = @Code AND IsDeleted = 1;

            SET @BlockId = (SELECT TOP (1) BlockId FROM dbo.LTYC_ContentBlock
                            WHERE PropertyId = @PropertyId AND Code = @Code AND IsDeleted = 0);
        END
        ELSE
        BEGIN
            INSERT INTO dbo.LTYC_ContentBlock
                  (PropertyId, Code, Name, BlockType, BodyHtml, ParamsSchemaJson, IsActive, IsDeleted, CreatedBy)
            VALUES(@PropertyId, @Code, @Name, @BlockType, @BodyHtml, @ParamsSchemaJson, @IsActive, 0, @ActionBy);

            SET @BlockId = SCOPE_IDENTITY();
        END
    END

    SELECT BlockId = @BlockId, Code = @Code;
END

GO

