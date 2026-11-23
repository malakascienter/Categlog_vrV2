
CREATE PROCEDURE Sys_Add_UserWiseCompany
	@userid int,
	@companyid int
AS
BEGIN

INSERT INTO [dbo].[UserWiseCompanies]
           ([UserId]
           ,[CompnayId]
           ,[IPAddress]
           ,[CreatedUserID]
           ,[LastModUserID]
           ,[CreatedDate]
           ,[LastModDate])
     VALUES
           (@userid , @companyid, '',1,1,GETDATE(),GETDATE())

select * from UserWiseCompanies

END

GO

