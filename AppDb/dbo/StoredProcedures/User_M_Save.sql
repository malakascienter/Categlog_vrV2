
-- =============================================  
-- Author:  Yasiru  
-- Create date: 2017-8-29  
-- Description:   
-- =============================================  
CREATE PROCEDURE [dbo].[User_M_Save]  
@Id INT,  
@Username NVARCHAR(20),   
@EmployeeId  INT = 1,  
@Password NVARCHAR(500),   
@Salt NVARCHAR(500),   
@IsActive BIT,   
@IsLocked BIT = 0,   
@UserId INT,
@UserRoleId INT,    
@Operation CHAR(1) ,
@IsPOSUser BIT,
@AccessCardNo VARCHAR(50),
@POSpassword NVARCHAR(MAX),
@PropertyId INT,
@IsPasswordChange BIT,
@IsViewAllOrders BIT,
@IsCashier BIT,
@MobileNumber NVARCHAR(15)
AS  
BEGIN  TRY

BEGIN TRANSACTION

	DECLARE @UserWiseRolesId BIGINT
	DECLARE @IsUserCreateAsWaiter BIT 
	SELECT @IsUserCreateAsWaiter = IsUserCreateAsWaiter FROM Companies WHERE CompanyID = @PropertyId



	IF( @IsPOSUser = 0 )
	BEGIN

		SET @AccessCardNo = ''
		SET @IsViewAllOrders = 0
		SET @IsCashier = 0
	END
	ELSE
	BEGIN
		IF( ISNULL(@AccessCardNo,'') = '' )
		BEGIN
		  RAISERROR('Please enter access card number.',16,1)  
		END	
	END


	SET NOCOUNT ON;  
	DECLARE @UserTableID INT	
	IF @Operation='I'  --Not use
		IF EXISTS (SELECT 1 FROM Users WHERE Username = @Username )  --AND PropertyId=@PropertyId
		BEGIN  
			RAISERROR('This username is already taken. Please choose another name.',16,1)  
		END  
		ELSE IF EXISTS (SELECT 1 FROM Users WHERE AccessCardNo = @AccessCardNo)  
		BEGIN  
			RAISERROR('This access card no  is already taken. Please choose another card no.',16,1)  
		END  
		ELSE  
		BEGIN  
			--SELECT @Id = MAX(Id)+1 FROM Users
			INSERT INTO [dbo].[Users]  
			([Id],[Username],[EmployeeId],[Password],[Salt],[IsActive] ,[UserRoleId], IsLocked,IsUpload,POSPassword,AccessCardNo,IsPOSUser, [CreatedUserId], [CreatedDateTime],PropertyId,IsViewAllOrders,IsCashier,MobileNumber)  
			VALUES(@Id,@Username,@EmployeeId,@Password,@Salt,@IsActive, @UserRoleId, @IsLocked,0,@POSpassword,@AccessCardNo,@IsPOSUser, @UserId, GETDATE(),@PropertyId,@IsViewAllOrders,@IsCashier,@MobileNumber)   

			-- Audit trail ----------------------------		
			EXEC HotelResWeb_AuditTail_WriteToLog 'Users',@Id,'POS','POSUUI','I',@UserId,'','','','','',@PropertyId
			-- End of Audit trail ---------------------
			
			
			SET @UserTableID=@Id
			INSERT INTO UserWiseRoles([UserId], [RoleId], [IsActive], [CreatedUserId], [CreatedDateTime], [PropertyId])
			VALUES (@UserTableID,@UserRoleId,@IsActive, @UserId, GETDATE(),@PropertyId)

		

			-- Audit trail ----------------------------		
			SET @UserWiseRolesId= SCOPE_IDENTITY()
			EXEC HotelResWeb_AuditTail_WriteToLog 'UserWiseRoles',@UserWiseRolesId,'POS','POSUWRI','I',@UserId,'','','','','',@PropertyId
			-- End of Audit trail ---------------------

			DELETE 
			FROM [POS_UserAccessTemp] 
			WHERE  UserId = @UserTableID --AND PropertyId = @PropertyId 

			INSERT INTO [dbo].[POS_UserAccessTemp](UserId, AccessCodeId, PropertyId, CreatedUserId, CreatedDateTime,IsUpload)
			SELECT @UserTableID, AccessCodeId, PropertyId, @UserId, GETDATE(), 0 
			FROM POS_UserRoleWiseAccess 
			WHERE UserRoleId = @UserRoleId --AND PropertyId = @PropertyId

			UPDATE	Users 
			SET		IsUpload = 0
			WHERE	Id = @UserRoleId --AND PropertyId = @PropertyId


			IF( @IsPOSUser = 1  AND @IsUserCreateAsWaiter = 1)
			BEGIN


				IF EXISTS( SELECT * FROM [Waiter] WHERE Code=@Username AND PropertyId=@PropertyId  )
				BEGIN
					EXEC [Waiter_M_Save] @Username,@Username,@AccessCardNo,@IsActive,'U',@PropertyId,@UserId,@IsViewAllOrders,@IsCashier
				END
				ELSE
				BEGIN
					EXEC [Waiter_M_Save] @Username,@Username,@AccessCardNo,@IsActive,'I',@PropertyId,@UserId,@IsViewAllOrders,@IsCashier
				END



			END



	END  
  
   
	ELSE IF @Operation='U'  
	BEGIN  

		IF EXISTS (SELECT 1 FROM Users WHERE Username != @Username AND AccessCardNo = @AccessCardNo)  
		BEGIN  
				RAISERROR('This access card no  is already taken. Please choose another card no.',16,1)  
		END  

		IF EXISTS (SELECT 1 FROM Users WHERE Username = @Username )  --AND PropertyId=@PropertyId
		BEGIN 
			IF @IsPasswordChange=1
			BEGIN

				-- Audit trail ----------------------------		
				SELECT @Id = Id FROM [Users] WHERE Username=  @Username
				EXEC HotelResWeb_AuditTail_WriteToLog 'Users',@Id,'POS','POSUUU','U',@UserId,'','','','','',@PropertyId
				-- End of Audit trail ---------------------

				UPDATE [dbo].[Users]   
				SET  
					Username   = @Username,   
					EmployeeId  =  @EmployeeId,  
					Password   =  @Password,   
					Salt  =  @Salt,  
					IsActive=   @IsActive,
					UserRoleId = @UserRoleId,  
					IsLocked =   @IsLocked,  
					LastEditedUserId= @UserId,   
					LastEditedDateTime= GETDATE(),
					PropertyId=@PropertyId,
					POSPassword=@POSpassword,
					AccessCardNo=@AccessCardNo,
					IsPOSUser=@IsPOSUser,
					IsUpload=0,
					IsViewAllOrders = @IsViewAllOrders,
					IsCashier = @IsCashier,
					MobileNumber = @MobileNumber
					WHERE Username=  @Username  --AND PropertyId=@PropertyId

					

			END
			ELSE
			BEGIN

			-- Audit trail ----------------------------		
			SELECT @Id = Id FROM [Users] WHERE Username=  @Username
			EXEC HotelResWeb_AuditTail_WriteToLog 'Users',@Id,'POS','POSUUU','U',@UserId,'','','','','',@PropertyId
			-- End of Audit trail ---------------------


			UPDATE [dbo].[Users]   
				SET 
					IsActive=   @IsActive,
					UserRoleId = @UserRoleId,  
					LastEditedUserId= @UserId,   
					LastEditedDateTime= GETDATE(),
					PropertyId=@PropertyId,
					AccessCardNo=@AccessCardNo,
					IsPOSUser=@IsPOSUser,
					IsUpload=0,
					IsViewAllOrders = @IsViewAllOrders,
					IsCashier = @IsCashier,
					MobileNumber = @MobileNumber
					WHERE Username=  @Username  --AND PropertyId=@PropertyId

					
			END

			-- Audit trail ----------------------------		
			SELECT @UserWiseRolesId = Id FROM UserWiseRoles WHERE UserId= @Id 
			EXEC HotelResWeb_AuditTail_WriteToLog 'UserWiseRoles',@UserWiseRolesId,'POS','POSUWRU','U',@UserId,'','','','','',@PropertyId
			-- End of Audit trail ---------------------

			UPDATE UserWiseRoles
			SET
			RoleId=@UserRoleId,
			IsActive=@IsActive,
			PropertyId=@PropertyId
			WHERE UserId= @Id  --AND PropertyId=@PropertyId

			SELECT @UserTableID = Id FROM Users WHERE Username = @Username --AND PropertyId=@PropertyId

			DELETE 
			FROM [POS_UserAccessTemp] 
			WHERE UserId = @UserTableID --AND PropertyId = @PropertyId

			INSERT INTO [dbo].[POS_UserAccessTemp](UserId, AccessCodeId, PropertyId, CreatedUserId, CreatedDateTime,IsUpload)
			SELECT @UserTableID, AccessCodeId, PropertyId, @UserId, GETDATE(), 0 
			FROM POS_UserRoleWiseAccess 
			WHERE UserRoleId = @UserRoleId --AND PropertyId = @PropertyId

			UPDATE	Users 
			SET		IsUpload = 0
			WHERE	Id = @UserTableID --AND PropertyId = @PropertyId

			IF( @IsPOSUser = 1 AND @IsUserCreateAsWaiter = 1)
			BEGIN


				IF EXISTS( SELECT * FROM [Waiter] WHERE Code=@Username AND PropertyId=@PropertyId  )
				BEGIN
					EXEC [Waiter_M_Save] @Username,@Username,@AccessCardNo,@IsActive,'U',@PropertyId,@UserId,@IsViewAllOrders,@IsCashier
				END
				ELSE
				BEGIN
					EXEC [Waiter_M_Save] @Username,@Username,@AccessCardNo,@IsActive,'I',@PropertyId,@UserId,@IsViewAllOrders,@IsCashier
				END



			END

		
	END   
	ELSE  
	BEGIN  
			--SELECT @Id = MAX(Id)+1 FROM Users
			--RAISERROR('No record exists.',16,1)  
			INSERT INTO [dbo].[Users]  
			([Id],[Username],[EmployeeId],[Password],[Salt],[IsActive] ,[UserRoleId], IsLocked,IsUpload,POSPassword,AccessCardNo,IsPOSUser, [CreatedUserId], [CreatedDateTime],PropertyId,IsViewAllOrders,IsCashier,MobileNumber)  
			VALUES(@Id,@Username,@EmployeeId,@Password,@Salt,@IsActive, @UserRoleId, @IsLocked,0,@POSpassword,@AccessCardNo,@IsPOSUser, @UserId, GETDATE(),@PropertyId,@IsViewAllOrders,@IsCashier,@MobileNumber)   
			
			-- Audit trail ----------------------------		
			EXEC HotelResWeb_AuditTail_WriteToLog 'Users',@Id,'POS','POSUUI','I',@UserId,'','','','','',@PropertyId
			-- End of Audit trail ---------------------
			
			SET @UserTableID=@Id
			INSERT INTO UserWiseRoles([UserId], [RoleId], [IsActive], [CreatedUserId], [CreatedDateTime], [PropertyId])
			VALUES (@UserTableID,@UserRoleId,@IsActive, @UserId, GETDATE(),@PropertyId)


			-- Audit trail ----------------------------		
			SET @UserWiseRolesId= SCOPE_IDENTITY()
			EXEC HotelResWeb_AuditTail_WriteToLog 'UserWiseRoles',@UserWiseRolesId,'POS','POSUWRI','I',@UserId,'','','','','',@PropertyId
			-- End of Audit trail ---------------------
			

			DELETE 
			FROM [POS_UserAccessTemp] 
			WHERE   UserId = @UserTableID --AND PropertyId = @PropertyId

			INSERT INTO [dbo].[POS_UserAccessTemp](UserId, AccessCodeId, PropertyId, CreatedUserId, CreatedDateTime,IsUpload)
			SELECT @UserTableID, AccessCodeId, PropertyId, @UserId, GETDATE(), 0 
			FROM POS_UserRoleWiseAccess 
			WHERE UserRoleId = @UserRoleId --AND PropertyId = @PropertyId

			UPDATE	Users 
			SET		IsUpload = 0
			WHERE	Id = @UserTableID --AND PropertyId = @PropertyId

			IF( @IsPOSUser = 1  AND @IsUserCreateAsWaiter = 1  )
			BEGIN


				IF EXISTS( SELECT * FROM [Waiter] WHERE Code=@Username AND PropertyId=@PropertyId  )
				BEGIN
					EXEC [Waiter_M_Save] @Username,@Username,@AccessCardNo,@IsActive,'U',@PropertyId,@UserId,@IsViewAllOrders,@IsCashier
				END
				ELSE
				BEGIN
					EXEC [Waiter_M_Save] @Username,@Username,@AccessCardNo,@IsActive,'I',@PropertyId,@UserId,@IsViewAllOrders,@IsCashier
				END



			END

	END  
	END  
	ELSE  
	BEGIN  
		RAISERROR('Invalid operation',16,1)  
	END  

  DECLARE @UserTableIDStr VARCHAR(50) = CONVERT(VARCHAR(50),@UserTableID)
  EXEC Insert_Sync_MasterDataTransferStatus 'User',@IsActive,@UserTableIDStr,@PropertyId

COMMIT TRANSACTION

END TRY 
BEGIN CATCH

ROLLBACK TRANSACTION

	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())

	DECLARE  @ERRmsg VARCHAR(MAX) =ERROR_MESSAGE()
	RAISERROR(@ERRmsg,16,1)
END CATCH

GO

