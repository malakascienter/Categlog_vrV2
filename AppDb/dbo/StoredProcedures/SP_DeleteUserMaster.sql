

CREATE PROCEDURE [SP_DeleteUserMaster] 
	@UserName varchar(max)
AS
BEGIN
	--DECLARE  
	--@UserName varchar(max)

	UPDATE UserMasters SET IsDelete = 1 WHERE UserName = @UserName

END

GO

