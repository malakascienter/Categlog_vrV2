-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2023-12-06
-- Description:	Save UserRole wise POS Access

-- RT_SaveUserRoleWisePOSAccess 
-- =============================================
CREATE PROCEDURE [dbo].[RT_SaveUserRoleWisePOSAccess]
	@XMLData AS XML
AS

	DECLARE @iDocID INT 
	 DECLARE @ErrorMsg VARCHAR(300)
BEGIN
BEGIN TRY
    BEGIN TRANSACTION
	EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLData;
	SET NOCOUNT ON;

	DECLARE @UserGroupID INT, @PropertyId INT,@UserID INT

		SELECT  *
		INTO    #TempPOSAccess
		FROM    OPENXML (@iDocID,'ArrayOfPOSAccessCode/POSAccessCode',2)	
		WITH (Id int,UserGroupID INT,PropertyId INT,UserID INT ,AccessCode VARCHAR(MAX) ,DisplayName VARCHAR(MAX),IsCheck BIT)

		SELECT TOP(1) @UserGroupID=UserGroupID ,@PropertyId = PropertyId,@UserID =UserID
		FROM #TempPOSAccess

		DELETE FROM RT_POS_UserRoleWiseAccess
		WHERE PropertyId=@PropertyId AND UserRoleId=@UserGroupID

		INSERT INTO RT_POS_UserRoleWiseAccess(UserRoleId, AccessCodeId, PropertyId, CreatedUserId, CreatedDateTime, UpdatedUserId, UpdatedDateTime, IsUpload)
		SELECT UserGroupID,Id,PropertyId,UserID,GETDATE(),UserID,GETDATE(),0
		FROM #TempPOSAccess
		WHERE IsCheck =1

		DELETE 
		FROM [RT_POS_UserAccessTemp] 
		WHERE PropertyId = @PropertyId AND UserId IN (SELECT Id FROM UserMasters WHERE UserGroupID = @UserGroupID)

		INSERT INTO [dbo].[RT_POS_UserAccessTemp](UserId, AccessCodeId, PropertyId, CreatedUserId, CreatedDateTime,IsUpload)
		SELECT U.Id, A.AccessCodeId, A.PropertyId, @UserID, GETDATE(), 0 
		FROM RT_POS_UserRoleWiseAccess A INNER JOIN UserMasters U ON A.UserRoleId = U.UserGroupID
		WHERE A.UserRoleId = @UserGroupID AND A.PropertyId = @PropertyId

		SELECT 1
				
		DROP TABLE #TempPOSAccess
			
     COMMIT TRAN  --Transaction Success!
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


    END CATCH;



END

GO

