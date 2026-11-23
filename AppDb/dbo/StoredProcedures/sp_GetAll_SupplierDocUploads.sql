
-- =============================================
-- Author: Thisen
-- Create date: 2025-11-04
-- Description: Get Supplier Request document upload details for Supplier Request View

--exec [dbo].[sp_GetAll_SupplierDocUploads] 'SR',2013,3294


-- exec [dbo].[sp_GetAll_SupplierDocUploads] 'SU',0,3297

-- =============================================
create PROCEDURE [dbo].[sp_GetAll_SupplierDocUploads]
    @Type NVARCHAR(20),
    @SupplierReqID INT = 0,
    @SupplierID INT =0
AS
BEGIN
    SET NOCOUNT ON;

    IF @Type = 'SR'
    BEGIN
        SELECT
            SS.ID,
            SS.FileType,
            SS.DocumentTypeName,
            SS.SetupCode,
            SS.IsActive,
            SU.SupplierReqID,
            SU.FileName,
            SU.ID AS DocID
        FROM SupplierDocUploadSetup AS SS
        LEFT JOIN SupplierDocUploads AS SU 
            ON SS.ID = SU.SetupID 
            AND SU.SupplierReqID = @SupplierReqID 
            AND SU.IsDelete = 0
        WHERE SS.IsActive = 1
        ORDER BY SS.ID;
    END
    ELSE IF @Type = 'SU'
    BEGIN
        SELECT
            SS.ID,
            SS.FileType,
            SS.DocumentTypeName,
            SS.SetupCode,
            SS.IsActive,
            SU.SupplierID,
            SU.FileName,
            SU.ID AS DocID
        FROM SupplierDocUploadSetup AS SS
        LEFT JOIN SupplierDocUploads AS SU 
            ON SS.ID = SU.SetupID 
            AND SU.SupplierID = @SupplierID 
            AND SU.IsDelete = 0
        WHERE SS.IsActive = 1
        ORDER BY SS.ID;
    END
    ELSE
    BEGIN
        RAISERROR('Invalid Type. Expected ''SR'' or ''SU''.', 16, 1);
    END
END

GO

