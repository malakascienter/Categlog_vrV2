--[dbo].[SP_RPT_GetUserWiseAccess] 1
--go
CREATE PROCEDURE [dbo].[SP_RPT_GetUserWiseAccess](@UserList VARCHAR(MAX))
AS
BEGIN

	drop table UserList
	SELECT @UserList UserList
	into UserList

	--SET @UserList = '[62,1,64,21,84]'

	SET @UserList  = REPLACE(@UserList, '[', '');
	SET @UserList  = REPLACE(@UserList, ']', '');

	SELECT VALUE INTO #TempUserID FROM STRING_SPLIT(@UserList, ',');

	SELECT UM.UserGroupID, UM.Id INTO #TempGroup FROM usermasters UM
	INNER JOIN #TempUserID TT ON TT.value =  UM.Id

	CREATE TABLE #SecurityList (
		FromID INT,
		ModuleID INT,
		CanView BIT,
		CanInsert BIT,
		CanModify BIT,
		CanDelete BIT,
		CanPrint BIT,
		UserName VARCHAR(500)
	)

	INSERT INTO #SecurityList
	SELECT AGP.FormID , AGP.ModuleID, AGP.DefaultViewAccess, AGP.DefaultInsertAccess,AGP.DefaultModifyAccess,
	AGP.DefaultDeleteAccess , AGP.DefaultPrintAccess , U.UserName
	FROM AutoGenerateGroupPrivileges AS AGP 
	INNER JOIN #TempGroup TG ON TG.UserGroupID = AGP.UserGroupID
	INNER JOIN UserMasters U ON U.Id = TG.Id

	UPDATE SL SET 
	SL.CanView = AUP.IsViewAccess,
	SL.CanInsert = AUP.IsInsertAccess,
	SL.CanModify = AUP.IsModifyAccess,
	SL.CanDelete = AUP.IsDeleteAccess,
	SL.CanPrint = AUP.IsPrintAccess
	FROM #SecurityList AS SL 
	INNER JOIN AutoGenerateUserPrivileges AS AUP
	ON SL.FromID = AUP.FormID 
	INNER JOIN #TempUserID TU ON TU.value = AUP.UserMasterId 

	--SELECT M.FormName,U.UserName, S.ModuleName,AP.DefaultViewAccess AS DefaultInsertAccess 

	SELECT  AutoGenerateInfoes.FormName,CanInsert AS DefaultInsertAccess , UserName
	FROM #SecurityList INNER JOIN AutoGenerateInfoes ON #SecurityList.FromID = AutoGenerateInfoes.FormId


END

GO

