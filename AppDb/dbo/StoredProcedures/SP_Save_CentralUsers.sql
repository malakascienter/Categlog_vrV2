-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2023-12-07
-- Description:	Inserting Central Users for POS 

-- [dbo].[SP_Save_CentralUsers] '<CentralUsersView xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><Id>0</Id><GroupID>61</GroupID><UserGroupName>18TH JAN</UserGroupName><UserProfileID>4168</UserProfileID><IsPOSUser>false</IsPOSUser></CentralUsersView>'

-- =============================================
CREATE PROCEDURE [dbo].[SP_Save_CentralUsers]
	@XMLData AS XML
AS
	 
	 DECLARE @iDocID INT 
	 DECLARE @ErrorMsg VARCHAR(300)
	 DECLARE @InvoiceError VARCHAR(350)
BEGIN
BEGIN TRY
        BEGIN TRANSACTION
		 EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLData;
	SET NOCOUNT ON;

	DECLARE @UserID INT,@UserGroupID INT,@CreatedUserID INT

	SELECT  *
	INTO    #TempCentralUsersSave
	FROM    OPENXML (@iDocID,'CentralUsersView',2)	
	WITH (Id int,GroupID INT,UserGroupName VARCHAR(50),UserName VARCHAR(50) ,FullName VARCHAR(50) ,EmpNumber VARCHAR(50),UserProfileID INT,IsPOSUser BIT,AccessCard VARCHAR(50))


	IF NOT EXISTS (SELECT (1) FROM #TempCentralUsersSave )
	BEGIN
	SET @InvoiceError =  'Insert Fail!'
	RAISERROR ( @InvoiceError, 16, 1 );  
	ROLLBACK TRANSACTION
	END 

		SELECT  @UserID = Id,@UserGroupID=GroupID,@CreatedUserID=UserProfileID
		FROM  #TempCentralUsersSave
		PRINT CONCAT('test', @CreatedUserID);

		IF(@CreatedUserID = 0)
		BEGIN
			--SET @ErrorMsg2  =  'User ID Invalid, Please Log Again'
			--RAISERROR ( @ErrorMsg2, 16, 1 ); 
			RAISERROR('User ID Invalid, Please Log In Again',16,1)
			ROLLBACK TRANSACTION
		END

		IF EXISTS(SELECT 1 FROM UserMasters WHERE Id = @UserID)
		BEGIN
		DELETE FROM UserMasters WHERE Id = @UserID

		END


		INSERT  INTO UserMasters(Id, CompanyID, LocationID, UserName, UserDescription, Email, Password, UserGroupID, IsActive, IsUserCantChangePassword, IsUserMustChangePassword, IsDelete, EmployeeId, IPAddress, CreatedUserID, 
                         LastModUserID, CreatedDate, LastModDate, FirstName, LastName, IsPOSUser, AccessCard)
		SELECT Id,0,0,UserName,UserName,NULL,NULL,GroupID,1,1,0,0,0,'192.168.1.0',UserProfileID,UserProfileID,GETDATE(),GETDATE(),FullName,NULL,IsPOSUser,AccessCard
		FROM #TempCentralUsersSave



		select @UserID,@UserGroupID

		SELECT @UserID, AccessCodeId, PropertyId, @CreatedUserID, GETDATE(), 0 
			FROM RT_POS_UserRoleWiseAccess 
			WHERE UserRoleId = @UserGroupID --AND PropertyId = @PropertyId

			DELETE 
			FROM [RT_POS_UserAccessTemp] 
			WHERE  UserId = @UserID --AND PropertyId = @PropertyId 

			INSERT INTO [dbo].[RT_POS_UserAccessTemp](UserId, AccessCodeId, PropertyId, CreatedUserId, CreatedDateTime,IsUpload)
			SELECT @UserID, AccessCodeId, PropertyId, @CreatedUserID, GETDATE(), 0 
			FROM RT_POS_UserRoleWiseAccess 
			WHERE UserRoleId = @UserGroupID --AND PropertyId = @PropertyId

	DECLARE @PropertyID INT
	SELECT CompanyID INTO #TempCompany FROM Companies where IsActive = 1 AND IsRetail = 1
	WHILE EXISTS( SELECT * FROM #TempCompany )
	BEGIN
	
	SELECT TOP(1) @PropertyID = CompanyID FROM #TempCompany
	
			Declare @LocationJson VARCHAR(MAX)
			SET @LocationJson = (SELECT  Id AS LocationID FROM Locations WHERE IsActive = 1 AND CompanyID = @PropertyID and IsSalesLocation = 1 FOR JSON PATH,INCLUDE_NULL_VALUES)
			EXEC RT_SYNC_DATA_INSERT @PropertyID,@UserID,'0','User',1,0,@LocationJson
	
	DELETE TOP(1) FROM #TempCompany
	
	END



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

