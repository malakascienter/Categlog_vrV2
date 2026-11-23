


CREATE PROCEDURE [dbo].[SP_CheckAccess]

	@userid int
AS
BEGIN

declare @SecurityList table(
		FormId  int,
		FormName  varchar(max),
		ViewAccess bit
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
	select AGP.FormID , AGI.FormName, AGP.DefaultInsertAccess 
	
	from AutoGenerateGroupPrivileges as AGP 
	inner join AutoGenerateInfoes AGI on AGP.FormID =AGI.FormId
	where AGP.UserGroupID = @GroupID and AGP.FormID in (2521,2522,2523)

	--Override any user specific Permmisions . so on the AutoGenerateUserPrivileges there can be only specified permission sets those need to override
	--against the Group permissions
	update SL set 
	SL.ViewAccess = AUP.IsViewAccess
	from @SecurityList as SL inner join AutoGenerateUserPrivileges AS AUP
	on SL.FormId = AUP.FormID
	where AUP.UserMasterId = @userid  

	end
	else
	begin
		 RAISERROR ('Given User not belong to any User Group', 16,  1 );
	end
	



select * from @SecurityList




END

GO

