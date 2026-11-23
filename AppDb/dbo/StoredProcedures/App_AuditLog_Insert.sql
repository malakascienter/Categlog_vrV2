
CREATE PROCEDURE dbo.App_AuditLog_Insert
    @PropertyId   INT,
    @EntityName   VARCHAR(100),
    @RecordId     VARCHAR(50),
    @RecordLabel  NVARCHAR(200) = NULL,
    @Action       CHAR(1),
    @UserId       INT,
    @Username     NVARCHAR(100) = NULL,
    @SourceScreen VARCHAR(100)  = NULL,
    @ChangesJson  NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @AuditLogId BIGINT;

        INSERT INTO dbo.App_AuditLog
            (PropertyId, EntityName, RecordId, RecordLabel, Action, UserId, Username, SourceScreen)
        VALUES
            (@PropertyId, @EntityName, @RecordId, @RecordLabel, @Action, @UserId, @Username, @SourceScreen);

        SET @AuditLogId = SCOPE_IDENTITY();

        IF @ChangesJson IS NOT NULL AND LTRIM(RTRIM(@ChangesJson)) NOT IN ('', '[]')
        BEGIN
            INSERT INTO dbo.App_AuditLogDetail (AuditLogId, FieldName, OldValue, NewValue)
            SELECT @AuditLogId, j.FieldName, j.OldValue, j.NewValue
            FROM OPENJSON(@ChangesJson)
            WITH (
                FieldName VARCHAR(100)  '$.FieldName',
                OldValue  NVARCHAR(MAX) '$.OldValue',
                NewValue  NVARCHAR(MAX) '$.NewValue'
            ) AS j
            WHERE j.FieldName IS NOT NULL;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        DECLARE @ErrMsg VARCHAR(MAX) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END

GO

