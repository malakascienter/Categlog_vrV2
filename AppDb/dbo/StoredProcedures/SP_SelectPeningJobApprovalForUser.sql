--SP_SelectPeningJobApprovalForUser 1,1
CREATE PROCEDURE [dbo].[SP_SelectPeningJobApprovalForUser] --1,1
	@UserProfileId	INT = 0,
	@PropertyID		INT = 0
AS
BEGIN
	SELECT distinct req.ID,					
					UserToApprove.ApprovalTypeID,
					req.CreateUserID AS 'ReqUserProfId',
					up.firstName+' '+ISNULL(up.lastName,'') AS 'ReqUserProf',
					--(SELECT SUM(ISNULL(RequestedQuantity,0) * ISNULL(UnitPrice,0)) FROM dbo.PoDetails WHERE PoHeaderID = req.Id) AS 'POValue',
					al.TransactionID
	FROM dbo.ApprovalLogs al 
    INNER JOIN(

		SELECT ta.PropertyID,ta.LocationID, ta.TransactionID , ua.UserProfileID, ta.SeqID,tt.Name AS 'TransationTypeName',ld.Name 'Location',tt.Code AS 'Code' ,ta.ApprovalTypeID 
		FROM dbo.UserWiseApproveLevels ua
		INNER JOIN dbo.TransactionWiseApprovalTypes ta 
		ON ua.approvelevelID =ta.ApprovalTypeID AND
			ua.locationID=ta.locationID AND 
			ua.propertyID=ta.PropertyID
		INNER JOIN dbo.TransactionTypes tt ON tt.Id = ta.TransactionID
		INNER JOIN dbo.Locations ld ON ld.Id = ta.LocationID
		WHERE ua.userprofileID= @UserProfileId  AND ua.PropertyID =@PropertyID AND tt.Id =57

		) 
		
		UserToApprove ON al.PropertyID=UserToApprove.PropertyID
		INNER JOIN dbo.JobHeaders req ON  req.ID = al.TransactionHeaderID AND UserToApprove.PropertyID = UserToApprove.PropertyID  
		--AND req.LocationID = UserToApprove.LocationID 
			--AND al.LocationID=UserToApprove.LocationID 
			AND al.TransactionID = UserToApprove.TransactionID 
			AND IsComplete=0 
			AND UserToApprove.SeqID = al.SeqID 
		INNER JOIN dbo.UserMasters up ON up.Id = req.CreateUserID
		--INNER JOIN 

WHERE al.SeqID  in (
	SELECT MIN(seqID) 
	FROM dbo.ApprovalLogs 
	WHERE IsComplete = 0 
	AND PropertyID =@PropertyID
	--AND LocationID =@LocationID 
	AND dbo.ApprovalLogs.TransactionID = al.TransactionID 
	AND TransactionHeaderID=al.TransactionHeaderID 
)  	
END

GO

