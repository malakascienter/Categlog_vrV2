
-- [dbo].[SP_UpdateCommonApprovalForRequest] '<Approved><OrderHeaderId>183</OrderHeaderId><UserProfileID>1</UserProfileID><ApprovedDate>2018-04-11T04:52:14.654Z</ApprovedDate><RequestTransactionTypeID>14</RequestTransactionTypeID><ApprovalLevelID>1</ApprovalLevelID><IsReject>false</IsReject><SalesOrderApprovalDetailCollection><SalesOrderApprovalDetail><OrderDetailID>233</OrderDetailID><ProductID>3</ProductID><ApprovedQuantity>100</ApprovedQuantity></SalesOrderApprovalDetail></SalesOrderApprovalDetailCollection></Approved>'
--[dbo].[SP_Update_Common_Approval_For_Sales] '<Approved xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><OrderHeaderId>363</OrderHeaderId><UserProfileID>1</UserProfileID><ApprovedDate>2018-05-02T09:32:19.739Z</ApprovedDate><RequestTransactionTypeID>16</RequestTransactionTypeID><ApprovalLevelID>1</ApprovalLevelID><IsReject>false</IsReject><SalesOrderApprovalDetailCollection><SalesOrderApprovalDetail><OrderDetailID>638</OrderDetailID><ProductID>6</ProductID><ApprovedQuantity>1</ApprovedQuantity></SalesOrderApprovalDetail><SalesOrderApprovalDetail><OrderDetailID>639</OrderDetailID><ProductID>8</ProductID><ApprovedQuantity>1</ApprovedQuantity></SalesOrderApprovalDetail><SalesOrderApprovalDetail><OrderDetailID>640</OrderDetailID><ProductID>10</ProductID><ApprovedQuantity>1</ApprovedQuantity></SalesOrderApprovalDetail><SalesOrderApprovalDetail><OrderDetailID>641</OrderDetailID><ProductID>72</ProductID><ApprovedQuantity>1</ApprovedQuantity></SalesOrderApprovalDetail><SalesOrderApprovalDetail><OrderDetailID>642</OrderDetailID><ProductID>77</ProductID><ApprovedQuantity>1</ApprovedQuantity></SalesOrderApprovalDetail></SalesOrderApprovalDetailCollection></Approved>'
CREATE PROCEDURE [dbo].[SP_Update_Common_Approval_For_Sales] 
	@XMLDetails XML,
	@status INT OUTPUT, 
	@message VARCHAR(20) OUTPUT,
	@executesql NVARCHAR(MAX) OUTPUT
AS

DECLARE @iDocID INT 

declare  @RequestTransactionTypeID INT --for MRN TransactionID 16
       , @ApprovedDate DATETIME
	   , @UserProfileID BIGINT
	   , @RequestHeaderID BIGINT
	   , @ApprovalLevelID INT 
	   , @StockItemID BIGINT
	   , @ApprovedQuantity MONEY
	   , @RequestDetailID BIGINT
	   , @DepartmentID INT
	   

DECLARE @PropertyID INT
	  , @LocationID INT
	  , @TransactionID INT
	  , @TransactionHeaderID BIGINT	 
	  , @statusIN[int]


	
	  
		SET @statusIN = 0;
		SET  @message = '';
	  
DECLARE @reqestedQTY INT,@Balance INT,@BoqID INT,@ProjectID INT   

EXEC sp_xml_preparedocument @iDocID OUTPUT,@XMLDetails

SELECT   @RequestTransactionTypeID = RequestTransactionTypeID
	   , @ApprovedDate = ApprovedDate 
	   , @UserProfileID = UserProfileID 
	   , @RequestHeaderID = RequestHeaderID 
	   , @ApprovalLevelID = ApprovalLevelID 
FROM     OPENXML (@iDocID,'/Approved',2)
WITH (RequestTransactionTypeID INT, ApprovedDate DATETIME, UserProfileID BIGINT, RequestHeaderID BIGINT, ApprovalLevelID INT)


Create table #ItemList (  StockItemID BIGINT
						, ApprovedQuantity MONEY
						, RequestDetailID BIGINT)

INSERT INTO #ItemList
SELECT StockItemID 
     , ApprovedQuantity 
	 , RequestDetailID  
FROM OPENXML (@iDocID,'/Approved/SalesOrderApprovalDetailCollection/SalesOrderApprovalDetail',2)
WITH #ItemList

SELECT * FROM #ItemList

--SELECT * FROM TransactionTypes WHERE Id=16

--SELECT OrderHeaderId From OrderDetails

IF @RequestTransactionTypeID=40

BEGIN 


WHILE( (SELECT COUNT(*) FROM #ItemList) > 0)
BEGIN 
	print 'hi'
	SELECT TOP (1) @StockItemID = StockItemID 
				 , @ApprovedQuantity = ApprovedQuantity 
				 , @RequestDetailID  = RequestDetailID 
	FROM #ItemList
	ORDER BY StockItemID

	print @StockItemID
	print @RequestDetailID
	UPDATE dbo.OrderDetails
	SET ApprovedQuantity = @ApprovedQuantity
	WHERE Id = @RequestDetailID

  
	DELETE FROM #ItemList
	WHERE StockItemID = @StockItemID

END 

UPDATE dbo.ApprovalLogs 
SET IsComplete =  1 
  , DocStatus  = 'C'
  ,ApprovalDate=GETDATE()
WHERE TransactionID = @RequestTransactionTypeID 
AND   TransactionHeaderID = @RequestHeaderID
AND   ApprovalLevelID = @ApprovalLevelID
SELECT  @PropertyID = PropertyID
      , @LocationID = LocationID
	  , @TransactionID = TransactionID
	  , @TransactionHeaderID = TransactionHeaderID
FROM dbo.ApprovalLogs
WHERE TransactionID = @RequestTransactionTypeID and TransactionHeaderID=@RequestHeaderID and ApprovalLevelID = @ApprovalLevelID

EXEC [SP_Chek_Approvels_For_Order] @PropertyID,@LocationID,@TransactionID,@TransactionHeaderID


END  
-- Credit Approvals begins here
ELSE IF @RequestTransactionTypeID=49
BEGIN
	WHILE( (SELECT COUNT(*) FROM #ItemList) > 0)
BEGIN 
	print 'hi'
	SELECT TOP (1) @StockItemID = StockItemID 
				 , @ApprovedQuantity = ApprovedQuantity 
				 , @RequestDetailID  = RequestDetailID 
	FROM #ItemList
	ORDER BY StockItemID

	print @StockItemID
	print @RequestDetailID
	--UPDATE dbo.CreditApprovals
	--SET ApprovedQuantity = @ApprovedQuantity
	--WHERE Id = @RequestDetailID
	--SELECT * FROM CreditApprovals
  
	DELETE FROM #ItemList
	WHERE StockItemID = @StockItemID

END 

UPDATE dbo.ApprovalLogs 
SET IsComplete =  1 
  , DocStatus  = 'C'
  ,ApprovalDate=GETDATE()
WHERE TransactionID = @RequestTransactionTypeID 
AND   TransactionHeaderID = @RequestHeaderID
AND   ApprovalLevelID = @ApprovalLevelID
SELECT  @PropertyID = PropertyID
      , @LocationID = LocationID
	  , @TransactionID = TransactionID
	  , @TransactionHeaderID = TransactionHeaderID
FROM dbo.ApprovalLogs
WHERE TransactionID = @RequestTransactionTypeID and TransactionHeaderID=@RequestHeaderID and ApprovalLevelID = @ApprovalLevelID

EXEC [SP_Chek_Approvels_For_Order] @PropertyID,@LocationID,@TransactionID,@TransactionHeaderID 
END


--END


--for MRN TransactionID 16


--IF @RequestTransactionTypeID=16
--BEGIN

----For Updating IR-----
--DECLARE @IRID INT,@IRDetailID INT 
--SELECT @IRID=IssueID FROM dbo.MRNRegistries WHERE RequestionID=@RequestHeaderID
----SELECT @IRDetailID=Id FROM dbo.OrderDetails WHERE RequestHeaderID=@IRID

--Create table #ItemList2 (  StockItemID BIGINT
--					, ApprovedQuantity MONEY
--					, RequestDetailID BIGINT,RequestedQTY MONEY )

--INSERT INTO #ItemList2
--SELECT OrderDetails.StockItemID 
--    , #ItemList.ApprovedQuantity 
--	,Id,RequestedQuantity  
--FROM dbo.OrderDetails INNER JOIN #ItemList ON #ItemList.StockItemID = OrderDetails.StockItemID WHERE RequestHeaderID=@IRID 

--WHILE( (SELECT COUNT(*) FROM #ItemList2) > 0)
--BEGIN 
--	print 'hi'
--	SELECT TOP (1) @StockItemID = StockItemID 
--				 , @ApprovedQuantity = ApprovedQuantity 
--				 , @IRDetailID  = RequestDetailID  
--	FROM #ItemList2
--	ORDER BY StockItemId



--	print @StockItemId
--	print @RequestDetailID

--	UPDATE dbo.OrderDetails
--	SET ApprovedQuantity = @ApprovedQuantity
--	WHERE Id = @IRDetailID 

--	--SELECT * FROM #ItemList2
--	--SELECT @IRDetailID
--	--SELECT @ApprovedQuantity
	
--	DELETE FROM #ItemList2
--	WHERE StockItemId = @StockItemId


--END 

----for updating PR
--WHILE( (SELECT COUNT(*) FROM #ItemList) > 0)
--BEGIN 
--	print 'hi'
--	SELECT TOP (1) @StockItemID = StockItemID 
--				 , @ApprovedQuantity = ApprovedQuantity 
--				 , @RequestDetailID  = RequestDetailID  
--	FROM #ItemList
--	ORDER BY StockItemId

--	print @StockItemId
--	print @RequestDetailID

--	UPDATE dbo.OrderDetails
--	SET ApprovedQuantity = @ApprovedQuantity
--	WHERE Id = @RequestDetailID
	 
--	SELECT @reqestedQTY=RequestedQuantity FROM dbo.OrderDetails WHERE Id=@RequestDetailID

--	SELECT @Balance=@reqestedQTY-@ApprovedQuantity

--	IF @Balance>0
--	BEGIN

--	SELECT @ProjectID=ProjectID,@BoqID=BoqID FROM dbo.MRNRegistries WHERE RequestionID=@RequestHeaderID
--	SELECT @DepartmentID=DepartmentID FROM dbo.RequestHeaders WHERE Id=@RequestHeaderID
--	UPDATE dbo.MRNItemRegistries SET BalanceQuantity=BalanceQuantity+@Balance WHERE ItemId=@StockItemID AND BOQId=@BoqID AND ProjectID=@ProjectID AND DepId=@DepartmentID
	
--	END	   
--	DELETE FROM #ItemList
--	WHERE StockItemId = @StockItemId

--END 

-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------

----update PR
--UPDATE dbo.ApprovalLogs 
--SET IsComplete =  1 
--  , DocStatus  = 'C',
--  ApprovalDate=GETDATE()
--WHERE TransactionID = 1 
--AND   TransactionHeaderID = @RequestHeaderID 
----AND   ApprovalLevelID = @ApprovalLevelID

--SELECT  @PropertyID = PropertyID
--      , @LocationID = LocationID
--	  , @TransactionID = TransactionID
--	  , @TransactionHeaderID = TransactionHeaderID
--FROM dbo.ApprovalLogs
--WHERE TransactionID = 1 and TransactionHeaderID=@RequestHeaderID AND  ApprovalLevelID = 1

--EXEC [dbo].[SP_ChekApprovelsForRequest] @PropertyID,@LocationID,@TransactionID,@TransactionHeaderID

----update IR

--SELECT @IRID=IssueID FROM dbo.MRNRegistries WHERE RequestionID=@RequestHeaderID
--UPDATE dbo.ApprovalLogs 
--SET IsComplete =  1 
--  , DocStatus  = 'C',
--  ApprovalDate=GETDATE()
--WHERE TransactionID = 11 
--AND   TransactionHeaderID = @IRID 
----AND   ApprovalLevelID = @ApprovalLevelID

--SELECT  @PropertyID = PropertyID
--      , @LocationID = LocationID
--	  , @TransactionID = TransactionID
--	  , @TransactionHeaderID = TransactionHeaderID
--FROM dbo.ApprovalLogs
--WHERE TransactionID = 11 and TransactionHeaderID=@IRID and ApprovalLevelID = 1

--EXEC [dbo].[SP_ChekApprovelsForRequest] @PropertyID,@LocationID,@TransactionID,@TransactionHeaderID




--END 

GO

