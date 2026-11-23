--select * from AutoGenerateTemplates
--truncate table AutoGenerateTemplates

--truncate table [dbo].[AutoGenerateTemplateBases]
--truncate table [dbo].[AutoGenerateTemplates]

--truncate table [dbo].[AutoGenerateUserPrivileges]
--truncate table [dbo].[AutoGenerateGroupPrivileges]

--[dbo].[SP_S_CreateTemplates] "Full Access" 
CREATE PROCEDURE [dbo].[SP_S_CreateTemplates]
	@TemplateName varchar(50)
AS
BEGIN

declare @newid int
set @newid = 0

BEGIN TRY
	BEGIN TRANSACTION


INSERT INTO [dbo].[AutoGenerateTemplateBases]
           ([Name],[IPAddress],[CreatedUserID],[LastModUserID],[CreatedDate],[LastModDate])
VALUES (@TemplateName , '192.168.1.120' , 1,1,GETDATE(),GETDATE() )


set @newid = scope_identity()

INSERT INTO [dbo].[AutoGenerateTemplates]
           ([Name]
           ,[IPAddress]
           ,[CreatedUserID]
           ,[LastModUserID]
           ,[CreatedDate]
           ,[LastModDate]
           ,[AutoGenerateID]
           ,[FormID]
           ,[ModuleID]
           ,[DefaultViewAccess]
           ,[DefaultInsertAccess]
           ,[DefaultModifyAccess]
           ,[DefaultDeleteAccess]
           ,[DefaultPrintAccess]
		   ,TemplateBaseId)

 select @TemplateName , '192.168.1.120' , 1,1,GETDATE(),GETDATE(),id,FormId,ModuleType,1,1,1,1,1,@newid
 from AutoGenerateInfoes        
 

 --truncate table AutoGenerateTemplates
 select * from AutoGenerateTemplates


	COMMIT TRAN -- Transaction Success!
END TRY
BEGIN CATCH
	return CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN --RollBack in case of Error
END CATCH
end

GO

