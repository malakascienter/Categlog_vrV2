
-- [dbo].[SP_SelectAll_RequestNotes] 1,'RI',-34,'R',1,59

CREATE Procedure [dbo].[SP_SelectAll_RequestNotes] --1,'RI',32,'R'
(
@PropertyID int,
@RequestType char(2),
@RequestHeaderID int,
@Operation char(1),
@locationID INT=0,
@DeptId INT=0
)
As

IF (@Operation = 'R')

BEGIN
	SELECT DISTINCT dbo.RequestHeaders.Id AS RequestDetailID, dbo.RequestHeaders.DocumentNo +' '+' | '+ CONVERT(VARCHAR,RequestDate,31) as DocumentNo
	FROM dbo.RequestHeaders 
	INNER JOIN	dbo.RequestDetails ON dbo.RequestHeaders.Id = dbo.RequestDetails.RequestHeaderID
	WHERE  dbo.RequestHeaders.PropertyID = @PropertyID AND dbo.RequestHeaders.RequestType = @RequestType
	AND dbo.RequestHeaders.IsApproved = 1
	AND dbo.RequestHeaders.DocumentStatus = 'P' 
	AND dbo.RequestHeaders.LocationID=@locationID
	AND dbo.RequestHeaders.DepartmentID=@DeptId
	 ORDER BY dbo.RequestHeaders.Id DESC
	
END

ELSE IF	(@Operation='A')

BEGIN
		SELECT      dbo.RequestHeaders.DepartmentID,dbo.RequestHeaders.LocationID,dbo.RequestHeaders.TransferLocation,dbo.RequestHeaders.Id AS RequestHeaderID, dbo.RequestDetails.Id AS RequestDetailID, dbo.StockItemHeaders.StockItemCode, StockItemHeaders.Name AS ItemName, 
					dbo.Units.Code AS UnitCode, 
					--dbo.StockItemDetails.AveragePrice as UnitPrice, --Commented by Isuru 2025-07-23 to loading last average price
					 dbo.[FN_GetLastAveragePrice](RequestHeaders.LocationID,RequestDetails.StockItemID) AS UnitPrice, --Added by Isuru 2025-07-23 to loading last average price
					dbo.RequestHeaders.DocumentNo,RequestDetails.ApprovedQuantity RequestedQuantity, 
					[dbo].[FN_GetStockInHand_Reatils](StockItemHeaders.CompanyId,StockItemDetails.LocationID,StockItemHeaders.Id) AS QuantityInHand, RequestHeaders.RequestDate, dbo.RequestDetails.Remarks, RequestHeaders.DocumentStatus, 
					StockItemHeaders.Id AS StockItemHeaderID, Units.Id AS UnitID,RequestDetails.ApprovedQuantity- dbo.RequestDetails.IssuedQuantity ApprovedQuantity,
					dbo.StockItemHeaders.IsExpiryDateApplicable,dbo.Units.Name AS UnitName, UM.UserName AS RequestedUser,
					RequestHeaders.PaxCount
		FROM        dbo.RequestHeaders INNER JOIN
					dbo.RequestDetails ON dbo.RequestHeaders.Id = RequestDetails.RequestHeaderID INNER JOIN
					dbo.Units ON dbo.RequestDetails.UnitID = Units.Id INNER JOIN
					StockItemDetails ON RequestHeaders.LocationID = StockItemDetails.LocationID AND 
					RequestDetails.StockItemID = StockItemDetails.StockItemHeaderID INNER JOIN
					dbo.StockItemHeaders ON StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
					LEFT JOIN UserMasters UM ON UM.Id = RequestHeaders.UserProfileID
		WHERE       RequestHeaders.PropertyID = @PropertyID AND RequestHeaders.RequestType = @RequestType 
		AND RequestHeaders.Id = @RequestHeaderID
		AND dbo.RequestHeaders.IsApproved = 1
		AND RequestHeaders.DocumentStatus = 'P'
		and ApprovedQuantity - IssuedQuantity >0
		ORDER BY RequestHeaders.Id,dbo.RequestDetails.Id
END



--SELECT * FROM requestheaders
--SELECT * FROM requestdetails

GO

