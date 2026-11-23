
--SP_S_LoadMenus 1
CREATE PROCEDURE [dbo].[SP_S_LoadMenus] 
@UserId INT
AS 

BEGIN
DECLARE @GroupID INT
SELECT @GroupID=UserGroupID FROM dbo.UserMasters
select SM.MainModuleId  , SM.SubModuleId, SMO.Name AS ParentName , SML1.Name AS SubModuleLName,  AGP.FormId  AS FormId, AGP.DefaultViewAccess AS CanView   from AutoGenerateGroupPrivileges AGP
INNER JOIN SystemMenues SM ON  AGP.FormId=SM.FormId
INNER JOIN SubModulesL1 SML1 ON SM.SubModuleId=SML1.SubModulesId
INNeR JOIN SystemModules SSM ON SSM.Id=SML1.ParentModuleId
INNER JOIN SubModules SMO ON SMO.Id=SML1.SubModulesId



  
 WHERE UserGroupID=@GroupID 
END

GO

