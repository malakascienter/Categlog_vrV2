-- =============================================
-- Author:		Yasiru
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Products_M_Select_ByUserId]
@UserId  INT
AS
BEGIN	
	SET NOCOUNT ON;

	SELECT U.*
	FROM Products U
	Inner join UserWiseProducts AS UWP On U.Id = UWP.ProductId
	WHERE UWP.UserId = @UserId


END

GO

