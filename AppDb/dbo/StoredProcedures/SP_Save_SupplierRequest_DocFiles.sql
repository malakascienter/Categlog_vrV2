-- =============================================
-- Author:		Thisen
-- Create date: 2025-11-04
-- Description:	Supplier Document Save 
-- =============================================
create PROCEDURE [dbo].[SP_Save_SupplierRequest_DocFiles]
    @SupplierReqID INT = 0,
    @SetupID INT,
    @SetupCode VARCHAR(20),
    @Type VARCHAR(10),
    @FileName VARCHAR(MAX),
    @CreateduserID INT,
    @SupplierID INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO SupplierDocUploads
        (
            SupplierReqID,
            SetupID,
            Type,
            FileName,
            CreateduserID,
            CreatedDate,
			IsDelete,
            SupplierID,
            SetupCode
        )
        VALUES
        (
            @SupplierReqID,
            @SetupID,
            @Type,
            @FileName,
            @CreateduserID,
            GETDATE(),
			0,
            @SupplierID,
            @SetupCode
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ERRmsg VARCHAR(MAX) = ERROR_MESSAGE();
        RAISERROR(@ERRmsg, 16, 1);
    END CATCH
END;

GO

