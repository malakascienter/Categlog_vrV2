--EXEC [SP_SelectPeningPOApprovalForUserForTransactionApproval] 4168,1,8120
CREATE PROCEDURE [dbo].[SP_SelectPeningPOApprovalForUserForTransactionApproval](
	@UserProfileId	INT = 0,
	@PropertyID		INT = 0,
	@TransferUser INT = 0)
AS
BEGIN
	DECLARE @IsCentralLogin BIT
	SELECT @IsCentralLogin = IsCentralLogin FROM Companies 
	WHERE CompanyID = CASE WHEN @PropertyID = -999 THEN 1 ELSE @PropertyID END
	declare @RowCount INT = 1, @TotalRows INT , @TempHeaderID int 

	IF(@IsCentralLogin = 1)
	BEGIN
	-------------------------------------------
	SELECT ta.PropertyID,ta.LocationID, ta.TransactionID , ua.UserProfileID, ta.SeqID,tt.Name AS 'TransationTypeName',ld.Name 'Location',tt.Code AS 'Code' ,ta.ApprovalTypeID 
			INTO #TempTable FROM dbo.UserWiseApproveLevels ua
			INNER JOIN dbo.TransactionWiseApprovalTypes ta 
			ON ua.approvelevelID =ta.ApprovalTypeID AND
				ua.locationID=ta.locationID AND 
				ua.propertyID=ta.PropertyID
				----------Added-----------------
				AND ua.TransactionTypeID = ta.TransactionID
				----------Added-----------------
			INNER JOIN dbo.TransactionTypes tt ON tt.Id = ta.TransactionID
			INNER JOIN dbo.Locations ld ON ld.Id = ta.LocationID
			WHERE ua.userprofileID= @UserProfileId  AND ua.PropertyID = CASE WHEN @PropertyID = -999 THEN ua.PropertyId ELSE @PropertyID END 
			AND tt.Id =2 -- added by Nivesh 2024 02 08
	-------------------------------------------------------
		SELECT distinct req.Id,					
						UserToApprove.ApprovalTypeID,
						req.UserProfileID AS 'ReqUserProfId',
						up.UserName AS 'ReqUserProf',
						(SELECT SUM(ISNULL(RequestedQuantity,0) * (ISNULL(UnitPrice,0) - case when DiscountValue > 0 THEN DiscountValue ELSE (UnitPrice *DiscountPercentage /100) END)) FROM dbo.PoDetails WHERE PoHeaderID = req.Id) AS 'POValue',
						al.TransactionID
						into #DataObtained
		FROM dbo.ApprovalLogs al 
		INNER JOIN
		#TempTable
		
			UserToApprove ON al.PropertyID=UserToApprove.PropertyID
			INNER JOIN dbo.PoHeaders req ON  req.Id = al.TransactionHeaderID AND UserToApprove.PropertyID = UserToApprove.PropertyID  AND req.LocationID = UserToApprove.LocationID 
				AND al.LocationID=UserToApprove.LocationID 
				AND al.TransactionID = UserToApprove.TransactionID 
				AND IsComplete=0 
				AND UserToApprove.SeqID = al.SeqID 
			INNER JOIN [dbo].[CentralUsers] up ON up.Id = req.UserProfileID
			--INNER JOIN 

	WHERE al.SeqID  in (
		SELECT MIN(seqID) 
		FROM dbo.ApprovalLogs 
		WHERE IsComplete = 0 
		AND PropertyID = CASE WHEN @PropertyID = -999 THEN PropertyID ELSE @PropertyID END
		--AND LocationID =@LocationID 
		AND dbo.ApprovalLogs.TransactionID =2
		AND TransactionHeaderID=al.TransactionHeaderID 
		and al.CreatedDate > '2023-12-01' 
	) 
	

		SELECT @TotalRows = COUNT(*) FROM #DataObtained;
		--select @TotalRows TotalRows
			WHILE @RowCount <= @TotalRows
				begin
			
				SELECT @TempHeaderID = id
		
				FROM (
				SELECT 
						id,
					ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNum
        FROM #DataObtained
    ) AS SubQuery
    WHERE RowNum = @RowCount;
	--select @TempHeaderID val
				--select @ti ti		
		--select 111, * from ApprovalLogs where ApprovalUserID = @TransferUser and TransactionHeaderID = @TempHeaderID

		if exists (select * from ApprovalLogs where ApprovalUserID = @TransferUser and TransactionHeaderID = @TempHeaderID)
			BEGIN
		
					--select 55555555
					--select @TempHeaderID val23
					delete from #DataObtained where id = @TempHeaderID 

			END
		SET @RowCount = @RowCount + 1;
			END

			select * from #DataObtained
	END
	ELSE
	BEGIN
		SELECT distinct req.Id,					
						UserToApprove.ApprovalTypeID,
						req.UserProfileID AS 'ReqUserProfId',
						up.firstName+' '+ISNULL(up.lastName,'') AS 'ReqUserProf',
						(SELECT SUM(ISNULL(RequestedQuantity,0) * (ISNULL(UnitPrice,0) - case when DiscountValue > 0 THEN DiscountValue ELSE (UnitPrice *DiscountPercentage /100) END)) FROM dbo.PoDetails WHERE PoHeaderID = req.Id) AS 'POValue',
						al.TransactionID
		FROM dbo.ApprovalLogs al 
		INNER JOIN
		--(
	
		--	SELECT ta.PropertyID,ta.LocationID, ta.TransactionID , ua.UserProfileID, ta.SeqID,tt.Name AS 'TransationTypeName',ld.Name 'Location',tt.Code AS 'Code' ,ta.ApprovalTypeID 
		--	FROM dbo.UserWiseApproveLevels ua
		--	INNER JOIN dbo.TransactionWiseApprovalTypes ta 
		--	ON ua.approvelevelID =ta.ApprovalTypeID AND
		--		ua.locationID=ta.locationID AND 
		--		ua.propertyID=ta.PropertyID
		--		----------Added-----------------
		--		AND ua.TransactionTypeID = ta.TransactionID
		--		----------Added-----------------
		--	INNER JOIN dbo.TransactionTypes tt ON tt.Id = ta.TransactionID
		--	INNER JOIN dbo.Locations ld ON ld.Id = ta.LocationID
		--	WHERE ua.userprofileID= @UserProfileId  AND ua.PropertyID = CASE WHEN @PropertyID = -999 THEN ua.PropertyId ELSE @PropertyID END 
		--	AND tt.Id =2

		--	) 
		#TempTable
			UserToApprove ON al.PropertyID=UserToApprove.PropertyID
			INNER JOIN dbo.PoHeaders req ON  req.Id = al.TransactionHeaderID AND UserToApprove.PropertyID = UserToApprove.PropertyID  AND req.LocationID = UserToApprove.LocationID 
				AND al.LocationID=UserToApprove.LocationID 
				AND al.TransactionID = UserToApprove.TransactionID 
				AND IsComplete=0 
				AND UserToApprove.SeqID = al.SeqID 
			INNER JOIN dbo.UserMasters up ON up.Id = req.UserProfileID
			--INNER JOIN 

	WHERE al.SeqID  in (
		SELECT MIN(seqID) 
		FROM dbo.ApprovalLogs 
		WHERE IsComplete = 0 
		AND PropertyID = CASE WHEN @PropertyID = -999 THEN PropertyID ELSE @PropertyID END
		--AND LocationID =@LocationID 
		AND dbo.ApprovalLogs.TransactionID = al.TransactionID 
		AND TransactionHeaderID=al.TransactionHeaderID 
	) 
	END
	 	
END

GO

