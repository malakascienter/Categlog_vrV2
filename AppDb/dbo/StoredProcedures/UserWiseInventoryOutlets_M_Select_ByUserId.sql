---EXECUTE UserWiseInventoryOutlets_M_Select_ByUserId 1
CREATE PROCEDURE [dbo].[UserWiseInventoryOutlets_M_Select_ByUserId] 
	@UserId		INT
AS
BEGIN
	SELECT UWO.OutletCode AS Code,UWO.Id,LR.description,UWO.IsActive
	FROM Location LR
	Inner join UserWiseOutlet AS UWO On LR.code = UWO.OutletCode
	WHERE UWO.UserId = @UserId AND LR.Active = 1 
END

GO

