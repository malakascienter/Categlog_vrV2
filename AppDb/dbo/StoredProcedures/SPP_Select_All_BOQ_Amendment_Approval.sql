CREATE PROCEDURE [dbo].[SPP_Select_All_BOQ_Amendment_Approval] --SPP_Select_All_BOQ_Amendment_Approval 1,5,1,0,61,1

	@UserProfileId	INT = -1,
	@LocationID		INT = 52,
	@PropertyID		INT = -1,
	@Departmentid   INT = -1,
	@TransactionID INT = -1,
	@IsLocationFilter bit = 0
AS
BEGIN
	
	SET NOCOUNT ON;

	--IF OBJECT_ID('tempdb..#TempRequsetApproval') IS NOT NULL DROP TABLE #TempRequsetApproval	
	IF OBJECT_ID(N'#TempRequsetApproval', N'U') IS NOT NULL
	BEGIN
	  DROP TABLE #TempRequsetApproval
	END
   

	 IF @TransactionID=61
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
				req.CreatedDate AS 'HeadersCreatedDate',
				--req.BOQStatus,
				1 AS 'JobNo',
				req.Approve,
				1 AS 'TransferLocation',
				CURRENT_TIMESTAMP AS 'TimeStamp',
				al.LastModUserID
				, req.Remark AS 'Name' 
				--,req.CurrentVersion
		INTO #TempRequsetApproval3
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
																	   INNER JOIN TransactionTypes tt ON tt.Id = ta.TransactionID
																	 --  INNER JOIN dbo.Locations ld ON ld.Id = ta.LocationID 
																	-- WHERE ua.TransactionTypeID =49

										  WHERE 
										  ua.userprofileID = @UserProfileId
										  AND
										   ua.PropertyID = @PropertyID
										AND ua.LocationID=@LocationID
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
														
							--INNER JOIN dbo.UserMasters up ON up.Id = req.UserProfileID

				WHERE al.SeqID  in (SELECT MIN(seqID) 
						FROM dbo.ApprovalLogs
						WHERE IsComplete = 0  AND TransactionID = @TransactionID
						AND al.PropertyID = @PropertyID
						AND dbo.ApprovalLogs.TransactionID = al.TransactionID 
						AND TransactionHeaderID=al.TransactionHeaderID 
						)  
	
	    --SELECT * FROM CreditApprovals
		

		SELECT * FROM #TempRequsetApproval3

	END

    
END

GO

