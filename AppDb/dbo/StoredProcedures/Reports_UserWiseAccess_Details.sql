  --[dbo].[Reports_UserWiseAccess_Details]1
CREATE PROCEDURE [dbo].[Reports_UserWiseAccess_Details]   
  @PropertyId INT
AS  
select U.UserName,UR.Name AS RoleName,A.Name AS AreaName,P.Name AS PageName,URWP.MainNavigationId,URWP.PageId,
URWP.IsAllowInsert,URWP.IsAllowUpdate,URWP.IsAllowDelete,URWP.IsAllowSelect
from UserRoleWisePages AS URWP
INNER JOIN userroles AS UR ON UR.Id=URWP.RoleId
INNER JOIN UserWiseRoles AS UWR ON UWR.RoleId=URWP.RoleId
INNER JOIN [dbo].[Admin_Nav_AreasWisePages] AS P ON P.Id=URWP.PageId
INNER JOIN [dbo].[Admin_Nav_MainNavigations] AS M ON M.Id=URWP.MainNavigationId
INNER JOIN [dbo].[Admin_Nav_MainNavigationWiseAreas] AS A ON A.Id=P.AreaId
INNER JOIN Users AS U ON U.Id=UWR.UserId
WHERE URWP.PropertyId=@PropertyId --and userId=77




--where UWA.propertyID=@PropertyId
--select  AP.AreaId , AP.ID PageID, AP.Name PageName, AP.IsActive PageActive, U.id USERID, U.Username Username, U.isactive UserActive  
--into #UserWisePages 
--from Admin_Nav_AreasWisePages AP ,Users  U 
--where AP.IsActive = 1 and u.propertyid=@propertyid
 
--select distinct UP.AreaId, A.Name AreaName ,UP.PageID, UP.PageName, UP.PageActive, UP.USERID, UP.Username, UP.UserActive,
--ISNULL(IsAllowDelete,0)IsAllowDelete, ISNULL(IsAllowInsert,0) IsAllowInsert , ISNULL(IsAllowSelect,0) IsAllowSelect , ISNULL(IsAllowUpdate,0) IsAllowUpdate 
--from #UserWisePages UP 
--left join UserRoleWisePages UR on  UP.PageID = UR.PageId 
--left join UserWiseRoles  UUR on UUR.UserId = UP.USERID  and uur.RoleId = UR.RoleId 
--left join Admin_Nav_MainNavigationWiseAreas A on A.Id = UP.AreaId 
----where UP.PageName = 'Guest Arrival - Alphabetically'
 
-- order by Username, AreaName, PageName

GO

