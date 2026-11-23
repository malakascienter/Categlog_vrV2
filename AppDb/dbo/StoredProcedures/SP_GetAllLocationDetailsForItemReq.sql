CREATE PROCEDURE [dbo].[SP_GetAllLocationDetailsForItemReq](@Propertyid INT)

AS
BEGIN

    BEGIN TRANSACTION;

    BEGIN TRY

		SELECT  * FROM  Locations WHERE Locations.companyid  = @Propertyid AND IsActive = 1 AND DefaultLocation = 1

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

