-- =============================================
-- Author:		Nivesh
-- Create date: 2024-08-26
-- Description:	Get locationwise budjet
-- =============================================
-- SP_GetLocationwiseBudget 1

CREATE PROCEDURE [dbo].[SP_GetLocationwiseBudget]
	@PropertyId INT
AS
BEGIN
    BEGIN TRY
    SET NOCOUNT ON;
	
	SELECT B.*,L.Name LocationName FROM
	BudgetAllocation B
	INNER JOIN Locations L ON L.Id = B.LocationID
	WHERE B.PropertyID = @PropertyId
	
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
        ROLLBACK TRANSACTION;
        
    END CATCH
END

GO

