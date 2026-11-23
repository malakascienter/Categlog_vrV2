
--[dbo].[SP_S_GetGroupPermissionForUser] 1
CREATE PROCEDURE [dbo].[SP_S_GetGroupPermissionForUser] @UserID INT
AS
BEGIN

    CREATE TABLE #SecurityList
    (
        FromID INT,
        ModuleID INT,
        CanView BIT,
        CanInsert BIT,
        CanModify BIT,
        CanDelete BIT,
        CanPrint BIT
    );

    DECLARE @GroupID INT;
    SET @GroupID = 0;

    SELECT @GroupID = UserGroupID
    FROM UserMasters
    WHERE Id = @UserID;
    --select @GroupID

    IF (@GroupID > 0)
    BEGIN
        --Extract Group Permission Set from Relevent Group that user belongs to
        INSERT INTO #SecurityList
        SELECT AGP.FormID,
               AGP.ModuleID,
               AGP.DefaultViewAccess,
               AGP.DefaultInsertAccess,
               AGP.DefaultModifyAccess,
               AGP.DefaultDeleteAccess,
               AGP.DefaultPrintAccess
        FROM AutoGenerateGroupPrivileges AS AGP
        WHERE AGP.UserGroupID = @GroupID;

        SELECT FromID AS FormId,
               AutoGenerateInfoes.FormName,
               CanView AS ViewAccess,
               CanInsert AS InsertAccess,
               CanModify AS UpdateAccess,
               CanDelete AS DeleteAccess,
               CanPrint AS PrintAccess,
               0 AS OverridedDefault,
               0 AS RwUpdated
        FROM #SecurityList
            INNER JOIN AutoGenerateInfoes
                ON #SecurityList.FromID = AutoGenerateInfoes.FormId;
    END;
    ELSE
    BEGIN
        RAISERROR('Given User not belong to any User Group', 16, 1);
    END;
--update AutoGenerateUserPrivileges set IsViewAccess =0 where usermasterid =1

END;

GO

