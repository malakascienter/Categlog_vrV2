
--AuditTrailLogHistory_SupplierWiseItemDetails 71
-- =============================================
-- Author:		Vinuki
-- Create date: 2024.03.14
-- Description:	Audit Trail Log for Supplier wise item details component 
-- =============================================
create PROCEDURE AuditTrailLogHistory_SupplierWiseItemDetails
    @SupplierID INT
AS
BEGIN
    BEGIN TRY
        SELECT
            AuditTrailID, TableName, LogDate, SWD.StockItemID, StockItemCode, SIH.Name As ItemName,  AM.Username,
            AM.PropertyId as PropertyID, SWD.SupplierID, SUP.name As SupplierName, 
            (select top 1 Username from  Categlog_vrV2..users  where id = SWD.createduserid UNION select Username from  Categlog_vrV2..CentralUsers  where id = SWD.createduserid) as CreatedUserName, 
(select top 1 Username from  Categlog_vrV2..users  where id = SWD.LastModUserID UNION select Username from  Categlog_vrV2..CentralUsers  where id = SWD.LastModUserID) as LastModUserName,
            CASE WHEN Action = 'I' THEN 'Inserted' WHEN Action = 'D' THEN 'Deleted' END Action
        FROM 
            HotelResWeb_AuditTail..SupplierWiseItemDetails_History SWD
        INNER JOIN  
            HotelResWeb_AuditTail..AuditTrailMaster AM ON AM.trailid = SWD.AuditTrailID 
        INNER JOIN 
            Categlog_vrV2..Suppliers SUP ON SWD.SupplierID = SUP.ID
        INNER JOIN 
            Categlog_vrV2..StockItemHeaders SIH ON SWD.StockItemID = SIH.Id
        LEFT JOIN  
            HotelResWeb_AuditTail..AuditTrailDetail AD ON AD.TrailID = SWD.AuditTrailID
        WHERE 
            SWD.SupplierID = @SupplierID;


    END TRY
    BEGIN CATCH
        -- Error handling
        SELECT   
            ERROR_NUMBER() AS ErrorNumber,  
            ERROR_MESSAGE() AS ErrorMessage,  
            ERROR_SEVERITY() AS ErrorSeverity,  
            ERROR_STATE() AS ErrorState,  
            ERROR_PROCEDURE() AS ErrorProcedure,  
            ERROR_LINE() AS ErrorLine;  
    END CATCH;
END

GO

