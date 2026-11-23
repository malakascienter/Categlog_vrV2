
CREATE PROCEDURE dbo.SP_GetFranchiseIssueRequestDocuments
    @Propertyid   INT,
    @Locationid   INT,   -- issuing store; request notes are filed under this
    @Departmentid INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DISTINCT
        RH.Id                                                        AS RequestHeaderID,
        RH.DocumentNo,
        RH.RequestDate,
        RH.DocumentNo + ' | ' + CONVERT(VARCHAR, RH.RequestDate, 23) AS DisplayText
    FROM RequestHeaders RH
    INNER JOIN RequestDetails RD ON RD.RequestHeaderID = RH.Id
    WHERE RH.PropertyID     = @Propertyid
      --AND RH.RequestType    = 'RI'
      --Edited 2026-09-11 - also list Franchise Requests (TransactionTypes Id 86, Code 'FR').
      --'RI' is kept so Issue Requests already raised for franchise departments still show.
      AND RH.RequestType    IN ('RI', 'FR')
      --End 2026-09-11
      AND RH.IsApproved     = 1
      AND RH.DocumentStatus = 'P'
      AND RH.LocationID     = @Locationid
      AND RH.DepartmentID   = @Departmentid
   
      AND ISNULL(RD.ApprovedQuantity, RD.RequestedQuantity)
            - ISNULL(RD.IssuedQuantity, 0) > 0
    ORDER BY RH.Id DESC;

END

GO

