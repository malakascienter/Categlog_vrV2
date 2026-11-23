
CREATE PROCEDURE SP_S_InitializeUserPrivilages
	@TemplateID int,
	@UserID int

AS
BEGIN

if exists(select * from AutoGenerateUserPrivileges as A where  A.UserMasterId = @UserID)
begin
	delete from AutoGenerateUserPrivileges  where  UserMasterId = @UserID 
end


INSERT INTO [dbo].[AutoGenerateUserPrivileges]
           ([UserMasterId]
           ,[AutoGenerateID]
           ,[HasBrekdown]
           ,[FormID]
           ,[ModuleID]
           ,[IsViewAccess]
           ,[IsInsertAccess]
           ,[IsModifyAccess]
           ,[IsDeleteAccess]
           ,[IsPrintAccess]
           ,[IPAddress]
           ,[CreatedUserID]
           ,[LastModUserID]
           ,[CreatedDate]
           ,[LastModDate])




select UG.id, AGT.id,0,AGT.FormID ,AGT.ModuleID, DefaultViewAccess,DefaultInsertAccess,DefaultModifyAccess,DefaultDeleteAccess,	DefaultPrintAccess,'192.168.1.120' , 1,1,GETDATE(),GETDATE()
from AutoGenerateTemplates as AGT cross join
UserMasters as UG 
where templatebaseid =@TemplateID and UG.Id = @UserID


select * from AutoGenerateUserPrivileges
END


--Id	Name	IPAddress	CreatedUserID	LastModUserID	CreatedDate	LastModDate	AutoGenerateID	FormID	ModuleID	DefaultViewAccess	DefaultInsertAccess	DefaultModifyAccess	DefaultDeleteAccess	DefaultPrintAccess	TemplateBaseId	Id	UserGroupName	IsActive	IPAddress	CreatedUserID	LastModUserID	CreatedDate	LastModDate

GO

