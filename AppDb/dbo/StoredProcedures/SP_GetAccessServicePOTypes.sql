-- =============================================
-- Author:		Nivesh
-- Create date: 2024-06-04
-- Description:	Get Access Service PO Types
-- =============================================
-- SP_GetAccessServicePOTypes 1,6
CREATE PROCEDURE [dbo].[SP_GetAccessServicePOTypes]
	@PropertyID INT,
	@LocationID INT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY 

		--SELECT 1
		--FROM Locations WHERE PropertyId = @PropertyID
		--AND ApplyDailyMarketProcess = 1 AND DailyMarketDepartment IS NOT NULL
		--AND Id = @LocationID;

		SELECT CASE WHEN EXISTS (SELECT 1
		FROM Locations WHERE PropertyId = @PropertyID
		AND ApplyDailyMarketProcess = 1 AND DailyMarketDepartment IS NOT NULL
		AND Id = @LocationID) THEN 1 ELSE 1 END

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT>0
		ROLLBACK TRANSACTION
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

