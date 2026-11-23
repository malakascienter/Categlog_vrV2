-- =============================================
-- Author: Ravindu
-- Create date: 2026-03-03
-- Description: Get Userwise Outlet
-- =============================================
-- EXEC SPO_GetUserWiseOutlet 1,4168
CREATE   PROCEDURE [dbo].[SPO_GetUserWiseOutlet] 
(
  @PropertyId INT,
  @UserId INT
)

AS
BEGIN

	SELECT 
		CO.Code,
		CO.Name AS OutletName
	FROM SPO_Central_Outlets AS CO
	INNER JOIN SPO_Central_UserWiseOutlets AS CUO ON CUO.OutletId = CO.Id
	INNER JOIN  Location_Ref AS RF ON RF.code = CO.Code AND CUO.PropertyId = RF.PropertyId
	WHERE CUO.UserId = @UserId AND CUO.PropertyId = @PropertyId

END

GO

