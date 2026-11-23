--exec SP_S_GetMenuSet 15
--delete from AutoGenerateUserPrivileges where formid in (301,101)

CREATE PROCEDURE [dbo].[SP_S_GetMenuSet]

	@userid int
AS
BEGIN

declare @SecurityList table(
		FromID int,
		ModuleID int,
		CanView bit
		--,CanInsert bit,
		--CanModify bit,
		--CanDelete bit,
		--CanPrint bit
	)

	declare @GroupID int
	set @GroupID = 0

	select @GroupID = UserGroupID from usermasters  where Id = @userid
	--select @GroupID

	if(@GroupID >0)
	begin
	--Extract Group Permission Set from Relevent Group that user belongs to
	insert into @SecurityList
	select AGP.FormID , AGP.ModuleID, AGP.DefaultInsertAccess 
	--,AGP.DefaultInsertAccess,AGP.DefaultModifyAccess,AGP.DefaultDeleteAccess , AGP.DefaultPrintAccess 
	from AutoGenerateGroupPrivileges as AGP 
	where AGP.UserGroupID = @GroupID

	--Override any user specific Permmisions . so on the AutoGenerateUserPrivileges there can be only specified permission sets those need to override
	--against the Group permissions
	update SL set 
	SL.CanView = AUP.IsViewAccess
	--,SL.CanInsert = AUP.IsInsertAccess,
	--SL.CanModify = AUP.IsModifyAccess,
	--SL.CanDelete = AUP.IsDeleteAccess,
	--SL.CanPrint = AUP.IsPrintAccess
	--from AutoGenerateUserPrivileges as AUP inner join @SecurityList as SL on SL.FromID = AUP.FormID where AUP.UserMasterId = @userid 
	from @SecurityList as SL inner join AutoGenerateUserPrivileges AS AUP
	on SL.FromID = AUP.FormID
	where AUP.UserMasterId = @userid  

	--(select * from  AutoGenerateUserPrivileges as AUP1 where AUP1.IsViewAccess = 1)
	--select * from AUP
	end
	else
	begin
		 RAISERROR ('Given User not belong to any User Group', 16,  1 );
	end
	

select *  from SystemModules
select * from SubModules
--select *,'kobi' Icon  from SubModulesL1

select SM.Id,SM.MainModuleId , SM.SubModuleId , SM.FormID , SM.RoutePath, SM.Icon , AGI.FormName ,SL.CanView from SystemMenues SM 
inner join @SecurityList  as SL on SM.FormID = SL.FromID
inner join AutoGenerateInfoes as AGI on SM.FormID = AGI.FormId
---inner join AutoGenerateUserPrivileges as AUP on SL.FromID = AUP.FormID 
where SL.CanView = 1 AND AGI.IsActive =1




END

--select * from SubModulesL1
--select * from AutoGenerateInfoes
--select * from SystemMenues

GO

