
-- [dbo].[SelectAllGenericItems] 1
CREATE PROCEDURE [dbo].[SelectAllGenericItems] @PropertyId INT

AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY


	SELECT DISTINCT SH.Id, SH.StockItemCode, SH.Name FROM StockItemHeaders SH
	INNER JOIN StockItemDetails SD ON SH.Id = SD.StockItemHeaderID
	WHERE BrandedItem = 0 AND SH.CompanyId = @PropertyId AND SD.IsActive = 1

		
	-------------------------------------------------------------
				IF(@PropertyId = 0)
		BEGIN
			--SET @ErrorMsg2  =  'User ID Invalid, Please Log Again'
			--RAISERROR ( @ErrorMsg2, 16, 1 ); 
			RAISERROR('Error Occured : Property ID Invalid, Please Log In Again',16,1)
			ROLLBACK TRANSACTION
		END
	-------------------------------------------------------------

        COMMIT TRANSACTION;
    END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
	
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);

	END CATCH
	
	
END;

GO

