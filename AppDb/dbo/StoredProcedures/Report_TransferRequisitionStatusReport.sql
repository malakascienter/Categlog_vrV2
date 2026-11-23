-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2026-03-24
-- Description:	Loading Transfer Requisition status

--	[dbo].[Report_TransferRequisitionStatusReport] 1, '2025-01-01','2026-03-24','15,14,16,7,12,1,8,13,21,19,20',4168,1

-- =============================================
create PROCEDURE [dbo].[Report_TransferRequisitionStatusReport]
	@PropertyID	INT,
	@FromDate DATE,
	@ToDate DATE,
	@MultipleLocationID VARCHAR(MAX),
	@UserID INT,
	@LocationID INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT RH.DocumentNo RequestDocNo
	,CASE WHEN RH.IsApproved = 0 AND RH.DocumentStatus = 'P' THEN 'Approval Pending' 
	WHEN RH.IsApproved = 1 AND RH.DocumentStatus = 'P' THEN 'Pending'
	WHEN RH.DocumentStatus = 'X' THEN 'Rejected'
	WHEN RH.DocumentStatus = 'C' THEN 'Completed'
	END AS STATUS
	,LO.Name RequestedFrom,LO2.Name CurrentLocation,RH.RequestDate,U1.Name RequestedUnitName,SIH.StockItemCode
	,SIH.Name ItemName
	,RD.RequestedQuantity,RD.IssuedQuantity
	,STH.TransactionDate TOTransactionDate,STH.DocumentNo TODocNo,STD.Quantity TOQuantity,U2.Name TOUnit
	,STH2.TransactionDate TITransactionDate,STH2.DocumentNo TIDocNo,STD2.Quantity TIQuantity,U3.Name TIUnit
	FROM RequestHeaders RH
	INNER JOIN RequestDetails RD ON RH.ID = RD.RequestHeaderID
	INNER JOIN StockItemHeaders SIH ON SIH.Id = RD.StockItemID
	INNER JOIN Locations LO ON LO.ID = RH.LocationID
	INNER JOIN Locations LO2 ON LO2.ID = RH.TransferLocation
	INNER JOIN Units U1 ON U1.ID = RD.UnitID
	LEFT JOIN StockTransactionHeaders STH ON STH.ReferenceID = RH.Id AND STH.TransactionType = 'TO'
	LEFT JOIN StockTransactionDetails STD ON STD.StockTransactionHeaderID = STH.Id AND RD.StockItemID = STD.StockItemID
	LEFT JOIN Units U2 ON U2.ID = STD.TxnUnitID 
	
	LEFT JOIN StockTransactionHeaders STH2 ON STH2.ReferenceID = STH.Id AND STH2.TransactionType = 'TI' AND STH.TransactionType = 'TO'
	LEFT JOIN StockTransactionDetails STD2 ON STD2.StockTransactionHeaderID = STH2.Id AND RD.StockItemID = STD2.StockItemID
	LEFT JOIN Units U3 ON U2.ID = STD2.TxnUnitID 
	WHERE RH.RequestType = 'RT'
	AND RH.LocationID = @LocationID
	AND RH.TransferLocation IN (SELECT * FROM string_split(@MultipleLocationID,N','))
	AND RH.RequestDate BETWEEN @FromDate AND @ToDate
	AND RH.PropertyID = @PropertyID
   
END

GO

