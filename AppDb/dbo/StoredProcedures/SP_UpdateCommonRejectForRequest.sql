
CREATE PROCEDURE [dbo].[SP_UpdateCommonRejectForRequest]


	@ApprovedDate DATE,
	@RequestHeaderID INT,
	@TransactionID INT,
	@UserProfileID INT,
	@ApprovalLevelID INT,
	@RejectReason VARCHAR(500) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @IsMailNotification BIT
	-----------------------------------------------------Begin Try-------------------------------------------------------------------
	BEGIN TRY 

	SELECT   @IsMailNotification = IsMailNotification
	FROM TransactionTypes
	WHERE ID = @TransactionID
	
	IF(@UserProfileID = 0)
    BEGIN
        RAISERROR('User ID Invalid, Please Log In Again', 16, 1);
        RETURN; -- Exit the stored procedure if user ID is invalid
    END
	--16 is for MRN
	
	IF(@UserProfileID = 0)
		BEGIN

			RAISERROR('User ID Invalid, Please Log In Again',16,1)
			ROLLBACK TRANSACTION
		END

	IF @TransactionID=16

	BEGIN

	DECLARE @IRID INT,@MRNID INT 
	 
	SELECT @IRID=IssueID,@MRNID=id FROM dbo.MRNRegistries WHERE RequestionID=@RequestHeaderID

    UPDATE dbo.ApprovalLogs
			
		SET DocStatus = 'X',
			ApprovalDate = @ApprovedDate,
			IsComplete=1,
			ApprovalUserID = @UserProfileID,
			Remarks = @RejectReason
	WHERE  TransactionID = 33 --MRN
	AND TransactionHeaderID=@MRNID
	AND ApprovalLevelID = @ApprovalLevelID
	
	
	
	UPDATE dbo.RequestHeaders
			SET DocumentStatus = 'X',
				IsApproved = 0
	WHERE Id = @RequestHeaderID

	 --UPDATE dbo.ApprovalLogs
			
	--	SET DocStatus = 'X',
	--		ApprovalDate = @ApprovedDate,
	--		IsComplete=1,
	--		ApprovalUserID = @UserProfileID
	--WHERE  TransactionID = 11
	--AND TransactionHeaderID=@IRID 
	--AND ApprovalLevelID = @ApprovalLevelID
	
	
	
	UPDATE dbo.RequestHeaders
			SET DocumentStatus = 'X',
				IsApproved = 0
	WHERE Id = @IRID

	Create table #ItemList2 (  StockItemID BIGINT
					, ApprovedQuantity MONEY
					, RequestDetailID BIGINT,RequestedQTY MONEY )

	INSERT INTO #ItemList2
	SELECT StockItemID 
		,ApprovedQuantity 
		,Id,RequestedQuantity  
	FROM dbo.RequestDetails  WHERE RequestHeaderID=@RequestHeaderID 


	DECLARE 
	@StockItemID INT,
	@RequestedQuantity INT,
	@RequestDetailID INT,
	@ProjectID INT,
	@BoqID INT,
	@DepartmentID INT
	
	SELECT @ProjectID=ProjectID,@BoqID=BoqID FROM dbo.MRNRegistries WHERE RequestionID=@RequestHeaderID
	SELECT @DepartmentID=DepartmentID FROM dbo.RequestHeaders WHERE Id=@RequestHeaderID   
	  
	WHILE( (SELECT COUNT(*) FROM #ItemList2) > 0)
    BEGIN 
	SELECT TOP (1) @StockItemID = StockItemID 
				 ,  @RequestedQuantity = RequestedQTY 
				 , @RequestDetailID  = RequestDetailID  
	FROM #ItemList2
	ORDER BY StockItemId

	print @StockItemId
	print @RequestDetailID

	UPDATE dbo.MRNItemRegistries SET BalanceQuantity=BalanceQuantity+@RequestedQuantity WHERE ItemId=@StockItemID AND BOQId=@BoqID AND ProjectID=@ProjectID AND DepId=@DepartmentID
	
	 
	DELETE FROM #ItemList2
	WHERE StockItemId = @StockItemId

    END 

	END 

	---if not MRN
	ELSE 

    BEGIN
	UPDATE dbo.ApprovalLogs
	SET DocStatus = 'X',
	ApprovalDate = @ApprovedDate,
	IsComplete=1,
	ApprovalUserID = @UserProfileID,
	Remarks = @RejectReason
	WHERE  TransactionID = @TransactionID
	AND TransactionHeaderID=@RequestHeaderID 
	AND ApprovalLevelID = @ApprovalLevelID


	--Added by Isuru 2026-02-23 to update approval if user rejects
	UPDATE dbo.ApprovalLogs
	SET DocStatus = 'X',
	IsComplete=1
	WHERE  TransactionID = @TransactionID
	AND TransactionHeaderID=@RequestHeaderID 
	--End
	
	
	UPDATE dbo.RequestHeaders
			SET DocumentStatus = 'X',
				IsApproved = 0,
				LastModUserID =@UserProfileID
	WHERE Id = @RequestHeaderID


	------------SEND MAIL TO REQUEST USER WHEN REJECT-------------------
	IF(@IsMailNotification = 1)
	BEGIN
		IF(@TransactionID = 1)
		BEGIN
			DECLARE @RejectUser VARCHAR(200), @LocationName VARCHAR(200), @CompanyName VARCHAR(200), @DocumentNo VARCHAR(20), @Email VARCHAR(100),
			@EmailBody VARCHAR(MAX)

			--SELECT @LocationName = L.Name,@CompanyName = C.Name, @DocumentNo = RH.DocumentNo,@Email=E.Email
			--FROM RequestHeaders RH
			--INNER JOIN UserMasters U ON RH.UserProfileID = U.Id
			--INNER JOIN Locations L On L.Id = RH.LocationID
			--INNER JOIN Companies C ON C.CompanyID =RH.PropertyID
			--INNER JOIN UserMasters UM ON UM.Id = RH.UserProfileID
			--INNER JOIN Employees E ON E.Id = UM.EmployeeId
			--WHERE RH.Id = @RequestHeaderID

			SELECT @LocationName = LO.Name ,@CompanyName=  CO.Name ,@DocumentNo =RH.DocumentNo,@Email =CU.Email
			FROM RequestHeaders RH
			INNER JOIN CentralUsers CU ON CU.Id = RH.UserProfileID
			INNER JOIN Companies CO ON CO.CompanyID = RH.PropertyID
			INNER JOIN Locations LO ON LO.Id = RH.LocationID
			WHERE RH.Id =@RequestHeaderID

			--SELECT @RejectUser =  U.UserName
			--FROM  ApprovalLogs A 
			--INNER JOIN UserWiseApproveLevels UL ON UL.ApproveLevelID = A.ApprovalLevelID 
			--INNER JOIN UserMasters U ON U.Id = UL.UserProfileId
			--WHERE A.TransactionHeaderID = @RequestHeaderID AND A.TransactionID = 1 AND A.DocStatus = 'X'

			SELECT @RejectUser =  U.UserName
			FROM  ApprovalLogs A 
			INNER JOIN UserWiseApproveLevels UL ON UL.ApproveLevelID = A.ApprovalLevelID 
			INNER JOIN CentralUsers U ON U.Id = UL.UserProfileId
			WHERE A.TransactionHeaderID = @RequestHeaderID AND A.TransactionID = 1 AND A.DocStatus = 'X'


				SET @EmailBody = '<html><body><p>Your Request is Rejected</p>
							  <table border = 1>
							  <thead>
								  <th  style="width: 20%" >Approval type</th>
								  <th  style="width: 20%" >Document Number</th>
								  <th  style="width: 20%" >Company Name</th>
								  <th  style="width: 20%" >Location Name</th>
								  <th  style="width: 20%" >Rejected User</th>
								  <th  style="width: 20%" >Reject Reason</th>
							  </thead>
							  <tbody >
								<tr>
								 <td  style="width: 20%" >Purchase Request</td>
								 <td  style="width: 20%" >'+@DocumentNo+'</td>
								 <td  style="width: 20%" >'+@CompanyName+'</td>
								 <td  style="width: 20%" >'+@LocationName+'</td>
								 <td  style="width: 20%" >'+@RejectUser+'</td>
								 <td  style="width: 20%" >'+@RejectReason+'</td>
								</tr>
							  </tbody>
							  </table></html></body>'

			IF @Email IS NOT NULL
			BEGIN
				EXEC [dbo].[SendReuestMail] @Email, 'Reject Request',@EmailBody,1;

			END

		END
	END
------------SEND MAIL TO REQUEST USER WHEN REJECT-------------------



	END
    

	IF (@TransactionID = 14) -- IF DAMAGE NOTE
	BEGIN
		
		UPDATE StockItemWiseEXPDateIns
		SET BalanceQuantity=  Quantity
		WHERE TransactionID=@RequestHeaderID and TransactionType='RD'

	END
	 
    -- Insert statements for procedure here
	END TRY
	----------------------------------------------------------End Try-----------------------------------------------------------------
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

END

GO

