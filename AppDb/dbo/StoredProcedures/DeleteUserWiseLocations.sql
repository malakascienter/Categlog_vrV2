CREATE PROCEDURE [dbo].[DeleteUserWiseLocations] @ID INT
AS

BEGIN

BEGIN
	DELETE FROM dbo.UserWise_Location WHERE Id=@ID

END

END

GO

