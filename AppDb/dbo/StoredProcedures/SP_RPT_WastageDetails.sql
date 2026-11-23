-- =============================================
-- Author:		Tharuka Sachinath
-- Create date: 2026-06-08
-- Description:	get wastage details for the report 

--  SP_RPT_WastageDetails 1, '2026-06-08', '2026-06-10'

-- =============================================
CREATE   PROCEDURE SP_RPT_WastageDetails
	@LocationId INT,
	@FromDate DATETIME,
	@ToDate DATETIME
AS
BEGIN
	
	SET NOCOUNT ON;

    SELECT DISTINCT 
        SH.ReferenceID,
        SIH.Name AS ItemName,
        SIH.StockItemCode,
        U.Name AS Unit,
        SD.Remarks AS Reason,
        SD.Quantity AS WastedQty,
        ISNULL(US.Username, '-') AS ApprovedUser,
        DC.Name AS wastageType,
        SD.UnitPrice,
        (SD.Quantity * SD.UnitPrice) AS TotalLoss,
        C.Name AS CategoryName,
        L.NAME AS Location, 
        SH.DocumentNo AS DocNo,
        SH.TransactionDate AS TransactionDate
    FROM StockTransactionHeaders SH
    INNER JOIN StockTransactionDetails SD ON SH.Id = SD.StockTransactionHeaderID
    INNER JOIN StockItemHeaders SIH ON SD.StockItemID = SIH.Id
    INNER JOIN StockItemDetails SID ON SIH.Id = SID.StockItemHeaderID
    INNER JOIN Units U ON SD.TxnUnitID = U.Id
    INNER JOIN Locations L ON L.Id = SH.LocationID
    LEFT JOIN ApprovalLogs AL ON AL.TransactionHeaderID = SH.ReferenceID
    LEFT JOIN CentralUsers US ON US.Id = AL.ApprovalUserID
    INNER JOIN DamageRequestCategories DC ON DC.ID = SH.DamageCategoryID
    INNER JOIN Categories C ON C.Id = SIH.CategoryID
    WHERE (@LocationId = -999 OR SH.LocationID = @LocationId)
      AND SH.TransactionType = 'DN' 
      AND SH.TransactionDate BETWEEN @FromDate AND @ToDate
    ORDER BY SH.TransactionDate 
END

GO

