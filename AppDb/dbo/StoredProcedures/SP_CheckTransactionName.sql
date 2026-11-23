-- =============================================
-- Author			: Isuru Pramodya
-- Create date		: 02 October 2023
-- Modified By		: Nivesh
-- Modified Date	: 2025-11-18
-- Description:	Check TransactionWise Approval User 

-- [dbo].[SP_CheckTransactionName] 10,1,4168,1,1

-- =============================================
CREATE PROCEDURE [dbo].[SP_CheckTransactionName]
	@TrasactionTypeID INT,
	@ApprovalTypeID INT,
	@UserID INT = -999,
	@PropertyId INT = -999,
	@LocationID INT
AS
BEGIN
SET NOCOUNT ON;

	CREATE TABLE #temp1(
		TransID INT,
		LocationId INT,
		ApprovedUserId INT,
		IsComplete BIT,
		ApprovalLevelID INT,
		CreatedDate DATETIME,
		CreatedUserId INT,
		UserProfileId INT,
		[status] CHAR(1)
	)

	INSERT INTO #temp1 (
		TransID,
		LocationId,
		ApprovedUserId,
		IsComplete,
		ApprovalLevelID,
		CreatedDate,
		CreatedUserId,
		UserProfileId,
		[status]
	)
	SELECT 
		T.ID as TransID,
		g.LocationId,
		g.ApprovedUserId,
		g.IsComplete,
		g.ApprovalLevelID,
		g.CreatedDate,
		g.CreatedUserId,
		g.UserProfileId,
		g.[status]
	FROM GRNApprovalLog G
	INNER JOIN TransactionTypes T ON G.TransactionType = T.Code
	WHERE T.ID = @TrasactionTypeID
	ORDER BY g.CreatedDate DESC --GRN, StockReconcilation


	SELECT 1 
	FROM approvallogs AP
	INNER JOIN RequestHeaders RH ON AP.TransactionHeaderID = RH.ID 
		AND AP.transactionid = RH.TransactionTypeCode
		WHERE AP.transactionid= @TrasactionTypeID 
		AND AP.approvalUserid = @UserID 
		AND AP.DocStatus='P' 
		AND RH.DocumentStatus ='P'
		AND AP.LocationID = @LocationID -- Request Based
	UNION 
	SELECT 1 
	FROM #temp1 
		WHERE UserProfileId = @UserID 
		AND TransID = @TrasactionTypeID 
		AND LocationId = @LocationID 
		AND [Status] ='P'
	UNION 
	SELECT 1 
	FROM approvallogs AP
	INNER JOIN PoHeaders PH ON AP.TransactionHeaderID = PH.ID 
		AND AP.transactionid = @TrasactionTypeID
		WHERE 
		AP.approvalUserid = @UserID 
		AND AP.DocStatus='P' 
		AND ph.DocumentStatus ='P'
		AND AP.LocationID = @LocationID 
		AND AP.TransactionID=2
		-- PO Based

	DROP TABLE #temp1

END

GO

