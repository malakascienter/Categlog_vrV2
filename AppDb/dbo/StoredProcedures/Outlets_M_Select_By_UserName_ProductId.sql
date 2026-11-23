-- =============================================
-- Author:		Yasiru
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Outlets_M_Select_By_UserName_ProductId]
@UserName		Nvarchar(50),
@ProductId      INT
AS
BEGIN	
	SET NOCOUNT ON;

	SELECT UWO.*,LR.description
	FROM HUserWiseOutlets UWO
	Inner Join HUsers As U on U.Id = UWO.UserId
	Inner join HProductWiseUsers AS PWU On U.Id = PWU.UserId	
	inner join Location_Ref AS LR ON UWO.OutletCode = LR.code
	WHERE U.Username = @UserName AND PWU.ProductId = @ProductId

END

GO

