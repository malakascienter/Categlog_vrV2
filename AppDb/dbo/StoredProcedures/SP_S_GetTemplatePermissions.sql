

CREATE PROCEDURE [dbo].[SP_S_GetTemplatePermissions]
	@TemplateBaseID int,@Module int
AS
BEGIN
----------------------------------------------------------------------------
BEGIN TRY 
	create table #SecurityList (
		FormID int,
		ModuleID int,
		CanView bit,
		CanInsert bit,
		CanModify bit,
		CanDelete bit,
		CanPrint bit
	)

	--declare @GroupID int
	--set @GroupID = 0

	--select @GroupID = UserGroupID from usermasters  where Id = @UserID
	--select @GroupID

	--if(@GroupID >0)
	begin
	--Extract Group Permission Set from Relevent Group that user belongs to
	if(@Module = 3000)
	BEGIN
	insert into #SecurityList
	
	select	AGP.FormID , AGP.ModuleID, AGP.DefaultInsertAccess DefaultViewAccess, AGP.DefaultInsertAccess,AGP.DefaultInsertAccess DefaultModifyAccess,AGP.DefaultInsertAccess DefaultDeleteAccess, 
			AGP.DefaultInsertAccess DefaultPrintAccess
	from AutoGenerateGroupPrivileges as AGP 
	where AGP.UserGroupID = @TemplateBaseID and AGP.formID > @Module 


	insert into #SecurityList
	select f.FormID , f.ModuleType, 0, 0,0,0 , 0 
	from AutoGenerateInfoes as f 

	where f.Formid not in (select s.Formid from #SecurityList s) and FormId>@Module
	END
	ELSE
	BEGIN
	insert into #SecurityList
	
	select	AGP.FormID , AGP.ModuleID, AGP.DefaultInsertAccess DefaultViewAccess, AGP.DefaultInsertAccess,
			AGP.DefaultInsertAccess DefaultModifyAccess,AGP.DefaultInsertAccess DefaultDeleteAccess, 
			AGP.DefaultInsertAccess DefaultPrintAccess
	from AutoGenerateGroupPrivileges as AGP 
	where AGP.UserGroupID = @TemplateBaseID and AGP.formID < 3000


	insert into #SecurityList
	select f.FormID , f.ModuleType, 0, 0,0,0 , 0 
	from AutoGenerateInfoes as f 

	where f.Formid not in (select Formid from #SecurityList) and  f.FormId<3000

	END


	--Override any user specific Permmisions . so on the AutoGenerateUserPrivileges there can be only specified permission sets those need to override
	--against the Group permissions
	--update SL set 
	--SL.CanView = AUP.DefaultViewAccess,
	--SL.CanInsert = AUP.DefaultInsertAccess,
	--SL.CanModify = AUP.DefaultModifyAccess,
	--SL.CanDelete = AUP.DefaultDeleteAccess,
	--SL.CanPrint = AUP.DefaultPrintAccess
	--from #SecurityList as SL inner join AutoGenerateTemplates as AUP
	--on SL.FormID = AUP.FormID 
	--where AUP.TemplateBaseId = @TemplateBaseID

	select '22', @TemplateBaseID Id, s.FormID AS FormId,AgI.FormName,CanView AS ViewAccess,	CanInsert AS InsertAccess,	CanModify AS UpdateAccess,	CanDelete AS DeleteAccess, 	CanPrint AS PrintAccess , 0 AS OverridedDefault , 0 as RwUpdated
	from #SecurityList s
	inner join AutoGenerateInfoes AgI on s.FormID = AgI.FormId 
	--left join AutoGenerateGroupPrivileges g on AgI.FormId = g.FormID 
	--where g.UserGroupID = @TemplateBaseID

	end
	--else
	--begin
		-- RAISERROR ('Given User not belong to any User Group', 16,1);
	--end
	--update AutoGenerateUserPrivileges set IsViewAccess =0 where usermasterid =1
	

END TRY
BEGIN CATCH
	IF @@TRANCOUNT>0
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH;
----------------------------------------------------------------------------

END

GO

