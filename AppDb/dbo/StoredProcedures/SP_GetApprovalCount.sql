
-- [dbo].[SP_GetApprovalCount] 9212,1


CREATE PROCEDURE [dbo].[SP_GetApprovalCount] -- SP_GetApprovalCount 5248,1
	@UserProfileId	INT,
	--@LocationID		INT,
	@PropertyID		INT
	
AS
BEGIN
--------------------------------------------------------------------------------------------------------
BEGIN TRY 

IF(@UserProfileId = 0)
BEGIN
	RAISERROR('User ID Invalid, Please Log In Again',16,1)
	ROLLBACK TRANSACTION
END
DECLARE @TotalCount INT,
		@PRCount INT,
		@POCount INT,
		@TransferCount INT,
		@DamageCount INT,
		@IssueCount INT,
		@IssueReturnCount INT,
		@GRNCount INT,
		@SupplierReturnCount INT,
		@StockReconciliationCount INT,
		@PendingCount INT
--isuru 2023-04-06
DECLARE @IsCentralLogn BIT
,@IsDepartmentWisePOApproval BIT = 0

	SELECT @IsCentralLogn = IsCentralLogin ,@IsDepartmentWisePOApproval = ISNULL(IsDepartmentWisePOApproval,0)
	FROM Companies WHERE CompanyID = CASE WHEN @PropertyID = -999 THEN CompanyID  ELSE @PropertyID END

	CREATE TABLE #TempApprovalData(Id INT, UserName NVARCHAR(3000))
	IF(@IsCentralLogn = 1)
	BEGIN
		INSERT INTO #TempApprovalData
		SELECT Id,Username 
		FROM [dbo].[CentralUsers]
	END
	ELSE 
	BEGIN
		INSERT INTO #TempApprovalData
		SELECT Id,Username 
		FROM UserMasters
	END

-- end 2023-04-06
		CREATE TABLE #Temp1
				(
					TotalCount INT,
					PRCount INT ,
					POCount INT,
					TransferCount INT,
					DamageCount INT    ,
					IssueCount INT,
					IssueReturnCount INT,
					GRNCount INT,
					SupplierReturnCount INT,
					PendingCount INT,
					StockReconciliationCount INT
				)
	 
	SELECT *
INTO #TempRequsetApproval1
FROM (
    -- First part: Transactions with IDs 1 and 11
    SELECT DISTINCT
        al.TransactionID,
        al.ApprovalLevelID,
        al.DocStatus,
        al.TransactionHeaderID
    FROM dbo.ApprovalLogs al
    INNER JOIN (
        SELECT DISTINCT
            uwal.ApproveLevelID AS ApprovalLevel,
            uwal.TransactionTypeID
        FROM dbo.UserWiseApproveLevels uwal
        WHERE uwal.UserProfileId = @UserProfileId
          AND uwal.PropertyId = @PropertyID
          -- AND uwal.LocationId = @LocationID
    ) UserToApprove
    ON al.ApprovalLevelID = UserToApprove.ApprovalLevel
       AND al.TransactionID = UserToApprove.TransactionTypeID
    WHERE al.DocStatus = 'P'
      --AND al.TransactionID IN (1, 11)
	  AND ((@IsDepartmentWisePOApproval = 1 AND al.TransactionID IN (1, 2, 11))
	OR (@IsDepartmentWisePOApproval <> 1 AND al.TransactionID IN (1, 11)))
      AND al.LocationID IN (
          SELECT uwl.deptid
          FROM dbo.UserWiseDepartments uwl
          WHERE uwl.CompanyId = @PropertyID
            AND uwl.UserID = @UserProfileId
      )
      AND al.SeqID IN (
          SELECT MIN(seqID)
          FROM dbo.ApprovalLogs
          WHERE IsComplete = 0
            AND PropertyID = @PropertyID
            AND TransactionID = al.TransactionID
            AND TransactionHeaderID = al.TransactionHeaderID
            --AND ApprovalUserID = @UserProfileId
			--AND AL.CREATEDDATE >='2023-12-31'
			--AND al.TransactionID IN (1, 11)
			AND ((@IsDepartmentWisePOApproval = 1 AND al.TransactionID IN (1, 2, 11))
			OR (@IsDepartmentWisePOApproval <> 1 AND al.TransactionID IN (1, 11)))
      )
	  AND al.ApprovalUserID = @UserProfileId
    UNION ALL
    -- Second part: Transactions not with IDs 1 and 11
    SELECT DISTINCT
        al.TransactionID,
        al.ApprovalLevelID,
        al.DocStatus,
        al.TransactionHeaderID
    FROM dbo.ApprovalLogs al
    INNER JOIN (
        SELECT DISTINCT
            uwal.ApproveLevelID AS ApprovalLevel,
            uwal.TransactionTypeID
        FROM dbo.UserWiseApproveLevels uwal
        WHERE uwal.UserProfileId = @UserProfileId
          AND uwal.PropertyId = @PropertyID
          -- AND uwal.LocationId = @LocationID
    ) UserToApprove
    ON al.ApprovalLevelID = UserToApprove.ApprovalLevel
       AND al.TransactionID = UserToApprove.TransactionTypeID
    WHERE al.DocStatus = 'P'
     -- AND al.TransactionID NOT IN (1, 11)
	  AND ((@IsDepartmentWisePOApproval = 1 AND al.TransactionID NOT IN (1, 2, 11))
		OR (@IsDepartmentWisePOApproval <> 1 AND al.TransactionID NOT IN (1, 11)))
      AND al.LocationID IN (
          SELECT uwl.LocationID
          FROM dbo.UserWise_Location uwl
          WHERE uwl.CompanyId = @PropertyID
            AND uwl.UserID = @UserProfileId
      )
      AND al.SeqID IN (
          SELECT MIN(seqID)
          FROM dbo.ApprovalLogs
          WHERE IsComplete = 0
            AND PropertyID = @PropertyID
            AND TransactionID = al.TransactionID
            AND TransactionHeaderID = al.TransactionHeaderID
            --AND ApprovalUserID = @UserProfileId
           -- AND TransactionID NOT IN (1, 11)
		    AND ((@IsDepartmentWisePOApproval = 1 AND al.TransactionID NOT IN (1, 2, 11))
			OR (@IsDepartmentWisePOApproval <> 1 AND al.TransactionID NOT IN (1, 11)))
      )
	  AND al.ApprovalUserID = @UserProfileId
) AS CombinedResults;




	--Added by Isuru 2023-09-21 for loading Userwise pending approvals --
	SELECT *
	INTO #TempPendingTable
	FROM (
	SELECT  COUNT(DISTINCT TransactionHeaderID) PendingCount
	from ApprovalLogs
	where CreatedUserID =@UserProfileId AND IsComplete = 0 AND DocStatus='P'
	Union all
	SELECT  COUNT(DISTINCT ApprovalDocNo) PendingCount
	from GRNApprovalLog
	where CreatedUserId=@UserProfileId AND Status='P' 
	) AS A

	SELECT @PendingCount=SUM(PendingCount) FROM #TempPendingTable
	--End

	
	--------------Added 15/9/2021------------------
		SELECT T.*,P.DocumentStatus AS POStatus,R.DocumentStatus AS ReqStatus INTO #TempOrgData  
		FROM #TempRequsetApproval1 T
		LEFT JOIN PoHeaders P ON T.TransactionHeaderID = P.Id AND T.TransactionID = 2
		LEFT JOIN RequestHeaders R ON R.Id =  T.TransactionHeaderID  AND T.TransactionID <> 2

		--SELECT * FROM #TempOrgData	
		--where TransactionID = 11 AND ReqStatus ='P'
		-------------------------------------------------------
		--SELECT GA.Id AS HeaderId,U.Username,GA.UserProfileId,GA.StockTransactionHeaderID, L.Name AS Location,GA.CreatedDate,GA.ApprovalDocNo,GA.ReferenceNo,AT.ApprovalTypeName,
		--GA.seqid, ROW_NUMBER() OVER (PARTITION BY GA.ApprovalDocNo ORDER BY GA.seqid) AS RowNum,GA.TransactionType,GA.Status,l.Id as LocationID,
		--GA.ApprovallevelId
		-- INTO #TempGrnApprovalTable FROM GRNApprovalLog GA
		--INNER JOIN #TempApprovalData U ON GA.CreatedUserId = U.Id
		--INNER JOIN Locations L ON L.Id = GA.LocationId
		--LEFT JOIN ApprovalTypes AT ON AT.Id = GA.ApprovallevelId
		--WHERE GA.CompanyId = CASE WHEN @PropertyID = -999 THEN GA.CompanyId ELSE @PropertyID END
		--AND GA.TransactionType = 'AA' 
		--AND GA.Status = 'P'
		--ORDER BY GA.Id DESC

		--select @StockReconciliationCount= COUNT(*) from
		--#TempGrnApprovalTable
		--where
		--RowNum =1 
		--AND UserProfileId = @UserProfileID
		--AND TransactionType = 'AA'
		--AND Status = 'P' -- Commented by Nivesh 2024-07-16
		SELECT GA.Id AS HeaderId,U.Username,GA.UserProfileId,GA.StockTransactionHeaderID, L.Name AS Location,GA.CreatedDate,GA.ApprovalDocNo,GA.ReferenceNo,AT.ApprovalTypeName,
		GA.seqid, DENSE_RANK() OVER (PARTITION BY GA.ApprovalDocNo ORDER BY GA.seqid) AS RowNum,GA.TransactionType,GA.Status,l.Id as LocationID,
		GA.ApprovallevelId
		 INTO #TempGrnApprovalTable FROM GRNApprovalLog GA
		INNER JOIN #TempApprovalData U ON GA.CreatedUserId = U.Id
		INNER JOIN Locations L ON L.Id = GA.LocationId
		LEFT JOIN ApprovalTypes AT ON AT.Id = GA.ApprovallevelId
		WHERE GA.CompanyId = CASE WHEN @PropertyID = -999 THEN GA.CompanyId ELSE @PropertyID END
		AND GA.TransactionType = 'AA' 
		AND GA.Status = 'P'
		ORDER BY GA.Id DESC

		select @StockReconciliationCount= COUNT(*) from
		#TempGrnApprovalTable
		where
		RowNum =1 
		AND UserProfileId = @UserProfileID
		AND TransactionType = 'AA'
		AND Status = 'P' --Modified by Nivesh 2024-07-16

		--SELECT * FROM #TempOrgData tra where   tra.TransactionID = 11 AND ReqStatus NOT IN ( 'X','C')

		--SELECT * INTO #TempIssueCount
		--EXEC SelectAllRequisitionApproval @UserProfileId,0,@PropertyID,-999,11,1
		--SELECT * FROM #TempIssueCount

		-------------------------------------------------------
		SELECT @TotalCount = COUNT(*) FROM #TempOrgData tra WHERE POStatus <> 'X' OR ReqStatus <> 'X'
		SELECT @PRCount = COUNT(*) FROM #TempOrgData tra WHERE tra.TransactionID = 1 AND ReqStatus <> 'X'
		SELECT @POCount = COUNT(*) FROM #TempOrgData tra WHERE tra.TransactionID = 2 AND POStatus <> 'X'
		SELECT @TransferCount = COUNT(*) FROM #TempOrgData tra WHERE tra.TransactionID = 8  AND ReqStatus <> 'X'
		SELECT @DamageCount = COUNT(*) FROM #TempOrgData tra WHERE tra.TransactionID = 14 AND ReqStatus <> 'X'
		SELECT @IssueCount = COUNT(*) FROM #TempOrgData tra WHERE tra.TransactionID = 11 AND ReqStatus NOT IN ( 'X','C')
		SELECT @IssueReturnCount = COUNT(*) FROM #TempOrgData tra WHERE tra.TransactionID = 7 AND ReqStatus <> 'X'
		--SELECT @GRNCount = COUNT(*) FROM GRNApprovalLog GA INNER JOIN #TempApprovalData U ON GA.CreatedUserId = U.Id WHERE Status = 'P' AND TransactionType = 'GR' AND CompanyId = @PropertyID //Commented by Nivesh 2024-07-16
		--SELECT @SupplierReturnCount = COUNT(*) FROM GRNApprovalLog WHERE Status = 'P' AND TransactionType = 'SR' AND CompanyId = @PropertyID AND UserProfileId = @UserProfileId
		------------------------------------------------Get GRN count added by Nivesh 2024-07-16----------------------------
		
		SELECT GA.UserProfileId,  DENSE_RANK() OVER (PARTITION BY GA.ApprovalDocNo ORDER BY GA.seqid) AS RowNum,
		GA.TransactionType,GA.Status
		INTO #TempGrnApprovalTable2
		FROM GRNApprovalLog GA
		INNER JOIN #TempApprovalData U ON GA.CreatedUserId = U.Id
		INNER JOIN Locations L ON L.Id = GA.LocationId
		INNER JOIN Suppliers S ON S.Id = GA.SupplierId
		LEFT JOIN PoHeaders PO ON PO.Id = GA.ReferenceId
		LEFT JOIN ApprovalTypes AT ON AT.Id = GA.ApprovallevelId
		WHERE GA.CompanyId = CASE WHEN @PropertyID = -999 THEN GA.CompanyId ELSE @PropertyID END
		AND TransactionType = 'GR' AND Status = 'P'
		ORDER BY GA.Id DESC

		SELECT GA.UserProfileId,  DENSE_RANK() OVER (PARTITION BY GA.ApprovalDocNo ORDER BY GA.seqid) AS RowNum,
		GA.TransactionType,GA.Status
		INTO #TempSRNApprovalTable2
		FROM GRNApprovalLog GA
		INNER JOIN #TempApprovalData U ON GA.CreatedUserId = U.Id
		INNER JOIN Locations L ON L.Id = GA.LocationId
		INNER JOIN Suppliers S ON S.Id = GA.SupplierId
		LEFT JOIN PoHeaders PO ON PO.Id = GA.ReferenceId
		LEFT JOIN ApprovalTypes AT ON AT.Id = GA.ApprovallevelId
		WHERE GA.CompanyId = CASE WHEN @PropertyID = -999 THEN GA.CompanyId ELSE @PropertyID END
		AND TransactionType = 'SR' AND Status = 'P'
		ORDER BY GA.Id DESC

		select @GRNCount = count(*) from
		#TempGrnApprovalTable2
		where
		RowNum =1 
		AND UserProfileId = @UserProfileId 
		AND TransactionType = 'GR'
		AND Status = 'P'

		select @SupplierReturnCount = count(*) from
		#TempSRNApprovalTable2
		where
		RowNum =1 
		AND UserProfileId = @UserProfileId 
		AND TransactionType = 'SR'
		AND Status = 'P'
		-----------------------------------------------------------------------------------------------------------------------
	--------------Added 15/9/2021------------------

		--SELECT @TotalCount = COUNT(*) FROM #TempRequsetApproval1 tra
		--SELECT @PRCount = COUNT(*) FROM #TempRequsetApproval1 tra WHERE tra.TransactionID = 1
		--SELECT @POCount = COUNT(*) FROM #TempRequsetApproval1 tra WHERE tra.TransactionID = 2
		--SELECT @TransferCount = COUNT(*) FROM #TempRequsetApproval1 tra WHERE tra.TransactionID = 8
		--SELECT @DamageCount = COUNT(*) FROM #TempRequsetApproval1 tra WHERE tra.TransactionID = 14
		--SELECT @IssueCount = COUNT(*) FROM #TempRequsetApproval1 tra WHERE tra.TransactionID = 11
		--SELECT @IssueReturnCount = COUNT(*) FROM #TempRequsetApproval1 tra WHERE tra.TransactionID = 7
		--SELECT @GRNCount = COUNT(*) FROM GRNApprovalLog WHERE Status = 'P' AND TransactionType = 'GR' AND CompanyId = @PropertyID
		--SELECT @SupplierReturnCount = COUNT(*) FROM GRNApprovalLog WHERE Status = 'P' AND TransactionType = 'SR' AND CompanyId = @PropertyID

		INSERT INTO #Temp1
					( TotalCount ,
						PRCount ,
						POCount ,
						TransferCount ,
						DamageCount ,
						IssueCount,
						IssueReturnCount,
						GRNCount,
						SupplierReturnCount,
						PendingCount,
						StockReconciliationCount
					) VALUES
						(	@TotalCount,
							@PRCount,
							@POCount,
							@TransferCount,
							@DamageCount,
							@IssueCount,
							@IssueReturnCount,
							@GRNCount,
							@SupplierReturnCount,
							@PendingCount,
							@StockReconciliationCount
						)

	SELECT * FROM #Temp1 t
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
--------------------------------------------------------------------------------------------------------


END

GO

