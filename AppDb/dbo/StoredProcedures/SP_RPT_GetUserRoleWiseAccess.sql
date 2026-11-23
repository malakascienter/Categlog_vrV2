CREATE PROCEDURE [dbo].[SP_RPT_GetUserRoleWiseAccess](@UserList VARCHAR(MAX))
AS
BEGIN


	SET @UserList  = REPLACE(@UserList, '[', '');
	SET @UserList  = REPLACE(@UserList, ']', '');

	SELECT VALUE INTO #TempUserGroupID FROM STRING_SPLIT(@UserList, ',');
		
	CREATE TABLE #SecurityList (
		FormID INT,
		ModuleID INT,
		CanView BIT,
	)

	INSERT INTO #SecurityList
	SELECT	AGP.FormID , AGP.ModuleID, AGP.DefaultInsertAccess DefaultViewAccess 
	FROM AutoGenerateGroupPrivileges AS AGP 
	INNER JOIN #TempUserGroupID T ON  T.value = AGP.UserGroupID
	WHERE  AGP.formID < 3000

	--select * from #SecurityList WHERE CanView  = 1
	SELECT DISTINCT U.UserGroupName,SM.modulename, AgI.FormName,CanView AS ViewAccess
	FROM #SecurityList s
	INNER JOIN AutoGenerateInfoes AgI ON s.FormID = AgI.FormId 
	INNER JOIN AutoGenerateGroupPrivileges AS AGP ON AGP.FormID = AGI.FormId
	INNER JOIN #TempUserGroupID T ON  T.value = AGP.UserGroupID
	INNER JOIN SystemModules SM ON SM.ModuleID = AGI.ModuleType
	INNER JOIN UserGroups U ON U.Id = T.value 
	--WHERE CanView  = 1

	

END

GO

