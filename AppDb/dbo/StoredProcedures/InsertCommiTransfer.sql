-- [dbo].[InsertCommiTransfer] 1148

CREATE PROCEDURE [dbo].[InsertCommiTransfer]
	@Id INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
	
		DECLARE @sErrorMessage VARCHAR(500),@HeaderId INT,@IsAutoProduction BIT,@PropertyID INT,@RequestedDate DATE, @IsSPOBased BIT, @SPOId INT;
		DECLARE @CommiTransferIDs TABLE (
			ID INT,
			TxnDate DATE,
			DeliveryScheduleID int
		);

		SELECT @PropertyID = PropertyID,@RequestedDate = RequestedDate, @IsSPOBased = IsSPOBased, @SPOId=SPOId
		FROM CommiRequestHeader
		WHERE ID = @Id;

		
		--Added by Isuru 2025-09-08
		SELECT @IsAutoProduction =ISNULL(IsAutoProduction,0)
		FROM Companies
		WHERE CompanyID = @PropertyID

		INSERT INTO CommiTransferHeader (ProductionLocationID, RequestedLocationID, TxnNo, TxnDate,UserID, DeliveryScheduleID, IsApproved, Status,Remarks,ReferenceID, IsSPOBased, SPOId)
		OUTPUT INSERTED.ID, INSERTED.TxnDate, inserted.DeliveryScheduleID INTO @CommiTransferIDs (ID, TxnDate,DeliveryScheduleID)
		SELECT	
			crh.ProductionLocationID, 
			crh.RequestedLocationID,
			CAST(NEWID() AS VARCHAR(50)) AS TxnNo,
			--CASE WHEN @IsAutoProduction = 1 THEN crd.RequestedDate ELSE @RequestedDate END,
			@RequestedDate,
			crh.UserID,
			CASE WHEN @IsAutoProduction = 1 THEN crd.DeliveryScheduleID ELSE 1 END,
			0 AS IsApproved,
			'P' AS Status
			,CRH.Remarks
			,@Id
			,@IsSPOBased
			,@SPOId
		FROM CommiRequestHeader crh
		INNER JOIN CommiRequestDetails crd ON crh.ID = crd.HeaderID
		WHERE crd.HeaderID = @Id AND crd.Status ='A'
		GROUP BY 
			crh.ProductionLocationID,
			crh.RequestedLocationID, 
			crh.TaxnDate, 
			crd.RequestedDate, 
			crd.DeliveryScheduleID,
			crh.UserID
			,CRH.Remarks;

		SET @HeaderId = SCOPE_IDENTITY()
   
		INSERT INTO CommiTransferDetail (CTHeaderID, ItemID, UnitID, ApprovedQTY, TransferredQTY, BalanceQTY, Status)
		SELECT 
			ph.ID,
			crd.StockItemID AS ItemID,
			crd.UnitID,
			crd.ApprovedQTY,
			crd.ApprovedQTY AS TransferredQTY,  -- Initially produced quantity is zero
			crd.RequestedQTY AS BalanceQTY,
			'P' AS Status
		FROM 
			CommiRequestDetails crd
		INNER JOIN 
			CommiRequestHeader crh ON crd.HeaderID = crh.ID
		INNER JOIN 
			@CommiTransferIDs ph ON crd.RequestedDate = ph.TxnDate and crd.DeliveryScheduleID = ph.DeliveryScheduleID 
		WHERE 
			crd.HeaderID = @Id AND crd.Status ='A'


		
		--ADDED BY Isuru 2025-09-08 
		WHILE EXISTS (SELECT DISTINCT ID FROM @CommiTransferIDs)
		BEGIN
			SELECT DISTINCT TOP 1 @HeaderID = ID 
			FROM @CommiTransferIDs;
    
			EXEC [dbo].[SP_InsertTransferRequestCommi] @HeaderId
    
			DELETE FROM @CommiTransferIDs WHERE ID = @HeaderID;
		END
		--End

			
		
		

		 -- Update the Status of CommiRequestHeader and capture the updated IDs
		DECLARE @CommiRequestIDs TABLE (
			ID INT
		); 

		UPDATE CommiRequestHeader 
		SET Status = 'T' 
		OUTPUT INSERTED.ID INTO @CommiRequestIDs (ID)
		WHERE Status = 'P' AND IsApproved = 1;

		-- Update the Status of CommiRequestDetails using the IDs from @CommiRequestIDs
		UPDATE crd
		SET crd.Status = 'T'
		FROM CommiRequestDetails crd
		INNER JOIN @CommiRequestIDs crh ON crd.HeaderID = crh.ID;

       	COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- If an error occurs, roll back the transaction and raise an error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @sErrorMessage = ERROR_MESSAGE();
        RAISERROR (@sErrorMessage, 16, 1);
    END CATCH;
END;

GO

