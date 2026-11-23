-- =============================================
-- Author:      Nivesh
-- Create date: 2023.09.18
-- Description: Delete Subcontractors
-- =============================================
CREATE PROCEDURE [dbo].[SP_DeleteSubContractors] 
(
    @ID INT,
    @UserID INT
)
AS
BEGIN
    BEGIN TRY
        -- Start a transaction
        BEGIN TRANSACTION;

        -- Ensure the record exists and belongs to the specified user
        IF EXISTS (SELECT 1 FROM SubContractors WHERE ID = @ID AND CreatedUserID = @UserID)
        BEGIN
            -- Delete the record
			EXEC Inventry_AuditTail_WriteToLog 'SubContractors', @ID, 'INV', 'SBCD', 'D', @UserID,0, '', ''
            DELETE FROM SubContractors WHERE ID = @ID AND CreatedUserID = @UserID;
        END
        ELSE
        BEGIN
         Raiserror('Record not found or does not belong to the specified user' , 16,1)
            --THROW 51000, 'Record not found or does not belong to the specified user.', 1;
        END

        -- Commit the transaction if everything is successful
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
	
END

GO

