-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 22 september 2023
-- Description:	Loading User Wise Pending Approval Count

-- [dbo].[SP_GetAllPendingTransactionsCount] 1,143

-- =============================================
CREATE PROCEDURE [dbo].[SP_GetAllPendingTransactionsCount]
(
	@CompanyId	INT ,
	@userProfileId INT
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @IsCentralLogin BIT,@PendingCount INT

	SELECT @IsCentralLogin = IsCentralLogin FROM Companies WHERE CompanyID =  @CompanyId

	DECLARE @UserTempTable TABLE(
	Id INT,
	FirstName NVARCHAR(300)
	)

	IF(@IsCentralLogin = 1)
	BEGIN
		INSERT INTO @UserTempTable
		SELECT Id,FullName
		FROM [dbo].[CentralUsers]
	END
	ELSE
	BEGIN
		INSERT INTO @UserTempTable
		SELECT Id, FirstName 
		FROM UserMasters
	END


	
	SELECT *
	INTO #TempPendingTable
	FROM (
	SELECT COUNT(DISTINCT PH.ID)  PendingCount,2 TransactionHeaderID
	FROM POHEADERS PH
	WHERE PH.IsApproved=0 AND PH.UserProfileID=@userProfileId 
	AND DocumentStatus <>'X'
	Union all
	select COUNT(DISTINCT ID) PendingCount,TransactionTypeCode TransactionHeaderID
	from requestheaders
	where UserProfileID=@userProfileId 
	and isapproved=0 
	AND DocumentStatus <>'X'
	group by TransactionTypeCode
	Union all
	SELECT COUNT(DISTINCT ApprovalDocNo) PendingCount,TR.ID TransactionHeaderID
	from GRNApprovalLog GR
	INNER JOIN TransactionTypes TR ON GR.TransactionType=Code
	where GR.CreatedUserId=@userProfileId  AND Status='P' 
	group by TR.ID
	) AS A

	SELECT @PendingCount=SUM(PendingCount) FROM #TempPendingTable

	--SELECT  COUNT(TR.Id) TransactionCounts,TR.Name TransactionTypeName,TR.Id TransactionTypeId
	--FROM ApprovalLogs AP
	--INNER JOIN RequestHeaders RH ON AP.TransactionHeaderID = RH.Id
	--INNER JOIN RequestDetails RD ON RD.RequestHeaderID = RH.Id
	--INNER JOIN Locations LO ON LO.Id = RH.LocationID
	--LEFT JOIN Departments DE ON DE.Id = RH.DepartmentID
	--INNER JOIN TransactionTypes TR ON TR.Id = AP.TransactionID
	--WHERE AP.CreatedUserID = @userProfileId 
	--AND AP.IsComplete =0 AND AP.DocStatus='P' AND AP.TransactionID NOT IN (2) 
	--GROUP BY TR.Name,TR.Id


	SELECT COUNT(DISTINCT TR.ID) TransactionCounts,TR.Name TransactionTypeName,TR.Id TransactionTypeId
	FROM RequestHeaders RH 
	INNER JOIN TransactionTypes TR ON TR.Id = RH.TransactionTypeCode
	WHERE RH.UserProfileID=@userProfileId 
	AND RH.ISaPPROVED=0 
	AND RH.DocumentStatus <>'X'
	GROUP BY TR.Name,TR.Id
	UNION ALL
	--SELECT COUNT(TR.Id) TransactionCounts, TR.Name TransactionTypeName,TR.Id TransactionTypeId
	--FROM ApprovalLogs AP
	--INNER JOIN PoHeaders PH ON PH.Id = AP.TransactionHeaderID
	--INNER JOIN PoDetails PD ON PD.PoHeaderID =PH.Id
	--INNER JOIN Locations LO ON LO.Id = PH.LocationID
	--INNER JOIN @UserTempTable US ON US.Id = AP.CreatedUserID
	--INNER JOIN TransactionTypes TR ON TR.Id = AP.TransactionID
	--INNER JOIN Suppliers SU ON SU.ID = PH.SupplierID
	--WHERE AP.CreatedUserID = @userProfileId AND AP.IsComplete =0 AND AP.DocStatus='P' AND AP.TransactionID =2
	--GROUP BY TR.Name,TR.Id

	SELECT COUNT(DISTINCT TR.ID) TransactionCounts, TR.Name TransactionTypeName,TR.Id TransactionTypeId
	FROM PoHeaders PH 
	INNER JOIN TransactionTypes TR ON TR.Id = 2
	WHERE PH.UserProfileID = @userProfileId AND  PH.IsApproved=0 and PH.DocumentStatus='P'  
	AND PH.DocumentStatus <>'X'
	GROUP BY TR.Name,TR.Id
	UNION ALL
	SELECT COUNT(DISTINCT GP.ApprovalDocNo) TransactionCounts, TR.Name TransactionTypeName,TR.Id TransactionTypeId
	FROM GRNApprovalLog GP
	INNER JOIN Locations LO ON LO.Id = GP.LocationId
	INNER JOIN @UserTempTable US ON US.Id = GP.CreatedUserId
	INNER JOIN TransactionTypes TR ON TR.Code = GP.TransactionType
	LEFT JOIN Suppliers SU ON SU.ID = GP.SupplierId
	WHERE GP.CreatedUserId =@userProfileId AND GP.ApprovedUserId IS NULL AND GP.ApprovedDateTime IS NULL AND GP.Status = 'P'
	GROUP BY TR.Name,TR.Id

	UNION ALL
	SELECT @PendingCount TransactionCounts,'--ALL--',-999 TransactionTypeId
	ORDER BY TransactionTypeId 


   
END

GO

