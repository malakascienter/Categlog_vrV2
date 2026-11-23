
CREATE PROCEDURE SP_AccessDenneyUserForScreen
	@UserId int,
	@ScreenId int,
	@ViewAccess bit
AS
BEGIN

declare @AutoGenID int
select @AutoGenID = Id from AutoGenerateInfoes where FormId = @ScreenId

if @AutoGenID <=0 
begin
 RAISERROR ('Wrong Screen Id', 16,  1 );
end
else
begin


if exists(select * from AutoGenerateUserPrivileges where FormID = @ScreenId)
begin
	
	update AutoGenerateUserPrivileges set IsViewAccess = @ViewAccess where FormID = @ScreenId

end
else
begin

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
     VALUES
           ( @UserId , @AutoGenID ,0, @ScreenId,0,@ViewAccess,@ViewAccess,@ViewAccess,@ViewAccess,@ViewAccess,'192.168.1.120',1,1,getdate(),getdate()  )

end

end

END

GO

