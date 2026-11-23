CREATE PROCEDURE [dbo].[SP_UpdateProfomaInvApprovalForRequest]
	@XMLDetails XML 
AS
BEGIN
		declare @iDocID int 

		declare @RequestTransactionTypeID int,@ApprovedDate datetime,@UserProfileID bigint, @RequestHeaderID bigint, @ApprovalLevelID int 
		declare @StockItemID bigint, @ApprovedQuantity money, @RequestDetailID bigint


		EXEC sp_xml_preparedocument @iDocID OUTPUT,@XMLDetails

		IF OBJECT_ID(N'#temptemList', N'U') IS NOT NULL
		BEGIN
		  DROP TABLE #temptemList
		END

		SELECT  @RequestTransactionTypeID =RequestTransactionTypeID,@ApprovedDate =ApprovedDate ,@UserProfileID =UserProfileID , @RequestHeaderID =RequestHeaderID , @ApprovalLevelID =ApprovalLevelID 
		FROM     OPENXML (@iDocID,'/Approved',2)
		with (RequestTransactionTypeID int,ApprovedDate datetime,UserProfileID bigint, RequestHeaderID bigint,ApprovalLevelID int)
			

		Create table #temptemList
		(StockItemID bigint, ApprovedQuantity money, RequestDetailID bigint)

		insert into #temptemList
		select StockItemID , ApprovedQuantity , RequestDetailID  
		FROM     OPENXML (@iDocID,'/Approved/RequestionApprovalDetailCollection/RequestionApprovalDetail',2)
		with #temptemList

		select * FROM #temptemList

		while (select COUNT(*) from #temptemList)>0
		begin 
		print 'hi'
		select top (1) @StockItemID =StockItemID , @ApprovedQuantity =ApprovedQuantity , @RequestDetailID  =RequestDetailID  from #temptemList
		order by StockItemId
		print @StockItemId
		print @RequestDetailID
		update dbo.RequestDetails
		set ApprovedQuantity = @ApprovedQuantity
		where Id = @RequestDetailID

		delete from #temptemList
		where RequestDetailID= @RequestDetailID

		end 

		update dbo.ApprovalLogs 
		set IsComplete=1 , DocStatus='C'
		where TransactionID = @RequestTransactionTypeID and TransactionHeaderID=@RequestHeaderID and ApprovalLevelID = @ApprovalLevelID

		declare @PropertyID int,@LocationID int,@TransactionID int,@TransactionHeaderID bigint

		select @PropertyID=PropertyID,@LocationID=LocationID,@TransactionID=TransactionID,@TransactionHeaderID=TransactionHeaderID
		from dbo.ApprovalLogs
		where TransactionID = @RequestTransactionTypeID and TransactionHeaderID=@RequestHeaderID and ApprovalLevelID = @ApprovalLevelID

		

		exec [dbo].[SP_ChekApprovelsForRequest_ProfomaInv] @PropertyID,@LocationID,@TransactionID,@TransactionHeaderID
END

GO

