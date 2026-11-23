-- =============================================
-- Author:		Chiraj
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[User_M_ResetPwd] 
	@Password NVARCHAR(500),
	@Salt NVARCHAR(500),
	@UserName VARCHAR(20)
	
	
                
AS
BEGIN
	

	DECLARE @PropertyId INT
	SET @PropertyId=(SELECT PropertyId from Users where Username=@UserName AND IsPasswordReset=1)
	SET NOCOUNT ON;
	UPDATE Users SET 
[Password]=@Password,
Salt=@Salt,
IsPasswordReset=0 ,
IsUpload=0,
LastEditedUserId=1,LastEditedDateTime=GETDATE()
where Username=@UserName AND PropertyId=@PropertyId
   
END

GO

