-- =============================================
-- Author:		Vinuki 
-- Create date:28.06.2024
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_SelectAllRequisitionApprovalForTransferApproval] --SP_SelectAllRequisitionApprovalForTransferApproval 4168,0,1,16,1,0,8210

	@UserProfileId	INT = -1,
	@LocationID		INT = 52,
	@PropertyID		INT = -1,
	@Departmentid   INT = -1,
	@TransactionID INT = -1,
	@IsLocationFilter bit = 0,
	@TransferUser int = 0
AS
BEGIN
----------------------------------------TRY CATCH----------------------------------------------
BEGIN TRY 
---------------------------------------TRY---------------------------------------------------------
insert INTO tempdataPara
	
SELECT @UserProfileId UserProfileId,
	@LocationID		location,
	@PropertyID		property,
	@Departmentid   department,
	@TransactionID transerlocation,
	@IsLocationFilter locfilter



	SET NOCOUNT ON;

	DECLARE @Type CHAR(2), @IsCentralLogin BIT,@NewTransactionID INT
	declare @RowCount INT = 1, @TotalRows INT, @TempDocNo varchar(255), @HeaderID int = 0  
	IF(@UserProfileId = 0)
		BEGIN
			RAISERROR('User ID Invalid, Please Log In Again',16,1)
			ROLLBACK TRANSACTION
		END

	SELECT @IsCentralLogin = IsCentralLogin FROM Companies WHERE CompanyID = CASE WHEN @PropertyID = -999 THEN 1 ELSE @PropertyID END

	CREATE TABLE #TempUserTable (Id INT, UserName NVARCHAR(250), IsActive BIT , CreatedUserId INT, Password NVARCHAR(300),
	FirstName NVARCHAR(300), LastName NVARCHAR(300))



	IF(@IsCentralLogin  = 1)
	BEGIN
		INSERT INTO #TempUserTable 
		SELECT Id,UserName,IsActive,CreatedUserId, Password, FullName, ''
		FROM [dbo].[CentralUsers]

		
	END	
	ELSE
	BEGIN
		INSERT INTO #TempUserTable 
		SELECT Id,UserName,IsActive,CreatedUserId , Password, FirstName, LastName
		FROM UserMasters
	END
	SET @Type = 'A'
	--select @TransactionID,@Type
	IF @TransactionID = 2502
	BEGIN 
	    SET @Type = 'CO'
		SET @NewTransactionID = 1
	END 

	IF @TransactionID = 2504
	BEGIN 
	    SET @Type = 'CO'
		SET @NewTransactionID = 11
	END 

	IF @TransactionID = 2506
	BEGIN 
	    SET @Type = 'CO'
		SET @NewTransactionID = 11
	END 

	IF @TransactionID = 2505
	BEGIN 
	    SET @Type = 'T'
		SET @TransactionID = 8
	END 
	--select @TransactionID,@Type
	--IF OBJECT_ID('tempdb..#TempRequsetApproval') IS NOT NULL DROP TABLE #TempRequsetApproval	
	IF OBJECT_ID(N'#TempRequsetApproval', N'U') IS NOT NULL
	BEGIN
	  DROP TABLE #TempRequsetApproval
	END
    --16 is MRN
	--	select @Type
	IF(@IsLocationFilter = 1 AND @TransactionID NOT IN (7, 16 )) or @TransactionID=11 OR @TransactionID=1
	BEGIN
	print 1
	SELECT DISTINCT al.ApprovalLogID,
				al.SeqID,
				al.TransactionID,
				al.ApprovalLevelID,
				al.TransactionHeaderID,
		
				al.PropertyID,
				al.LocationID,
				al.ApprovalUserID,
				al.ApprovalDate,
				al.IsComplete,
				al.DocStatus,
				UserToApprove.UserProfileID,
				UserToApprove.TransationTypeName,
				--UserToApprove.Location,
				CASE WHEN @TransactionID=11 OR @TransactionID=1 THEN LO.NAME WHEN @TransactionID=8 THEN (SELECT TOP 1 NAME FROM Locations WHERE ID=req.LocationID)  ELSE UserToApprove.Location END AS Location , --Added by Isuru 2023-09-08
				UserToApprove.Code,
				UserToApprove.ApprovalTypeID,
				req.Id AS 'PIID',
				req.RequestType,
				req.DocumentNo,
				req.RequestDate AS 'HeadersCreatedDate',
				req.DocumentStatus AS Status,
				1 AS 'JobNo',
				req.IsApproved,
				req.Remarks,
				req.DepartmentID AS 'DepartmentID',
				1 AS 'TransferLocation',
				CURRENT_TIMESTAMP AS 'TimeStamp',
				1 AS 'TransactionTypeID', --txnTypeId
				userName,
				password,
				userName AS 'firstname',
				lastName,
				up.createdUserID,
				al.LastModUserID,
				req.RequestDate AS 'CreatedDate',
				req.RequestDate AS 'LastModDate',
				up.isActive
		, req.UserProfileID AS 'ReqUser'
		, up.firstName+' '+up.lastName AS 'ReqUserName'
		, (SELECT SUM(ISNULL(UnitPrice,0) * RequestedQuantity) AS SumOf FROM dbo.RequestDetails WHERE RequestHeaderID = al.TransactionHeaderID AND req.Flag=0) AS 'ValueOfRequest' 
		 ,AT.ApprovalTypename
		 ,[dbo].[GET_LastApprovedUser](@TransactionID,al.TransactionHeaderID) AS LastApprovedUser,
		 (SELECT Name FROM Locations WHERE Id = Req.TransferLocation) AS 'TransferLocName'
		 ,C.Name 'CompanyName'
		INTO #TempRequsetApproval
	FROM dbo.ApprovalLogs al INNER JOIN ( SELECT  ta.PropertyID
											   , ta.LocationID
											   , ta.TransactionID 
											   , ua.UserProfileID
											   , ta.SeqID,tt.Name AS 'TransationTypeName'
											   , CASE WHEN ld.Name IS NULL THEN Dp.Name else ld.Name end  'Location'
											   , tt.Code AS 'Code' 
											   , ta.ApprovalTypeID 
										  FROM dbo.UserWiseApproveLevels ua INNER JOIN dbo.TransactionWiseApprovalTypes ta ON  ua.approvelevelID =ta.ApprovalTypeID 
																													 AND ua.locationID=ta.locationID 
																													 AND ua.propertyID=ta.PropertyID
																													 ----------Added-----------------
																													 AND ua.TransactionTypeID = ta.TransactionID
																													 ----------Added-----------------
																	   INNER JOIN TransactionTypes tt ON tt.Id = ta.TransactionID
																	   LEFT OUTER JOIN dbo.Locations ld ON ld.Id = ta.LocationID
																	   LEFT OUTER JOIN Departments DP ON Dp.Id= ta.LocationID
										  WHERE ua.userprofileID = @UserProfileId 
										  AND ua.PropertyID = CASE WHEN @PropertyID = -999 THEN ua.PropertyId ELSE @PropertyID END 
										AND ua.LocationID =CASE WHEN @LocationID = -999 or @TransactionID=11 OR @TransactionID=1 THEN  ua.LocationID ELSE @LocationID END



										) UserToApprove ON al.PropertyID = UserToApprove.PropertyID
							INNER JOIN dbo.RequestHeaders req ON  req.Id = al.TransactionHeaderID 
															 AND UserToApprove.PropertyID = UserToApprove.PropertyID  
															 AND CASE WHEN @TransactionID=8 then req.TransferLocation else CASE WHEN @transactionid=11 OR @TransactionID=1 then req.DepartmentID else  req.LocationID end end  = UserToApprove.LocationID 
														     --AND req.TransactionTypeCode = UserToApprove.ApprovalTypeID
															 AND al.LocationID=UserToApprove.LocationID 
															 AND al.TransactionID = UserToApprove.TransactionID 
															 AND IsComplete=0 
															 AND UserToApprove.SeqID = al.SeqID 
															 --AND req.DepartmentID = @Departmentid
															 --AND req.Flag=0
							 INNER JOIN  #TempUserTable up ON up.Id = req.UserProfileID
							 LEFT JOIN LOCATIONS LO ON LO.ID = REQ.LOCATIONID --Added by Isuru 2023-09-08
							
							
INNER JOIN dbo.ApprovalTypes AT ON AT.Id = al.ApprovalLevelID
INNER JOIN Companies C ON C.CompanyID = al.propertyId
 WHERE req.DocumentStatus <> 'X' AND  req.DocumentStatus <> 'C'  --added by Isuru 2023-07-17
	AND al.SeqID  in (SELECT MIN(seqID) 
						FROM dbo.ApprovalLogs
						WHERE IsComplete = 0  AND TransactionID = @TransactionID
						AND al.PropertyID = CASE WHEN @PropertyID = -999 THEN al.PropertyID ELSE @PropertyID END
						--AND LocationID =@LocationID 
					--	AND LocationID = CASE WHEN @LocationID = -999 THEN  LocationID ELSE CASE WHEN @TransactionID=11 then @Departmentid else  @LocationID end END COMMENTED BY Isuru for all department selecting 
						AND LocationID = CASE WHEN @LocationID = -999 THEN  LocationID  WHEN ((@TransactionID=11 OR @TransactionID=1) and @Departmentid=-999) then req.DepartmentID  WHEN ((@TransactionID=11 OR @TransactionID=1) and @Departmentid<>999) then @Departmentid else  @LocationID  END						
						AND dbo.ApprovalLogs.TransactionID = al.TransactionID 
						AND dbo.ApprovalLogs.TransactionHeaderID=al.TransactionHeaderID 
						)  
	

						
		

				--SELECT* FROM #TempRequsetApproval WHERE ApprovalUserID = @UserProfileId


			SELECT @TotalRows = COUNT(*) FROM #TempRequsetApproval;

		WHILE @RowCount <= @TotalRows
BEGIN
    -- Select the DocumentNo and TransactionHeaderID for the current row
    SELECT @TempDocNo = DocumentNo, 
           @HeaderID = TransactionHeaderID
    FROM (
        SELECT DocumentNo, 
               TransactionHeaderID,
               ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNum
        FROM #TempRequsetApproval
    ) AS SubQuery
    WHERE RowNum = @RowCount;

 

		if exists (select * from ApprovalLogs where ApprovalUserID = @Transferuser and TransactionHeaderID = @HeaderID)
		begin
		--select 555555555
		--select @HeaderID headerid
			delete from #TempRequsetApproval where  TransactionHeaderID = @HeaderID
		end

		

		SET @RowCount = @RowCount + 1;
				end



				SELECT* FROM #TempRequsetApproval WHERE ApprovalUserID = @UserProfileId



	END
	-----------------Added for IR---------------------
	ELSE IF( @IsLocationFilter = 1 AND @TransactionID = 7)
	BEGIN
	SELECT DISTINCT al.ApprovalLogID,
				al.SeqID,
				al.TransactionID,
				al.ApprovalLevelID,
				al.TransactionHeaderID,
				SH.DocumentNo AS DocumentNo,
				al.PropertyID,
				al.LocationID,
				al.ApprovalUserID,
				al.ApprovalDate,
				al.IsComplete,
				al.DocStatus,
				UserToApprove.UserProfileID,
				UserToApprove.TransationTypeName,
				UserToApprove.Location,
				UserToApprove.Code,
				UserToApprove.ApprovalTypeID,
				req.Id AS 'PIID',
				req.ApprovalDocNo As RequestType,
				--req.RequestType,
				--req.DocumentNo,
				req.CreatedDate AS 'HeadersCreatedDate',
				req.Status AS Status,
				--1 AS 'JobNo',
				--req.IsApproved,
				req.Remarks,
				--req.DepartmentID AS 'DepartmentID',
				1 AS 'TransferLocation',
				CURRENT_TIMESTAMP AS 'TimeStamp',
				1 AS 'TransactionTypeID', --txnTypeId
				userName,
				password,
				userName AS 'firstname',
				lastName,
				up.createdUserID,
				al.LastModUserID,
				req.CreatedDate AS 'CreatedDate',
				req.CreatedDate AS 'LastModDate',
				up.isActive
		, req.CreatedUserId AS 'ReqUser'
		, up.firstName+' '+up.lastName AS 'ReqUserName'
		--, (SELECT SUM(ISNULL(UnitPrice,0) * RequestedQuantity) AS SumOf FROM dbo.RequestDetails WHERE RequestHeaderID = al.TransactionHeaderID AND req.Flag=0) AS 'ValueOfRequest' 
		, (SELECT SUM(ISNULL(UnitPrice,0) * RequestedQuantity) AS SumOf FROM dbo.RequestDetails WHERE RequestHeaderID = al.TransactionHeaderID ) AS 'ValueOfRequest' 
		 ,AT.ApprovalTypename
		 ,[dbo].[GET_LastApprovedUser](@TransactionID,al.TransactionHeaderID) AS LastApprovedUser
		 ,C.Name 'CompanyName'
		INTO #TempIssueReturnApproval
	FROM dbo.ApprovalLogs al INNER JOIN ( SELECT  ta.PropertyID
											   , ta.LocationID
											   , ta.TransactionID 
											   , ua.UserProfileID
											   , ta.SeqID,tt.Name AS 'TransationTypeName'
											   , ld.Name 'Location'
											   , tt.Code AS 'Code' 
											   , ta.ApprovalTypeID 
										  FROM dbo.UserWiseApproveLevels ua INNER JOIN dbo.TransactionWiseApprovalTypes ta ON  ua.approvelevelID =ta.ApprovalTypeID 
																													 AND ua.locationID=ta.locationID 
																													 AND ua.propertyID=ta.PropertyID
																													 ----------Added-----------------
																													 AND ua.TransactionTypeID = ta.TransactionID
																													 ----------Added-----------------
																	   INNER JOIN TransactionTypes tt ON tt.Id = ta.TransactionID
																	   INNER JOIN dbo.Locations ld ON ld.Id = ta.LocationID
										  WHERE ua.userprofileID = @UserProfileId 
										  AND ua.PropertyID = CASE WHEN @PropertyID = -999 THEN ua.PropertyId ELSE @PropertyID END 
										 AND ua.LocationID= CASE WHEN @LocationID = -999 THEN ua.LocationID ELSE @LocationID END
										) UserToApprove ON al.PropertyID = UserToApprove.PropertyID
							INNER JOIN dbo.GRNApprovalLog req ON  req.Id = al.TransactionHeaderID 
															 AND UserToApprove.PropertyID = UserToApprove.PropertyID  
															 AND req.LocationID = UserToApprove.LocationID 
														     --AND req.TransactionTypeCode = UserToApprove.ApprovalTypeID
															 AND al.LocationID=UserToApprove.LocationID 
															 AND al.TransactionID = UserToApprove.TransactionID 
															 AND al.IsComplete=0 
															 AND UserToApprove.SeqID = al.SeqID 
															 --AND req.DepartmentID = @Departmentid
															 --AND req.Flag=0
							INNER JOIN #TempUserTable up ON up.Id = req.CreatedUserId
							
INNER JOIN dbo.ApprovalTypes AT ON AT.Id = al.ApprovalLevelID
LEFT JOIN StockTransactionHeaders SH ON SH.Id = req.ReferenceId AND SH.TransactionType = 'IN'
INNER JOIN Companies C ON C.CompanyID = al.propertyId

	WHERE al.SeqID  in (SELECT MIN(seqID) 
						FROM dbo.ApprovalLogs
						WHERE IsComplete = 0  AND TransactionID = @TransactionID
						AND al.PropertyID = CASE WHEN @PropertyID = -999 THEN al.PropertyID ELSE @PropertyID END
						AND LocationID = CASE WHEN @LocationID = -999 THEN  LocationID ELSE @LocationID END
						AND dbo.ApprovalLogs.TransactionID = al.TransactionID 
						AND dbo.ApprovalLogs.TransactionHeaderID=al.TransactionHeaderID 
						)  

		SELECT * FROM #TempIssueReturnApproval WHERE ApprovalUserID = @UserProfileId



	END
	-----------------Added for IR---------------------
	 
	ELSE IF @TransactionID=16
	BEGIN

	SELECT DISTINCT al.ApprovalLogID,
				al.SeqID,
				al.TransactionID,
				al.ApprovalLevelID,
				--al.TransactionHeaderID,
				req.Id AS TransactionHeaderID,
				al.PropertyID,
				al.LocationID,
				al.ApprovalUserID,
				al.ApprovalDate,
				al.IsComplete,
				al.DocStatus,
				UserToApprove.UserProfileID,
				TransationTypeName='MRN',
				UserToApprove.Location,
				UserToApprove.Code,
				UserToApprove.ApprovalTypeID,
				req.Id AS 'PIID',
				req.RequestType,
				MRN.DocNo AS DocumentNo,
				req.RequestDate AS 'HeadersCreatedDate',
				req.DocumentStatus,
				1 AS 'JobNo',
				req.IsApproved,
				req.Remarks,
				req.DepartmentID AS 'DepartmentID',
				1 AS 'TransferLocation',
				CURRENT_TIMESTAMP AS 'TimeStamp',
				1 AS 'TransactionTypeID', --txnTypeId
				userName,
				password,
				userName AS 'firstname',
				lastName,
				--communicationTypeID1,
				--communicationTypeID2,
				--communicationTypeID3,
				--communicationTypeID4,
				--contactValue1,
				--contactValue2,
				--contactValue3,
				--contactValue4,
				up.createdUserID,
				al.LastModUserID,
				req.RequestDate AS CreatedDate,
				req.RequestDate AS LastModDate,
				up.isActive
		, req.UserProfileID AS 'ReqUser'
		, up.firstName+' '+up.lastName AS 'ReqUserName'
		, (SELECT SUM(ISNULL(UnitPrice,0) * RequestedQuantity) AS SumOf FROM dbo.RequestDetails WHERE RequestHeaderID = al.TransactionHeaderID) AS 'ValueOfRequest' 
	    ,AT.ApprovalTypename
		,[dbo].[GET_LastApprovedUser](@TransactionID,al.TransactionHeaderID) AS LastApprovedUser
		,C.Name 'CompanyName'
		INTO #TempRequsetApproval3
	FROM dbo.ApprovalLogs al INNER JOIN ( SELECT  ta.PropertyID
											   , ta.LocationID
											   , ta.TransactionID 
											   , ua.UserProfileID
											   , ta.SeqID,tt.Name AS 'TransationTypeName'
											   , ld.Name 'Location'
											   , tt.Code AS 'Code' 
											   , ta.ApprovalTypeID 
										  FROM dbo.UserWiseApproveLevels ua INNER JOIN dbo.TransactionWiseApprovalTypes ta ON  ua.approvelevelID =ta.ApprovalTypeID 
																													 AND ua.locationID=ta.locationID 
																													 AND ua.propertyID=ta.PropertyID
																													 ----------Added-----------------
																													 AND ua.TransactionTypeID = ta.TransactionID
																													 ----------Added-----------------
																	   INNER JOIN TransactionTypes tt ON tt.Id = ta.TransactionID
																	   INNER JOIN dbo.Locations ld ON ld.Id = ta.LocationID
										  WHERE ua.userprofileID = @UserProfileId 
										  AND ua.PropertyID = CASE WHEN @PropertyID = -999 THEN ua.PropertyId ELSE @PropertyID END 
										--AND ua.LocationID=@LocationID
										) UserToApprove ON al.PropertyID = UserToApprove.PropertyID
							INNER JOIN dbo.RequestHeaders req ON  req.Id = (SELECT RequestionID FROM dbo.MRNRegistries WHERE ID=al.TransactionHeaderID)
															 AND UserToApprove.PropertyID = UserToApprove.PropertyID  
															 AND req.LocationID = UserToApprove.LocationID
															 and req.DocumentStatus <> 'X' 
														     --AND req.TransactionTypeCode = UserToApprove.ApprovalTypeID
															 AND al.LocationID=UserToApprove.LocationID 
															 AND al.TransactionID = UserToApprove.TransactionID 
															 AND IsComplete=0 
															 AND UserToApprove.SeqID = al.SeqID 
															 AND req.DepartmentID = CASE WHEN @Departmentid = -999 THEN req.DepartmentID ELSE @Departmentid END
															 AND req.Flag=1 INNER JOIN dbo.MRNRegistries AS MRN ON MRN.RequestionID=req.Id
							INNER JOIN #TempUserTable up ON up.Id = req.UserProfileID
							INNER JOIN dbo.ApprovalTypes AT ON AT.Id = al.ApprovalLevelID
							INNER JOIN Companies C ON C.CompanyID = al.propertyId
				WHERE al.SeqID  in (SELECT MIN(seqID) 
						FROM dbo.ApprovalLogs
						WHERE IsComplete = 0  AND TransactionID = 33
						AND al.PropertyID = CASE WHEN @PropertyID = -999 THEN al.PropertyID ELSE @PropertyID END
						--AND LocationID =@LocationID 
						AND dbo.ApprovalLogs.TransactionID = al.TransactionID 
						AND dbo.ApprovalLogs.TransactionHeaderID=al.TransactionHeaderID 
						)  
	
		

		SELECT * FROM #TempRequsetApproval3 WHERE ApprovalUserID = @UserProfileId

	END
	ELSE IF @TransactionID=61
	BEGIN
	SELECT DISTINCT al.ApprovalLogID,
				al.SeqID,
				al.TransactionID,
				al.ApprovalLevelID,
				al.TransactionHeaderID,
				al.PropertyID,
				al.LocationID,
				al.ApprovalUserID,
				al.ApprovalDate,
				al.IsComplete,
				al.DocStatus,
				UserToApprove.UserProfileID,
				UserToApprove.TransationTypeName,
				UserToApprove.Code,
				UserToApprove.ApprovalTypeID,
				req.Id AS 'PIID',
				req.DocumentNo  AS 'DocumentNo',
			--	req.RequestType,
				C.ProjectName,
				req.CreatedDate AS 'CreatedDate',
				--req.BOQStatus,
				1 AS 'JobNo',
				req.Approve,
				1 AS 'TransferLocation',
				CURRENT_TIMESTAMP AS 'TimeStamp',
				al.LastModUserID
				, req.Remark AS 'Name' 
				--,req.CurrentVersion
				,AT.ApprovalTypename
				,[dbo].[GET_LastApprovedUser](@TransactionID,al.TransactionHeaderID) AS LastApprovedUser
		INTO #TempRequsetApproval4
		--SELECT * 
	FROM dbo.ApprovalLogs al INNER JOIN ( SELECT  ta.PropertyID
											   , ta.LocationID
											   , ta.TransactionID 
											   , ua.UserProfileID
											   , ta.SeqID,tt.Name AS 'TransationTypeName'
											 --  , ld.Name 'Location'
											   , tt.Code AS 'Code' 
											   , ta.ApprovalTypeID 
											   
										  FROM dbo.UserWiseApproveLevels ua INNER JOIN dbo.TransactionWiseApprovalTypes ta ON  ua.approvelevelID =ta.ApprovalTypeID 
																													 AND ua.locationID=ta.locationID 
																													 AND ua.propertyID=ta.PropertyID
																													 ----------Added-----------------
																													 AND ua.TransactionTypeID = ta.TransactionID
																													 ----------Added-----------------
																	   INNER JOIN TransactionTypes tt ON tt.Id = ta.TransactionID
																	 --  INNER JOIN dbo.Locations ld ON ld.Id = ta.LocationID 
																	-- WHERE ua.TransactionTypeID =49

										  WHERE 
										  ua.userprofileID = @UserProfileId
										  AND
										   ua.PropertyID = CASE WHEN @PropertyID = -999 THEN ua.PropertyId ELSE @PropertyID END
										
										) UserToApprove ON al.PropertyID = UserToApprove.PropertyID
							INNER JOIN dbo.BOQAmendmentHeader req ON  req.Id = al.TransactionHeaderID 
															 AND UserToApprove.PropertyID = UserToApprove.PropertyID  
															-- AND req.LocationID = UserToApprove.LocationID 
														     --AND req.TransactionTypeCode = UserToApprove.ApprovalTypeID
															 AND al.LocationID=UserToApprove.LocationID 
															 AND al.TransactionID = UserToApprove.TransactionID 
															 AND IsComplete=0 
															 AND UserToApprove.SeqID = al.SeqID 
															  INNER JOIN dbo.ProjectDetails C ON C.ID=req.ProjectID
														INNER JOIN dbo.ApprovalTypes AT ON AT.Id = al.ApprovalLevelID
							--INNER JOIN dbo.UserMasters up ON up.Id = req.UserProfileID


				WHERE al.SeqID  in (SELECT MIN(seqID) 
						FROM dbo.ApprovalLogs
						WHERE IsComplete = 0  AND TransactionID = @TransactionID
						AND al.PropertyID = CASE WHEN @PropertyID = -999 THEN al.PropertyID ELSE @PropertyID END
						AND dbo.ApprovalLogs.TransactionID = al.TransactionID 
						AND dbo.ApprovalLogs.TransactionHeaderID=al.TransactionHeaderID 
						)  
	
		SELECT TT.*,um.UserName as FirstName,ll.name as Location FROM #TempRequsetApproval4 as TT 
		inner join locations as ll on TT.LocationID=ll.id 
		inner join #TempUserTable as um on um.Id=UserProfileID
		
	END
	ELSE
    BEGIN
	
	IF @Type = 'A'
	BEGIN
	    SELECT DISTINCT al.ApprovalLogID,
				al.SeqID,
				al.TransactionID,
				al.ApprovalLevelID,
				al.TransactionHeaderID,
				al.PropertyID,
				al.LocationID,
				al.ApprovalUserID,
				al.ApprovalDate,
				al.IsComplete,
				al.DocStatus,
				UserToApprove.UserProfileID,
				UserToApprove.TransationTypeName,
				UserToApprove.Location,
				UserToApprove.Code,
				UserToApprove.ApprovalTypeID,
				req.Id AS 'PIID',
				req.RequestType,
				req.DocumentNo,
				req.RequestDate AS 'HeadersCreatedDate',
				req.DocumentStatus,
				1 AS 'JobNo',
				req.IsApproved,
				req.Remarks,
				req.DepartmentID AS 'DepartmentID',
				1 AS 'TransferLocation',
				CURRENT_TIMESTAMP AS 'TimeStamp',
				1 AS 'TransactionTypeID', --txnTypeId
				userName,
				password,
				userName AS 'firstname',
				lastName,
				up.createdUserID,
				al.LastModUserID,
				req.RequestDate AS 'CreatedDate',
				req.RequestDate AS 'LastModDate',
				up.isActive
		, req.UserProfileID AS 'ReqUser'
		, up.firstName+' '+up.lastName AS 'ReqUserName'
		, (SELECT SUM(ISNULL(UnitPrice,0) * RequestedQuantity) AS SumOf FROM dbo.RequestDetails WHERE RequestHeaderID = al.TransactionHeaderID ) AS 'ValueOfRequest' 
	    ,AT.ApprovalTypename
		,[dbo].[GET_LastApprovedUser](@TransactionID,al.TransactionHeaderID) AS LastApprovedUser
		,C.Name 'CompanyName'
		INTO #TempRequsetApproval2
	FROM dbo.ApprovalLogs al INNER JOIN ( SELECT  ta.PropertyID
											   , ta.LocationID
											   , ta.TransactionID 
											   , ua.UserProfileID
											   , ta.SeqID,tt.Name AS 'TransationTypeName'
											   , ld.Name 'Location'
											   , tt.Code AS 'Code' 
											   , ta.ApprovalTypeID 
										  FROM dbo.UserWiseApproveLevels ua INNER JOIN dbo.TransactionWiseApprovalTypes ta ON  ua.approvelevelID =ta.ApprovalTypeID 
																													 AND ua.locationID=ta.locationID 
																													 AND ua.propertyID=ta.PropertyID
																													 ----------Added-----------------
																													 AND ua.TransactionTypeID = ta.TransactionID
																													 ----------Added-----------------
																	   INNER JOIN TransactionTypes tt ON tt.Id = ta.TransactionID
																	   INNER JOIN dbo.Locations ld ON ld.Id = ta.LocationID
										  WHERE ua.userprofileID = @UserProfileId 
										  AND ua.PropertyID = CASE WHEN @PropertyID = -999 THEN ua.PropertyId ELSE @PropertyID END 
										--AND ua.LocationID=@LocationID
										) UserToApprove ON al.PropertyID = UserToApprove.PropertyID
							INNER JOIN dbo.RequestHeaders req ON  req.Id = al.TransactionHeaderID 
															 AND UserToApprove.PropertyID = UserToApprove.PropertyID  
															 and req.DocumentStatus <> 'X'
															AND req.LocationID  = UserToApprove.LocationID 
-- remove chandimal no need									--AND req.TransactionTypeCode = UserToApprove.ApprovalTypeID
															 AND al.LocationID=UserToApprove.LocationID 
															 AND al.TransactionID = UserToApprove.TransactionID 
															 AND IsComplete=0 
															 AND UserToApprove.SeqID = al.SeqID 
															 AND req.DepartmentID = CASE WHEN @Departmentid = -999 THEN req.DepartmentID ELSE @Departmentid END
															 AND req.Flag=0
							INNER JOIN #TempUserTable up ON up.Id = req.UserProfileID
							INNER JOIN dbo.ApprovalTypes AT ON AT.Id = al.ApprovalLevelID
							INNER JOIN Companies C ON C.CompanyID = al.propertyId

				WHERE al.SeqID  in (SELECT MIN(seqID) 
						FROM dbo.ApprovalLogs
						WHERE IsComplete = 0  AND TransactionID = @TransactionID
						AND al.PropertyID = CASE WHEN @PropertyID = -999 THEN al.PropertyID ELSE @PropertyID END
						--AND LocationID =@LocationID 
						AND dbo.ApprovalLogs.TransactionID = al.TransactionID 
						AND dbo.ApprovalLogs.TransactionHeaderID=al.TransactionHeaderID 
						)  
		 
			IF(@transactionid = 11 OR @TransactionID=1)
				BEGIN
					SELECT * FROM #TempRequsetApproval2 T
					INNER JOIN userwisedepartments ud ON ud.deptid = T.departmentid and ud.userid = @UserProfileId AND T.ApprovalUserID = @UserProfileId ORDER BY HeadersCreatedDate DESC
				END
				ELSE 
					SELECT * FROM #TempRequsetApproval2 WHERE ApprovalUserID = @UserProfileId ORDER BY HeadersCreatedDate DESC

	END	

	IF @Type = 'C'
	BEGIN

		SELECT  RH.Id TransactionHeaderID,RH.TransactionTypeCode,
		        U.UserName firstName, 
				RH.DocumentNo DocumentNo, 
				CASE WHEN RH.DocumentStatus = 'P' THEN 'PENDING' ELSE 'APPROVED' END  DocumentStatus , 
				RH.RequestDate CreatedDate,
				L.Name  Location,
				(SELECT SUM(ISNULL(UnitPrice *   RequestedQuantity ,0)  ) AS SumOf FROM dbo.RequestDetails WHERE RequestHeaderID = RH.ID ) AS 'ValueOfRequest' ,
				C.Name 'CompanyName',
				ISNULL([dbo].[GET_LastApprovedUser](RH.TransactionTypeCode,RH.ID),'') AS LastApprovedUser,
				ISNULL([dbo].[GET_NetPendingApproval](RH.TransactionTypeCode,RH.ID),'') AS ApprovalTypename
				FROM dbo.RequestHeaders RH
				INNER JOIN #TempUserTable U ON u.Id = RH.UserProfileID
				INNER JOIN dbo.Locations L ON L.Id = RH.LocationID
				INNER JOIN Companies C On C.CompanyID = RH.PropertyID
				WHERE RH.TransactionTypeCode = @TransactionID AND DocumentStatus <> 'C' AND DocumentStatus <> 'X' 
				AND RH.DepartmentID = CASE WHEN @Departmentid = -999 THEN RH.DepartmentID ELSE @Departmentid END
				AND RH.PropertyID = CASE WHEN @PropertyID = -999 THEN RH.PropertyID ELSE @PropertyID END
				AND RH.Id NOT IN (SELECT RequestHeaderId from PoWisePRs) 
	END 

	IF @Type = 'CO'
	BEGIN
	print 11
		SELECT  RH.Id TransactionHeaderID,RH.TransactionTypeCode,
		        U.UserName firstName, 
				RH.DocumentNo DocumentNo, 
				CASE WHEN RH.DocumentStatus = 'P' THEN 'PENDING' ELSE 'APPROVED' END  DocumentStatus , 
				RH.RequestDate CreatedDate,
				L.Name  Location,
				(SELECT SUM(ISNULL(UnitPrice *   RequestedQuantity ,0)  ) AS SumOf FROM dbo.RequestDetails WHERE RequestHeaderID = RH.ID ) AS 'ValueOfRequest' ,
				C.Name 'CompanyName',
				ISNULL([dbo].[GET_LastApprovedUser](RH.TransactionTypeCode,RH.ID),'') AS LastApprovedUser,
				ISNULL([dbo].[GET_NetPendingApproval](RH.TransactionTypeCode,RH.ID),'') AS ApprovalTypename
				FROM dbo.RequestHeaders RH
				INNER JOIN #TempUserTable U ON u.Id = RH.UserProfileID
				INNER JOIN dbo.Locations L ON L.Id = RH.LocationID
				INNER JOIN Companies C On C.CompanyID = RH.PropertyID
				WHERE RH.TransactionTypeCode = @NewTransactionID AND DocumentStatus <> 'C' AND DocumentStatus <> 'X' 
				AND RH.DepartmentID = CASE WHEN @Departmentid = -999 THEN RH.DepartmentID ELSE @Departmentid END
				AND RH.PropertyID = CASE WHEN @PropertyID = -999 THEN RH.PropertyID ELSE @PropertyID END
				AND RH.Id NOT IN (SELECT RequestHeaderId from PoWisePRs) 
				AND RH.IsApproved=1
	END 

	IF @Type = 'T'
	BEGIN
	print 888
		SELECT  RH.Id TransactionHeaderID,
		        U.UserName firstName, 
				RH.DocumentNo DocumentNo, 
				CASE WHEN RH.DocumentStatus = 'P' THEN 'PENDING' ELSE 'APPROVED' END  DocumentStatus , 
				RH.RequestDate CreatedDate,
				L.Name  Location,
				(SELECT SUM(ISNULL(UnitPrice *   RequestedQuantity ,0)  ) AS SumOf FROM dbo.RequestDetails WHERE RequestHeaderID = RH.ID ) AS 'ValueOfRequest' 
				--[dbo].[GET_LastApprovedUser](@TransactionID,TransactionHeaderID) AS LastApprovedUser
				FROM dbo.RequestHeaders RH
				INNER JOIN #TempUserTable U ON u.Id = RH.UserProfileID
				INNER JOIN dbo.Locations L ON L.Id = RH.TransferLocation
				WHERE RH.TransactionTypeCode = @TransactionID AND DocumentStatus <> 'C' AND DocumentStatus <> 'X' 
				AND RH.TransferLocation = CASE WHEN @LocationID = -999 THEN RH.LocationID  ELSE @LocationID END
	END 


	END
---------------------------------------------------------------------------------------------------
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
--------------------------------------------------------------------------------------

    
END

GO

