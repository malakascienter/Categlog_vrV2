

--Test_Asanga 1

CREATE PROCEDURE Test_Asanga
	@userid int
AS
BEGIN

declare @SecurityList table(
		FromID int,
		ModuleID int,
		CanView bit,
		CanInsert bit,
		CanModify bit,
		CanDelete bit,
		CanPrint bit
	)

	declare @GroupID int
	set @GroupID = 0

	select @GroupID = UserGroupID from usermasters  where Id = @UserID
	--select @GroupID

	if(@GroupID >0)
	begin
	--Extract Group Permission Set from Relevent Group that user belongs to
	insert into @SecurityList
	select AGP.FormID , AGP.ModuleID, AGP.DefaultViewAccess, AGP.DefaultInsertAccess,AGP.DefaultModifyAccess,AGP.DefaultDeleteAccess , AGP.DefaultPrintAccess 
	from AutoGenerateGroupPrivileges as AGP 
	where AGP.UserGroupID = @GroupID

	--Override any user specific Permmisions . so on the AutoGenerateUserPrivileges there can be only specified permission sets those need to override
	--against the Group permissions
	update SL set 
	SL.CanView = AUP.IsViewAccess,
	SL.CanInsert = AUP.IsInsertAccess,
	SL.CanModify = AUP.IsModifyAccess,
	SL.CanDelete = AUP.IsDeleteAccess,
	SL.CanPrint = AUP.IsPrintAccess
	from @SecurityList as SL inner join AutoGenerateUserPrivileges as AUP
	on SL.FromID = AUP.FormID 
	where AUP.UserMasterId = @UserID


	
	end
	else
	begin
		 RAISERROR ('Given User not belong to any User Group', 16,  1 );
	end
	

select *  from SystemModules
select *  from SubModules
select *  from SubModulesL1

select *  from SystemMenues SM inner join 
@SecurityList  as SL on SM.FormID = SL.FromID





END

GO

