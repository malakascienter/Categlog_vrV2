

--SP_S_LoadUserWiseSecurity 1
CREATE PROCEDURE SP_S_LoadUserWiseSecurity @UserId INT
AS 

BEGIN
DECLARE @GroupID INT
SELECT @GroupID=UserGroupID FROM dbo.UserMasters
select FormId AS FormId,DefaultViewAccess AS ViewAccess,DefaultInsertAccess AS InsertAccess,DefaultModifyAccess AS UpdateAccess,DefaultDeleteAccess AS DeleteAccess,DefaultPrintAccess AS PrintAccess,0 AS OverridedDefault from AutoGenerateGroupPrivileges WHERE UserGroupID=@GroupID
END

GO

