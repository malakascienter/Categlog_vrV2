--Sys_AddSystemMenuItems
CREATE PROCEDURE [dbo].[Sys_AddSystemMenuItems]
	@ModuleId int,
	@SubModuleId int,
	@FormId int,
	@FormName varchar(100),
	@RoutePath varchar(100),
	@TransTypeCode varchar(20)=''
	
AS
BEGIN

DECLARE @MainModuleId int
    if(@TransTypeCode <>'')
	begin
	INSERT INTO [dbo].[TransactionTypes]
			   ([Code]
			   ,[Name]
			   ,[GLNarration]
			   ,[IsActive]
			   ,[tempDocumentNo]
			   ,[DocumentNo]
			   ,[DocumentID]
			   ,[CompanyId]
			   ,[LocationId]
			   ,[IPAddress]
			   ,[CreatedUserID]
			   ,[LastModUserID]
			   ,[CreatedDate]
			   ,[LastModDate]
			   ,[DocumentTitle])
		 VALUES
			   (@TransTypeCode,@FormName,'',1,'','',0,1,1,'192.168.1.113',1,1,getdate(),getdate(),''
			   )

      end

	INSERT INTO [dbo].[AutoGenerateInfoes]
			   ([ModuleType]
			   ,[FormId]
			   ,[FormName]
			   ,[FormText]
			   ,[IsActive])
		 VALUES
			   (@ModuleId,@FormId,@FormName,@FormName,1)


	SELECT @MainModuleId=sm.Id FROM dbo.SystemModules sm WHERE sm.ModuleID = @ModuleId

		INSERT INTO [dbo].[SystemMenues]
				   ([MainModuleId]
				   ,[SubModuleId]
				   ,[FormID]
				   ,[RoutePath]
				   ,[Icon])
			 VALUES
				   (@MainModuleId,@SubModuleId,@FormId,@RoutePath,'' )

		TRUNCATE TABLE dbo.AutoGenerateTemplates
		TRUNCATE TABLE dbo.AutoGenerateTemplateBases

		EXEC [dbo].[SP_S_CreateTemplates] 'Full Access'

		TRUNCATE TABLE dbo.AutoGenerateGroupPrivileges

		EXEC [dbo].[SP_S_InitializeGroupPrivileges] 1,1


END

GO

