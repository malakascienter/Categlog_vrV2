-- =============================================
-- Author:		Chiraj
-- Create date:2020-10-28
-- Description:	UserPasswordReset
-- =============================================
CREATE PROCEDURE [dbo].[UserPasswordReset]
@ResetUserId INT,
@UserId INT,
@PropertyId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    Update 
	Users 
	SET IsPasswordReset=1 ,
LastEditedUserId=@UserId,
LastEditedDateTime=getdate(),
IsUpload=0
	where id=@ResetUserId AND PropertyId=@PropertyId
END

GO

