
--[SP_S_InitializeGroupPrivileges] 1,1
CREATE  PROCEDURE [dbo].[SP_S_InitializeGroupPrivileges]
	@TemplateID int,
	@GroupID int

AS
BEGIN

INSERT INTO [dbo].[AutoGenerateGroupPrivileges]
           ([UserGroupID]
           ,[AutoGenerateID]
           ,[HasBrekdown]
           ,[FormID]
           ,[ModuleID]
           ,[DefaultViewAccess]
           ,[DefaultInsertAccess]
           ,[DefaultModifyAccess]
           ,[DefaultDeleteAccess]
           ,[DefaultPrintAccess]
           ,[IPAddress]
           ,[CreatedUserID]
           ,[LastModUserID]
           ,[CreatedDate]
           ,[LastModDate])


select UG.id, AGT.id,0,AGT.FormID ,AGT.ModuleID, DefaultViewAccess,DefaultInsertAccess,DefaultModifyAccess,DefaultDeleteAccess,	DefaultPrintAccess,'192.168.1.120' , 1,1,GETDATE(),GETDATE()
 from AutoGenerateTemplates as AGT cross join
UserGroups as UG 
 where templatebaseid =@TemplateID and UG.Id = @GroupID

END


--Id	Name	IPAddress	CreatedUserID	LastModUserID	CreatedDate	LastModDate	AutoGenerateID	FormID	ModuleID	DefaultViewAccess	DefaultInsertAccess	DefaultModifyAccess	DefaultDeleteAccess	DefaultPrintAccess	TemplateBaseId	Id	UserGroupName	IsActive	IPAddress	CreatedUserID	LastModUserID	CreatedDate	LastModDate

GO

