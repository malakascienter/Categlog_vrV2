
CREATE PROCEDURE [dbo].[SP_GetFranchiseInvoiceDepartments]
    @CompanyID INT,
    @UserID    INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Franchise invoicing switched off for this company: nothing to load.
    IF NOT EXISTS (SELECT 1
                   FROM   dbo.Companies
                   WHERE  CompanyID = @CompanyID
                   AND    IsFranchiseInvoiceEnable = 1)
    BEGIN
        SELECT  CAST(0    AS INT)           AS id,
                CAST(NULL AS NVARCHAR(MAX)) AS text,
                CAST(NULL AS NVARCHAR(MAX)) AS DepartmentCode,
                CAST(NULL AS VARCHAR(MAX))  AS CustomerBSPCode,
                CAST(NULL AS INT)           AS LocationID
        WHERE   1 = 0;

        RETURN;
    END

    SELECT  DP.Id                              AS id,
            DP.Name                            AS text,
            DP.Code                            AS DepartmentCode,
            LTRIM(RTRIM(DP.CustomerBSPCode))   AS CustomerBSPCode,
            LO.Id                              AS LocationID
    FROM    dbo.Departments DP
    -- A franchise department is reached through Locations.DepartmentID; TOP 1 keeps
    -- one row per department even if more than one location points at it.
    OUTER APPLY (SELECT TOP 1 L.Id
                 FROM   dbo.Locations L
                 WHERE  L.FranchiseDepartmentID = DP.Id
                 AND    L.IsActive = 1
                 ORDER BY L.Id) LO
    WHERE   DP.PropertyID = @CompanyID
    AND     DP.IsActive = 1
    AND     NULLIF(LTRIM(RTRIM(DP.CustomerBSPCode)), '') IS NOT NULL
    AND     (NULLIF(@UserID, 0) IS NULL
             OR EXISTS (SELECT 1
                        FROM   dbo.UserWiseDepartments UD
                        WHERE  UD.deptid = DP.Id
                        AND    UD.userId = @UserID))
    ORDER BY DP.Name;
END

GO

