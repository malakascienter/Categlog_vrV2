-- =============================================
-- Author:		Ravindu
-- Create date: 2025-07-30
-- Description:	Delete Tour guide companies uploaded document
-- =============================================
create PROCEDURE [dbo].[sp_Delete_SupplierRequestDoc]
    @ID INT,
    @LastModifiedUserID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE SupplierDocUploads
        SET
            IsDelete = 1,
            LastModifiedUserID = @LastModifiedUserID,
            LastModifiedDateTime = GETDATE()
        WHERE ID = @ID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();

        -- Raise the caught error
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END

GO

