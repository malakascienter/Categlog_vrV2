CREATE PROCEDURE [dbo].[SP_Chek_Approvels_For_Order]--[SP_Chek_Approvels_For_Order] 1,1,40,1019
(  @PropertyID int 
 , @LocationID int 
 , @TransactionID int
 , @TransactionHeaderID int )
AS

DECLARE @CUNT INT 
SET @CUNT = (SELECT COUNT(*) 
			 FROM dbo.ApprovalLogs 
			 WHERE PropertyID= @PropertyID 
			 AND LocationID=@LocationID 
			 AND TransactionHeaderID= @TransactionHeaderID and TransactionID = @TransactionID 
			 AND DocStatus <> 'C')
PRINT @PropertyID
		PRINT @LocationID
		PRINT @TransactionHeaderID
IF (@CUNT = 0)
BEGIN
--SELECT * FROM OrderHeaders
	IF @TransactionID = 40  --if a Sales Order
	BEGIN
		UPDATE  OrderHeaders
		SET   isApproved     = 1 
			, DocumentStatus ='P'
		WHERE Id = @TransactionHeaderID 
	END

	--SELECT * FROM CreditApprovals
	ELSE IF(@TransactionID = 49)    
	BEGIN
		UPDATE dbo.CreditApprovals
		SET IsApproved = 1, DocumentStatus = 'P'
		WHERE Id = @TransactionHeaderID
	END
    
	--ELSE IF(@TransactionID = 36)
	--BEGIN
	--	UPDATE dbo.OutSourceLabourHeaders
	--	SET IsApproved = 1, Status = 'P'
	--	WHERE Id = @TransactionHeaderID
	--END

	

	--ELSE IF (@TransactionID = 38)
	--BEGIN
	--	UPDATE dbo.CustomerSuppliedStockHeaders
	--	SET Completed = 1, Status = 'P'
	--	WHERE Id = @TransactionHeaderID
	--END
    
	ELSE
	BEGIN
		UPDATE  dbo.RequestHeaders
		SET   isApproved = 1 
			, DocumentStatus ='P'
		WHERE Id = @TransactionHeaderID 
		AND RequestType =(SELECT Code FROM TransactionTypes WHERE Id= @TransactionID )

		DECLARE @ApprovLevels INT = 0	
		SET @ApprovLevels =  (SELECT  COUNT(*) 
							  FROM dbo.ApprovalLogs 
							  WHERE PropertyID = @PropertyID 
							  AND LocationID = @LocationID  
							  AND TransactionID =@TransactionID)

		IF(@ApprovLevels = 0)
		BEGIN
			
			DECLARE @ApprovedQuantity INT
			SELECT  @ApprovedQuantity = dbo.RequestDetails.RequestedQuantity 
			FROM dbo.RequestDetails 
			WHERE  RequestHeaderID = @TransactionHeaderID

			UPDATE dbo.RequestDetails
			SET ApprovedQuantity = @ApprovedQuantity ,IssuedQuantity = 0
			WHERE  RequestHeaderID = @TransactionHeaderID

	    END
		
		--IF @TransactionID = 14 -- IF Damage Request Note
		--BEGIN		
		--	EXEC [SP_InsertDamageNoteOnApproval] @PropertyID,@LocationID,@TransactionHeaderID 
		--END  
	
	
	END

end 
else if (select COUNT(*) from ApprovalLogs
	where PropertyID=@PropertyID and LocationID=@LocationID 
	and TransactionHeaderID= @TransactionHeaderID and TransactionID = @TransactionID 
	and DocStatus ='X')>0
begin

	if @TransactionID=40
	begin
		Update  dbo.OrderHeaders
		set isApproved=0 , DocumentStatus ='X'
		WHERE Id = @TransactionHeaderID 
	END
  
    
	if @TransactionID=49
	BEGIN
		UPDATE dbo.CreditApprovals
		SET IsApproved = 0, DocumentStatus = 'X'
		WHERE Id = @TransactionHeaderID
	END
    
	--if @TransactionID=37
	--BEGIN
    
	--END

	--if @TransactionID=38
	--BEGIN
	--	UPDATE dbo.CustomerSuppliedStockHeaders
	--	SET Completed = 0, Status = 'X'
	--	WHERE Id = @TransactionHeaderID
	--end
    
	--else
	--begin
		
	--	Update  dbo.RequestHeaders
	--	set isApproved=0 , DocumentStatus ='X'
	--	where Id = @TransactionHeaderID and RequestType = (select Code from TransactionTypes where Id= @TransactionID )
		
	--end

end

GO

