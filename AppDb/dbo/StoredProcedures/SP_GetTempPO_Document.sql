-- =============================================
-- Author:		Nivesh
-- Create date: 2024-10-07
-- Description:	Get Temp PO
-- =============================================
-- SP_GetTempPO_Document 1,1,1

CREATE PROCEDURE SP_GetTempPO_Document
	@PropertyID INT,
	@LocationID INT,
	@SupplierID INT
AS
BEGIN

	SET NOCOUNT ON;

	BEGIN TRY 
		SELECT Id, PoNo, DocumentStatus 
		FROM PoHeaders_Temp 
		WHERE PropertyID = @PropertyID AND LocationID = @LocationID AND SupplierID = @SupplierID
		AND documentstatus = 'P'

	END TRY
	BEGIN CATCH
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

