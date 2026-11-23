-- =============================================
-- Author:		Nivesh
-- Create date: 2024-09-30
-- Description:	Check Exsistion of Budget Allocation
-- =============================================
--SP_CheckBudgetAllocationForLocation 1
CREATE PROCEDURE [dbo].[SP_CheckBudgetAllocationForLocation]
@LocationID INT
AS
BEGIN

	BEGIN TRY 
		SET NOCOUNT ON;
		IF EXISTS (SELECT 1 FROM BudgetAllocation WHERE LocationID = @LocationID)
		BEGIN
			SELECT 1
		END
		ELSE
		BEGIN
			SELECT 0
		END

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

