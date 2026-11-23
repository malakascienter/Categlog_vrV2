-- =============================================
-- Author:		Dilshan
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[POSRoleWiseAccessCode_M_Save]
	@AccessCodes NVARCHAR(MAX),
	@PropertyId INT,
	@RoleId INT,
	@UserId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	SELECT * 
	INTO #TempAccess	
	FROM OPENJSON(@AccessCodes,N'$.AccessCodeLst')  
	WITH 
	(	
		AccessCodeId	INT		'$.AccessCodeId'
		
	) 

	DELETE 
	FROM [POS_UserRoleWiseAccess] 
	WHERE PropertyId = @PropertyId AND UserRoleId = @RoleId

    INSERT INTO [dbo].[POS_UserRoleWiseAccess](UserRoleId, AccessCodeId, PropertyId, CreatedUserId, CreatedDateTime,IsUpload)
	SELECT @RoleId, AccessCodeId, @PropertyId, @UserId, GETDATE(), 0 
	FROM #TempAccess

	DELETE 
	FROM [POS_UserAccessTemp] 
	WHERE PropertyId = @PropertyId AND UserId IN (SELECT Id FROM Users WHERE UserRoleId = @RoleId)

	INSERT INTO [dbo].[POS_UserAccessTemp](UserId, AccessCodeId, PropertyId, CreatedUserId, CreatedDateTime,IsUpload)
	SELECT U.Id, A.AccessCodeId, A.PropertyId, @UserId, GETDATE(), 0 
	FROM POS_UserRoleWiseAccess A INNER JOIN Users U ON A.UserRoleId = U.UserRoleId
	WHERE A.UserRoleId = @RoleId AND A.PropertyId = @PropertyId


	UPDATE R 
	SET R.IsUpload = 0
	FROM dbo.Users AS R
	--INNER JOIN dbo.UserWiseRoles AS P 
    --ON R.Id = P.UserId
	WHERE R.UserRoleId = @RoleId

END

GO

