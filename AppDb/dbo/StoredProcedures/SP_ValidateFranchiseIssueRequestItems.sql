
-- =============================================
-- Author:		Tharuka Sachintha
-- Create date: 2026-08-18
-- Description:	get item validations for franchise issue 
-- =============================================

CREATE   PROCEDURE dbo.SP_ValidateFranchiseIssueRequestItems
    @RequestHeaderID       INT,
    @Departmentid          INT,
    @Locationid            INT,
    @Propertyid            INT,
    @Supplierid            INT,
    @FranchiseLocationid   INT = NULL   
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Locationid2 INT = NULLIF(@FranchiseLocationid, 0);

    IF (@Locationid2 IS NULL)
    BEGIN
        SELECT @Locationid2 = LO.Id
        FROM   Departments DE
        INNER JOIN Locations LO ON LO.DepartmentID = DE.Id
        WHERE  DE.Id = @Departmentid;
    END

    DECLARE @LocationName  VARCHAR(200),
            @FranchiseName VARCHAR(200);

    SELECT @LocationName  = Name FROM Locations WHERE Id = @Locationid;
    SELECT @FranchiseName = Name FROM Locations WHERE Id = @Locationid2;

    SELECT
        RD.StockItemID,
        SH.StockItemCode,
        SH.Name                                                    AS ItemName,
        ISNULL(RD.ApprovedQuantity, RD.RequestedQuantity)
            - ISNULL(RD.IssuedQuantity, 0)                         AS OutstandingQuantity,
        ISNULL(STK.QuantityInHand, 0)                              AS QuantityInHand,
        @LocationName                                              AS LocationName,
        @FranchiseName                                             AS FranchiseLocationName,
       
        CASE WHEN EXISTS (SELECT 1
                          FROM   SupplierWiseItemDetails
                          WHERE  StockItemID = RD.StockItemID
                            AND  LocationId  = @Locationid2
                            AND  SupplierID  = @Supplierid)
             THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END           AS HasSupplierItem,
        CASE
            WHEN @Locationid2 IS NULL
                THEN 'NO_FRANCHISE_LOCATION'

            WHEN NOT EXISTS (SELECT 1
                             FROM   StockItemDetails
                             WHERE  LocationID        = @Locationid
                               AND  StockItemHeaderID = RD.StockItemID)
                THEN 'NOT_IN_LOCATION'

            WHEN NOT EXISTS (SELECT 1
                             FROM   StockItemDetails
                             WHERE  LocationID        = @Locationid2
                               AND  StockItemHeaderID = RD.StockItemID)
                THEN 'NOT_IN_DEPARTMENT'

            WHEN NOT EXISTS (SELECT 1
                             FROM   SupplierWiseItemDetails
                             WHERE  StockItemID = RD.StockItemID
                               AND  LocationId  = @Locationid2
                               AND  SupplierID  = @Supplierid)
                THEN 'NO_SUPPLIER_ITEM'

            WHEN NOT EXISTS (SELECT 1
                             FROM   StockItemDetails SD
                             INNER JOIN Units UN ON UN.Id = SD.MasterUnitID
                             WHERE  SD.StockItemHeaderID = RD.StockItemID
                               AND  SD.LocationID        = @Locationid2)
                THEN 'NO_UNIT'

            WHEN ISNULL(STK.QuantityInHand, 0) <= 0
                THEN 'NO_QUANTITY'

            WHEN ISNULL(STK.QuantityInHand, 0) <
                 ISNULL(RD.ApprovedQuantity, RD.RequestedQuantity)
                     - ISNULL(RD.IssuedQuantity, 0)
                THEN 'INSUFFICIENT_QUANTITY'

            ELSE 'OK'
        END                                                        AS Reason
    FROM RequestDetails RD
    INNER JOIN StockItemHeaders SH
            ON SH.Id        = RD.StockItemID
           AND SH.CompanyId = @Propertyid
    
    OUTER APPLY dbo.FN_TV_GetStockInHand(@Propertyid, @Locationid, RD.StockItemID) STK
    WHERE RD.RequestHeaderID = @RequestHeaderID
    ORDER BY SH.Name;

END

GO

