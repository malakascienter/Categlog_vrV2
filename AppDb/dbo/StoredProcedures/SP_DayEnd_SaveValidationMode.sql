-- =============================================
-- Author : Tharuka Sachintha
-- Create date: 2026-10-09
-- Description: Day End Validation Modes - Saves one mode from the Day End Validation Modes screen

-- =============================================

CREATE   PROCEDURE dbo.SP_DayEnd_SaveValidationMode
    @JsonData NVARCHAR(MAX),
    @NewId    INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @NewId = 0;

    IF ISJSON(@JsonData) <> 1
    BEGIN
        RAISERROR('Invalid data.', 16, 1);
        RETURN;
    END

    DECLARE @Id INT, @Code NVARCHAR(100), @Name NVARCHAR(200), @IsActive BIT,
            @PropertyID INT, @UserID INT, @Msg NVARCHAR(400);

    SELECT  @Id         = ISNULL(j.Id, 0),
            @Code       = UPPER(LTRIM(RTRIM(ISNULL(j.Code, N'')))),
            @Name       = LTRIM(RTRIM(ISNULL(j.Name, N''))),
            @IsActive   = ISNULL(j.IsActive, 1),
            @PropertyID = j.PropertyID,
            @UserID     = j.UserID
    FROM    OPENJSON(@JsonData)
            WITH (Id INT '$.Id', Code NVARCHAR(100) '$.Code', Name NVARCHAR(200) '$.Name',
                  IsActive BIT '$.IsActive', PropertyID INT '$.PropertyID', UserID INT '$.UserID') j;

    DECLARE @Details TABLE (ValidationCheckID INT, ItemTemplateID INT);
    INSERT INTO @Details (ValidationCheckID, ItemTemplateID)
    SELECT  d.ValidationCheckID, d.ItemTemplateID
    FROM    OPENJSON(@JsonData, '$.Details')
            WITH (ValidationCheckID INT '$.ValidationCheckID', ItemTemplateID INT '$.ItemTemplateID') d;

    -------------------------------------------------------------------------
    -- header checks
    -------------------------------------------------------------------------
    IF ISNULL(@PropertyID, 0) <= 0
    BEGIN
        RAISERROR('Property is required.', 16, 1);
        RETURN;
    END

    IF @Code = N''
    BEGIN
        RAISERROR('Code is required.', 16, 1);
        RETURN;
    END

    -- binary collation so [A-Z] means plain capital letters only
    IF LEN(@Code) > 4 OR @Code COLLATE Latin1_General_BIN LIKE N'%[^A-Z0-9]%'
    BEGIN
        RAISERROR('Code must be 1 to 4 letters or digits.', 16, 1);
        RETURN;
    END

    IF @Name = N''
    BEGIN
        RAISERROR('Name is required.', 16, 1);
        RETURN;
    END

    IF LEN(@Name) > 50
    BEGIN
        RAISERROR('Name can''t be longer than 50 characters.', 16, 1);
        RETURN;
    END

    IF @Id > 0
    BEGIN
        DECLARE @SavedCode NVARCHAR(100), @IsSystem BIT;
        SELECT @SavedCode = LTRIM(RTRIM(Code)), @IsSystem = ISNULL(IsSystem, 0)
        FROM   dbo.DayEnd_ValidationModes
        WHERE  Id = @Id;

        IF @SavedCode IS NULL
        BEGIN
            RAISERROR('Validation mode not found. It may have been deleted.', 16, 1);
            RETURN;
        END

        IF @IsSystem = 1
        BEGIN
            RAISERROR('The system mode %s can''t be changed.', 16, 1, @SavedCode);
            RETURN;
        END

        IF UPPER(@SavedCode) <> @Code
        BEGIN
            RAISERROR('The code can''t change after saving, because locations store it.', 16, 1);
            RETURN;
        END
    END

    IF EXISTS (SELECT 1 FROM dbo.DayEnd_ValidationModes
               WHERE UPPER(LTRIM(RTRIM(Code))) = @Code AND Id <> @Id)
    BEGIN
        RAISERROR('Code %s already exists.', 16, 1, @Code);
        RETURN;
    END

    -------------------------------------------------------------------------
    -- detail checks
    -------------------------------------------------------------------------
    IF EXISTS (SELECT 1 FROM @Details d
               WHERE d.ValidationCheckID IS NULL
                  OR NOT EXISTS (SELECT 1 FROM dbo.DayEnd_ValidationChecks c
                                 WHERE c.Id = d.ValidationCheckID AND c.IsActive = 1))
    BEGIN
        RAISERROR('Unknown or inactive transaction type.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT ValidationCheckID FROM @Details GROUP BY ValidationCheckID HAVING COUNT(*) > 1)
    BEGIN
        RAISERROR('A transaction type is selected more than once.', 16, 1);
        RETURN;
    END

    -- DESC types never keep a template
    UPDATE d
    SET    d.ItemTemplateID = NULL
    FROM   @Details d
           INNER JOIN dbo.DayEnd_ValidationChecks c ON c.Id = d.ValidationCheckID
    WHERE  c.ConfigType <> 'TEMPLATE';

    SET @Msg = NULL;
    SELECT TOP (1) @Msg = c.Name
    FROM   @Details d
           INNER JOIN dbo.DayEnd_ValidationChecks c ON c.Id = d.ValidationCheckID
    WHERE  c.ConfigType = 'TEMPLATE'
           AND d.ItemTemplateID IS NULL
    ORDER BY c.SortOrder;
    IF @Msg IS NOT NULL
    BEGIN
        RAISERROR('Select an item template for %s.', 16, 1, @Msg);
        RETURN;
    END

    SET @Msg = NULL;
    SELECT TOP (1) @Msg = c.Name
    FROM   @Details d
           INNER JOIN dbo.DayEnd_ValidationChecks c ON c.Id = d.ValidationCheckID
    WHERE  d.ItemTemplateID IS NOT NULL
           AND NOT EXISTS (SELECT 1 FROM dbo.RequestTemplateHeader h
                           WHERE h.TemplateHeaderID = d.ItemTemplateID
                                 AND h.PropertyId = @PropertyID
                                 AND h.IsActive = 1)
    ORDER BY c.SortOrder;
    IF @Msg IS NOT NULL
    BEGIN
        RAISERROR('The item template selected for %s was not found, or is inactive.', 16, 1, @Msg);
        RETURN;
    END

    -------------------------------------------------------------------------
    -- save
    -------------------------------------------------------------------------
    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Id = 0
        BEGIN
            INSERT INTO dbo.DayEnd_ValidationModes
                   (Code, Name, IsActive, IsSystem, CreatedUserID, CreatedDate, LastModUserID, LastModDate)
            VALUES (@Code, @Name, @IsActive, 0, @UserID, GETDATE(), @UserID, GETDATE());

            SET @Id = SCOPE_IDENTITY();

            EXEC dbo.InsertMasterFileChangeLog 'Day End Validation Mode', @UserID, 'I', @Code;
        END
        ELSE
        BEGIN
            UPDATE dbo.DayEnd_ValidationModes
            SET    Name          = @Name,
                   IsActive      = @IsActive,
                   LastModUserID = @UserID,
                   LastModDate   = GETDATE()
            WHERE  Id = @Id;

            EXEC dbo.InsertMasterFileChangeLog 'Day End Validation Mode', @UserID, 'U', @Code;
        END

        -- unticked types
        DELETE d
        FROM   dbo.DayEnd_ValidationModeDetails d
        WHERE  d.ValidationModeID = @Id
               AND d.PropertyID = @PropertyID
               AND NOT EXISTS (SELECT 1 FROM @Details x WHERE x.ValidationCheckID = d.ValidationCheckID);

        -- changed templates
        UPDATE d
        SET    d.ItemTemplateID = x.ItemTemplateID,
               d.LastModUserID  = @UserID,
               d.LastModDate    = GETDATE()
        FROM   dbo.DayEnd_ValidationModeDetails d
               INNER JOIN @Details x ON x.ValidationCheckID = d.ValidationCheckID
        WHERE  d.ValidationModeID = @Id
               AND d.PropertyID = @PropertyID
               AND ISNULL(d.ItemTemplateID, -1) <> ISNULL(x.ItemTemplateID, -1);

        -- newly ticked types
        INSERT INTO dbo.DayEnd_ValidationModeDetails
               (ValidationModeID, PropertyID, ValidationCheckID, ItemTemplateID, CreatedUserID, CreatedDate)
        SELECT @Id, @PropertyID, x.ValidationCheckID, x.ItemTemplateID, @UserID, GETDATE()
        FROM   @Details x
        WHERE  NOT EXISTS (SELECT 1 FROM dbo.DayEnd_ValidationModeDetails d
                           WHERE d.ValidationModeID = @Id
                                 AND d.PropertyID = @PropertyID
                                 AND d.ValidationCheckID = x.ValidationCheckID);

        COMMIT TRANSACTION;
        SET @NewId = @Id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE(),
                @ErrorSeverity INT = ERROR_SEVERITY(),
                @ErrorState INT = ERROR_STATE();
        RAISERROR(N'%s', @ErrorSeverity, @ErrorState, @ErrorMessage);
    END CATCH
END

GO

