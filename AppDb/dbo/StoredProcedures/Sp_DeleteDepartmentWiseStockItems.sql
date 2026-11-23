
CREATE PROCEDURE [dbo].[Sp_DeleteDepartmentWiseStockItems](@DeptId INT, @StockItemId INT,@UserID INT=1)
AS
BEGIN
	BEGIN TRY

		DECLARE @ItemName VARCHAR(350),@DeptName VARCHAR(350), @Name VARCHAR(350), @TempLogDeWiIt int

		SELECT @ItemName = Name FROM StockItemHeaders WHERE Id =  @StockItemId
		SELECT @DeptName = Name FROM Departments WHERE Id =  @DeptId

		SET @Name = @DeptName +'/'+ @ItemName 

		EXEC InsertMasterFileChangeLog 'Department Wise Items',@UserID,'D',@Name
		------------------------------------Log DepartmentWiseItems Delete 2024-02-26-------------------------------------------
		IF EXISTS (SELECT 1 FROM DepartmentWiseItems WHERE DepartmentId = @DeptId AND StockItemId = @StockItemId )
		BEGIN
			SELECT @TempLogDeWiIt = ID FROM DepartmentWiseItems WHERE DepartmentId = @DeptId AND StockItemId = @StockItemId
			EXEC Inventry_AuditTail_WriteToLog 'DepartmentWiseItems', @TempLogDeWiIt, 'INV', 'DWID', 'D', @UserID,0, '', ''
		END
		-------------------------------------------------------------------------------
		DELETE FROM DepartmentWiseItems WHERE DepartmentId = @DeptId AND StockItemId = @StockItemId
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
   END CATCH
END

GO

