
CREATE PROCEDURE [dbo].[sp_ManageSupplierCategory]
  @XMLData XML,
  @Mode CHAR(1)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @iDocID INT;

    BEGIN TRY 
        BEGIN TRANSACTION;

        IF OBJECT_ID('tempdb..#TempAllDetails') IS NOT NULL
            DROP TABLE #TempAllDetails;

        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLData;

        SELECT ID, SupplierCategoryCode, SupplierCategoryName, IsActive, UserID
        INTO #TempAllDetails
        FROM OPENXML(@iDocID, '/SupplierCategory', 2)
        WITH (
            ID INT,
            SupplierCategoryCode VARCHAR(255),
            SupplierCategoryName VARCHAR(255),
            IsActive BIT,
            UserID INT
        );

        

        IF @Mode = 'I'
        BEGIN
            IF EXISTS (
                SELECT 1 FROM SupplierCategory
                WHERE SupplierCategoryCode IN (SELECT SupplierCategoryCode FROM #TempAllDetails)
            )
            BEGIN
                RAISERROR('Duplicate Supplier Category Code.', 16, 1);
                ROLLBACK TRANSACTION;
                EXEC sp_xml_removedocument @iDocID;
                RETURN;
            END

            IF EXISTS (
                SELECT 1 FROM SupplierCategory
                WHERE SupplierCategoryName IN (SELECT SupplierCategoryName FROM #TempAllDetails)
            )
            BEGIN
                RAISERROR('Duplicate Supplier Category name.', 16, 1);
                ROLLBACK TRANSACTION;
                EXEC sp_xml_removedocument @iDocID; 
                RETURN;
            END

            
            INSERT INTO SupplierCategory
            (
                SupplierCategoryCode,
                SupplierCategoryName,
                IsActive,
                CreatedUserID,
                LastModUserID,
                CreatedDate,
                LastModDate
            )
            SELECT
                SupplierCategoryCode,
                SupplierCategoryName,
                IsActive,
                UserID,
                UserID,
                GETDATE(),
                GETDATE()
            FROM #TempAllDetails;
        END

        ELSE IF @Mode = 'U'
        BEGIN
             IF EXISTS (
                  SELECT 1
                  FROM SupplierCategory SC
                  INNER JOIN #TempAllDetails T ON 1 = 1
                  WHERE SC.SupplierCategoryCode = T.SupplierCategoryCode
                  AND SC.ID <> T.ID
                 )
             BEGIN
                 RAISERROR('Duplicate Supplier Category Code.', 16, 1);
                 ROLLBACK TRANSACTION;
                 EXEC sp_xml_removedocument @iDocID;
                 RETURN;
             END

             IF EXISTS (
                  SELECT 1
                  FROM SupplierCategory SC
                  INNER JOIN #TempAllDetails T ON 1 = 1
                  WHERE SC.SupplierCategoryName = T.SupplierCategoryName
                  AND SC.ID <> T.ID
                 )
             BEGIN
                 RAISERROR('Duplicate Supplier Category Name', 16, 1);
                 ROLLBACK TRANSACTION;
                 EXEC sp_xml_removedocument @iDocID;
                 RETURN;
             END

            UPDATE SC
            SET
                SC.SupplierCategoryCode = T.SupplierCategoryCode,
                SC.SupplierCategoryName = T.SupplierCategoryName,
                SC.IsActive = T.IsActive,
                SC.LastModUserID = T.UserID,
                SC.LastModDate = GETDATE()
            FROM SupplierCategory SC
            INNER JOIN #TempAllDetails T ON SC.ID = T.ID;
        END

        ELSE IF @Mode = 'D'
        BEGIN
            DELETE FROM SupplierCategory
            WHERE ID IN (SELECT ID FROM #TempAllDetails);
        END

        EXEC sp_xml_removedocument @iDocID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        ROLLBACK TRANSACTION;

        IF @iDocID IS NOT NULL
            EXEC sp_xml_removedocument @iDocID;

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END

GO

