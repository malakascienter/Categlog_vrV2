-- =============================================
-- Author:		Yasiru
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UserWiseProperty_M_SelectByUserId]
@UserId		Int
AS
BEGIN	
	SET NOCOUNT ON;

	SELECT Id,UserId,ProductId AS PropertyId
	FROM UserWiseProperty 	
	WHERE UserId = @UserId	

END

GO

