CREATE PROCEDURE [dbo].[SP_RPT_UserActivity] 
(
@UserID INT = 1,
@FromDateTime DATETIME, 
@ToDateTime DATETIME, 
@ActivityType CHAR(3) = 'All', 
@LocationID INT=-999,
@CategoryID INT =-999, 
@DepartmentID INT =-999,
@PropertyID INT = 1,
@StockItemID INT = -999 
)

AS
BEGIN
	drop table ActivityRpt
	--set @PropertyID=2
	SELECT @UserID UserID,
	@FromDateTime FromDateTim, 
	@ToDateTime ToDateTim, 
	@ActivityType ActivityTyp, 
	@LocationID loc,
	@CategoryID CAT, 
	@DepartmentID DEP,
	@PropertyID PROP,
	@StockItemID ITEM
	into ActivityRpt

	CREATE TABLE #TempData(
	RequestDate DATETIME,
	RequestType VARCHAR(500),
	DocumentNo VARCHAR(50),
	Location VARCHAR(300),
	Department VARCHAR(300),
	Remarks VARCHAR(500 ),
	Amount DECIMAL(18,6),
	ActivityType VARCHAR(500)
	)


	IF(@ActivityType = 'R' OR @ActivityType = 'All')
	BEGIN
		INSERT INTO  #TempData
		SELECT RH.RequestDate, TT.Name AS RequestType,RH.DocumentNo,L.Name AS Location, D.Name AS Department, 'Request Created',
		SUM(RD.RequestedQuantity * RD.UnitPrice) AS Amount, 'Request Notes' AS ActivityType
		FROM RequestHeaders  RH
		INNER JOIN RequestDetails RD ON RH.Id = RD.RequestHeaderID
		LEFT JOIN StockItemHeaders SH ON SH.Id =RD.StockItemID
		LEFT JOIN Categories C ON C.Id = SH.CategoryID
		LEFT JOIN Locations L ON L.Id = RH.LocationID
		LEFT JOIN Departments D ON D.Id = RH.DepartmentID
		INNER JOIN TransactionTypes TT ON TT.Code = RH.RequestType
		WHERE RH.UserProfileID = @UserID
		AND RH.RequestDate BETWEEN  @FromDateTime AND @ToDateTime
		AND RH.LocationID = CASE WHEN @LocationID = -999 THEN RH.LocationID ELSE @LocationID END
		AND RH.DepartmentID = CASE WHEN @DepartmentID = -999 THEN RH.DepartmentID ELSE @DepartmentID END
		AND RD.StockItemID = CASE WHEN @StockItemID = -999 THEN RD.StockItemID ELSE @StockItemID END
		AND C.Id = CASE WHEN @CategoryID = -999 THEN C.Id ELSE @CategoryID END
		AND RH.PropertyID = @PropertyID
		GROUP BY RH.RequestDate,TT.Name,RH.DocumentNo,L.Name , D.Name , RH.Remarks

		
		IF(@ActivityType = 'R')
			SELECT * FROM #TempData

	END
	IF(@ActivityType = 'T' OR @ActivityType = 'All')
	BEGIN
		DECLARE @addtionalCostPre DECIMAL(18,6) = 0,@addtionalCostTotal DECIMAL(18,6) = 0


		INSERT INTO  #TempData
		SELECT TH.CreatedDate, TT.Name AS RequestType,TH.DocumentNo,L.Name AS Location, D.Name AS Department, 'Transaction Created',
		SUM(TD.Quantity * (UnitPrice - ( CASE WHEN DiscountValue > 0 THEN ( DiscountValue / Quantity ) ELSE UnitPrice * DiscountPercentage /100 END ))) AS Amount,'Transactions' AS ActivityType
		FROM StockTransactionHeaders  TH
		INNER JOIN StockTransactionDetails TD ON TH.Id = TD.StockTransactionHeaderID
		LEFT JOIN StockItemHeaders SH ON SH.Id = TD.StockItemID
		LEFT JOIN Categories C ON C.Id = SH.CategoryID
		LEFT JOIN Locations L ON L.Id = TH.LocationID
		LEFT JOIN Departments D ON D.Id = TH.DepartmentID
		INNER JOIN TransactionTypes TT ON TT.Code = TH.TransactionType
		WHERE TH.CreatedUserID = @UserID
		AND TH.TransactionDate BETWEEN  @FromDateTime AND @ToDateTime
		AND TH.LocationID = CASE WHEN @LocationID = -999 THEN TH.LocationID ELSE @LocationID END
		AND TH.DepartmentID = CASE WHEN @DepartmentID = -999 THEN TH.DepartmentID ELSE @DepartmentID END
		AND TD.StockItemID = CASE WHEN @StockItemID = -999 THEN TD.StockItemID ELSE @StockItemID END
		AND C.Id = CASE WHEN @CategoryID = -999 THEN C.Id ELSE @CategoryID END
		AND TH.PropertyID = @PropertyID
		GROUP BY TH.CreatedDate,TT.Name,TH.DocumentNo,L.Name , D.Name , TH.Remarks
		UNION
		SELECT TH.CreatedDate, TT.Name AS RequestType,TH.PoNo,L.Name AS Location, '', 'Transaction Created',
		SUM(TD.RequestedQuantity * (UnitPrice - ( CASE WHEN DiscountValue > 0 THEN ( DiscountValue / ReceivedQuantity ) ELSE UnitPrice * DiscountPercentage /100 END ))) AS Amount,'Transactions' AS ActivityType
		FROM PoHeaders  TH
		INNER JOIN PoDetails TD ON TH.Id = TD.PoHeaderID
		LEFT JOIN StockItemHeaders SH ON SH.Id = TD.StockItemID
		LEFT JOIN Categories C ON C.Id = SH.CategoryID
		LEFT JOIN Locations L ON L.Id = TH.LocationID
		INNER JOIN TransactionTypes TT ON TT.Code = 'PO'
		WHERE TH.UserProfileID = @UserID
		AND TH.DocumentDate BETWEEN  @FromDateTime AND @ToDateTime
		AND TH.LocationID = CASE WHEN @LocationID = -999 THEN TH.LocationID ELSE @LocationID END
		AND TD.StockItemID = CASE WHEN @StockItemID = -999 THEN TD.StockItemID ELSE @StockItemID END
		AND C.Id = CASE WHEN @CategoryID = -999 THEN C.Id ELSE @CategoryID END
		AND TH.PropertyID = @PropertyID
		GROUP BY TH.CreatedDate,TT.Name,TH.PoNo,L.Name , TH.Remarks

		IF(@ActivityType = 'T')
			SELECT * FROM #TempData

	END
	IF(@ActivityType = 'A' OR @ActivityType = 'All')
	BEGIN
		INSERT INTO  #TempData
		SELECT A.CreatedDate,TT.Name  AS RequestType, TH.DocumentNo,L.Name AS  Location, D.Name AS Department, AT.ApprovalTypeName,
		NULL,'Approvals' AS ActivityType
		FROM ApprovalLogs A
		INNER JOIN RequestHeaders TH ON TH.Id = A.TransactionHeaderID
		LEFT JOIN RequestDetails TD ON TH.Id = TD.RequestHeaderID
		LEFT JOIN StockItemHeaders SH ON SH.Id = TD.StockItemID
		LEFT JOIN Categories C ON C.Id = SH.CategoryID
		LEFT JOIN Locations L ON L.Id = TH.LocationID
		LEFT JOIN Departments D ON D.Id = TH.DepartmentID
		INNER JOIN TransactionTypes TT ON TT.Id = A.TransactionID AND TT.Code = TH.RequestType
		LEFT JOIN ApprovalTypes AT ON AT.Id = A.ApprovalLevelID
		WHERE A.ApprovalUserID = @UserID
		AND A.ApprovalDate BETWEEN  @FromDateTime AND @ToDateTime
		AND TH.LocationID = CASE WHEN @LocationID = -999 THEN TH.LocationID ELSE @LocationID END
		AND TH.DepartmentID = CASE WHEN @DepartmentID = -999 THEN TH.DepartmentID ELSE @DepartmentID END
		AND TD.StockItemID = CASE WHEN @StockItemID = -999 THEN TD.StockItemID ELSE @StockItemID END
		AND C.Id = CASE WHEN @CategoryID = -999 THEN C.Id ELSE @CategoryID END
		AND A.PropertyID = @PropertyID
		GROUP BY A.CreatedDate,TT.Name,TH.DocumentNo,L.Name , D.Name , TH.Remarks,AT.ApprovalTypeName
		UNION
		SELECT A.CreatedDate,TT.Name  AS RequestType, TH.DocumentNo,L.Name AS  Location, D.Name AS Department, AT.ApprovalTypeName,
		SUM(TD.ReturnQuantity * TD.UnitPrice) AS Amount,'Approvals' AS ActivityType
		FROM ApprovalLogs A
		INNER JOIN StockTransactionHeaders TH ON TH.Id = A.TransactionHeaderID
		LEFT JOIN StockTransactionDetails TD ON TH.Id = TD.StockTransactionHeaderID
		LEFT JOIN StockItemHeaders SH ON SH.Id = TD.StockItemID
		LEFT JOIN Categories C ON C.Id = SH.CategoryID
		LEFT JOIN Locations L ON L.Id = TH.LocationID
		LEFT JOIN Departments D ON D.Id = TH.DepartmentID
		INNER JOIN TransactionTypes TT ON TT.Id = A.TransactionID AND TT.Code = TH.TransactionType
		LEFT JOIN ApprovalTypes AT ON AT.Id = A.ApprovalLevelID
		WHERE A.ApprovalUserID = @UserID
		AND A.ApprovalDate BETWEEN  @FromDateTime AND @ToDateTime
		AND TH.LocationID = CASE WHEN @LocationID = -999 THEN TH.LocationID ELSE @LocationID END
		AND TH.DepartmentID = CASE WHEN @DepartmentID = -999 THEN TH.DepartmentID ELSE @DepartmentID END
		AND TD.StockItemID = CASE WHEN @StockItemID = -999 THEN TD.StockItemID ELSE @StockItemID END
		AND C.Id = CASE WHEN @CategoryID = -999 THEN C.Id ELSE @CategoryID END
		AND A.PropertyID = @PropertyID
		GROUP BY A.CreatedDate,TT.Name,TH.DocumentNo,L.Name , D.Name , TH.Remarks,AT.ApprovalTypeName
		UNION
		SELECT TH.CreatedDate,TT.Name  AS RequestType, TH.ApprovalDocNo,L.Name AS  Location, '',
		CASE WHEN TT.Code = 'GR' THEN 'GRN APPROVAL' WHEN TT.Code = 'SR' THEN 'SUPPLIER RETURN APPROVAL' ELSE AT.ApprovalTypeName END,
		NULL AS Amount,'Approvals' AS ActivityType
		FROM  GRNApprovalLog TH
		LEFT JOIN ApprovalLogs A ON TH.Id = A.TransactionHeaderID AND A.TransactionID IN (3,4,7) 	
		LEFT JOIN Locations L ON L.Id = TH.LocationID
		--LEFT JOIN Departments D ON D.Id = TH.DepartmentID
		LEFT JOIN TransactionTypes TT ON TT.Code = TH.TransactionType
		LEFT JOIN ApprovalTypes AT ON AT.Id = A.ApprovalLevelID
		WHERE TH.ApprovedUserId = @UserID
		AND TH.ApprovedDateTime BETWEEN  @FromDateTime AND @ToDateTime
		AND TH.LocationID = CASE WHEN @LocationID = -999 THEN TH.LocationID ELSE @LocationID END
		--AND TH.DepartmentID = CASE WHEN @DepartmentID = -999 THEN TH.DepartmentID ELSE @DepartmentID END
		AND TH.CompanyId = @PropertyID
		GROUP BY TH.CreatedDate,TT.Name,TH.ApprovalDocNo,L.Name ,  TH.Remarks, AT.ApprovalTypeName,TT.Code
		UNION
		SELECT A.CreatedDate,TT.Name  AS RequestType, TH.PoNo,L.Name AS  Location, '' AS Department, AT.ApprovalTypeName,
		NULL AS Amount,'Approvals' AS ActivityType
		FROM ApprovalLogs A
		INNER JOIN PoHeaders TH ON TH.Id = A.TransactionHeaderID
		LEFT JOIN PoDetails TD ON TH.Id = TD.PoHeaderID
		LEFT JOIN StockItemHeaders SH ON SH.Id = TD.StockItemID
		LEFT JOIN Categories C ON C.Id = SH.CategoryID
		LEFT JOIN Locations L ON L.Id = TH.LocationID
		--LEFT JOIN Departments D ON D.Id = TH.DepartmentID
		INNER JOIN TransactionTypes TT ON TT.Id = A.TransactionID AND TT.Code = 'PO'
		LEFT JOIN ApprovalTypes AT ON AT.Id = A.ApprovalLevelID
		WHERE A.ApprovalUserID = @UserID
		AND A.ApprovalDate BETWEEN  @FromDateTime AND @ToDateTime
		AND TH.LocationID = CASE WHEN @LocationID = -999 THEN TH.LocationID ELSE @LocationID END
		--AND TH.DepartmentID = CASE WHEN @DepartmentID = -999 THEN TH.DepartmentID ELSE @DepartmentID END
		AND TD.StockItemID = CASE WHEN @StockItemID = -999 THEN TD.StockItemID ELSE @StockItemID END
		AND C.Id = CASE WHEN @CategoryID = -999 THEN C.Id ELSE @CategoryID END
		AND A.PropertyID = @PropertyID
		GROUP BY A.CreatedDate,TT.Name,TH.PoNo,L.Name ,  TH.Remarks,AT.ApprovalTypeName
		UNION
		SELECT TH.CreatedDate,'Quotation'  AS RequestType, TH.QuotationNo,'' AS  Location, '', 'QUOTATION APPROVAL',
		NULL AS Amount,'Approvals' AS ActivityType
		FROM  SupplierQuotationHeader TH
		INNER JOIN QuotationWiseProperties QWP ON QWP.QuotationHeaderId = TH.Id
		WHERE TH.ApprovedUserId = @UserID
		AND TH.ApprovedDate BETWEEN  @FromDateTime AND @ToDateTime
		AND QWP.PropertyId = @PropertyID
		GROUP BY TH.CreatedDate,TH.QuotationNo, TH.Remarks
		



		IF(@ActivityType = 'A')
			SELECT * FROM #TempData
	END
	IF(@ActivityType = 'M' OR @ActivityType = 'All')
	BEGIN

		INSERT INTO #TempData 
		SELECT LogTime , MasterFileName ,'', '' ,
		'' , Narration, NULL,'Master Files'  FROM MasterFileChangeLog

		IF(@ActivityType = 'M')
			SELECT * FROM #TempData WHERE RequestDate BETWEEN @FromDateTime AND @ToDateTime

	END
	
	IF(@ActivityType = 'All')
			SELECT * FROM #TempData WHERE RequestDate BETWEEN @FromDateTime AND @ToDateTime
END

GO

