-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-09-29
-- Description:	Loading Tour Guide Companies wise approvals

-- [dbo].[SP_SelectPeningTourGuideApprovalForUser] 4168,1,82

-- =============================================
create PROCEDURE [dbo].[SP_SelectPeningTourGuideApprovalForUser] 
@UserProfileId	INT = 0,
@PropertyID		INT = 0,
@TransactionTypeID INT = 0
AS
BEGIN
	SET NOCOUNT ON;



    -------------------------------------------
	SELECT ta.PropertyID,ta.LocationID, ta.TransactionID , ua.UserProfileID, ta.SeqID,tt.Name AS 'TransationTypeName','All' 'Location',tt.Code AS 'Code' ,ta.ApprovalTypeID 
			INTO #TempTable 
			FROM dbo.UserWiseApproveLevels ua
			INNER JOIN dbo.TransactionWiseApprovalTypes ta 
			ON ua.approvelevelID =ta.ApprovalTypeID AND
				ua.locationID=ta.locationID AND 
				ua.propertyID=ta.PropertyID
				----------Added-----------------
				AND ua.TransactionTypeID = ta.TransactionID
				----------Added-----------------
			INNER JOIN dbo.TransactionTypes tt ON tt.Id = ta.TransactionID
			WHERE ua.userprofileID= @UserProfileId  AND ua.PropertyID = CASE WHEN @PropertyID = -999 THEN ua.PropertyId ELSE @PropertyID END 
			AND tt.Id =@TransactionTypeID 
	-------------------------------------------------------

	IF(@TransactionTypeID = 81)
	BEGIN

	
		SELECT distinct req.Id,					
						UserToApprove.ApprovalTypeID,
						req.CreatedUserId AS 'ReqUserProfId',
						up.UserName AS 'ReqUserProf',
						0 'POValue',
						al.TransactionID
		FROM dbo.ApprovalLogs al 
		INNER JOIN
		#TempTable
		
			UserToApprove ON al.PropertyID=UserToApprove.PropertyID AND AL.TransactionID = UserToApprove.TransactionID
			INNER JOIN dbo.TourGuideCompanies req ON  req.Id = al.TransactionHeaderID AND UserToApprove.PropertyID = al.PropertyID AND AL.TransactionID = @TransactionTypeID
				AND al.LocationID=UserToApprove.LocationID 
				AND al.TransactionID = UserToApprove.TransactionID 
				AND IsComplete=0 
				AND UserToApprove.SeqID = al.SeqID 
			INNER JOIN [dbo].[CentralUsers] up ON up.Id = req.CreatedUserId
			--INNER JOIN 

	WHERE al.SeqID  in (
		SELECT MIN(seqID) 
		FROM dbo.ApprovalLogs 
		WHERE IsComplete = 0 
		AND PropertyID = CASE WHEN @PropertyID = -999 THEN PropertyID ELSE @PropertyID END
		--AND LocationID =@LocationID 
		AND dbo.ApprovalLogs.TransactionID =@TransactionTypeID
		AND TransactionHeaderID=al.TransactionHeaderID 
		
	) 
	END
	IF(@TransactionTypeID = 82)
	BEGIN

	
		SELECT distinct req.Id,					
						UserToApprove.ApprovalTypeID,
						req.CreatedUserId AS 'ReqUserProfId',
						up.UserName AS 'ReqUserProf',
						0 'POValue',
						al.TransactionID
		FROM dbo.ApprovalLogs al 
		INNER JOIN
		#TempTable
		
			UserToApprove ON al.PropertyID=UserToApprove.PropertyID AND AL.TransactionID = UserToApprove.TransactionID
			INNER JOIN dbo.TourGuideMaster req ON  req.Id = al.TransactionHeaderID AND UserToApprove.PropertyID = al.PropertyID AND AL.TransactionID = @TransactionTypeID
				AND al.LocationID=UserToApprove.LocationID 
				AND al.TransactionID = UserToApprove.TransactionID 
				AND IsComplete=0 
				AND UserToApprove.SeqID = al.SeqID 
			INNER JOIN [dbo].[CentralUsers] up ON up.Id = req.CreatedUserId
			--INNER JOIN 

	WHERE al.SeqID  in (
		SELECT MIN(seqID) 
		FROM dbo.ApprovalLogs 
		WHERE IsComplete = 0 
		AND PropertyID = CASE WHEN @PropertyID = -999 THEN PropertyID ELSE @PropertyID END
		--AND LocationID =@LocationID 
		AND dbo.ApprovalLogs.TransactionID =@TransactionTypeID
		AND TransactionHeaderID=al.TransactionHeaderID 
		
	) 
	END
END

GO

