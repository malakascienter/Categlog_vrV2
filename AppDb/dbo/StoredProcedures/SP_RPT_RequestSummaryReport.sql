-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-07-14
-- Description:	Loading Request Summary Report
-- [dbo].[SP_RPT_RequestSummaryReport] 1,1,'2023-01-01','2025-07-14','RT','p'

-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_RequestSummaryReport]
(@PropertyID INT, 
@LocationId INT,
@FromDate DATE,
@ToDate DATE,
@TransactionType CHAR(4),
@Status CHAR(2)
)
AS
BEGIN
	SET NOCOUNT ON;


	IF (@Status = 'PE') --APPROVAL PENDING REQUESTS
	BEGIN
		SELECT RH.Id,LO.Name LocationName,DE.Name Department,RH.DocumentNo,SH.StockItemCode,SH.Name ItemName,UN.Name,RH.Remarks,RD.ApprovedQuantity,RD.IssuedQuantity,
		RH.RequestDate,'APPROVAL PENDING' Status
		FROM RequestHeaders RH with (nolock)
		INNER JOIN RequestDetails RD with (nolock) ON RH.ID = RD.RequestHeaderID
		INNER JOIN Locations LO with (nolock) ON LO.ID = RH.LocationID
		LEFT JOIN Departments DE with (nolock) ON DE.Id = RH.DepartmentID
		INNER JOIN StockItemHeaders SH with (nolock) ON SH.ID = RD.StockItemID
		INNER JOIN Units UN with (nolock) ON UN.ID = RD.UnitID
		WHERE RH.RequestType= @TransactionType
		AND RH.IsApproved=0
		AND RH.RequestDate BETWEEN @FromDate AND @ToDate
		AND RH.LocationID = CASE WHEN @LocationId = -999 THEN RH.LocationID  ELSE @LocationId END
		AND RH.PropertyID = @PropertyID 
	END

	IF (@Status = 'X') --CANCELLED REQUESTS
	BEGIN
		SELECT RH.Id,LO.Name LocationName,DE.Name Department,RH.DocumentNo,SH.StockItemCode,SH.Name ItemName,UN.Name,RD.ApprovedQuantity,RD.IssuedQuantity
		,RH.RequestDate,RH.Remarks,'CANCELLED' Status
		FROM RequestHeaders RH with (nolock)
		INNER JOIN RequestDetails RD with (nolock) ON RH.ID = RD.RequestHeaderID
		INNER JOIN Locations LO with (nolock) ON LO.ID = RH.LocationID
		LEFT JOIN Departments DE with (nolock) ON DE.Id = RH.DepartmentID
		INNER JOIN StockItemHeaders SH with (nolock) ON SH.ID = RD.StockItemID
		INNER JOIN Units UN with (nolock) ON UN.ID = RD.UnitID
		WHERE RH.RequestType= @TransactionType
		AND RH.RequestDate BETWEEN @FromDate AND @ToDate
		AND RH.LocationID = CASE WHEN @LocationId = -999 THEN RH.LocationID  ELSE @LocationId END
		AND RH.PropertyID = @PropertyID 
		AND RH.DocumentStatus='X'
	END

	IF (@Status = 'C') --COMPLERE REQUESTS
	BEGIN
		SELECT RH.Id,LO.Name LocationName,DE.Name Department,RH.DocumentNo,SH.StockItemCode,SH.Name ItemName,UN.Name,RD.ApprovedQuantity,RD.IssuedQuantity
		,RH.RequestDate,RH.Remarks,'COMPLETE' Status
		FROM RequestHeaders RH with (nolock)
		INNER JOIN RequestDetails RD with (nolock) ON RH.ID = RD.RequestHeaderID
		INNER JOIN Locations LO with (nolock) ON LO.ID = RH.LocationID
		LEFT JOIN Departments DE with (nolock) ON DE.Id = RH.DepartmentID
		INNER JOIN StockItemHeaders SH with (nolock) ON SH.ID = RD.StockItemID
		INNER JOIN Units UN with (nolock) ON UN.ID = RD.UnitID
		WHERE RH.RequestType= @TransactionType
		AND RH.RequestDate BETWEEN @FromDate AND @ToDate
		AND RH.LocationID = CASE WHEN @LocationId = -999 THEN RH.LocationID  ELSE @LocationId END
		AND RH.PropertyID = @PropertyID 
		AND RH.DocumentStatus='C'
	END

	
	IF (@Status = 'O') --OPEN REQUEST
	BEGIN
		SELECT RH.Id,LO.Name LocationName,DE.Name Department,RH.DocumentNo,SH.StockItemCode,SH.Name ItemName,UN.Name,RD.ApprovedQuantity,RD.IssuedQuantity
		,RH.RequestDate,RH.Remarks, 'OPEN' Status
		FROM RequestHeaders RH with (nolock)
		INNER JOIN RequestDetails RD with (nolock) ON RH.ID = RD.RequestHeaderID
		INNER JOIN Locations LO with (nolock) ON LO.ID = RH.LocationID
		LEFT JOIN Departments DE with (nolock) ON DE.Id = RH.DepartmentID
		INNER JOIN StockItemHeaders SH with (nolock) ON SH.ID = RD.StockItemID
		INNER JOIN Units UN with (nolock) ON UN.ID = RD.UnitID
		WHERE RH.RequestType= @TransactionType
		AND RH.RequestDate BETWEEN @FromDate AND @ToDate
		AND RH.LocationID = CASE WHEN @LocationId = -999 THEN RH.LocationID  ELSE @LocationId END
		AND RH.PropertyID = @PropertyID 
		AND RH.DocumentStatus='P'
		AND RH.IsApproved=1
		AND NOT EXISTS (
        SELECT 1
        FROM RequestDetails RD2
        WHERE RD2.RequestHeaderID = RH.ID
          AND RD2.IssuedQuantity > 0
		);
	END

	IF (@Status = 'P') -- PARTIAL REQUESTS
	BEGIN
		SELECT RH.Id,LO.Name LocationName,DE.Name Department,RH.DocumentNo,SH.StockItemCode,SH.Name ItemName,UN.Name,RD.ApprovedQuantity,RD.IssuedQuantity
		,RH.RequestDate,RH.Remarks,'PARTIAL' Status
		FROM RequestHeaders RH with (nolock)
		INNER JOIN RequestDetails RD with (nolock) ON RH.ID = RD.RequestHeaderID
		INNER JOIN Locations LO with (nolock) ON LO.ID = RH.LocationID
		LEFT JOIN Departments DE with (nolock) ON DE.Id = RH.DepartmentID
		INNER JOIN StockItemHeaders SH with (nolock) ON SH.ID = RD.StockItemID
		INNER JOIN Units UN with (nolock) ON UN.ID = RD.UnitID
		WHERE RH.RequestType= @TransactionType
		AND RH.RequestDate BETWEEN @FromDate AND @ToDate
		AND RH.LocationID = CASE WHEN @LocationId = -999 THEN RH.LocationID  ELSE @LocationId END
		AND RH.PropertyID = @PropertyID 
		AND RH.DocumentStatus='P'
		AND RH.IsApproved=1
		--AND EXISTS (SELECT 1 FROM RequestDetails RD2 WHERE RD2.RequestHeaderID = RH.ID AND RD2.IssuedQuantity > 0)
		AND EXISTS (SELECT 1 FROM RequestDetails RD3 WHERE RD3.RequestHeaderID = RH.ID AND RD3.ApprovedQuantity > RD3.IssuedQuantity)
	END

	IF(@Status = 'A') -- All Requests
	BEGIN
		SELECT 
    RH.Id,
    LO.Name AS LocationName,
    DE.Name AS Department,
    RH.DocumentNo,
    SH.StockItemCode,
    SH.Name AS ItemName,
    UN.Name,
    RD.ApprovedQuantity,
    RD.IssuedQuantity,
    RH.RequestDate,
    RH.Remarks,
    CASE 
        WHEN RH.DocumentStatus = 'C' THEN 'COMPLETE' 
        WHEN RH.DocumentStatus = 'X' THEN 'REJECTED'
        WHEN RH.IsApproved = 0 AND RH.DocumentStatus = 'P' THEN 'APPROVAL PENDING'
        WHEN RH.IsApproved = 1 AND RH.DocumentStatus = 'P' 
             AND agg.TotalIssued > 0 
             AND agg.TotalIssued < agg.TotalApproved THEN 'PARTIAL'
        WHEN RH.IsApproved = 1 AND RH.DocumentStatus = 'P' THEN 'ACCEPTED'
    END AS Status
FROM RequestHeaders RH WITH (NOLOCK)
INNER JOIN RequestDetails RD WITH (NOLOCK) ON RH.ID = RD.RequestHeaderID
INNER JOIN Locations LO WITH (NOLOCK) ON LO.ID = RH.LocationID
LEFT JOIN Departments DE WITH (NOLOCK) ON DE.Id = RH.DepartmentID
INNER JOIN StockItemHeaders SH WITH (NOLOCK) ON SH.ID = RD.StockItemID
INNER JOIN Units UN WITH (NOLOCK) ON UN.ID = RD.UnitID

CROSS APPLY (
    SELECT 
        SUM(RD2.IssuedQuantity) AS TotalIssued,
        SUM(RD2.ApprovedQuantity) AS TotalApproved
    FROM RequestDetails RD2 WITH (NOLOCK)
    WHERE RD2.RequestHeaderID = RH.ID
) agg

		WHERE RH.RequestType= @TransactionType
		AND RH.RequestDate BETWEEN @FromDate AND @ToDate
		AND RH.LocationID = CASE WHEN @LocationId = -999 THEN RH.LocationID  ELSE @LocationId END
		AND RH.PropertyID = @PropertyID 
		ORDER BY RH.RequestDate 

	END

   

END

GO

