-- =============================================
-- Author:       Ravindu
-- Create date:  2025-09-22
-- Description:  Insert, Update, Delete Damage Request Category
-- =============================================
CREATE PROCEDURE [dbo].[SP_DamageRequestCategory_Save]
    @JsonData NVARCHAR(MAX),
    @Action NVARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        
        -- Temporary table to hold JSON data
        DECLARE @temp TABLE (
            ID INT, 
            Name NVARCHAR(200),
            IsActive BIT,
            UserId INT,
            CompanyId INT
        );
        
        INSERT INTO @temp(ID, Name, IsActive, UserId, CompanyId)
        SELECT 
            ISNULL(ID, 0),
            Name, 
            IsActive, 
            UserId, 
            CompanyId
        FROM OPENJSON(@JsonData)
        WITH (
            ID INT '$.ID',
            Name NVARCHAR(200) '$.Name',
            IsActive BIT '$.IsActive',
            UserId INT '$.UserId',
            CompanyId INT '$.CompanyId'
        );

        IF NOT EXISTS (SELECT 1 FROM @temp)
        BEGIN
            RAISERROR('No data found in JSON.', 16, 1);
            RETURN;
        END

        -- INSERT
        IF (@Action) = 'Insert'
        BEGIN
            IF EXISTS (
                SELECT 1 
                FROM DamageRequestCategories DRC
                INNER JOIN @temp T ON DRC.Name = T.Name AND DRC.CompanyId = T.CompanyId
            )
            BEGIN
                RAISERROR('Category name already exists for this company.', 16, 1);
                RETURN;
            END

            INSERT INTO DamageRequestCategories(Name, IsActive, CompanyId, CreatedUserID, LastModUserID, CreatedDate, LastModDate)
            SELECT Name, IsActive, CompanyId, UserId, UserId, GETDATE(), GETDATE()
            FROM @temp;

            DECLARE @NewId INT = SCOPE_IDENTITY();
            DECLARE @CreatedUserID INT;
            DECLARE @CompanyId INT;
            SELECT TOP 1 @CreatedUserID = UserId, @CompanyId = CompanyId FROM @temp;

            EXEC Inventry_AuditTail_WriteToLog 'DamageRequestCategories', @NewId, 'INV', 'CDI', 'I', @CreatedUserID, @CompanyId, '', '';
        END

        -- UPDATE
        ELSE IF (@Action) = 'Update'
        BEGIN
            IF EXISTS (
                SELECT 1
                FROM DamageRequestCategories DRC
                INNER JOIN @temp T 
                ON DRC.Name = T.Name 
                AND DRC.CompanyId = T.CompanyId
                AND DRC.ID <> T.ID
            )
            BEGIN
                RAISERROR('Category name already exists for this company. Cannot update.', 16, 1);
                RETURN;
            END 

            UPDATE DRC
            SET
                DRC.Name = T.Name,
                DRC.IsActive = T.IsActive,
                DRC.LastModUserID = T.UserId,
                DRC.LastModDate = GETDATE()
            FROM DamageRequestCategories DRC
            INNER JOIN @temp T ON DRC.ID = T.ID;

            IF @@ROWCOUNT = 0
            BEGIN
                RAISERROR('Update failed. No matching ID found.', 16, 1);
            END
            ELSE
            BEGIN
                DECLARE @UpdatedId INT;
                DECLARE @UpdatedUserID INT;
                DECLARE @UpdatedCompanyId INT;
                SELECT TOP 1 @UpdatedId = ID, @UpdatedUserID = UserId, @UpdatedCompanyId = CompanyId FROM @temp;

                EXEC Inventry_AuditTail_WriteToLog 'DamageRequestCategories', @UpdatedId, 'INV', 'CDU', 'U', @UpdatedUserID, @UpdatedCompanyId, '', '';
            END
        END

        -- DELETE
        ELSE IF (@Action) = 'Delete'
        BEGIN
            IF NOT EXISTS (
                SELECT 1 
                FROM DamageRequestCategories DRC
                INNER JOIN @temp T ON DRC.ID = T.ID
            )
            BEGIN
                RAISERROR('Delete failed. No matching ID found.', 16, 1);
                RETURN;
            END

            DELETE DRC
            FROM DamageRequestCategories DRC
            INNER JOIN @temp T ON DRC.ID = T.ID;

            DECLARE @DeletedId INT;
            DECLARE @DeletedUserID INT;
            DECLARE @DeletedCompanyId INT;
            SELECT TOP 1 @DeletedId = ID, @DeletedUserID = UserId, @DeletedCompanyId = CompanyId FROM @temp;

            EXEC Inventry_AuditTail_WriteToLog 'DamageRequestCategories', @DeletedId, 'INV', 'CDD', 'D', @DeletedUserID, @DeletedCompanyId, '', '';
        END

        -- INVALID ACTION
        ELSE
        BEGIN
            RAISERROR('Invalid action. Must be "Insert", "Update", or "Delete".', 16, 1);
        END

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END

GO

