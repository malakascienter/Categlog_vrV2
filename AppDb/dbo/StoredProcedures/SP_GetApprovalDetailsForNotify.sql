
-- [dbo].[SP_GetApprovalDetailsForNotify] 4168,1

CREATE PROCEDURE [dbo].[SP_GetApprovalDetailsForNotify] -- SP_GetApprovalDetailsForNotify 2,1
	@UserProfileId	INT,
	--@LocationID		INT,
	@PropertyID		INT
	
AS
BEGIN
		

	
		SELECT DISTINCT	al.TransactionID,
						tt.Name AS ReqName,
						al.ApprovalLevelID,
						al.DocStatus,
						al.TransactionHeaderID,
						rh.LocationID,
						d.Name AS DepartmentName,
						--rh.DepartmentID,
						rh.DocumentNo,
						rh.RequestDate,
						rh.UserProfileID,
						um.UserName,
						um.FullName UserDescription
				
		INTO #TempRequsetApproval1
		FROM dbo.ApprovalLogs al 

		INNER JOIN (SELECT DISTINCT uwal.ApproveLevelID AS ApprovalLevel
					FROM dbo.UserWiseApproveLevels uwal
					WHERE uwal.UserProfileId = @UserProfileId AND uwal.PropertyId = @PropertyID 
					--AND uwal.LocationId= @LocationID
					)UserToApprove 
		ON al.ApprovalLevelID = UserToApprove.ApprovalLevel

		INNER JOIN dbo.RequestHeaders rh
		ON rh.Id = al.TransactionHeaderID
		--INNER JOIN dbo.UserMasters um ON rh.UserProfileID = um.Id
		INNER JOIN dbo.CentralUsers um ON rh.UserProfileID = um.Id
		INNER JOIN dbo.TransactionTypes tt
		ON al.TransactionID = tt.Id
		INNER JOIN dbo.Departments d
		ON rh.DepartmentID = d.Id

		WHERE al.DocStatus = 'P' 
		AND al.LocationID IN ( SELECT uwl.LocationID FROM dbo.UserWise_Location uwl WHERE uwl.CompanyId = @PropertyID AND uwl.UserID = @UserProfileId )
		AND al.SeqID  IN (SELECT MIN(seqID) FROM dbo.ApprovalLogs WHERE IsComplete = 0 AND al.PropertyID = @PropertyID AND TransactionHeaderID=al.TransactionHeaderID )


		SELECT TOP 1 * FROM #TempRequsetApproval1 tra	ORDER BY tra.TransactionHeaderID DESC
		

		

END

GO

