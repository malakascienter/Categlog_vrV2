-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 18 September 2023
-- Description:	Load Creditor Types
-- [dbo].[SP_LoadCreditorType]
-- =============================================
CREATE PROCEDURE [dbo].[SP_LoadCreditorType]
	
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
	SET NOCOUNT ON;

	SELECT ID, Name
	FROM    Destinity_AP_CreditorTypes
	WHERE   IsActive = 1
	
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

