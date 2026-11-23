-- =============================================
-- Author:      Tharuka Sachintha
-- Create date: 2026-05-07
-- Description: Outlet wise pending transfer request items report
--              Flat rows for SSRS Matrix (outlet columns handled by SSRS)

-- EXEC [dbo].[RPT_SP_PendingTransferRequestSummary] 1, '2026-04-01', '2026-06-30', 1

-- =============================================
CREATE PROCEDURE [dbo].[RPT_SP_PendingTransferRequestSummary]
    @LocationID INT,
    @FromDate DATE,
    @ToDate DATE,
    @PropertyID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT   
        SIH.StockItemCode,
        SIH.Name AS ItemName,
        TL.Name AS OutletName,
        SUM(RD.ApprovedQuantity - RD.IssuedQuantity) AS PendingQty

    FROM RequestHeaders RH
    INNER JOIN RequestDetails RD ON RD.RequestHeaderID = RH.Id
    INNER JOIN StockItemHeaders SIH ON SIH.Id = RD.StockItemID
    INNER JOIN Locations TL ON TL.ID = RH.TransferLocation

    WHERE
        RH.PropertyID = @PropertyID
        AND RH.DocumentStatus = 'P'
        AND CAST(RH.DeliveryDate AS DATE) BETWEEN @FromDate AND @ToDate
        AND RD.ApprovedQuantity > RD.IssuedQuantity
        AND RH.LocationID = @LocationID
        AND RH.IsSPOBased = 0

    GROUP BY
        SIH.StockItemCode,
        SIH.Name,
        TL.Name

    ORDER BY
        
        ItemName;

END

GO

