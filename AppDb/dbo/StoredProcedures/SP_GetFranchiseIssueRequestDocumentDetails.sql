
-- [dbo].[SP_GetFranchiseIssueRequestDocumentDetails] 9551,1,1,3598,4407

CREATE PROCEDURE [dbo].[SP_GetFranchiseIssueRequestDocumentDetails]
    @RequestHeaderID     INT,
    @Propertyid          INT,
    @Locationid          INT,        
    @FranchiseLocationid INT = NULL, 
    @Supplierid          INT = NULL  
AS
BEGIN
    SET NOCOUNT ON;

  
    DECLARE @Locationid2 INT = NULLIF(@FranchiseLocationid, 0);

    IF (@Locationid2 IS NULL)
    BEGIN
        SELECT @Locationid2 = LO.Id
        FROM   Departments DE
        INNER JOIN Locations LO ON LO.DepartmentID = DE.Id
        WHERE  DE.Id = (SELECT DepartmentID FROM RequestHeaders WHERE Id = @RequestHeaderID);
    END

    -- The supplier whose price list applies. The caller reads it from Companies
    -- too, so it is normally passed in; re-read it here when it is not.
    DECLARE @Sup INT = NULLIF(@Supplierid, 0);

    IF (@Sup IS NULL)
    BEGIN
        SELECT @Sup = SupplierId FROM Companies WHERE CompanyID = @Propertyid;
    END

    SELECT
        RH.Id                                             AS RequestHeaderID,
        RD.Id                                             AS RequestDetailID,
        RH.DocumentNo,
        SH.Id                                             AS StockItemID,
        SH.StockItemCode,
        SH.Name                                           AS ItemName,
        SH.IsExpiryDateApplicable,
        SH.CategoryID,
        CAT.Name                                          AS CategoryName,
        RD.UnitID,
        UN.Name                                           AS UnitName,
        UN.Code                                           AS UnitCode,
        UN.Id                                             AS MasterUnitID,
        RD.RequestedQuantity,
        ISNULL(RD.ApprovedQuantity, RD.RequestedQuantity) AS ApprovedQuantity,
        ISNULL(RD.IssuedQuantity, 0)                      AS IssuedQuantity,
        ISNULL(RD.ApprovedQuantity, RD.RequestedQuantity)
            - ISNULL(RD.IssuedQuantity, 0)                AS OutstandingQuantity,
        ISNULL(SWP.CostPrice, 0)*
        dbo.FN_GetUnitConvertionRate(@propertyID,rd.UnitID,SWP.PurchaseUnitID)        AS SellingPrice,
        ISNULL(STK.QuantityInHand,0)
        *dbo.FN_GetUnitConvertionRate(@propertyID,sd2.MasterUnitID,SWP.PurchaseUnitID)                    AS QuantityInHand,
        
        0 CostPrice,
        RD.Remarks
    FROM RequestHeaders RH
    INNER JOIN RequestDetails RD  ON RD.RequestHeaderID = RH.Id
    INNER JOIN StockItemHeaders SH ON SH.Id        = RD.StockItemID
                                  AND SH.CompanyId = @Propertyid
    LEFT JOIN Units UN            ON UN.Id = RD.UnitID
    LEFT JOIN Categories CAT      ON CAT.Id = SH.CategoryID
    LEFT JOIN StockItemDetails SD ON SD.StockItemHeaderID = RD.StockItemID
                                 AND SD.LocationID        = @Locationid2
    left join StockItemDetails sd2 on sd2.StockItemHeaderID = rd.StockItemID
                                    and sd2.LocationID = @Locationid

    OUTER APPLY (
        SELECT TOP (1) SW.CostPrice,SW.PurchaseUnitID
        FROM   SupplierWiseItemDetails SW
        WHERE  SW.StockItemID = RD.StockItemID
          AND  SW.LocationId  = @Locationid2
          AND  SW.SupplierID  = @Sup
        ORDER BY SW.IsDefaultSupplier DESC, SW.CostPrice DESC
    ) SWP
    
    OUTER APPLY dbo.FN_TV_GetStockInHand(@Propertyid, @Locationid, RD.StockItemID) STK
    WHERE RH.Id = @RequestHeaderID
      AND ISNULL(RD.ApprovedQuantity, RD.RequestedQuantity)
            - ISNULL(RD.IssuedQuantity, 0) > 0
    ORDER BY SH.Name;

END

GO

