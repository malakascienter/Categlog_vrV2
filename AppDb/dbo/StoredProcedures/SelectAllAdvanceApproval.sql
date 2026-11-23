--[dbo].[SelectAllAdvanceApproval] 1,1,1,0,37,1
CREATE PROCEDURE [dbo].[SelectAllAdvanceApproval] --SelectAllRequisitionApproval 1,1,1,0,37,1
									--SelectAllAdvanceApproval 1,1,1,0,37,1

	@UserProfileId	INT = -1,
	@LocationID		INT = 52,
	@PropertyID		INT = -1,
	@Departmentid   INT = -1,
	@TransactionID INT = -1,
	@IsLocationFilter bit = 0
AS
BEGIN
	
	SET NOCOUNT ON;

	IF(@TransactionID = 36) --out source
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
				req.TransactionType AS RequestType,
				req.TxnNumber AS DocumentNo,
				req.TxnDate AS 'HeadersCreatedDate',
				req.Status,
				1 AS 'JobNo',
				req.IsApproved,
				'' AS Remarks,
				0 AS 'DepartmentID',
				1 AS 'TransferLocation',
				CURRENT_TIMESTAMP AS 'TimeStamp',
				userName,
				password,
				firstName,
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
				up.CreatedDate,
				up.LastModDate,
				isActive
		, req.CreatedUserID AS 'ReqUser'
		, up.firstName+' '+up.lastName AS 'ReqUserName'
		,req.Amount AS 'ValueOfRequest'
			    --(SELECT SUM(ISNULL(Rate,0) * Qty) AS SumOf FROM dbo.OutSourceLabourDetails WHERE HedId = al.TransactionHeaderID) AS 'ValueOfRequest' 
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
																	   INNER JOIN TransactionTypes tt ON tt.Id = ta.TransactionID
																	   INNER JOIN dbo.Locations ld ON ld.Id = ta.LocationID
										  WHERE ua.userprofileID = @UserProfileId 
										  AND ua.PropertyID = @PropertyID 
										  AND ua.LocationID= @LocationID
										) UserToApprove ON al.PropertyID = UserToApprove.PropertyID
							INNER JOIN dbo.UserMasters up ON up.id = UserToApprove.UserProfileId
							INNER JOIN dbo.OutSourceLabourHeaders req ON  req.Id = al.TransactionHeaderID 
															 AND UserToApprove.PropertyID = UserToApprove.PropertyID  
															 AND al.TransactionID = UserToApprove.TransactionID 
															 AND al.IsComplete = 0
															 AND UserToApprove.SeqID = al.SeqID 

	WHERE al.SeqID  in (SELECT MIN(seqID) 
						FROM dbo.ApprovalLogs
						WHERE IsComplete = 0  AND TransactionID = @TransactionID
						AND al.PropertyID = @PropertyID
						AND al.LocationID = @LocationID
						AND dbo.ApprovalLogs.TransactionID = al.TransactionID 
						AND TransactionHeaderID=al.TransactionHeaderID 
						)  
	SELECT * FROM #TempRequsetApproval2
	END
    
    
	ELSE IF(@TransactionID = 34) --bill
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
				req.TransactionType AS RequestType,
				req.BillNumber AS DocumentNo,
				req.BillDate AS 'HeadersCreatedDate',
				req.Status,
				1 AS 'JobNo',
				req.IsApproved,
				'' AS Remarks,
				0 AS 'DepartmentID',
				1 AS 'TransferLocation',
				CURRENT_TIMESTAMP AS 'TimeStamp',
				userName,
				password,
				firstName,
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
				up.CreatedDate,
				up.LastModDate,
				isActive
		, req.CreatedUserID AS 'ReqUser'
		, up.firstName+' '+up.lastName AS 'ReqUserName',
		req.TotalVal AS 'ValueOfRequest'	
		--,(SELECT amount AS SumOf FROM dbo.BillDetails WHERE Id = al.TransactionHeaderID) AS 'ValueOfRequest'	
			    --(SELECT SUM(ISNULL(Rate,0) * Qty) AS SumOf FROM dbo.BillDetails WHERE HedId = al.TransactionHeaderID) AS 'ValueOfRequest'	
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
																	   INNER JOIN TransactionTypes tt ON tt.Id = ta.TransactionID
																	   INNER JOIN dbo.Locations ld ON ld.Id = ta.LocationID
										  WHERE ua.userprofileID = @UserProfileId 
										  AND ua.PropertyID = @PropertyID 
										  AND ua.LocationID= @LocationID
										) UserToApprove ON al.PropertyID = UserToApprove.PropertyID
							INNER JOIN dbo.UserMasters up ON up.id = UserToApprove.UserProfileId
							INNER JOIN dbo.BillHeaders req ON  req.Id = al.TransactionHeaderID 
															 AND UserToApprove.PropertyID = UserToApprove.PropertyID  
															 AND al.TransactionID = UserToApprove.TransactionID 
															 AND al.IsComplete = 0
															 AND UserToApprove.SeqID = al.SeqID 

	WHERE al.SeqID  in (SELECT MIN(seqID) 
						FROM dbo.ApprovalLogs
						WHERE IsComplete = 0  AND TransactionID = 34
						AND al.PropertyID = @PropertyID
						AND al.LocationID = @LocationID
						AND dbo.ApprovalLogs.TransactionID = al.TransactionID 
						AND TransactionHeaderID=al.TransactionHeaderID 
						)  
	
	SELECT * FROM #TempRequsetApproval3
	END

	ELSE IF(@TransactionID = 37)
	BEGIN




	SELECT DISTINCT 
				al.ApprovalLogID,
				al.ApprovalLevelID,
				al.SeqID,
				al.TransactionHeaderID,
				al.PropertyID,
				al.LocationID,
				UserToApprove.TransationTypeName,
				req.ProjectID,
				req.TransactionType AS RequestType,
				req.DocumentNo AS DocumentNo,
				req.txnDate AS 'HeadersCreatedDate',
				req.Status,
				req.AssessedValue,
				req.BilledValue,
          		up.firstName+' '+up.lastName AS 'ReqUserName'
				INTO #TempRequsetApproval4		
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
																	   INNER JOIN TransactionTypes tt ON tt.Id = ta.TransactionID
																	   INNER JOIN dbo.Locations ld ON ld.Id = ta.LocationID
										  WHERE ua.userprofileID = @UserProfileId 
										  AND ua.PropertyID = @PropertyID 
										  AND ua.LocationID= @LocationID
										) UserToApprove ON al.PropertyID = UserToApprove.PropertyID
							INNER JOIN dbo.UserMasters up ON up.id = UserToApprove.UserProfileId
							INNER JOIN dbo.WorkDoneRegistries req ON  req.Id = al.TransactionHeaderID 
															 AND UserToApprove.PropertyID = UserToApprove.PropertyID  
															 AND al.TransactionID = UserToApprove.TransactionID 
															 AND al.IsComplete = 0
															 AND UserToApprove.SeqID = al.SeqID 

	WHERE al.SeqID  in (SELECT MIN(seqID) 
						FROM dbo.ApprovalLogs
						WHERE IsComplete = 0  AND TransactionID = 37
						AND al.PropertyID = @PropertyID
						AND al.LocationID = @LocationID
						AND dbo.ApprovalLogs.TransactionID = al.TransactionID 
						AND TransactionHeaderID=al.TransactionHeaderID 
						)  
	
	SELECT c.Name, *  FROM #TempRequsetApproval4  
	tt Inner JOIN  ProjectDetails P ON tt.ProjectID = p.Id
										inner join Clients C on c.Id = p.ClientID



	--SELECT * FROM ApprovalLogs where TransactionID = 37
	--SELECT * FROM WorkDoneRegistries

	--select * from ProjectDetails P inner join 
	---Clients C on c.Id = p.ClientID





	END

	ELSE IF(@TransactionID = 38)
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
				req.TransactionType AS RequestType,
				req.TxnNumber AS DocumentNo,
				req.TxnDate AS 'HeadersCreatedDate',
				req.Status,
				1 AS 'JobNo',
				req.invoiced AS IsApproved,
				'' AS Remarks,
				0 AS 'DepartmentID',
				1 AS 'TransferLocation',
				CURRENT_TIMESTAMP AS 'TimeStamp',
				userName,
				password,
				firstName,
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
				up.CreatedDate,
				up.LastModDate,
				isActive
		, 0 AS 'ReqUser'
		, up.firstName+' '+up.lastName AS 'ReqUserName',
		req.TotalValue AS  'ValueOfRequest'	
			    --(SELECT SUM(ISNULL(Rate,0) * Qty) AS SumOf FROM dbo.BillDetails WHERE HedId = al.TransactionHeaderID) AS 'ValueOfRequest'										
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
																	   INNER JOIN TransactionTypes tt ON tt.Id = ta.TransactionID
																	   INNER JOIN dbo.Locations ld ON ld.Id = ta.LocationID
										  WHERE ua.userprofileID = @UserProfileId 
										  AND ua.PropertyID = @PropertyID
										  AND ua.LocationID= @LocationID
										) UserToApprove ON al.PropertyID = UserToApprove.PropertyID
							INNER JOIN dbo.UserMasters up ON up.id = UserToApprove.UserProfileId
							INNER JOIN dbo.CustomerSuppliedStockHeaders req ON  req.Id = al.TransactionHeaderID 
															 AND UserToApprove.PropertyID = UserToApprove.PropertyID  
															 AND al.TransactionID = UserToApprove.TransactionID 
															 AND al.IsComplete = 0
															 AND UserToApprove.SeqID = al.SeqID 

	WHERE al.SeqID  in (SELECT MIN(seqID) 
						FROM dbo.ApprovalLogs
						WHERE IsComplete = 0  AND TransactionID = 38
						AND al.PropertyID = @PropertyID
						AND al.LocationID = @LocationID
						AND dbo.ApprovalLogs.TransactionID = al.TransactionID 
						AND TransactionHeaderID=al.TransactionHeaderID 
						)  

	END

	

	END

GO

