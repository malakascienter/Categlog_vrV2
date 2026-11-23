
CREATE PROCEDURE [dbo].[Table_Category_M_Save]
    @Id INT,
    @Name VARCHAR(50),
    @OutletId VARCHAR(5),
    @IsActive BIT,
    @UserId INT,
    @PropertyId INT,
    @Operation CHAR(1)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    BEGIN TRY

        DECLARE @Remark NVARCHAR(250);

        IF @Operation = 'I'
        BEGIN
            -- Duplicate validation
            IF EXISTS
            (
                SELECT 1
                FROM POS_TableCategories
                WHERE PropertyId = @PropertyId
                  AND OutletID = @OutletId
                  AND TableCategoryName = @Name
            )
            BEGIN
                RAISERROR('Table Category Name already exists for this outlet.',16,1);
            END
            ELSE
            BEGIN
                -- Audit Trail
                EXEC dbo.AuditTrail_InsertToHistory
                    'POS_TableCategories',
                    @Id;

                INSERT INTO POS_TableCategories
                (
                    TableCategoryName,
                    OutletID,
                    IsActive,
                    SequenceID,
                    IsUpload,
                    PropertyId,
                    CreatedUserID,
                    CreatedDateTime
                )
                VALUES
                (
                    @Name,
                    @OutletId,
                    @IsActive,
                    (
                        SELECT ISNULL(MAX(SequenceID),0) + 1
                        FROM POS_TableCategories
                        WHERE PropertyId = @PropertyId
                    ),
                    0,
                    @PropertyId,
                    @UserId,
                    GETDATE()
                );

                SET @Id = SCOPE_IDENTITY();

                -- Audit Trail
                EXEC HotelResWeb_AuditTail_WriteToLog
                    'POS_TableCategories',
                    @Id,
                    'POS',
                    'POSTCI',
                    'I',
                    @UserId,
                    '',
                    '',
                    '',
                    '',
                    '',
                    @PropertyId;

                SET @Remark = 'POS_TableCategories ' + @Name + ', ' + @OutletId + ' created.';

                EXEC dbo.AuditTrail_InsertTableChanges
                    'POS_TableCategories',
                    @Id,
                    @UserId,
                    'I',
                    @Remark;
            END
        END
        ELSE IF @Operation = 'U'
        BEGIN
            -- Duplicate validation (exclude current record)
            IF EXISTS
            (
                SELECT 1
                FROM POS_TableCategories
                WHERE PropertyId = @PropertyId
                  AND OutletID = @OutletId
                  AND TableCategoryName = @Name
                  AND TableCategoryID <> @Id
            )
            BEGIN
                RAISERROR('Table Category Name already exists for this outlet.',16,1);
            END
            ELSE
            BEGIN
                -- Audit Trail
                EXEC HotelResWeb_AuditTail_WriteToLog
                    'POS_TableCategories',
                    @Id,
                    'POS',
                    'POSTCU',
                    'U',
                    @UserId,
                    '',
                    '',
                    '',
                    '',
                    '',
                    @PropertyId;

                UPDATE POS_TableCategories
                SET
                    TableCategoryName = @Name,
                    OutletID = @OutletId,
                    IsActive = @IsActive,
                    IsUpload = 0
                WHERE TableCategoryID = @Id
                  AND PropertyId = @PropertyId;
            END
        END

        EXEC Insert_Sync_MasterDataTransferStatus
            'TableCategory',
            @IsActive,
            @Id,
            @PropertyId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Error NVARCHAR(MAX);
        SET @Error = ERROR_MESSAGE();

        RAISERROR(@Error,16,1);
    END CATCH
END

GO

