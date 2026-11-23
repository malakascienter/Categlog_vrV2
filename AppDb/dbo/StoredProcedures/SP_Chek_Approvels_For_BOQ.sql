CREATE PROCEDURE [dbo].[SP_Chek_Approvels_For_BOQ]--[SP_Chek_Approvels_For_Order] 1,1,52,1076
(  @PropertyID INT 
 , @LocationID INT 
 , @TransactionID INT
 , @TransactionHeaderID INT )
AS

DECLARE @CUNT INT 
SET @CUNT = (SELECT COUNT(*) 
			 FROM dbo.ApprovalLogs 
			 WHERE PropertyID= @PropertyID 
			 AND LocationID=@LocationID 
			 AND TransactionHeaderID= @TransactionHeaderID AND TransactionID = @TransactionID 
			 AND DocStatus <> 'C')
PRINT @PropertyID
		PRINT @LocationID
		PRINT @TransactionHeaderID
IF (@CUNT = 0)
BEGIN
--SELECT * FROM OrderHeaders 
   IF(@TransactionID = 52)    
	BEGIN
	PRINT 'Hello'
	PRINT @CUNT
		UPDATE dbo.BOQHeaders
		SET Approve = 1, BOQStatus = 1
		WHERE Id = @TransactionHeaderID

		SELECT * FROM dbo.MRNItemRegistries

	INSERT INTO dbo.MRNItemRegistries
		        ( ItemId ,
		          BOQId ,
		          DepId ,
		          BOQQuantity ,
		          RequestQuantity ,
		          IssueQuantity ,
		          BalanceQuantity ,
		          SuspendedQuantity ,
		          IPAddress ,
		          CreatedUserID ,
		          LastModUserID ,
		          CreatedDate ,
		          LastModDate ,
		          ProjectID ,
		          UnitID,
				  Source
		        )


	SELECT	     BRD.ItemID , -- ItemId - int
		         BSWA.BOQID, -- BOQId - int
		         BSWA.DepartmentID , -- DepId - int
		         SUM(BSWA.Quantity*BRA.RateQtyInWork*BRD.Quantity) Qty , -- BOQQuantity - decimal
		          0 , -- RequestQuantity - decimal
		          0 , -- IssueQuantity - decimal
		          SUM(BSWA.Quantity*BRA.RateQtyInWork*BRD.Quantity) Qty , -- BalanceQuantity - decimal
		          0 , -- SuspendedQuantity - decimal
		          N'' , -- IPAddress - nvarchar(max)
		          0 , -- CreatedUserID - int
		          0 , -- LastModUserID - int
		          GETDATE() , -- CreatedDate - datetime
		          GETDATE() , -- LastModDate - datetime
		         B.ProjectID  , -- ProjectID - int
		         BRD.Unit,  -- UnitID - int,
				 'BOQ'
		
		-- SUM(BSWA.Quantity*BRA.RateQtyInWork*BRD.Quantity) Qty,BRD.ItemID,BRD.RateID,BSWA.DepartmentID,BRD.Unit,BSWA.BOQID,B.ProjectID 
		 FROM BOQSubWorkAllocations BSWA 
		INNER JOIN dbo.BOQRateanalysisAllocationHeaders BRA 
		ON BRA.BOQID=BSWA.BOQID AND BRA.WorkID=BSWA.Id INNER JOIN 
		dbo.BOQRateanalysisAllocationDetails BRD ON BRD.BOQID=BRA.BOQID
		INNER JOIN dbo.BOQHeaders B ON B.Id=BSWA.BOQID
		WHERE BRA.BOQID=@TransactionHeaderID AND BRD.ItemType IN('I','P') GROUP BY BRD.ItemID,BSWA.DepartmentID,BRD.Unit,BSWA.BOQID,B.ProjectID
 



INSERT INTO [dbo].[SundryRegistries]
           ([BOQId]
           ,[DepId]
           ,[SundryAmount]
           ,[RequestAmount]
           ,[IssueAmount]
           ,[BalanceAmount]
		   )
			Select BOQID,
				   DepartmentID,
				   Quantity*SundryAmount,
				   0,
				   0,
				   Quantity*SundryAmount   	
			 from BOQSubWorkAllocations

							



		

		CREATE TABLE #TempT(
		Id INT IDENTITY(1,1),
		BOQID INT,
		DepartmentID INT,
		CategoryId INT,
		TotalCost DECIMAL(18,2),
		Updated BIT
		)
	



		INSERT INTO #TempT 
		SELECT CPS.BOQID,BSA.DepartmentID,CPS.CategoryId AS CategoryId,SUM(CPS.Cost) AS TotalCost,0 FROM BOQSubWorkAllocations AS BSA 
		INNER JOIN BOQRateanalysisAllocationHeaders AS BRA ON BSA.BOQID=BRA.BOQID AND BRA.WorkID=BSA.Id
		INNER JOIN dbo.BOQRateanalysisAllocationDetails BRD ON BRD.BOQID=BRA.BOQID AND BRA.RateanalysisID=BRD.RateID
		INNER JOIN dbo.BOQHeaders B ON B.Id=BSA.BOQID INNER JOIN CostProvisionSnapShot AS CPS ON CPS.RateHeaderId=BRD.RateId AND CPS.BOQID=BRD.BOQID AND CPS.ItemId=BRD.ItemID
		WHERE BRA.BOQID=@TransactionHeaderID AND BRD.ItemType IN('I','P') GROUP BY BSA.DepartmentID,CPS.RateHeaderId,CPS.CategoryId,CPS.BOQID
		

		INSERT INTO #TempT
		SELECT BOQID,DepartmentID,1000 AS CategoryId,SundryAmount AS TotalCost,0 FROM BOQSubWorkAllocations  WHERE BOQID =@TransactionHeaderID


		DECLARE @IdC INT,@BOQIDC INT,@DepartmentIDC INT,@CategoryIdC INT,@TotalCostC DECIMAL


		WHILE((SELECT COUNT(*) FROM #TempT)>0)
		BEGIN
			
			SELECT TOP(1) @IdC=Id,@BOQIDC=BOQID,@DepartmentIDC=DepartmentID,@CategoryIdC=CategoryId,@TotalCostC=TotalCost   FROM #TempT

			IF EXISTS( SELECT * FROM [dbo].[DepartmentWiseCostProvisions] WHERE BOQID=@BOQIDC AND categoryId=@CategoryIdC AND DepartmentId= @DepartmentIDC)
			BEGIN

				UPDATE DepartmentWiseCostProvisions SET TotalCost=TotalCost + @TotalCostC WHERE BOQID=@BOQIDC AND DepartmentID=@DepartmentIDC AND CategoryId=@CategoryIdC

			END
			ELSE
			BEGIN

				INSERT INTO DepartmentWiseCostProvisions (BOQID,CategoryId,DepartmentId,Totalcost,balanceCost)
				VALUES(@BOQIDC,@CategoryIdC,@DepartmentIDC,@TotalCostC,0)

			END
			DELETE FROM #TempT WHERE Id=@IdC

		END


	END

	ELSE IF (@TransactionID = 64)
	BEGIN

		

		UPDATE ProjectWisePricesLogHeader SET Status='C',Approve=1 WHERE Id=@TransactionHeaderID


		

		UPDATE PWS SET  DefaultSupplier = PWLD.DefaultSupplier,PWS.Status='C'
		FROM [dbo].[ProjectWiseSupplierPrices] AS PWS 
		INNER JOIN ProjectWisePriceLogDetails AS PWLD 
		ON PWS.ProjectID = PWLD.ProjectID AND PWS.StocKItemID=PWLD.StockItemID

		UPDATE LG SET LG.SupplierID=PP.DefaultSupplier,LG.DefaultSupplier=PP.DefaultSupplier,LG.Price=PP.Price,LG.NetPrice=PP.NetPrice
		FROM ProjectWisePriceLogDetails AS LG INNER JOIN ProjectWiseSupplierPrices PP ON   LG.ProjectID = PP.ProjectID AND LG.StockItemID=PP.StockItemID
		WHERE LG.HeaderId =@TransactionHeaderID AND  PP.SupplierID=PP.DefaultSupplier

		

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

END 
ELSE IF (SELECT COUNT(*) FROM ApprovalLogs
	WHERE PropertyID=@PropertyID AND LocationID=@LocationID 
	AND TransactionHeaderID= @TransactionHeaderID AND TransactionID = @TransactionID 
	AND DocStatus ='X')>0
BEGIN

	IF @TransactionID=40
	BEGIN
		UPDATE  dbo.OrderHeaders
		SET isApproved=0 , DocumentStatus ='X'
		WHERE Id = @TransactionHeaderID 
	END
  
    
	IF @TransactionID=52
	BEGIN
		UPDATE dbo.BOQHeaders
		SET Approve = 0, BOQStatus = 'X'
		WHERE Id = @TransactionHeaderID
	END
	ELSE IF (@TransactionID = 64)
	BEGIN
		DECLARE @ProjectID INT;

		UPDATE ProjectWisePricesLogHeader SET Status='X',Approve=0 WHERE Id=@TransactionHeaderID

		SELECT @ProjectID = ProjectID FROM ProjectWisePricesLogHeader WHERE Id=@TransactionHeaderID

		UPDATE ProjectWiseSupplierPrices SET Status='X' WHERE ProjectID=@ProjectID

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

END

GO

