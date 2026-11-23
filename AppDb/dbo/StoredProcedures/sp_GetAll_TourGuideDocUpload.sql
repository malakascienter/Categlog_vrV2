
-- =============================================
-- Author:      Ravindu
-- Create date: 2025-07-28
-- Description: Get tour guide document upload details for Tour Guide
--  [dbo].[sp_GetAll_TourGuideDocUpload] 'TGC','I',1,3

-- =============================================
CREATE PROCEDURE [dbo].[sp_GetAll_TourGuideDocUpload]
    @Type NVARCHAR(20),
    @Module NVARCHAR(20),
    @PropertyId INT,
    @DocID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        TS.ID,
        TS.Code,
        TS.FileType,
        TS.DocumentTypeName,
        TS.Module,
        TS.Type,
        TS.IsActive,
        TS.PropertyId
        ,TU.ID DocID
        ,TU.FileName
    FROM TourGuideDocUpload_Setup TS
    LEFT JOIN TourGuideDocUploads TU ON TS.ID = TU.SetupID AND TU.DocID = @DocID AND TU.IsDelete=0
    
    WHERE
        TS.Type = @Type
        AND TS.Module = @Module 
        AND TS.PropertyId = @PropertyId
        AND TS.IsActive = 1
    ORDER BY
        TS.ID;
END

GO

