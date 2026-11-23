-- [dbo].[SP_RecallHeaderDetailsBOQ] 1
CREATE PROCEDURE [dbo].[SP_RecallHeaderDetailsBOQ]
	@headerID int
AS
BEGIN

	BEGIN TRY 
	
	SELECT RD.BalanceQTY as RequestedQuantity, 0 as UnitPrice,'' AS UnitName, SID.Name AS ItemName, RD.ItemID as StockItemID,0 as ApprovedQuantity,
	rd.id AS RequestDetailID, RD.Id
	FROM dbo.BOQAmedmentDetails AS RD 
	INNER JOIN dbo.StockItemHeaders AS SID ON RD.ItemID = SID.Id
	WHERE RD.BOQAMDheaderID = @headerID

	END TRY
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

   -- select * from [dbo].[BOQAmedmentDetails]

GO

