-- =============================================
-- Author:		Yasiru
-- Create date: 2018-04-20
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[UserWiseRoles_M_Select_ByUserId] 
@UserId int
AS
BEGIN
	SET NOCOUNT ON;

	SELECT * 
	FROM UserWiseRoles
	WHERE UserId = @UserId
END

GO

