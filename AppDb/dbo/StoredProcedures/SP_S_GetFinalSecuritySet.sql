CREATE PROCEDURE [dbo].[SP_S_GetFinalSecuritySet]
	@UserID int
AS
BEGIN
-----------------------------------------------------------------------------------------------	
BEGIN TRY 
IF(@UserID = 0)
		BEGIN
			RAISERROR('User ID Invalid, Please Log In Again',16,1)
			ROLLBACK TRANSACTION
		END

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


	select FromID AS FormId,	CanInsert AS ViewAccess,	CanInsert AS InsertAccess,	CanInsert AS UpdateAccess,	CanInsert AS DeleteAccess, 	CanInsert AS PrintAccess , 0 AS OverridedDefault from @SecurityList 
	end
	else
	begin
		 RAISERROR ('Given User not belong to any User Group', 16,  1 );
	end
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
-----------------------------------------------------------------------------------------------	



END

GO

