
--[dbo].[SP_UpdateCommonApprovalForRequest] '<Approved xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><RequestHeaderID>1</RequestHeaderID><UserProfileID>1</UserProfileID><ApprovedDate>2020-10-14T10:04:50.668Z</ApprovedDate><RequestTransactionTypeID>1</RequestTransactionTypeID><ApprovalLevelID>5</ApprovalLevelID><IsReject>false</IsReject><RequestionApprovalDetailCollection><RequestionApprovalDetail><RequestDetailID>1</RequestDetailID><StockItemID>4</StockItemID><ApprovedQuantity>3</ApprovedQuantity></RequestionApprovalDetail></RequestionApprovalDetailCollection></Approved>'
--go
CREATE PROCEDURE [dbo].[SP_UpdateCommonApprovalForRequest] 
	@XMLDetails XML
AS
BEGIN
BEGIN TRY
BEGIN TRANSACTION

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
	   ,@IsMailNotification BIT
	   ,@TxnType CHAR(2)


DECLARE @PropertyID INT
	  , @LocationID INT
	  , @TransactionID INT
	  , @TransactionHeaderID BIGINT	 
	  
DECLARE @reqestedQTY INT,@Balance INT,@BoqID INT,@ProjectID INT   

EXEC sp_xml_preparedocument @iDocID OUTPUT,@XMLDetails

SELECT   @RequestTransactionTypeID = RequestTransactionTypeID
	   , @ApprovedDate = ApprovedDate 
	   , @UserProfileID = UserProfileID 
	   , @RequestHeaderID = RequestHeaderID 
	   , @ApprovalLevelID = ApprovalLevelID 
FROM     OPENXML (@iDocID,'/Approved',2)
WITH (RequestTransactionTypeID INT, ApprovedDate DATETIME, UserProfileID BIGINT, RequestHeaderID BIGINT, ApprovalLevelID INT)

    IF(@UserProfileID = 0)
    BEGIN
        RAISERROR('User ID Invalid, Please Log In Again', 16, 1);
        RETURN; -- Exit the stored procedure if user ID is invalid
    END

	SELECT @IsMailNotification = IsMailNotification,@TxnType = TR.Code
	FROM RequestHeaders RH 
	INNER JOIN TransactionTypes TR ON RH.TransactionTypeCode = TR.Id
	WHERE RH.Id = @RequestHeaderID

INSERT INTO TempApproval VALUES(@RequestTransactionTypeID,@XMLDetails,getdate())


	IF(@UserProfileID = 0)
		BEGIN

			RAISERROR('User ID Invalid, Please Log In Again',16,1)
			ROLLBACK TRANSACTION
		END

Create table #ItemList (  StockItemID BIGINT
						, ApprovedQuantity MONEY
						, RequestDetailID BIGINT)

INSERT INTO #ItemList
SELECT StockItemID 
     , ApprovedQuantity 
	 , RequestDetailID  
FROM OPENXML (@iDocID,'/Approved/RequestionApprovalDetailCollection/RequestionApprovalDetail',2)
WITH #ItemList

IF EXISTS(SELECT TOP 1 1 FROM RequestHeaders WHERE ID=@RequestHeaderID and DocumentStatus ='X')
BEGIN
	declare @QuantityInHandError varchar(100)
	SET @QuantityInHandError =  'Document Already Cancelled!'

					RAISERROR ( @QuantityInHandError, 16, 1 );  
					ROLLBACK TRANSACTION
END 

IF @RequestTransactionTypeID!=16 and @RequestTransactionTypeID !=61

BEGIN 

IF( (SELECT count(ApprovedQuantity) FROM #ItemList ) =0 )
BEGIN
	RAISERROR('Cannot insert all approved values as 0 ',16,1)
	ROLLBACK TRANSACTION
END
ELSE
BEGIN
WHILE( (SELECT COUNT(*) FROM #ItemList) > 0)
BEGIN 

	SELECT TOP (1) @StockItemID = StockItemID 
				 , @ApprovedQuantity = ApprovedQuantity 
				 , @RequestDetailID  = RequestDetailID  
	FROM #ItemList
	ORDER BY StockItemId

	UPDATE dbo.RequestDetails
	SET ApprovedQuantity = @ApprovedQuantity
	WHERE Id = @RequestDetailID

  
	DELETE FROM #ItemList
	WHERE StockItemId = @StockItemId

END 

UPDATE dbo.ApprovalLogs 
SET IsComplete =  1 
  , DocStatus  = 'C'
  ,ApprovalDate=GETDATE()
  ,ApprovalUserID = @UserProfileID
WHERE TransactionID = @RequestTransactionTypeID 
AND   TransactionHeaderID = @RequestHeaderID 
AND   ApprovalLevelID = @ApprovalLevelID


SELECT  @PropertyID = PropertyID
      , @LocationID = LocationID
	  , @TransactionID = TransactionID
	  , @TransactionHeaderID = TransactionHeaderID
FROM dbo.ApprovalLogs
WHERE TransactionID = @RequestTransactionTypeID and TransactionHeaderID=@RequestHeaderID and ApprovalLevelID = @ApprovalLevelID

---------------Added by Nivesh getting location when purchase requestion
	DECLARE @EmailLocationID INT,@TransactionName VARCHAR(MAX)
	,@RequestType CHAR(2)
	
	SELECT @EmailLocationID = LocationID FROM RequestHeaders WHERE Id = @RequestHeaderID
---------------

------------SEND MAIL-------------------
IF(@IsMailNotification = 1)
BEGIN
	DECLARE @Email VARCHAR(MAX),@EmailBody VARCHAR(MAX), @CompanyName VARCHAR(200), @LocationName VARCHAR(200), @RequestedUser VARCHAR(200),@DocumentNo VARCHAR(25)
	SELECT @TransactionName = Name,@RequestType = Code
	FROM TransactionTypes
	WHERE ID =@TransactionID

	SELECT @RequestedUser = U.UserName ,@LocationName = L.Name,@CompanyName = C.Name,@DocumentNo = RH.DocumentNo
	FROM RequestHeaders RH
	INNER JOIN CentralUsers U ON RH.UserProfileID = U.Id
	INNER JOIN Locations L On L.Id = RH.LocationID
	INNER JOIN Companies C ON C.CompanyID =RH.PropertyID
	WHERE RH.Id = @RequestHeaderID


	SELECT TOP(1) @Email=us.Email
	FROM ApprovalLogs AS AL WITH(NOLOCK)
    INNER JOIN dbo.UserWiseApproveLevels AS UAL WITH(NOLOCK)
        ON AL.TransactionID = UAL.TransactionTypeID
            AND AL.LocationID = UAL.LocationId
            AND AL.PropertyID = UAL.PropertyId
            AND AL.ApprovalLevelID = UAL.ApproveLevelID
			AND AL.TransactionHeaderID = @RequestHeaderID
			 AND AL.ApprovalUserID = UAL.UserProfileId   
             AND UAL.SendEmail = 1
    INNER JOIN dbo.CentralUsers AS US WITH(NOLOCK) ON US.Id = UAL.UserProfileId
		WHERE AL.TransactionID = @TransactionID AND AL.SendMail = 0 AND AL.DocStatus = 'P' 
		ORDER BY AL.SeqID ASC;

			--Added by Isuru 2024-05-22 for sending multiplle users with approval mail
		DECLARE @SeqID INT

		SELECT TOP(1)@SeqID= AL.SeqID
		FROM ApprovalLogs AL
		WHERE AL.TransactionID= @TransactionID AND AL.TransactionHeaderID= @RequestHeaderID AND AL.SendMail = 0 AND AL.DocStatus = 'P' 
		ORDER BY AL.SeqID ASC;


		SELECT DISTINCT US.Email,AL.ApprovalUserID
		into #TempEmail
		FROM ApprovalLogs AS AL
			INNER JOIN dbo.UserWiseApproveLevels AS UAL
				   ON AL.TransactionID = UAL.TransactionTypeID
				   AND AL.LocationID = UAL.LocationId
				   AND AL.PropertyID = UAL.PropertyId
				   AND AL.ApprovalLevelID = UAL.ApproveLevelID
				    AND AL.ApprovalUserID = UAL.UserProfileId   
					AND UAL.SendEmail = 1
			INNER JOIN CentralUsers AS US ON US.Id = AL.ApprovalUserID
		WHERE AL.TransactionID = @TransactionID AND AL.SendMail = 0  
		AND AL.TransactionHeaderID=@RequestHeaderID AND AL.SeqID=@SeqID AND AL.DocStatus = 'P' 
		---END



		SET @EmailBody = '<html><body><p>You have to respond a pending approval</p>
						  <table border = 1>
						  <thead>
							  <th  style="width: 20%" >Approval type</th>
							  <th  style="width: 20%" >Document Number</th>
							  <th  style="width: 20%" >Company Name</th>
							  <th  style="width: 20%" >Location Name</th>
							  <th  style="width: 20%" >Requested User</th>
						  </thead>
						  <tbody >
							<tr>
							 <td  style="width: 20%" >'+@TransactionName+'</td>
							 <td  style="width: 20%" >'+@DocumentNo+'</td>
							 <td  style="width: 20%" >'+@CompanyName+'</td>
							 <td  style="width: 20%" >'+@LocationName+'</td>
							 <td  style="width: 20%" >'+@RequestedUser+'</td>
				            </tr>
						  </tbody>
						  </table></html></body>'

	IF @Email IS NOT NULL OR @Email  <> ''
	BEGIN
	DECLARE @NewEmail VARCHAR(MAX),@NewApprovalUserID INT,@MailSubject VARCHAR(MAX)
	
	SELECT @MailSubject = CONCAT(@TransactionName, ' Approval') 

	WHILE EXISTS(SELECT 1  FROM #TempEmail)
	BEGIN
		SELECT TOP(1) @NewEmail= EMAIL,@NewApprovalUserID =ApprovalUserID  FROM #TempEmail

		EXEC [dbo].[SendReuestMail] @NewEmail, @MailSubject, @EmailBody, 2

			;WITH CTE AS (
			SELECT TOP 1 AL.SeqID
			FROM ApprovalLogs AS AL
			INNER JOIN dbo.UserWiseApproveLevels AS UAL ON AL.TransactionID = UAL.TransactionTypeID AND AL.LocationID = UAL.LocationId 
			AND AL.PropertyID = UAL.PropertyId AND AL.ApprovalLevelID = UAL.ApproveLevelID AND AL.TransactionHeaderID = @RequestHeaderID
			INNER JOIN CentralUsers AS US ON US.Id = AL.ApprovalUserID
			WHERE AL.TransactionID = @TransactionID 
				AND AL.DocStatus = 'P'
				AND AL.SeqID=@SeqID
				AND AL.ApprovalUserID=@NewApprovalUserID
			ORDER BY AL.SeqID ASC
			)
			UPDATE AL
			SET AL.SendMail = 1
			FROM ApprovalLogs AS AL
			INNER JOIN CTE ON AL.SeqID = CTE.SeqID
			WHERE AL.TransactionHeaderID = @RequestHeaderID;

			DELETE TOP(1) FROM #TempEmail
		END
		DROP TABLE #TempEmail

		--EXEC [dbo].[SendReuestMail] @Email, 'PR Approval',@EmailBody,@RequestTransactionTypeID;

		--UPDATE TOP(1) AL
		--SET AL.SendMail = 1
		--FROM ApprovalLogs AS AL
		--	INNER JOIN dbo.UserWiseApproveLevels AS UAL
		--		ON AL.TransactionID = UAL.TransactionTypeID
		--		   AND AL.LocationID = UAL.LocationId
		--		   AND AL.PropertyID = UAL.PropertyId
		--		   AND AL.ApprovalLevelID = UAL.ApproveLevelID
		--		   AND AL.TransactionHeaderID = @RequestHeaderID
		--	INNER JOIN dbo.UserMasters AS US
		--		ON US.Id = UAL.UserProfileId
		--WHERE AL.TransactionID = @RequestTransactionTypeID AND AL.DocStatus = 'P' 
	END
		
END
------------SEND MAIL-------------------

EXEC [dbo].[SP_ChekApprovelsForRequest] @PropertyID,@LocationID,@TransactionID,@TransactionHeaderID

	IF(@IsMailNotification = 1)
	BEGIN
		--sending Tranasctionwise emails 2024-09-27
		EXEC [dbo].[SendTransactionWiseEmailS] @RequestType,@RequestHeaderID,@EmailLocationID,@PropertyID,'C'
	END

END

END

--for MRN TransactionID 16


IF @RequestTransactionTypeID=16
BEGIN

--For Updating IR-----
DECLARE @IRID INT,@IRDetailID INT,@MRNID INT  
SELECT @IRID=IssueID,@MRNID=ID FROM dbo.MRNRegistries WHERE RequestionID=@RequestHeaderID
--SELECT @IRDetailID=Id FROM dbo.RequestDetails WHERE RequestHeaderID=@IRID

Create table #ItemList2 (  StockItemID BIGINT
					, ApprovedQuantity MONEY
					, RequestDetailID BIGINT,RequestedQTY MONEY )

INSERT INTO #ItemList2
SELECT RequestDetails.StockItemID 
    , #ItemList.ApprovedQuantity 
	,Id,RequestedQuantity  
FROM dbo.RequestDetails INNER JOIN #ItemList ON #ItemList.StockItemID = RequestDetails.StockItemID WHERE RequestHeaderID=@IRID 

WHILE( (SELECT COUNT(*) FROM #ItemList2) > 0)
BEGIN 

	SELECT TOP (1) @StockItemID = StockItemID 
				 , @ApprovedQuantity = ApprovedQuantity 
				 , @IRDetailID  = RequestDetailID  
	FROM #ItemList2
	ORDER BY StockItemId


	UPDATE dbo.RequestDetails
	SET ApprovedQuantity = @ApprovedQuantity
	WHERE Id = @IRDetailID 

	--SELECT * FROM #ItemList2
	--SELECT @IRDetailID
	--SELECT @ApprovedQuantity
	
	DELETE FROM #ItemList2
	WHERE StockItemId = @StockItemId


END 

--for updating PR
WHILE( (SELECT COUNT(*) FROM #ItemList) > 0)
BEGIN 

	SELECT TOP (1) @StockItemID = StockItemID 
				 , @ApprovedQuantity = ApprovedQuantity 
				 , @RequestDetailID  = RequestDetailID  
	FROM #ItemList
	ORDER BY StockItemId


	UPDATE dbo.RequestDetails
	SET ApprovedQuantity = @ApprovedQuantity
	WHERE Id = @RequestDetailID
	 
	SELECT @reqestedQTY=RequestedQuantity FROM dbo.RequestDetails WHERE Id=@RequestDetailID

	SELECT @Balance=@reqestedQTY-@ApprovedQuantity

	IF @Balance>0
	BEGIN

	SELECT @ProjectID=ProjectID,@BoqID=BoqID FROM dbo.MRNRegistries WHERE RequestionID=@RequestHeaderID
	SELECT @DepartmentID=DepartmentID FROM dbo.RequestHeaders WHERE Id=@RequestHeaderID
	UPDATE dbo.MRNItemRegistries SET BalanceQuantity=BalanceQuantity+@Balance WHERE ItemId=@StockItemID AND BOQId=@BoqID AND ProjectID=@ProjectID AND DepId=@DepartmentID
	
	END	   
	DELETE FROM #ItemList
	WHERE StockItemId = @StockItemId

END 

-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------

--update MRN--
UPDATE dbo.ApprovalLogs 
SET IsComplete =  1 
  , DocStatus  = 'C',
  ApprovalDate=GETDATE()
  ,ApprovalUserID = @UserProfileID
WHERE TransactionID = 33 
AND   TransactionHeaderID = @MRNID 
AND   ApprovalLevelID = @ApprovalLevelID


SELECT  @PropertyID = PropertyID
      , @LocationID = LocationID
	  , @TransactionID = TransactionID
	  , @TransactionHeaderID = TransactionHeaderID
FROM dbo.ApprovalLogs
WHERE TransactionID = 33 and TransactionHeaderID=@MRNID AND  ApprovalLevelID = @ApprovalLevelID

EXEC [dbo].[SP_ChekApprovelsForRequest] @PropertyID,@LocationID,@TransactionID,@MRNID

--update IR

--SELECT @IRID=IssueID FROM dbo.MRNRegistries WHERE RequestionID=@RequestHeaderID
--UPDATE dbo.ApprovalLogs 
--SET IsComplete =  1 
--  , DocStatus  = 'C',
--  ApprovalDate=GETDATE()
--WHERE TransactionID = 11 
--AND   TransactionHeaderID = @IRID 


--SELECT  @PropertyID = PropertyID
--      , @LocationID = LocationID
--	  , @TransactionID = TransactionID
--	  , @TransactionHeaderID = TransactionHeaderID
--FROM dbo.ApprovalLogs
--WHERE TransactionID = 11 and TransactionHeaderID=@IRID and ApprovalLevelID = 1

--EXEC [dbo].[SP_ChekApprovelsForRequest] @PropertyID,@LocationID,@TransactionID,@TransactionHeaderID




END 



--ELSE
--BEGIN

--UPDATE dbo.ApprovalLogs 
--SET IsComplete =  1 
--  , DocStatus  = 'C'
--WHERE TransactionID = @RequestTransactionTypeID 
--AND   TransactionHeaderID = @RequestHeaderID 
--AND   ApprovalLevelID = @ApprovalLevelID
--SELECT  @PropertyID = PropertyID
--      , @LocationID = LocationID
--	  , @TransactionID = TransactionID
--	  , @TransactionHeaderID = TransactionHeaderID
--FROM dbo.ApprovalLogs
--WHERE TransactionID = @RequestTransactionTypeID and TransactionHeaderID=@RequestHeaderID and ApprovalLevelID = @ApprovalLevelID

--EXEC [dbo].[SP_ChekApprovelsForRequest] @PropertyID,@LocationID,@TransactionID,@TransactionHeaderID

--END 
IF @RequestTransactionTypeID=61
BEGIN

update BO set BO.BalanceQTY=IT.ApprovedQuantity from  #ItemList as IT inner join BOQAmedmentDetails as BO on IT.RequestDetailId= BO.id

UPDATE dbo.ApprovalLogs 
SET IsComplete =  1 
  , DocStatus  = 'C',
  ApprovalDate=GETDATE()
  ,ApprovalUserID = @UserProfileID
WHERE TransactionID = @RequestTransactionTypeID 
AND   TransactionHeaderID = @RequestHeaderID 
AND   ApprovalLevelID = @ApprovalLevelID


SELECT  @PropertyID = PropertyID
      , @LocationID = LocationID
	  , @TransactionID = TransactionID
	  , @TransactionHeaderID = TransactionHeaderID
FROM dbo.ApprovalLogs
WHERE TransactionID = @RequestTransactionTypeID and TransactionHeaderID=@RequestHeaderID AND  ApprovalLevelID = @ApprovalLevelID

EXEC [dbo].[SP_ChekApprovelsForRequest] @PropertyID,@LocationID,@TransactionID,@RequestHeaderID


END
COMMIT TRAN;
END TRY
--BEGIN CATCH
--	ROLLBACK TRANSACTION
	
--	DECLARE @ErrorMessage NVARCHAR(4000);  
--	DECLARE @ErrorSeverity INT;  
--	DECLARE @ErrorState INT;  

--	SELECT   
--    @ErrorMessage = ERROR_MESSAGE(),  
--    --@ErrorSeverity = ERROR_SEVERITY(),  
--    --@ErrorState = ERROR_STATE(); 
--	RAISERROR (@ErrorMessage);
--END CATCH

   BEGIN CATCH
	ROLLBACK TRANSACTION
	DECLARE @Message NVARCHAR(100)
	SET @Message = N'Error Occured: ' + ERROR_MESSAGE() 
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)	
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())
	RAISERROR(@Message,16,1)
END CATCH
END

GO

