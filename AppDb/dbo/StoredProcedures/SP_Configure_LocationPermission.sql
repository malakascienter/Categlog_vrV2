

CREATE PROCEDURE SP_Configure_LocationPermission
	@userid int
AS
BEGIN

INSERT INTO [dbo].[UserWise_Location]
           ([UserID]
           ,[LocationID]
           ,[CompanyId]
           ,[IsActive]
           ,[IPAddress]
           ,[CreatedUserID]
           ,[LastModUserID]
           ,[CreatedDate]
           ,[LastModDate])
   
SELECT um.Id, l.Id, 1,1,'192.168.1.120',1,1,GETDATE(),GETDATE() FROM dbo.UserMasters AS UM CROSS JOIN dbo.Locations AS L
WHERE um.id IN (@userid)

END

GO

