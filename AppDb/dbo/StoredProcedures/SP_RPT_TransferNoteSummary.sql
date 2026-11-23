-- =============================================
-- Author:		Tharuka sachintha
-- Create date: 2026-04-28
-- Description:	Tranfer note summary for all locations

-- SP_RPT_TransferNoteSummary '2026-04-01','2026-04-30',-999,-999

-- =============================================
CREATE PROCEDURE SP_RPT_TransferNoteSummary
	@FromDate DATE,
	@ToDate DATE,
	@FromLocationID INT,
	@ToLocationID INT
AS
BEGIN
	
	SET NOCOUNT ON;

    SELECT DISTINCT
LO1.Name as fromLocation, LO2.Name as toLocation, STD_TO.Id stocktransactionID, STD_TO.CreatedDate AS transferNoteDate, 
RH.DocumentNo AS RHDocumentNo, '' AS ProdPlanDocNo, RH.SystemDate AS RequestDate, RD.StockItemID, SID.StockItemCode, SID.Name, RD.RequestedQuantity as requestedQTY,
CASE WHEN STD_TO.StockItemID IS NOT NULL THEN STH_TO.DocumentNo      END AS TODocNo,
CASE WHEN STD_TO.StockItemID IS NOT NULL THEN STH_TO.TransactionDate END AS TODate,
STD_TO.Quantity AS TO_Quantity, STD_TO.UnitPrice AS TO_UnitPrice,
CASE WHEN STD_TI.StockItemID IS NOT NULL THEN STH_TI.DocumentNo      END AS TIDocNo,
CASE WHEN STD_TI.StockItemID IS NOT NULL THEN STH_TI.TransactionDate END AS TIDate,
STD_TI.Quantity AS TIQuantity, STD_TI.UnitPrice AS TIUnitPrice, U.Name AS unitName, CU_RT.FullName AS reqestedUser, CU_TO.FullName AS TOuser, CU_TI.FullName AS TIuser
FROM RequestHeaders RH
INNER JOIN RequestDetails RD ON RD.RequestHeaderID = RH.Id
LEFT JOIN StockTransactionHeaders STH_TO ON STH_TO.ReferenceID = RH.Id AND STH_TO.TransactionType = 'TO'
LEFT JOIN StockTransactionDetails STD_TO ON STD_TO.StockTransactionHeaderID = STH_TO.Id AND STD_TO.StockItemID = RD.StockItemID
LEFT JOIN StockTransactionHeaders STH_TI ON STH_TI.ReferenceID = STH_TO.Id AND STH_TI.TransactionType = 'TI'
LEFT JOIN StockTransactionDetails STD_TI ON STD_TI.StockTransactionHeaderID = STH_TI.Id AND STD_TI.StockItemID = RD.StockItemID
INNER JOIN Locations LO1 ON LO1.ID = STH_TO.TransferLocationID
INNER JOIN Locations LO2 ON LO2.ID = STH_TO.LocationID
INNER JOIN StockItemHeaders SID ON SID.Id = RD.StockItemID
INNER JOIN Units U ON U.Id = RD.UnitID
INNER JOIN CentralUsers CU_RT ON CU_RT.Id = RH.UserProfileID
LEFT JOIN CentralUsers CU_TO ON CU_TO.Id = STD_TO.UserProfileId 
LEFT JOIN CentralUsers CU_TI ON CU_TI.Id = STD_TI.UserProfileId
WHERE RH.SystemDate BETWEEN @FROMDATE AND @TODATE 
AND (@FROMLOCATIONID = -999 OR RH.TransferLocation = @FROMLOCATIONID)
AND (@TOLOCATIONID = -999 OR RH.LocationID = @TOLOCATIONID)

UNION ALL

-- DECLARE @FROMDATE DATE = '2026-01-27', @TODATE DATE = '2026-04-30', @FROMLOCATIONID INT = -999, @TOLOCATIONID INT = -999

SELECT 
LO1.Name as fromLocation, LO2.Name as toLocation, STD_TO.Id stocktransactionID, '' AS transferNoteDate, 
PH.DocumentNo AS RHDocumentNo, '' AS ProdPlanDocNo, '' AS RequestDate, STD_TO.StockItemID, SID.StockItemCode, SID.Name, PS.Quantity AS requestedQTY,
CASE WHEN STD_TO.StockItemID IS NOT NULL THEN STH_TO.DocumentNo      END AS TODocNo,
CASE WHEN STD_TO.StockItemID IS NOT NULL THEN STH_TO.TransactionDate END AS TODate,
STD_TO.Quantity AS TO_Quantity, STD_TO.UnitPrice AS TO_UnitPrice,
CASE WHEN STD_TI.StockItemID IS NOT NULL THEN STH_TI.DocumentNo      END AS TIDocNo,
CASE WHEN STD_TI.StockItemID IS NOT NULL THEN STH_TI.TransactionDate END AS TIDate,
STD_TI.Quantity AS TIQuantity, STD_TI.UnitPrice AS TIUnitPrice, U.Name AS unitName, CU_PH.FullName AS reqestedUser, CU_TO.FullName AS TOuser, CU_TI.FullName AS TIuser
FROM ProductionConsolidateHeader PH
INNER JOIN ProductionConsolidateRecipeSummary PS ON PH.ID = PS.ProductionConsolidateHeaderID
INNER JOIN StockTransactionHeaders STH_TO ON STH_TO.ReferenceID = PH.ID AND STH_TO.TransactionType = 'TO'
INNER JOIN StockTransactionDetails STD_TO ON STH_TO.ID = STD_TO.StockTransactionHeaderID
LEFT JOIN StockTransactionHeaders STH_TI ON STH_TI.ReferenceID = STH_TO.ID AND STH_TI.TransactionType = 'TI'
INNER JOIN StockTransactionDetails STD_TI ON STH_TI.ID = STD_TI.StockTransactionHeaderID
INNER JOIN Locations LO1 ON LO1.ID = STH_TO.TransferLocationID
INNER JOIN Locations LO2 ON LO2.ID = STH_TO.LocationID
INNER JOIN StockItemHeaders SID ON SID.Id = STD_TO.StockItemID
INNER JOIN Units U ON U.Id = STD_TO.TxnUnitID
INNER JOIN CentralUsers CU_PH ON CU_PH.Id = PH.UserID
INNER JOIN CentralUsers CU_TI ON CU_TI.Id = STH_TI.CreatedUserID
INNER JOIN CentralUsers CU_TO ON CU_TO.Id = STH_TO.CreatedUserID
WHERE STH_TO.IsProductionPlan=1 AND STH_TO.TransactionDate BETWEEN @FROMDATE AND @TODATE 
AND (@FROMLOCATIONID = -999 OR STH_TO.LocationID = @FROMLOCATIONID)
AND (@TOLOCATIONID = -999 OR STH_TO.TransferLocationID = @TOLOCATIONID)

UNION ALL

-- DECLARE @FROMDATE DATE = '2026-04-27', @TODATE DATE = '2026-04-30', @FROMLOCATIONID INT = -999, @TOLOCATIONID INT = -999

SELECT 
LO1.Name AS fromLocation, LO2.Name AS toLocation, STD_TO.Id AS stocktransactionID, STH_TO.TransactionDate AS transferNoteDate,
'' AS RHDocumentNo, '' AS ProdPlanDocNo, '' AS RequestDate,
STD_TO.StockItemID, SID.StockItemCode, SID.Name, 0 AS requestedQTY,
STH_TO.DocumentNo AS TODocNo, STH_TO.TransactionDate AS TODate,
STD_TO.Quantity AS TO_Quantity, STD_TO.UnitPrice AS TO_UnitPrice,
CASE WHEN STD_TI.StockItemID IS NOT NULL THEN STH_TI.DocumentNo      END AS TIDocNo,
CASE WHEN STD_TI.StockItemID IS NOT NULL THEN STH_TI.TransactionDate END AS TIDate,
STD_TI.Quantity AS TIQuantity, STD_TI.UnitPrice AS TIUnitPrice,
U.Name AS unitName, '' AS reqestedUser, CU_TO.FullName AS TOuser, CU_TI.FullName AS TIuser  
FROM StockTransactionHeaders STH_TO
INNER JOIN StockTransactionDetails STD_TO ON STH_TO.Id = STD_TO.StockTransactionHeaderID
INNER JOIN Locations LO1 ON LO1.Id = STH_TO.LocationID
INNER JOIN Locations LO2 ON LO2.Id = STH_TO.TransferLocationID
INNER JOIN StockItemHeaders SID ON SID.Id = STD_TO.StockItemID
LEFT JOIN StockTransactionHeaders STH_TI ON STH_TI.ReferenceID = STH_TO.Id AND STH_TI.TransactionType = 'TI'
LEFT JOIN StockTransactionDetails STD_TI ON STD_TI.StockTransactionHeaderID = STH_TI.Id AND STD_TI.StockItemID = STD_TO.StockItemID
LEFT JOIN CentralUsers CU_TO ON CU_TO.Id = STH_TO.CreatedUserID
LEFT JOIN CentralUsers CU_TI ON CU_TI.Id = STH_TI.CreatedUserID
INNER JOIN Units U ON U.Id = STD_TO.TxnUnitID
WHERE STH_TO.TransactionType = 'TO'
  AND STH_TO.IsProductionPlan = 0
  AND STH_TO.ReferenceID = -999
  AND STH_TO.TransactionDate BETWEEN @FROMDATE AND @TODATE
  AND (@FROMLOCATIONID = -999 OR STH_TO.LocationID        = @FROMLOCATIONID)
  AND (@TOLOCATIONID   = -999 OR STH_TO.TransferLocationID = @TOLOCATIONID)
ORDER BY STD_TO.Id; 
END

GO

