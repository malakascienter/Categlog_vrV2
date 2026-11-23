

CREATE PROCEDURE SP_SaveProjectWiseSubcontractors
   @ProjectID int,	 
   @BOQID	int,
   @SectionID	int,
   @WorkID	int,
   @SubcontractorID	int,
   @PWSID int output
AS
BEGIN
	declare @idid int = -1
	if exists(select * from ProjectWiseSubcontractors where 
	ProjectID=@ProjectID and BOQID=@BOQID and MainWorkID= @SectionID and WorkID= @WorkID and SubcontractorID=@SubcontractorID )
	begin
		RAISERROR ('Record Already Exists',16,1)
	end 
	else
	begin

		INSERT INTO [dbo].[ProjectWiseSubcontractors]
				   ([ProjectID]
				   ,[BOQID]
				   ,[MainWorkID]
				   ,[WorkID]
				   ,[SubcontractorID]
				   ,[Status]
				   ,[IPAddress]
				   ,[CreatedUserID]
				   ,[LastModUserID]
				   ,[CreatedDate]
				   ,[LastModDate])
			 VALUES
				   (@ProjectID,@BOQID,@SectionID,@WorkID,@SubcontractorID,0,'192.168.1.120',1,1,GETDATE(),GETDATE())

			set @idid = SCOPE_IDENTITY()

	end
	set @PWSID = @idid
	--select @PWSID
END

GO

