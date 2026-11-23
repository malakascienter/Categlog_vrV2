CREATE PROCEDURE [dbo].[SP_GetAllInquiryData] (	@UserProfileId	INT ,
	@CompanyId	INT ,
	@LocationId	INT ,
	@FromDate   DATE ,
	@ToDate DATE,
	@TxnTypeId INT,
	@Status CHAR(5)
	)

AS
BEGIN



IF (@TxnTypeId = 2 OR @TxnTypeId = -999)
BEGIN

CREATE TABLE #TempPOReqTable (
	Location VARCHAR(250),
	DocumentNo VARCHAR(250),
	CreatedDate DATE,
	DocStatus VARCHAR(50),
	FirstName VARCHAR(200),
	LastName VARCHAR(200),
	ValueOfRequest MONEY,
	ApprovalTypename VARCHAR(200),
	TransactionHeaderID INT,
	TransactionTypeID INT,
	Supplier VARCHAR(200)

)

		IF OBJECT_ID('tempdb..#PENINGPOHEADER') IS NOT NULL
			DROP TABLE #PENINGPOHEADER

			create table #PENINGPOHEADER (POHeaderID int ,ApprovalTypeID int,ReqUserProfId int, ReqUserProf varchar(max),POValue DECIMAL(18,2), TransactionID INT)

			insert into #PENINGPOHEADER 
			EXEC [dbo].[SP_SelectPeningPOApprovalForUser]  @UserProfileId, @CompanyId

			INSERT INTO #TempPOReqTable
			SELECT 
			l.Name Location,
			PoNo AS DocumentNo, 
			DocumentDate AS CreatedDate,
			h.DocumentStatus  AS DocStatus,
			UM.FirstName,
			UM.LastName,
			#PENINGPOHEADER.POValue AS ValueOfRequest,
			app.ApprovalTypeName,
			#PENINGPOHEADER.POHeaderID AS TransactionHeaderID,
			2 AS TransactionTypeID,
			s.Name AS Supplier
		FROM dbo.PoHeaders h
		inner join  #PENINGPOHEADER on #PENINGPOHEADER.POHeaderID = h.Id
		inner join dbo.Locations l on l.Id=h.locationId
		inner join dbo.Suppliers s on h.SupplierID=s.ID 
		inner join dbo.ApprovalTypes app ON app.Id= #PENINGPOHEADER.ApprovalTypeID
		LEFT JOIN dbo.UserMasters UM ON UM.Id = h.UserProfileID
		WHERE h.PropertyID = @CompanyId 
		AND l.Id = CASE WHEN @LocationId = -999 THEN l.Id ELSE @LocationId END 
		AND h.DocumentStatus = CASE WHEN @Status = '-999' THEN h.DocumentStatus ELSE @Status END 
		AND h.DocumentDate BETWEEN @FromDate AND @ToDate
		AND h.IsApproved = 0
		ORDER BY DocumentDate DESC 

		UPDATE #TempPOReqTable 
		SET DocStatus = CASE WHEN DocStatus='P' THEN 'Pending' 
						  WHEN DocStatus='C' THEN 'Complete' 
						  WHEN DocStatus='X' THEN 'Rejected' END

		IF(@TxnTypeId <> -999)
			SELECT * FROM #TempPOReqTable 

END
IF(@TxnTypeId <> 2 OR @TxnTypeId = -999)
BEGIN

CREATE TABLE #TempReqTable (
	Location VARCHAR(250),
	DocumentNo VARCHAR(250),
	CreatedDate DATE,
	DocStatus VARCHAR(50),
	FirstName VARCHAR(200),
	LastName VARCHAR(200),
	ValueOfRequest MONEY,
	ApprovalTypename VARCHAR(200),
	TransactionHeaderID INT,
	TransactionTypeID INT,
	Supplier VARCHAR(200)

)

	INSERT INTO #TempReqTable 
	SELECT DISTINCT 
					UserToApprove.Location,
					req.DocumentNo,
					req.RequestDate AS 'CreatedDate',
					req.DocumentStatus AS DocStatus,
					up.FirstName,
					up.LastName,
					(SELECT SUM(ISNULL(UnitPrice,0) * RequestedQuantity) AS SumOf FROM dbo.RequestDetails 
					WHERE RequestHeaderID = al.TransactionHeaderID AND req.Flag=0) AS 'ValueOfRequest' 
					,AT.ApprovalTypename,
			 		al.TransactionHeaderID,
					@TxnTypeId AS TransactionTypeID,
					'' AS Supplier
		FROM dbo.ApprovalLogs al INNER JOIN ( SELECT  ta.PropertyID
												   , ta.LocationID
												   , ta.TransactionID 
												   , ua.UserProfileID
												   , ta.SeqID,tt.Name AS 'TransationTypeName'
												   , ld.Name 'Location'
												   , tt.Code AS 'Code' 
												   , ta.ApprovalTypeID 
											  FROM dbo.UserWiseApproveLevels ua 
											  INNER JOIN dbo.TransactionWiseApprovalTypes ta ON  ua.approvelevelID =ta.ApprovalTypeID 
											  AND ua.locationID=ta.locationID 
											  AND ua.propertyID=ta.PropertyID
											  INNER JOIN TransactionTypes tt ON tt.Id = ta.TransactionID
											  INNER JOIN dbo.Locations ld ON ld.Id = ta.LocationID
											  WHERE ua.userprofileID = @UserProfileId 
											  AND ua.PropertyID = @CompanyId 
											  AND ua.LocationID= CASE WHEN @LocationId = -999 THEN ua.LocationID ELSE @LocationId END
											) UserToApprove ON al.PropertyID = UserToApprove.PropertyID
								 INNER JOIN dbo.RequestHeaders req ON  req.Id = al.TransactionHeaderID 
											  AND UserToApprove.PropertyID = UserToApprove.PropertyID  
											  AND req.LocationID = UserToApprove.LocationID 
											  AND al.LocationID=UserToApprove.LocationID 
											  AND al.TransactionID = UserToApprove.TransactionID 
											  AND UserToApprove.SeqID = al.SeqID 
											  AND req.DocumentStatus = CASE WHEN @Status = '-999' THEN req.DocumentStatus ELSE @Status END
											  AND req.TransactionTypeCode = CASE WHEN @TxnTypeId = -999 THEN req.TransactionTypeCode ELSE @TxnTypeId END

								INNER JOIN dbo.UserMasters up ON up.Id = req.UserProfileID
								INNER JOIN dbo.ApprovalTypes AT ON AT.Id = al.ApprovalLevelID

		WHERE al.SeqID  in (SELECT MIN(seqID) 
							FROM dbo.ApprovalLogs
							WHERE 
							al.PropertyID = @CompanyId
							AND LocationID =CASE WHEN @LocationId = -999 THEN LocationID ELSE @LocationId END 
							AND dbo.ApprovalLogs.TransactionID = al.TransactionID 
							AND TransactionHeaderID=al.TransactionHeaderID 
							AND RequestDate BETWEEN @FromDate AND @ToDate)  
							AND req.IsApproved = 0
							ORDER BY RequestDate DESC 


		
		UPDATE #TempReqTable 
		SET DocStatus = CASE WHEN DocStatus='P' THEN 'Pending' 
						  WHEN DocStatus='C' THEN 'Complete' 
						  WHEN DocStatus='X' THEN 'Rejected' END

		IF(@TxnTypeId <> -999)
			SELECT * FROM #TempReqTable 

END


IF(@TxnTypeId = -999)
BEGIN
	SELECT * FROM #TempReqTable 
	UNION
	SELECT * FROM #TempPOReqTable
	
END

----------------------------------------------------------------------


	
END

GO

