
-- =============================================
-- Author:		Tharuka Sachintha
-- Create date: 2026-03-03
-- Description:	get inquiry details for report 
-- =============================================
CREATE PROCEDURE [dbo].[SP_Report_GetAllInquiryDetails] (
	@CompanyId	INT ,
	@LocationId	INT ,
	@FromDate   DATE ,
	@ToDate DATE,
	@TxnTypeId INT,
	@Status CHAR(5),
	@Search VARCHAR(300)= NULL
	)

AS
BEGIN
-------------------------------------------------------------------------------
BEGIN TRY 
	DECLARE @ApprovalTypename VARCHAR(200) , @DocStatus CHAR(1), @TxnHeaderId INT , @TypeId INT , @ValueOfRequest DECIMAL(18,6), 
	@IsCentralLogin BIT

	DECLARE @UserTempTable TABLE(
	Id INT,
	FirstName NVARCHAR(300),
	LastName NVARCHAR(300)
	)
	
	SELECT @IsCentralLogin = IsCentralLogin FROM Companies WHERE CompanyID = CASE WHEN @CompanyId = -999 THEN CompanyID ELSE @CompanyId END 

	IF(@IsCentralLogin = 1)
	BEGIN
		INSERT INTO @UserTempTable
		SELECT Id,FullName,''
		FROM [dbo].[CentralUsers]
	END
	ELSE
	BEGIN
		INSERT INTO @UserTempTable
		SELECT Id, FirstName, LastName 
		FROM UserMasters
	END
	
	DECLARE @TempGrnSuppReturnTable TABLE(
		StockItemID INT,
		GRNQty DECIMAL(18,6),
		UnitPrice DECIMAL(18,6),
		Unit VARCHAR(300),
		ItemName VARCHAR(300),
		Remarks VARCHAR(500),
		LocationId INT,
		QuantityInHand DECIMAL(18,6)
	)
		IF (@Search IS NULL)
		BEGIN
		SET @Search = ''
		END
	
	IF OBJECT_ID('tempdb..#TempPoCopy') IS NOT NULL
    DROP TABLE #TempPoCopy;

	IF OBJECT_ID('tempdb..#TempPOReqTable') IS NOT NULL
    DROP TABLE #TempPOReqTable;

	IF OBJECT_ID('tempdb..#TempIssueTable') IS NOT NULL
    DROP TABLE #TempIssueTable;

	IF OBJECT_ID('tempdb..#TempGRNOrSuppReturn') IS NOT NULL
    DROP TABLE #TempGRNOrSuppReturn;

	IF OBJECT_ID('tempdb..#TempStockReconciliation') IS NOT NULL
    DROP TABLE #TempStockReconciliation;

	IF OBJECT_ID('tempdb..#TempReqTable') IS NOT NULL
    DROP TABLE #TempReqTable;

	IF OBJECT_ID('tempdb..#TempTransferIN') IS NOT NULL
    DROP TABLE #TempTransferIN;
	
	----------Added for PO approvals start------------------
	IF (@TxnTypeId = 2 OR @TxnTypeId = -999)
	BEGIN
		CREATE TABLE #TempPoCopy (
		Location NVARCHAR(200),
		DocumentNo NVARCHAR(200),
		CreatedDate DATETIME,
		DocStatus NVARCHAR(2),
		FirstName NVARCHAR(MAX),
		LastName NVARCHAR(MAX),
		ApprovedQuantity DECIMAL(18,8),
		UnitPrice DECIMAL(18,8),
		ApprovalTypeName NVARCHAR(MAX),
		TransactionHeaderID INT,
		TransactionTypeID INT,
		Supplier NVARCHAR(MAX),
		SeqID INT,
		PropertyID INT,
		LocationID INT,
		IsApproved BIT,
		stockitemid INT,
		Remarks NVARCHAR(100)
	)
		CREATE TABLE #TempPOReqTable (
		Location VARCHAR(250),
		DocumentNo VARCHAR(250),
		CreatedDate DATE,
		DocStatus VARCHAR(50),
		FirstName VARCHAR(200),
		LastName VARCHAR(200),
		ValueOfRequest DECIMAL(18,6),
		ApprovalTypename VARCHAR(200),
		TransactionHeaderID INT,
		TransactionTypeID INT,
		Supplier VARCHAR(200),
		SeqID INT,
		RowNum INT,
		PropertyID INT,
		LocationID INT,
		allRowCount INT,
		IsApproved BIT,
		Remarks VARCHAR(100)
		)

		IF @FromDate IS NULL 
			SELECT @FromDate = MIN(CreatedDate) FROM dbo.ApprovalLogs WHERE TransactionID = CASE WHEN @TxnTypeId = -999 THEN TransactionID ELSE @TxnTypeId END 
		IF @ToDate IS NULL 
			SELECT @ToDate = MAX(CreatedDate) FROM dbo.ApprovalLogs WHERE TransactionID = CASE WHEN @TxnTypeId = -999 THEN TransactionID ELSE @TxnTypeId END 

		 INSERT INTO #TempPoCopy
		SELECT DISTINCT  
			lo.Name AS Location ,ph.PoNo AS DocumentNo ,l.CreatedDate,l.DocStatus,u.FirstName,u.LastName,pd.ApprovedQuantity ,
			(pd.UnitPrice - case when DiscountValue<> 0 THEN DiscountValue ELSE (pd.UnitPrice *DiscountPercentage /100) END )  AS UnitPrice,
			at.ApprovalTypeName,ph.Id AS TransactionHeaderID,l.TransactionID AS TransactionTypeID,s.Name AS Supplier,l.SeqID,ph.PropertyID,l.LocationID,PH.IsApproved,pd.stockitemid,
			l.Remarks
		--INTO #TempPoCopy
		FROM dbo.ApprovalLogs l 
			LEFT JOIN dbo.Locations lo ON lo.Id = l.LocationID
			INNER JOIN dbo.PoHeaders ph ON ph.Id = l.TransactionHeaderID
			LEFT JOIN dbo.PoDetails pd ON pd.PoHeaderID = ph.Id
			INNER JOIN @UserTempTable u ON u.Id = ph.UserProfileID
			INNER JOIN dbo.Suppliers s ON s.ID = ph.SupplierID
			INNER JOIN dbo.ApprovalTypes at ON l.ApprovalLevelID = at.Id
		WHERE l.PropertyID = @CompanyId  
			AND l.LocationID = CASE WHEN @LocationId =-999 THEN l.LocationID ELSE @LocationId END 
			AND l.TransactionID = CASE WHEN @TxnTypeId = -999 THEN l.TransactionID ELSE @TxnTypeId END
			AND L.DocStatus = CASE WHEN PH.DocumentStatus = 'X' THEN 'X'  WHEN @Status = '-999' THEN l.DocStatus ELSE @Status END  --Added by Isuru 2025-05-08 
			--AND l.DocStatus = CASE WHEN @Status = '-999' THEN l.DocStatus ELSE @Status END 
			AND CAST(l.CreatedDate AS DATE) >= CAST( @FromDate AS DATE) AND cast(l.CreatedDate AS date) <= CAST(@ToDate AS DATE)
			AND (ph.PoNo LIKE '%'+ISNULL(@Search,ph.PoNo)+'%' 
			OR s.Name LIKE '%'+ISNULL(@Search,S.NAME)+'%'
			OR u.FirstName LIKE '%'+ISNULL(@Search,u.FirstName)+'%'
			OR u.LastName LIKE '%'+ISNULL(@Search,u.LastName)+'%')

		

		INSERT INTO #TempPOReqTable
		SELECT  
			Location ,   DocumentNo , CreatedDate,  DocStatus,  FirstName, LastName, 
			SUM(  ApprovedQuantity *  UnitPrice) AS ValueOfRequest, 
			ApprovalTypename, TransactionHeaderID,  TransactionTypeID,   Supplier,SeqID ,
			ROW_NUMBER() OVER (PARTITION BY DocumentNo ORDER BY SeqID) AS RowNum,PropertyID,LocationID,
			COUNT(*) OVER (PARTITION BY DocumentNo) AS allRowCount,IsApproved,Remarks
		FROM #TempPoCopy where 
			DocStatus= CASE WHEN @Status = '-999' THEN DocStatus ELSE @Status END  
			AND TransactionTypeID = CASE WHEN @TxnTypeId = -999 THEN TransactionTypeID ELSE @TxnTypeId END
			AND LocationID = CASE WHEN @LocationId =-999 THEN LocationID ELSE @LocationId END
			AND CAST(CreatedDate AS DATE) >= CAST( @FromDate AS DATE) AND CAST(CreatedDate AS date) <= CAST(@ToDate AS DATE)
		GROUP BY Location  ,DocumentNo,LocationID, CreatedDate, DocStatus, FirstName, LastName,ApprovalTypename,TransactionHeaderID,TransactionTypeID,Supplier,SeqID,PropertyID,IsApproved,Remarks;

      IF(@TxnTypeId <> -999)	  
		
		SELECT  
			Location,DocumentNo,CreatedDate,
			DocStatus = CASE WHEN DocStatus='P' THEN 'Pending' 
				WHEN DocStatus='C' THEN 'Completed' 
				WHEN DocStatus='X' THEN 'Rejected' END,
			FirstName,LastName,ValueOfRequest,
			CASE WHEN IsApproved=1 and DocStatus='C' THEN 'Approved' ELSE ApprovalTypeName END ApprovalTypeName,
			TransactionHeaderID,TransactionTypeID,Supplier,Remarks
		FROM #TempPOReqTable WHERE 
			(RowNum = (SELECT MIN(RowNum) FROM #TempPOReqTable AS sub WHERE sub.DocumentNo = #TempPOReqTable.DocumentNo AND sub.DocStatus <> 'C' AND sub.allRowCount >= 1 )
			OR (RowNum =1 AND allRowCount=1) OR (RowNum= CASE WHEN allRowCount = (SELECT COUNT(RowNum) FROM #TempPOReqTable AS sub
			WHERE sub.DocumentNo = #TempPOReqTable.DocumentNo AND sub.DocStatus = 'C' ) then 1 else 0 end) 
			) AND DocStatus= CASE WHEN @Status = '-999' THEN DocStatus ELSE @Status END  
			AND TransactionTypeID = CASE WHEN @TxnTypeId = -999 THEN TransactionTypeID ELSE @TxnTypeId END
			AND LocationID = CASE WHEN @LocationId =-999 THEN LocationID ELSE @LocationId END
			AND CAST(CreatedDate AS DATE) >= CAST( @FromDate AS DATE) AND CAST(CreatedDate AS DATE) <= CAST(@ToDate AS DATE) 
			and PropertyID = @CompanyId
		ORDER BY CreatedDate
	END
	----------Added for PO approvals End------------------
	
	----------Added for issue return approvals------------------
	IF (@TxnTypeId = 7 OR @TxnTypeId = -999)
	BEGIN
	CREATE TABLE #TempIssueTable (
		Location VARCHAR(250),
		DocumentNo VARCHAR(250),
		CreatedDate DATE,
		DocStatus VARCHAR(50),
		FirstName VARCHAR(200),
		LastName VARCHAR(200),
		ValueOfRequest DECIMAL(18,6),
		ApprovalTypename VARCHAR(200),
		TransactionHeaderID INT,
		TransactionTypeID INT,
		Supplier VARCHAR(200),
		SeqID INT,
		RowNum INT,
		PropertyID INT,
		LocationID INT,
		allRowCount INT
		)

		IF @FromDate IS NULL 
			SELECT @FromDate = MIN(CreatedDate) FROM dbo.ApprovalLogs WHERE TransactionID = CASE WHEN @TxnTypeId = -999 THEN TransactionID ELSE @TxnTypeId END 
		IF @ToDate IS NULL 
			SELECT @ToDate = MAX(CreatedDate) FROM dbo.ApprovalLogs WHERE TransactionID = CASE WHEN @TxnTypeId = -999 THEN TransactionID ELSE @TxnTypeId END 

		INSERT INTO #TempIssueTable
		SELECT 
			lo.Name AS Location , ph.ApprovalDocNo AS DocumentNo ,l.CreatedDate, l.DocStatus, u.FirstName,u.LastName, NULL AS ValueOfRequest,at.ApprovalTypeName,
			ph.Id AS TransactionHeaderID,  l.TransactionID AS TransactionTypeID, '' AS Supplier,l.SeqID,
			ROW_NUMBER() OVER (PARTITION BY ph.ApprovalDocNo ORDER BY l.SeqID) AS RowNum,
			ph.CompanyId as PropertyID,l.LocationID,
			COUNT(*) OVER (PARTITION BY ph.ApprovalDocNo) AS allRowCount
		FROM dbo.ApprovalLogs l 
		LEFT JOIN dbo.Locations lo ON lo.Id = l.LocationID
		INNER JOIN dbo.GRNApprovalLog ph ON ph.Id = l.TransactionHeaderID
		INNER JOIN @UserTempTable u ON u.Id = ph.CreatedUserId
		INNER JOIN dbo.ApprovalTypes at ON l.ApprovalLevelID = at.Id
		WHERE l.PropertyID = @CompanyId and ph.CompanyId = @CompanyId 
			AND l.LocationID = CASE WHEN @LocationId =-999 THEN l.LocationID ELSE @LocationId END  
			AND l.TransactionID = CASE WHEN @TxnTypeId = -999 THEN l.TransactionID ELSE @TxnTypeId END 
			AND l.DocStatus = CASE WHEN @Status = '-999' THEN l.DocStatus ELSE @Status END
			AND CAST(l.CreatedDate AS DATE) >= CAST( @FromDate AS DATE) AND cast(l.CreatedDate AS date) <= CAST(@ToDate AS DATE)
			AND l.TransactionID  = 7
			AND (ph.ApprovalDocNo LIKE '%'+ISNULL(@Search,ph.ApprovalDocNo)+'%' 
				OR u.FirstName LIKE '%'+ISNULL(@Search,u.FirstName)+'%'
				OR u.LastName LIKE '%'+ISNULL(@Search,u.LastName)+'%')
		GROUP BY lo.Name ,l.LocationID,l.SeqID,ph.ApprovalDocNo,ph.CompanyId,l.CreatedDate,l.DocStatus,u.FirstName,u.LastName,at.ApprovalTypeName,ph.Id,l.TransactionID,l.ApprovalLevelID,l.ApprovalUserID
	
		WHILE  EXISTS (SELECT 1 FROM #TempIssueTable WHERE ValueOfRequest IS NULL)
		BEGIN
			SELECT TOP(1) @TxnHeaderId = TransactionHeaderID FROM #TempIssueTable WHERE ValueOfRequest IS NULL
	
			EXEC  [dbo].[SP_GetAllGRNApprovalDetails]  @TxnHeaderId, @ValueOfRequest OUT
				
			UPDATE  #TempIssueTable SET ValueOfRequest = @ValueOfRequest  WHERE TransactionHeaderID = @TxnHeaderId			
		END
		  
		UPDATE #TempIssueTable 
		SET DocStatus = CASE WHEN DocStatus='P' THEN 'Pending' 
						  WHEN DocStatus='C' THEN 'Completed' 
						  WHEN DocStatus='X' THEN 'Rejected' END

      IF(@TxnTypeId <> -999)
		SELECT DISTINCT 
			Location ,DocumentNo ,CreatedDate ,DocStatus ,FirstName ,LastName ,ValueOfRequest ,
			CASE WHEN allRowCount = (SELECT COUNT(sub.RowNum)FROM #TempIssueTable AS sub WHERE sub.DocumentNo = #TempIssueTable.DocumentNo AND sub.DocStatus='Completed') THEN 'Approved' ELSE ApprovalTypename  END AS ApprovalTypeName,
			TransactionHeaderID ,TransactionTypeID ,Supplier 
		FROM #TempIssueTable WHERE
			(RowNum = (SELECT MIN(sub.RowNum) FROM #TempIssueTable AS sub WHERE sub.DocumentNo = #TempIssueTable.DocumentNo  AND sub.DocStatus <> 'Completed' AND sub.allRowCount >= 1)
			OR (RowNum =1 AND allRowCount=1) OR (RowNum= CASE WHEN allRowCount = (SELECT COUNT(RowNum) FROM #TempIssueTable AS sub WHERE sub.DocumentNo = #TempIssueTable.DocumentNo AND sub.DocStatus = 'Completed' ) then 1 else 0 end))
			AND PropertyID = @CompanyId
			AND LocationID = CASE WHEN @LocationId =-999 THEN LocationID ELSE @LocationId END
	END	
	----------Added for issue return approvals------------------

	---------Added for grn/supp return approvals----------------------------
	IF (@TxnTypeId IN ( 3,4) OR @TxnTypeId = -999)
	BEGIN
	CREATE TABLE #TempGRNOrSuppReturn (
		Location VARCHAR(250),
		DocumentNo VARCHAR(250),
		CreatedDate DATE,
		DocStatus VARCHAR(50),
		FirstName VARCHAR(200),
		LastName VARCHAR(200),
		ValueOfRequest DECIMAL(18,6),
		ApprovalTypename VARCHAR(200),
		TransactionHeaderID INT,
		TransactionTypeID INT,
		Supplier VARCHAR(200),
		CompanyId INT,
		LocationId INT
		)

		IF @FromDate IS NULL 
			SELECT @FromDate = MIN(CreatedDate) FROM dbo.GRNApprovalLog WHERE TransactionType = 
			CASE WHEN @TxnTypeId = 3 THEN 'GR' WHEN @TxnTypeId = 4 THEN 'SR' WHEN @TxnTypeId = -999 THEN TransactionType END
		IF @ToDate IS NULL 
			SELECT @ToDate = MAX(CreatedDate) FROM dbo.GRNApprovalLog WHERE TransactionType = 
			CASE WHEN @TxnTypeId = 3 THEN 'GR' WHEN @TxnTypeId = 4 THEN 'SR' WHEN @TxnTypeId = -999 THEN TransactionType END

		INSERT INTO #TempGRNOrSuppReturn
		SELECT 
			lo.Name AS Location , ph.ApprovalDocNo AS DocumentNo ,ph.CreatedDate, ph.Status, u.FirstName,u.LastName, NULL AS ValueOfRequest, 
			CASE WHEN ph.TransactionType = 'GR' THEN 'GRN Approval' WHEN ph.TransactionType = 'SR' THEN 'Supplier Return Approval' END AS ApprovalTypename,
			ph.Id AS TransactionHeaderID,  CASE WHEN ph.TransactionType = 'GR' THEN 3 WHEN ph.TransactionType = 'SR' THEN 4 END AS TransactionTypeID ,'' AS Supplier,ph.CompanyId,ph.LocationId
		FROM GRNApprovalLog ph
		LEFT JOIN dbo.Locations lo ON lo.Id = ph.LocationId
		INNER JOIN @UserTempTable u ON u.Id = ph.CreatedUserId
		WHERE ph.CompanyId = @CompanyId 
			AND ph.LocationID = CASE WHEN @LocationId =-999 THEN ph.LocationID ELSE @LocationId END  
			AND ph.TransactionType =  CASE WHEN @TxnTypeId = 3 THEN 'GR' WHEN @TxnTypeId = 4 THEN 'SR' WHEN @TxnTypeId = -999 THEN ph.TransactionType END
			AND ph.Status = CASE WHEN @Status = '-999' THEN ph.Status ELSE @Status END 
			AND ph.TransactionType IN ( 'GR', 'SR')
			AND CAST(ph.CreatedDate AS DATE) >= CAST( @FromDate AS DATE) AND CAST(ph.CreatedDate AS DATE) <= CAST(@ToDate AS DATE)
			AND (ph.ApprovalDocNo LIKE '%'+ISNULL(@Search,ph.ApprovalDocNo)+'%' 
			OR u.FirstName LIKE '%'+ISNULL(@Search,u.FirstName)+'%'
			OR u.LastName LIKE '%'+ISNULL(@Search,u.LastName)+'%')
		GROUP BY lo.Name ,ph.LocationId,ph.ApprovalDocNo,ph.CreatedDate,ph.Status,u.FirstName,u.LastName,ph.Id,ph.TransactionType,ph.CompanyId
	  
		UPDATE #TempGRNOrSuppReturn 
		SET DocStatus = CASE WHEN DocStatus='P' THEN 'Pending' 
						  WHEN DocStatus='C' THEN 'Completed' 
						  WHEN DocStatus='X' THEN 'Rejected' END
 	  
      IF(@TxnTypeId <> -999)
		SELECT DISTINCT 
			Location ,DocumentNo,CAST(CreatedDate AS DATE) AS CreatedDate ,DocStatus ,FirstName ,LastName,0 ValueOfRequest ,ApprovalTypename ,TransactionHeaderID ,TransactionTypeID ,Supplier 
		FROM #TempGRNOrSuppReturn WHERE CompanyId = @CompanyId
			AND LocationID = CASE WHEN @LocationId =-999 THEN LocationID ELSE @LocationId END ORDER BY CreatedDate 
	END
	-------------------Added for Stock Reconciliation return approvals------------- Added by Nivesh 2024-03-01
    IF (@TxnTypeId = 10 OR @TxnTypeId = -999)
	BEGIN
	CREATE TABLE #TempStockReconciliation (
		Location VARCHAR(250),
		DocumentNo VARCHAR(250),
		CreatedDate DATE,
		DocStatus VARCHAR(50),
		FirstName VARCHAR(200),
		LastName VARCHAR(200),
		ValueOfRequest DECIMAL(18,6),
		ApprovalTypename VARCHAR(200),
		TransactionHeaderID INT,
		TransactionTypeID INT,
		Supplier VARCHAR(200),
		CompanyId INT,
		LocationId INT,
		SeqID INT,
		allRowCount INT,
		RowNum INT,
		)

		IF @FromDate IS NULL 
			SELECT @FromDate = MIN(CreatedDate) FROM dbo.GRNApprovalLog WHERE TransactionType = 'AA'
		IF @ToDate IS NULL 
			SELECT @ToDate = MAX(CreatedDate) FROM dbo.GRNApprovalLog WHERE TransactionType = 'AA'

		INSERT INTO #TempStockReconciliation
		SELECT DISTINCT
			lo.Name AS Location , ph.ApprovalDocNo AS DocumentNo ,ph.CreatedDate, ph.Status, u.FirstName,u.LastName, NULL AS ValueOfRequest, 
			CASE WHEN ph.IsComplete = 1 AND ph.Status = 'C'  THEN 'Approved'  ELSE AT.ApprovalTypeName END AS ApprovalTypename,
			ph.ID AS TransactionHeaderID,  10 AS TransactionTypeID ,'' AS Supplier,ph.CompanyId,ph.LocationId,PH.SeqID
			,--ROW_NUMBER() OVER (PARTITION BY ph.ApprovalDocNo ORDER BY PH.SeqID) AS RowNum--,
			COUNT(*) OVER (PARTITION BY ph.ApprovalDocNo) AS allRowCount,
			ROW_NUMBER() OVER (PARTITION BY ph.ApprovalDocNo ORDER BY PH.SeqID) AS RowNum
		FROM GRNApprovalLog ph
		LEFT JOIN dbo.Locations lo ON lo.Id = ph.LocationId
		LEFT JOIN ApprovalTypes AT ON AT.Id = ph.ApprovallevelId
		INNER JOIN @UserTempTable u ON u.Id = ph.UserProfileId
		WHERE ph.CompanyId = @CompanyId 
			AND ph.LocationID = CASE WHEN @LocationId =-999 THEN ph.LocationID ELSE @LocationId END  
			AND ph.TransactionType =  CASE WHEN @TxnTypeId = -999 THEN ph.TransactionType ELSE 'AA' END
			AND ph.Status = CASE WHEN @Status = '-999' THEN ph.Status ELSE @Status END 
			AND ph.TransactionType IN ( 'AA')
			AND CAST(ph.CreatedDate AS DATE) >= CAST( @FromDate AS DATE) AND CAST(ph.CreatedDate AS DATE) <= CAST(@ToDate AS DATE)
			AND (ph.ApprovalDocNo LIKE '%'+ISNULL(@Search,ph.ApprovalDocNo)+'%' 
			OR u.FirstName LIKE '%'+ISNULL(@Search,u.FirstName)+'%'
			OR u.LastName LIKE '%'+ISNULL(@Search,u.LastName)+'%')
		GROUP BY lo.Name,PH.SeqID ,ph.LocationId,ph.ApprovalDocNo,ph.CreatedDate,ph.Status,u.FirstName,u.LastName,ph.ID,ph.TransactionType,ph.CompanyId,ph.IsComplete,AT.ApprovalTypeName
	  
		UPDATE #TempStockReconciliation 
		SET DocStatus = CASE WHEN DocStatus='P' THEN 'Pending' 
							WHEN DocStatus='C' THEN 'Completed' 
							WHEN DocStatus='X' THEN 'Rejected' END
 
		IF(@TxnTypeId <> -999)
		SELECT DISTINCT 
			Location ,DocumentNo,CreatedDate ,DocStatus ,FirstName ,LastName,ValueOfRequest ,ApprovalTypename ,TransactionHeaderID ,TransactionTypeID ,Supplier 
		FROM #TempStockReconciliation WHERE CompanyId = @CompanyId
			AND LocationID = CASE WHEN @LocationId =-999 THEN LocationID ELSE @LocationId END AND 
			--RowNum=1
				(RowNum =(SELECT MIN(RowNum) FROM #TempStockReconciliation AS sub WHERE sub.DocumentNo = #TempStockReconciliation.DocumentNo AND sub.DocStatus <> 'Completed' AND sub.allRowCount >= 1)
			OR (RowNum =1 AND allRowCount=1)
			OR (RowNum= CASE WHEN allRowCount = (SELECT COUNT(RowNum) FROM #TempStockReconciliation AS sub WHERE sub.DocumentNo = #TempStockReconciliation.DocumentNo AND sub.DocStatus = 'Completed' ) THEN 1 ELSE 0 END))
			ORDER BY CreatedDate 
	END
	-------------------------------------------------------------------------
	-- Issue Request 11, Transfer Request 8, Purchase Request 1, Damage Request Note 14 approvals
	IF(@TxnTypeId NOT IN (2,7,3,4,10,12) OR @TxnTypeId = -999) 
	BEGIN
	CREATE TABLE #TempReqTable (
		Location VARCHAR(250),
		DocumentNo VARCHAR(250),
		CreatedDate DATE,
		DocStatus VARCHAR(50),
		FirstName VARCHAR(200),
		LastName VARCHAR(200),
		ValueOfRequest DECIMAL(18,6),
		ApprovalTypename VARCHAR(200),
		TransactionHeaderID INT,
		TransactionTypeID INT,
		Supplier VARCHAR(200),
		DepartmentName VARCHAR(250),
		SeqID INT,
		RowNum INT,
		PropertyID INT,
		LocationID INT,
		allRowCount INT,
		IsApproved BIT,
		Remarks NVARCHAR(100)
		)

		IF @FromDate IS NULL 
			SELECT @FromDate = MIN(CreatedDate) FROM dbo.ApprovalLogs WHERE TransactionID = CASE WHEN @TxnTypeId = -999 THEN TransactionID ELSE @TxnTypeId END 
		IF @ToDate IS NULL 
			SELECT @ToDate = MAX(CreatedDate) FROM dbo.ApprovalLogs WHERE TransactionID = CASE WHEN @TxnTypeId = -999 THEN TransactionID ELSE @TxnTypeId END 


		IF (@Search IS NULL)
		BEGIN
		SET @Search = ''
		END

		INSERT INTO #TempReqTable
		SELECT 
			lo.Name AS Location , ph.DocumentNo AS DocumentNo ,l.CreatedDate, l.DocStatus, u.FirstName,u.LastName, SUM(pd.ApprovedQuantity * pd.UnitPrice) AS ValueOfRequest, 
			at.ApprovalTypeName,ph.Id AS TransactionHeaderID,  l.TransactionID AS TransactionTypeID, '' AS Supplier,D.Name AS DepartmentName,l.SeqID,
			ROW_NUMBER() OVER (PARTITION BY ph.DocumentNo ORDER BY l.SeqID) AS RowNum,
			l.PropertyID, ph.LocationID,
			COUNT(*) OVER (PARTITION BY ph.DocumentNo) AS allRowCount,
			PH.IsApproved,L.Remarks
		FROM dbo.ApprovalLogs l 
		--LEFT JOIN dbo.Locations lo ON lo.Id = l.LocationID commented by Isuru
		INNER JOIN dbo.RequestHeaders ph ON ph.Id = l.TransactionHeaderID
		LEFT JOIN dbo.Locations lo ON lo.Id = ph.LocationID
		LEFT JOIN dbo.RequestDetails pd ON pd.RequestHeaderID = ph.Id
		INNER JOIN @UserTempTable u ON u.Id = ph.UserProfileID
		LEFT JOIN Departments D ON D.Id = ph.DepartmentID --Modify by Nivesh for getting transafer request 2024-10-18 
		INNER JOIN dbo.ApprovalTypes at ON l.ApprovalLevelID = at.Id
		WHERE l.PropertyID = @CompanyId 
			AND ph.LocationID = CASE WHEN @LocationId =-999 THEN ph.LocationID ELSE @LocationId END  
			AND l.TransactionID = CASE WHEN @TxnTypeId = -999 THEN l.TransactionID ELSE @TxnTypeId END 
			AND l.DocStatus = CASE WHEN @Status = '-999' THEN l.DocStatus ELSE @Status END 
			AND CAST(l.CreatedDate AS DATE) >= CAST( @FromDate AS DATE) AND CAST(l.CreatedDate AS DATE) <= CAST(@ToDate AS DATE)
			AND l.TransactionID NOT IN (2,7,3,4,10,12) 
			AND ph.DocumentNo LIKE '%'+@Search+'%' -- Added by Isuru 2023-11-06
		GROUP BY L.Remarks,lo.Name,PH.IsApproved ,ph.LocationID,l.PropertyID,l.SeqID,ph.DocumentNo,l.CreatedDate,l.DocStatus,u.FirstName,u.LastName,at.ApprovalTypeName,ph.Id,l.TransactionID,l.ApprovalLevelID,l.ApprovalUserID,D.Name
		,L.Id -- Added by Isuru for duplicating ValueOfRequest if multiple same level users found
		  
		UPDATE #TempReqTable 
		SET DocStatus = CASE WHEN DocStatus='P' THEN 'Pending' 
						  WHEN DocStatus='C' THEN 'Completed' 
						  WHEN DocStatus='X' THEN 'Rejected' END

      IF(@TxnTypeId <> -999)
		SELECT DISTINCT 
			Location ,DocumentNo ,CreatedDate ,DocStatus ,FirstName ,LastName ,ValueOfRequest ,
			CASE WHEN IsApproved=1 and DocStatus='Completed' THEN 'Approved' ELSE ApprovalTypeName END ApprovalTypeName ,
			TransactionHeaderID ,TransactionTypeID ,Supplier,Remarks
		FROM #TempReqTable WHERE 
			(RowNum =(SELECT MIN(RowNum) FROM #TempReqTable AS sub WHERE sub.DocumentNo = #TempReqTable.DocumentNo AND sub.DocStatus <> 'Completed' AND sub.allRowCount >= 1)
			OR (RowNum =1 AND allRowCount=1)
			OR (RowNum= CASE WHEN allRowCount = (SELECT COUNT(RowNum) FROM #TempReqTable AS sub WHERE sub.DocumentNo = #TempReqTable.DocumentNo AND sub.DocStatus = 'Completed' ) THEN 1 ELSE 0 END))
			AND PropertyID = @CompanyId
			AND LocationID = CASE WHEN @LocationId =-999 THEN LocationID ELSE @LocationId END  
	END
   

   	IF((@TxnTypeId = 12 OR @TxnTypeId = -999) AND @Status <> 'X' )
	BEGIN
			
		CREATE TABLE #TempTransferIN (
		Location VARCHAR(250),
		DocumentNo VARCHAR(250),
		CreatedDate DATE,
		DocStatus VARCHAR(50),
		FirstName VARCHAR(200),
		LastName VARCHAR(200),
		ValueOfRequest DECIMAL(18,6),
		ApprovalTypename VARCHAR(200),
		TransactionHeaderID INT,
		TransactionTypeID INT,
		Supplier VARCHAR(200)
		)

		INSERT INTO #TempTransferIN
	      SELECT DISTINCT 
		  L.Name AS Location ,DocumentNo ,STH.CreatedDate AS CreatedDate ,  CASE WHEN STH.IsTrasferIn = 1 THEN 'Completed' ELSE 'Pending' END AS DocStatus ,U.FirstName ,U.LastName , SUM(STD.Quantity*STD.UnitPrice)  ValueOfRequest ,
		  CASE WHEN STH.IsTrasferIn = 1 THEN 'Completed' ELSE 'Pending' END AS ApprovalTypeName ,
		  STH.Id AS TransactionHeaderID ,12 AS TransactionTypeID ,''  AS Supplier
	      FROM StockTransactionHeaders STH WITH (NOLOCK)  
		  INNER JOIN StockTransactionDetails STD WITH (NOLOCK)   ON STH.Id = STD.StockTransactionHeaderID
	      INNER JOIN @UserTempTable u ON u.Id = STH.UserProfileID
		  LEFT JOIN Locations L ON L.Id = STH.LocationID
		  WHERE STH.PropertyID = @CompanyId
		  AND STH.LocationID = CASE WHEN @LocationId =-999 THEN STH.LocationID ELSE @LocationId END 
		  AND CAST(STH.TransactionDate AS DATE) >= CAST( @FromDate AS DATE) AND cast(STH.TransactionDate AS date) <= CAST(@ToDate AS DATE)
		  AND STH.TransactionID = 5 AND STH.IsTrasferIn =  (CASE WHEN @Status = 'C' THEN 1 ELSE CASE WHEN @Status = '-999' THEN STH.IsTrasferIn ELSE 0 END END)
		  GROUP BY L.Name,STH.DocumentNo,STH.CreatedDate,U.FirstName,U.LastName, STH.Id,STH.TransactionID,STH.IsTrasferIn;
		
		IF(@TxnTypeId <> -999 )
		BEGIN
			SELECT * FROM #TempTransferIN
		END
	END

	IF(@TxnTypeId = -999 )
	BEGIN


		IF( @Status <> 'X' )
		BEGIN

		   SELECT DISTINCT 
				  Location ,DocumentNo ,CreatedDate ,DocStatus ,FirstName ,LastName ,ValueOfRequest ,
				  CASE WHEN IsApproved=1 and DocStatus='Completed' THEN 'Approved' ELSE ApprovalTypeName END ApprovalTypeName ,
				  TransactionHeaderID ,TransactionTypeID ,Supplier,
				  Remarks --Added by Nivesh 2024-10-21 for getting remark
			  FROM #TempReqTable WHERE  
				 (RowNum =(SELECT MIN(RowNum) FROM #TempReqTable AS sub WHERE sub.DocumentNo = #TempReqTable.DocumentNo AND sub.DocStatus <> 'Completed' AND sub.allRowCount >= 1)
				 OR (RowNum =1 AND allRowCount=1)
				 OR (RowNum= CASE WHEN allRowCount = (SELECT COUNT(RowNum) FROM #TempReqTable AS sub WHERE sub.DocumentNo = #TempReqTable.DocumentNo AND sub.DocStatus = 'Completed' ) THEN 1 ELSE 0 END))
				 AND PropertyID = @CompanyId
				 AND LocationID = CASE WHEN @LocationId =-999 THEN LocationID ELSE @LocationId END 
			  UNION 
			  SELECT DISTINCT 
				  Location ,DocumentNo ,CreatedDate ,
				  DocStatus = CASE WHEN DocStatus='P' THEN 'Pending' 
										  WHEN DocStatus='C' THEN 'Completed' 
										  WHEN DocStatus='X' THEN 'Rejected' END,
				  FirstName ,LastName ,ValueOfRequest ,
				  CASE WHEN IsApproved=1 and DocStatus='C' THEN 'Approved' ELSE ApprovalTypeName END ApprovalTypeName,
				  TransactionHeaderID ,TransactionTypeID ,Supplier,
				  Remarks --Added by Nivesh 2024-10-21 for getting remark
			  FROM #TempPOReqTable WHERE
				  (RowNum = (SELECT MIN(RowNum) FROM #TempPOReqTable AS sub WHERE sub.DocumentNo = #TempPOReqTable.DocumentNo AND sub.DocStatus <> 'C' AND sub.allRowCount >= 1 )
				  OR (RowNum =1 AND allRowCount=1)
				  OR(RowNum= CASE WHEN allRowCount = (SELECT COUNT(RowNum) FROM #TempPOReqTable AS sub WHERE sub.DocumentNo = #TempPOReqTable.DocumentNo AND sub.DocStatus = 'C' ) THEN 1 ELSE 0 END)) 
				  AND  DocStatus= CASE WHEN @Status = '-999' THEN DocStatus ELSE @Status END  
				  AND TransactionTypeID = CASE WHEN @TxnTypeId = -999 THEN TransactionTypeID ELSE @TxnTypeId END
				  AND LocationID = CASE WHEN @LocationId =-999 THEN LocationID ELSE @LocationId END 
				  AND CAST(CreatedDate AS DATE) >= CAST( @FromDate AS DATE) AND CAST(CreatedDate AS DATE) <= CAST(@ToDate AS DATE) 
				  AND PropertyID = @CompanyId 
			  UNION 
			  SELECT DISTINCT 
				  Location ,DocumentNo ,CreatedDate ,DocStatus ,FirstName ,LastName ,ValueOfRequest ,
				  CASE WHEN allRowCount =(SELECT COUNT(sub.RowNum)FROM #TempIssueTable AS sub WHERE sub.DocumentNo = #TempIssueTable.DocumentNo AND sub.DocStatus='Completed') THEN 'Approved' ELSE ApprovalTypename  END AS ApprovalTypeName,
				  TransactionHeaderID ,TransactionTypeID ,Supplier,
				  '' Remarks --Added by Nivesh 2024-10-21 for getting remark
			  FROM #TempIssueTable WHERE
				  (RowNum = (SELECT MIN(sub.RowNum) FROM #TempIssueTable AS sub WHERE sub.DocumentNo = #TempIssueTable.DocumentNo AND sub.DocStatus <> 'Completed' AND sub.allRowCount >= 1)
				  OR (RowNum =1 AND allRowCount=1)
				  OR (RowNum= CASE WHEN allRowCount = (SELECT COUNT(RowNum) FROM #TempIssueTable AS sub WHERE sub.DocumentNo = #TempIssueTable.DocumentNo AND sub.DocStatus = 'Completed' ) THEN 1 ELSE 0 END))
				  AND PropertyID = @CompanyId
				  AND LocationID = CASE WHEN @LocationId =-999 THEN LocationID ELSE @LocationId END
			  UNION 
			  SELECT DISTINCT 
				  Location ,DocumentNo ,CreatedDate ,DocStatus ,FirstName ,LastName ,ValueOfRequest ,ApprovalTypename ,TransactionHeaderID ,TransactionTypeID ,Supplier,
				  '' Remarks --Added by Nivesh 2024-10-21 for getting remark
			  FROM #TempGRNOrSuppReturn 
			  WHERE CompanyId = @CompanyId
				  AND LocationID = CASE WHEN @LocationId =-999 THEN LocationID ELSE @LocationId END 
			  UNION 
			  SELECT DISTINCT 
				  Location ,DocumentNo ,CreatedDate ,DocStatus ,FirstName ,LastName ,ValueOfRequest ,ApprovalTypename ,TransactionHeaderID ,TransactionTypeID ,Supplier,
				  '' Remarks --Added by Nivesh 2024-10-21 for getting remark
			  FROM #TempStockReconciliation
			  WHERE CompanyId = @CompanyId AND
			   (RowNum = (SELECT MIN(sub.RowNum) FROM #TempStockReconciliation AS sub WHERE sub.DocumentNo = #TempStockReconciliation.DocumentNo AND sub.DocStatus <> 'Completed' AND sub.allRowCount >= 1)
				  OR (RowNum =1 AND allRowCount=1)
				  OR (RowNum= CASE WHEN allRowCount = (SELECT COUNT(RowNum) FROM #TempStockReconciliation AS sub WHERE sub.DocumentNo = #TempStockReconciliation.DocumentNo AND sub.DocStatus = 'Completed' ) THEN 1 ELSE 0 END))
				  AND LocationID = CASE WHEN @LocationId =-999 THEN LocationID ELSE @LocationId END 

			  UNION 
			  SELECT *,
				  '' Remarks --Added by Nivesh 2024-10-21 for getting remark
				  FROM #TempTransferIN
			  -- SELECT DISTINCT 
				 -- L.Name AS Location ,DocumentNo ,STH.CreatedDate AS CreatedDate ,CASE WHEN STH.IsTrasferIn = 1 THEN 'Completed' ELSE 'Pending' END AS DocStatus ,U.FirstName ,U.LastName , SUM(STD.Quantity*STD.UnitPrice)  ValueOfRequest ,
				 -- CASE WHEN STH.IsTrasferIn = 1 THEN 'Completed' ELSE 'Pending' END AS ApprovalTypeName ,
				 -- STH.Id AS TransactionHeaderID ,12 AS TransactionTypeID ,''  AS Supplier
				 -- FROM StockTransactionHeaders STH WITH (NOLOCK)  
				 -- INNER JOIN StockTransactionDetails STD WITH (NOLOCK)   ON STH.Id = STD.StockTransactionHeaderID
				 -- INNER JOIN @UserTempTable u ON u.Id = STH.UserProfileID
				 -- LEFT JOIN Locations L ON L.Id = STH.LocationID
				 -- WHERE STH.PropertyID = @CompanyId
				 -- AND STH.LocationID = CASE WHEN @LocationId =-999 THEN STH.LocationID ELSE @LocationId END 
				 -- AND CAST(STH.TransactionDate AS DATE) >= CAST( @FromDate AS DATE) AND cast(STH.TransactionDate AS date) <= CAST(@ToDate AS DATE)
				 -- AND STH.TransactionID = 5 AND STH.IsTrasferIn =  (CASE WHEN @Status = 'C' THEN 1 ELSE CASE WHEN @Status = '-999' THEN STH.IsTrasferIn ELSE 0 END END)
				 -- GROUP BY L.Name,DocumentNo,STH.CreatedDate,U.FirstName,U.LastName, STH.Id,STH.TransactionID,STH.IsTrasferIn

			  --ORDER BY CreatedDate

		END
		ELSE
		BEGIN

		   SELECT DISTINCT 
				  Location ,DocumentNo ,CreatedDate ,DocStatus ,FirstName ,LastName ,ValueOfRequest ,
				  CASE WHEN IsApproved=1 and DocStatus='Completed' THEN 'Approved' ELSE ApprovalTypeName END ApprovalTypeName ,
				  TransactionHeaderID ,TransactionTypeID ,Supplier,
				  Remarks --Added by Nivesh 2024-10-21 for getting remark
			  FROM #TempReqTable WHERE  
				 (RowNum =(SELECT MIN(RowNum) FROM #TempReqTable AS sub WHERE sub.DocumentNo = #TempReqTable.DocumentNo AND sub.DocStatus <> 'Completed' AND sub.allRowCount >= 1)
				 OR (RowNum =1 AND allRowCount=1)
				 OR (RowNum= CASE WHEN allRowCount = (SELECT COUNT(RowNum) FROM #TempReqTable AS sub WHERE sub.DocumentNo = #TempReqTable.DocumentNo AND sub.DocStatus = 'Completed' ) THEN 1 ELSE 0 END))
				 AND PropertyID = @CompanyId
				 AND LocationID = CASE WHEN @LocationId =-999 THEN LocationID ELSE @LocationId END 
			  UNION 
			  SELECT DISTINCT 
				  Location ,DocumentNo ,CreatedDate ,
				  DocStatus = CASE WHEN DocStatus='P' THEN 'Pending' 
										  WHEN DocStatus='C' THEN 'Completed' 
										  WHEN DocStatus='X' THEN 'Rejected' END,
				  FirstName ,LastName ,ValueOfRequest ,
				  CASE WHEN IsApproved=1 and DocStatus='C' THEN 'Approved' ELSE ApprovalTypeName END ApprovalTypeName,
				  TransactionHeaderID ,TransactionTypeID ,Supplier,
				  Remarks --Added by Nivesh 2024-10-21 for getting remark
			  FROM #TempPOReqTable WHERE
				  (RowNum = (SELECT MIN(RowNum) FROM #TempPOReqTable AS sub WHERE sub.DocumentNo = #TempPOReqTable.DocumentNo AND sub.DocStatus <> 'C' AND sub.allRowCount >= 1 )
				  OR (RowNum =1 AND allRowCount=1)
				  OR(RowNum= CASE WHEN allRowCount = (SELECT COUNT(RowNum) FROM #TempPOReqTable AS sub WHERE sub.DocumentNo = #TempPOReqTable.DocumentNo AND sub.DocStatus = 'C' ) THEN 1 ELSE 0 END)) 
				  AND  DocStatus= CASE WHEN @Status = '-999' THEN DocStatus ELSE @Status END  
				  AND TransactionTypeID = CASE WHEN @TxnTypeId = -999 THEN TransactionTypeID ELSE @TxnTypeId END
				  AND LocationID = CASE WHEN @LocationId =-999 THEN LocationID ELSE @LocationId END 
				  AND CAST(CreatedDate AS DATE) >= CAST( @FromDate AS DATE) AND CAST(CreatedDate AS DATE) <= CAST(@ToDate AS DATE) 
				  AND PropertyID = @CompanyId 
			  UNION 
			  SELECT DISTINCT 
				  Location ,DocumentNo ,CreatedDate ,DocStatus ,FirstName ,LastName ,ValueOfRequest ,
				  CASE WHEN allRowCount =(SELECT COUNT(sub.RowNum)FROM #TempIssueTable AS sub WHERE sub.DocumentNo = #TempIssueTable.DocumentNo AND sub.DocStatus='Completed') THEN 'Approved' ELSE ApprovalTypename  END AS ApprovalTypeName,
				  TransactionHeaderID ,TransactionTypeID ,Supplier,
				  '' Remarks --Added by Nivesh 2024-10-21 for getting remark
			  FROM #TempIssueTable WHERE
				  (RowNum = (SELECT MIN(sub.RowNum) FROM #TempIssueTable AS sub WHERE sub.DocumentNo = #TempIssueTable.DocumentNo AND sub.DocStatus <> 'Completed' AND sub.allRowCount >= 1)
				  OR (RowNum =1 AND allRowCount=1)
				  OR (RowNum= CASE WHEN allRowCount = (SELECT COUNT(RowNum) FROM #TempIssueTable AS sub WHERE sub.DocumentNo = #TempIssueTable.DocumentNo AND sub.DocStatus = 'Completed' ) THEN 1 ELSE 0 END))
				  AND PropertyID = @CompanyId
				  AND LocationID = CASE WHEN @LocationId =-999 THEN LocationID ELSE @LocationId END
			  UNION 
			  SELECT DISTINCT 
				  Location ,DocumentNo ,CreatedDate ,DocStatus ,FirstName ,LastName ,ValueOfRequest ,ApprovalTypename ,TransactionHeaderID ,TransactionTypeID ,Supplier,
				  '' Remarks --Added by Nivesh 2024-10-21 for getting remark
			  FROM #TempGRNOrSuppReturn 
			  WHERE CompanyId = @CompanyId
				  AND LocationID = CASE WHEN @LocationId =-999 THEN LocationID ELSE @LocationId END 
			  UNION 
			  SELECT DISTINCT 
				  Location ,DocumentNo ,CreatedDate ,DocStatus ,FirstName ,LastName ,ValueOfRequest ,ApprovalTypename ,TransactionHeaderID ,TransactionTypeID ,Supplier,
				  '' Remarks --Added by Nivesh 2024-10-21 for getting remark
			  FROM #TempStockReconciliation
			  WHERE CompanyId = @CompanyId AND
			   (RowNum = (SELECT MIN(sub.RowNum) FROM #TempStockReconciliation AS sub WHERE sub.DocumentNo = #TempStockReconciliation.DocumentNo AND sub.DocStatus <> 'Completed' AND sub.allRowCount >= 1)
				  OR (RowNum =1 AND allRowCount=1)
				  OR (RowNum= CASE WHEN allRowCount = (SELECT COUNT(RowNum) FROM #TempStockReconciliation AS sub WHERE sub.DocumentNo = #TempStockReconciliation.DocumentNo AND sub.DocStatus = 'Completed' ) THEN 1 ELSE 0 END))
				  AND LocationID = CASE WHEN @LocationId =-999 THEN LocationID ELSE @LocationId END 

			  

		END

	
	END
	
	


	


END TRY
BEGIN CATCH
	IF @@TRANCOUNT>0
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH;
------------------------------------------------------------------------------
END

GO

