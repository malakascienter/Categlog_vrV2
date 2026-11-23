CREATE PROCEDURE [dbo].[SP_Update_Common_Reject_For_Order]


	@ApprovedDate DATE,
	@RequestHeaderID INT,
	@TransactionID INT,
	@UserProfileID INT,
	@ApprovalLevelID INT
AS
BEGIN
	SET NOCOUNT ON;

	--16 is for MRN

	--IF @TransactionID=16

	--BEGIN

	--DECLARE @IRID INT
	 
	--SELECT @IRID=IssueID FROM dbo.MRNRegistries WHERE RequestionID=@RequestHeaderID

 --   UPDATE dbo.ApprovalLogs
			
	--	SET DocStatus = 'X',
	--		ApprovalDate = @ApprovedDate,
	--		IsComplete=1,
	--		ApprovalUserID = @UserProfileID
	--WHERE  TransactionID = 1
	--AND TransactionHeaderID=@RequestHeaderID 
	----AND ApprovalLevelID = @ApprovalLevelID
	
	
	
	--UPDATE dbo.RequestHeaders
	--		SET DocumentStatus = 'X',
	--			IsApproved = 0
	--WHERE Id = @RequestHeaderID

	-- UPDATE dbo.ApprovalLogs
			
	--	SET DocStatus = 'X',
	--		ApprovalDate = @ApprovedDate,
	--		IsComplete=1,
	--		ApprovalUserID = @UserProfileID
	--WHERE  TransactionID = 11
	--AND TransactionHeaderID=@IRID 
	----AND ApprovalLevelID = @ApprovalLevelID
	
	
	
	--UPDATE dbo.RequestHeaders
	--		SET DocumentStatus = 'X',
	--			IsApproved = 0
	--WHERE Id = @IRID

	--Create table #ItemList2 (  StockItemID BIGINT
	--				, ApprovedQuantity MONEY
	--				, RequestDetailID BIGINT,RequestedQTY MONEY )

	--INSERT INTO #ItemList2
	--SELECT StockItemID 
	--	,ApprovedQuantity 
	--	,Id,RequestedQuantity  
	--FROM dbo.RequestDetails  WHERE RequestHeaderID=@RequestHeaderID 


	--DECLARE 
	--@StockItemID INT,
	--@RequestedQuantity INT,
	--@RequestDetailID INT,
	--@ProjectID INT,
	--@BoqID INT,
	--@DepartmentID INT
	
	--SELECT @ProjectID=ProjectID,@BoqID=BoqID FROM dbo.MRNRegistries WHERE RequestionID=@RequestHeaderID
	--SELECT @DepartmentID=DepartmentID FROM dbo.RequestHeaders WHERE Id=@RequestHeaderID   
	  
	--WHILE( (SELECT COUNT(*) FROM #ItemList2) > 0)
 --   BEGIN 
	--SELECT TOP (1) @StockItemID = StockItemID 
	--			 ,  @RequestedQuantity = RequestedQTY 
	--			 , @RequestDetailID  = RequestDetailID  
	--FROM #ItemList2
	--ORDER BY StockItemId

	--print @StockItemId
	--print @RequestDetailID

	--UPDATE dbo.MRNItemRegistries SET BalanceQuantity=BalanceQuantity+@RequestedQuantity WHERE ItemId=@StockItemID AND BOQId=@BoqID AND ProjectID=@ProjectID AND DepId=@DepartmentID
	
	 
	--DELETE FROM #ItemList2
	--WHERE StockItemId = @StockItemId

 --   END 

	--END 

	---if not MRN
	--ELSE
	IF @TransactionID=40
    BEGIN
	UPDATE dbo.ApprovalLogs
			
		SET DocStatus = 'X',
			ApprovalDate = @ApprovedDate,
			IsComplete=1,
			ApprovalUserID = @UserProfileID
	WHERE  TransactionID = @TransactionID
	AND TransactionHeaderID=@RequestHeaderID 
	AND ApprovalLevelID = @ApprovalLevelID
	
	
	
	UPDATE dbo.OrderHeaders
			SET DocumentStatus = 'X',
				IsApproved = 0
	WHERE Id = @RequestHeaderID
	END

	ELSE IF @TransactionID=49
		BEGIN
			UPDATE dbo.ApprovalLogs
			
			SET DocStatus = 'X',
				ApprovalDate = @ApprovedDate,
				IsComplete=1,
				ApprovalUserID = @UserProfileID
			WHERE  TransactionID = @TransactionID
			AND TransactionHeaderID=@RequestHeaderID 
			AND ApprovalLevelID = @ApprovalLevelID


			UPDATE dbo.CreditApprovals
			SET DocumentStatus = 'X',
				IsApproved = 0
	WHERE Id = @RequestHeaderID


		END
    
    -- Insert statements for procedure here
	

END

--SELECT * FROM OrderHeaders

GO

