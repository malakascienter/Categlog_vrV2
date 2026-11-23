
-- [dbo].[InsertProductionRequest] '12'
CREATE PROCEDURE [dbo].[InsertProductionRequest]
  @ID INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
		DECLARE @ProductionHeaderIDs TABLE (
			ID INT,
			ProductionDate DATE,
			DeliveryScheduleID int
		);
		DECLARE @sErrorMessage VARCHAR(500);

		-- Insert into ProductionRequestHeader table, grouping by RequestedDate
		INSERT INTO ProductionRequestHeader (ProductionLocationID, ProductionDate, TxnNo,TxnDate,UserID,DeliveryScheduleID, IsApproved, Status)
		OUTPUT INSERTED.ID, INSERTED.ProductionDate, inserted.DeliveryScheduleID INTO @ProductionHeaderIDs (ID, ProductionDate,DeliveryScheduleID)
		SELECT 
			crh.ProductionLocationID, 
			crh.RequestedDate AS ProductionDate,
			CAST(NEWID() AS VARCHAR(50)) AS TxnNo,  -- Generating a new transaction number
			crd.RequestedDate,
			crh.UserID,
			crd.DeliveryScheduleID,
			0 AS IsApproved,
			'P' AS Status
		FROM 
			CommiRequestHeader crh
		INNER JOIN 
			CommiRequestDetails crd ON crh.ID = crd.HeaderID
		WHERE 
			crd.HeaderID=@ID AND crd.Status = 'A'
		GROUP BY 
			crh.ProductionLocationID, 
			crd.RequestedDate, 
			crd.DeliveryScheduleID,
			crh.RequestedDate,
			crh.UserID;

		-- Insert into ProductionRequestDetails table
		INSERT INTO ProductionRequestDetails (PRHeaderID, ItemID, UnitID, ApprovedQTY, AdjustedQty, ProducedQTY, BalanceQTY, Status)
		SELECT 
			ph.ID,
			crd.StockItemID AS ItemID,
			crd.UnitID,
			crd.ApprovedQTY,
			crd.AdjustedQty,
			0 AS ProducedQTY,
			crd.RequestedQTY AS BalanceQTY,
			'P' AS Status
		FROM 
			CommiRequestDetails crd
		INNER JOIN 
			CommiRequestHeader crh ON crd.HeaderID = crh.ID
		INNER JOIN 
			@ProductionHeaderIDs ph ON crd.RequestedDate = ph.ProductionDate and crd.DeliveryScheduleID = ph.DeliveryScheduleID 
		WHERE 
			crd.HeaderID=@ID AND crd.Status = 'A';

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

