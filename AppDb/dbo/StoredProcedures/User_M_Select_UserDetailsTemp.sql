-- =============================================
-- Author:		Yasiru
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[User_M_Select_UserDetailsTemp]
@UserName		Nvarchar(50)
AS
BEGIN	
	SET NOCOUNT ON;

	SELECT *
	FROM Users U
	WHERE U.Username = @UserName

END

GO

