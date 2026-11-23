CREATE PROCEDURE [dbo].[SP_ChekApprovelsForRequest] --1,5,61,35
(  @PropertyID int 
 , @LocationID int 
 , @TransactionID int
 , @TransactionHeaderID int
  ) 
AS

DECLARE @CUNT INT 


--added by Isuru 2023-08-17
DECLARE  @DepartmentID2 int 
,@IsBatchTransactionEnable BIT
IF(@TransactionID =11 OR @TransactionID =1)
BEGIN

	SELECT @DepartmentID2 = DepartmentID
	FROM RequestHeaders
	WHERE Id=@TransactionHeaderID
END
--end

SELECT @IsBatchTransactionEnable = IsBatchTransactionEnable
FROM Companies
WHERE CompanyID = @PropertyID


	
SET @CUNT = (SELECT COUNT(*) 
			 FROM dbo.ApprovalLogs 
			 WHERE PropertyID= @PropertyID 
			-- AND LocationID=@LocationID commented by Isuru 2023-08-17
			  AND LocationID=CASE WHEN @TransactionID=11 OR @TransactionID =1 then @DepartmentID2 ELSE  @LocationID END --added by Isuru 2023-08-17
			 AND TransactionHeaderID= @TransactionHeaderID and TransactionID = @TransactionID 
			 AND DocStatus <> 'C')

	
IF (@CUNT = 0) 
BEGIN

	IF @TransactionID = 2  --if a Purchase Order
	BEGIN
		UPDATE  dbo.PoHeaders
		SET   isApproved     = 1 
			, DocumentStatus ='P'
		WHERE Id = @TransactionHeaderID 
		
	END
	ELSE 
	IF @TransactionID=61
	BEGIN

		Update [dbo].[BOQAmendmentHeader] set Approve =1 
		where ID=@TransactionHeaderID 
		
		drop table #temb
		select BO.*,BAD.ItemID,BAD.BalanceQTY into #temb from [dbo].[BOQAmendmentHeader] as BO inner join  
		[dbo].[BOQAmedmentDetails] as BAD on BO.id=BOQAMDHeaderID where BO.id=@TransactionHeaderID

		select * from #temb

		While ((select count(Id) from #temb)>0 )
		BEGIN

		declare @ID2 INT,@BOQId INT,@DepartmentID INT,@LocationID2 INT,@ItemID INT,@BalanceQTY INT,@DocID Varchar(50),@ProjectID INT,@IPAddress varchar(max),@CreatedUserID INT,@LastModUserID INT
 
		 select top(1) @ID2=Id,@DocID=DocumentNo,@BOQId=BOQId,@DepartmentID=DepartmentID,@LocationID2=LocationID,@ItemID=ItemID,@BalanceQTY=BalanceQTY,@ProjectID=ProjectID,@IPAddress=IPAddress,@CreatedUserID=CreatedUserID,@LastModUserID=LastModUserID  from #temb

		 select @BalanceQTY

		 if(@BalanceQTY <0)
		 Begin 
	  
		 --update  MRNItemRegistries set suspendedQuantity= suspendedQuantity+(@BalanceQTY*-1) 
		 --where BOQId=@BOQId and DepId=@DepartmentID and ItemId=@ItemID and source='BOQ'


		 UPDATE  mrnitemregistries 
		SET SuspendedQuantity=suspendedQuantity+(@BalanceQTY*-1) 
		WHERE ID in (SELECT TOP (1) Id 
				 FROM mrnitemregistries 
				 where BOQId=@BOQId and DepId=@DepartmentID and ItemId=@ItemID)


		end
		else
		Begin
	
		if exists(select * from MRNItemRegistries where BOQId=@BOQId and DepId=@DepartmentID and ItemId=@ItemID)
		begin
	INSERT INTO [dbo].[MRNItemRegistries]
			   ([ItemId]
			   ,[BOQId]
			   ,[DepId]
			   ,[BOQQuantity]
			   ,[RequestQuantity]
			   ,[IssueQuantity]
			   ,[BalanceQuantity]
			   ,[SuspendedQuantity]
			   ,[IPAddress]
			   ,[CreatedUserID]
			   ,[LastModUserID]
			   ,[CreatedDate]
			   ,[LastModDate]
			   ,[ProjectID]
			   ,[UnitID]
			   ,[Source]
			   )
		 select top(1)
				ItemId,
				BOQId, 
				DepId, 
				BOQQuantity, 
				RequestQuantity, 
				IssueQuantity, 
				@BalanceQTY, 
				0, 
				IPAddress, 
				CreatedUserID, 
				LastModUserID,
				CreatedDate, 
				LastModDate, 
				ProjectID, 
				UnitID,
				@DocID
				from 
				MRNItemRegistries where BOQId=@BOQId and DepId=@DepartmentID and ItemId=@ItemID
				end
				else
				begin
				INSERT INTO [dbo].[MRNItemRegistries]
			   ([ItemId]
			   ,[BOQId]
			   ,[DepId]
			   ,[BOQQuantity]
			   ,[RequestQuantity]
			   ,[IssueQuantity]
			   ,[BalanceQuantity]
			   ,[SuspendedQuantity]
			   ,[IPAddress]
			   ,[CreatedUserID]
			   ,[LastModUserID]
			   ,[CreatedDate]
			   ,[LastModDate]
			   ,[ProjectID]
			   ,[UnitID]
			   ,[Source]
			   )
			values(
				@ItemID,
				@BOQId, 
				@DepartmentID, 
				0, 
				0, 
				0, 
				@BalanceQTY, 
				0, 
				'192.168.1.1', 
				@CreatedUserID, 
				@LastModUserID,
				GETDATE(), 
				  GETDATE(), 
				@ProjectID, 
				1,
				@DocID
				)


				end


		end
	
	
		delete from #temb where ItemID=@ItemID
		END
	



	END

	ELSE IF(@TransactionID = 34)    
	BEGIN
		UPDATE dbo.BillHeaders
		SET IsApproved = 1, Status = 'P'
		WHERE Id = @TransactionHeaderID
	END
    
	ELSE IF(@TransactionID = 36)
	BEGIN
		UPDATE dbo.OutSourceLabourHeaders
		SET IsApproved = 1, Status = 'P'
		WHERE Id = @TransactionHeaderID
	END

	--ELSE IF(@TransactionID = 37)
	--BEGIN
		--UPDATE dbo.WorkHeaders
		--SET IsApproved = 1, Status = 'P'
		--WHERE Id = @TransactionHeaderID
	--END

	ELSE IF (@TransactionID = 38)
	BEGIN
		UPDATE dbo.CustomerSuppliedStockHeaders
		SET Completed = 1, Status = 'P'
		WHERE Id = @TransactionHeaderID
	END

	



    ELSE IF(@TransactionID = 33)
	BEGIN

		DECLARE @IRID INT,@REQID INT
		SELECT @REQID=RequestionID,@IRID=IssueID FROM dbo.MRNRegistries WHERE ID=@TransactionHeaderID
		 -- for PR----
		UPDATE  dbo.RequestHeaders
			SET   isApproved = 1 
				, DocumentStatus ='P'
			WHERE Id = @TransactionID 
			AND RequestType =(SELECT Code FROM TransactionTypes WHERE Id= 1 )

			DECLARE @ApprovLevels INT = 0	
			SET @ApprovLevels =  (SELECT  COUNT(*) 
								  FROM dbo.ApprovalLogs 
								  WHERE PropertyID = @PropertyID 
								  AND LocationID = @LocationID  
								  AND TransactionID =@REQID)


		IF(@ApprovLevels = 0)
		BEGIN
			
			--DECLARE @ApprovedQuantity INT
			--SELECT  @ApprovedQuantity = dbo.RequestDetails.RequestedQuantity 
			--FROM dbo.RequestDetails 
			--WHERE  RequestHeaderID = @REQID
	
			UPDATE dbo.RequestDetails
			SET ApprovedQuantity = RequestedQuantity ,IssuedQuantity = 0
			WHERE  RequestHeaderID = @REQID
			---PR QUANTITY---

	    END
  ----------------
  --For IR-------------
		UPDATE  dbo.RequestHeaders
		SET   isApproved = 1 
			, DocumentStatus ='P'
		WHERE Id = @IRID 
		AND RequestType =(SELECT Code FROM TransactionTypes WHERE Id= 11  OR @TransactionID =1)

		--DECLARE @ApprovLevels INT = 0	
		SET @ApprovLevels =  (SELECT  COUNT(*) 
							  FROM dbo.ApprovalLogs 
							  WHERE PropertyID = @PropertyID 
							  AND LocationID = @LocationID  
							  AND TransactionID =@TransactionID)

		IF(@ApprovLevels = 0)
		BEGIN
			
			--DECLARE @ApprovedQuantity INT
			--SELECT  @ApprovedQuantity = dbo.RequestDetails.RequestedQuantity 
			--FROM dbo.RequestDetails 
			--WHERE  RequestHeaderID = @IRID

			UPDATE dbo.RequestDetails
			SET ApprovedQuantity = RequestedQuantity ,IssuedQuantity = 0
			WHERE  RequestHeaderID = @IRID

	    END
		----------		
		

	END 

	------------Added for IR-----------------
	ELSE IF (@TransactionID = 7)
	BEGIN
		DECLARE @XML VARCHAR(MAX), @XMLData XML

		SELECT @XML = XMLDetails FROM [dbo].[GRNApprovalLog] WHERE Id = @TransactionHeaderID 

		SET @XMLData = CAST(@XML AS XML)

		UPDATE dbo.GRNApprovalLog
		SET  Status = 'A'
		WHERE Id = @TransactionHeaderID

		EXEC [dbo].[SP_InsertStockTransactions] @XMLData,'',0,'',0,1
	END
	-------------Added for IR-------------------

	ELSE
	BEGIN
		UPDATE  dbo.RequestHeaders
		SET   isApproved = 1 
			, DocumentStatus ='P'
		WHERE Id = @TransactionHeaderID 
		AND RequestType =(SELECT Code FROM TransactionTypes WHERE Id= @TransactionID )

		--DECLARE @ApprovLevels INT = 0	
		SET @ApprovLevels =  (SELECT  COUNT(*) 
							  FROM dbo.ApprovalLogs 
							  WHERE PropertyID = @PropertyID 
							  AND LocationID = @LocationID  
							  AND TransactionID =@TransactionID
							  AND TransactionHeaderID =@TransactionHeaderID)

		SELECT @ApprovLevels 'fff' 

		IF(@ApprovLevels = 0)
		BEGIN
			
			--DECLARE @ApprovedQuantity INT
			--SELECT  @ApprovedQuantity = dbo.RequestDetails.RequestedQuantity 
			--FROM dbo.RequestDetails 
			--WHERE  RequestHeaderID = @TransactionHeaderID

			UPDATE dbo.RequestDetails
			SET ApprovedQuantity = RequestedQuantity ,IssuedQuantity = 0
			WHERE  RequestHeaderID = @TransactionHeaderID

	    END

		IF @TransactionID = 14 -- IF Damage Request Note
		BEGIN
		
			SELECT D.StockItemID, RequestedQuantity-ApprovedQuantity QTY  
			INTO #ApprovalDiff
			FROM RequestDetails D 
			INNER JOIN RequestHeaders H ON H.Id= d.RequestHeaderID
			INNER JOIN StockItemWiseEXPDateIns E on e.TransactionID = d.RequestHeaderID
			WHERE H.Id= @TransactionHeaderID AND ApprovedQuantity <RequestedQuantity

			DECLARE @CurID INT, @ExpDate DATE, @ExpItemID INT, @Qty MONEY, @TxnQty INT, @Error BIT= 0

			IF(@IsBatchTransactionEnable =0)
			BEGIN

				WHILE EXISTS (SELECT TOP 1 1 FROM #ApprovalDiff)
				BEGIN
					SELECT	TOP (1) @ExpItemID=StockItemID, @Qty=QTY
					FROM	#ApprovalDiff

 
					WHILE @Qty >0 and @Error =0
					BEGIN

						SELECT top 1 @CurID=ID, @TxnQty=Quantity-BalanceQuantity 
						FROM  StockItemWiseEXPDateIns
						WHERE	PropertyID = @PropertyID and LocationID= @LocationID 
								AND StockItemID =@ExpItemID 
								AND  BalanceQuantity < Quantity
								AND TransactionID = @TransactionHeaderID
								AND TransactionType ='RD'
						ORDER BY EXPDate

						IF @CurID is null
							set @Error =1

						UPDATE StockItemWiseEXPDateIns
						SET BalanceQuantity =BalanceQuantity + CASE WHEN @TxnQty > @Qty THEN @Qty ELSE @TxnQty END 
						WHERE ID= @CurID


						SET @Qty -= CASE WHEN @TxnQty > @Qty THEN @Qty ELSE @TxnQty END 

					END 

					DELETE FROM #ApprovalDiff 
					WHERE StockItemID = @ExpItemID

			END 
			END
				
			EXEC [SP_InsertDamageNoteOnApproval] @PropertyID,@LocationID,@TransactionHeaderID 
		END  
	
	
	END

end




else if (select COUNT(*) from ApprovalLogs
	where PropertyID=@PropertyID and LocationID=@LocationID 
	and TransactionHeaderID= @TransactionHeaderID and TransactionID = @TransactionID 
	and DocStatus ='X')>0
begin

	if @TransactionID=2
	begin
		Update  dbo.POHeaders
		SET isApproved=0 , DocumentStatus ='X'
		WHERE POHeaderID = @TransactionHeaderID 
	END

    if @TransactionID=34
	BEGIN
		UPDATE dbo.BillHeaders
		SET IsApproved = 0, Status = 'X'
		WHERE Id = @TransactionHeaderID
	END
    
	if @TransactionID=36
	BEGIN
		UPDATE dbo.OutSourceLabourHeaders
		SET IsApproved = 0, Status = 'X'
		WHERE Id = @TransactionHeaderID
	END


	if @TransactionID=38
	BEGIN
		UPDATE dbo.CustomerSuppliedStockHeaders
		SET Completed = 0, Status = 'X'
		WHERE Id = @TransactionHeaderID
	end
    
	IF(@TransactionID=33)
	BEGIN

		SELECT RequestionID=@REQID,IssueID=@IRID 
		FROM dbo.MRNRegistries 
		WHERE ID=@TransactionHeaderID

		Update  dbo.RequestHeaders
		set isApproved=0 , DocumentStatus ='X'
		where Id = @REQID and RequestType = (select Code from TransactionTypes where Id= 1 )

		Update  dbo.RequestHeaders
		set isApproved=0 , DocumentStatus ='X'
		where Id = @IRID and RequestType = (select Code from TransactionTypes where Id= 11 OR @TransactionID =1 )

	END

	------------Added for IR-----------------
	 IF (@TransactionID = 7)
	BEGIN
		UPDATE dbo.GRNApprovalLog
		SET  Status = 'X'
		WHERE Id = @TransactionHeaderID
	END
	-------------Added for IR-------------------

	else
	begin
		
		Update  dbo.RequestHeaders
		set isApproved=0 , DocumentStatus ='X'
		where Id = @TransactionHeaderID and RequestType = (select Code from TransactionTypes where Id= @TransactionID )
		
	end

end

GO

