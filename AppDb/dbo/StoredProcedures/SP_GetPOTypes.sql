-- =============================================
-- Author:		Nivesh
-- Create date: 2024-06-04
-- Description:	Get PO Types
-- =============================================
-- SP_GetPOTypes 2
CREATE PROCEDURE SP_GetPOTypes
	@PropertyID INT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY 
		SELECT Id,Name,IsActive FROM PoTypesNew
		
		WHERE isActive=1 --and (case when exists (select 1 from Companies where CompanyID =@PropertyID and isPOType =1) then 1 else 0 end) = 1 
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

