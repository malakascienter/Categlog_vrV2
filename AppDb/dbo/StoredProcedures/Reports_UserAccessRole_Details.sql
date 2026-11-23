CREATE PROCEDURE [dbo].[Reports_UserAccessRole_Details]   
  @PropertyId INT
AS  
 
  
select  AP.AreaId , AP.ID PageID, AP.Name PageName, AP.IsActive PageActive, U.id RoleID, U.Name Rolename, U.isactive RoleActive,PropertyId  into #UserWisePages   
from Admin_Nav_AreasWisePages AP  
,UserRoles  U   
where AP.IsActive = 1  AND PropertyId=@PropertyId
   
select UP.AreaId, A.Name AreaName ,UP.PageID, UP.PageName, UP.PageActive, UP.RoleID, UP.Rolename, UP.RoleActive,  
ISNULL(IsAllowDelete,0)IsAllowDelete, ISNULL(IsAllowInsert,0) IsAllowInsert , ISNULL(IsAllowSelect,0) IsAllowSelect , ISNULL(IsAllowUpdate,0) IsAllowUpdate  from #UserWisePages UP   
left join UserRoleWisePages UR on up.RoleID = ur.RoleId  AND UP.PageID = UR.PageId  
inner join Admin_Nav_MainNavigationWiseAreas A on A.Id = UP.AreaId   AND A.IsActive=1
  
 
ORder by  Rolename  ,AreaName , PageName

GO

