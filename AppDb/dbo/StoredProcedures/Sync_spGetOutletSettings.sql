


CREATE PROCEDURE [dbo].[Sync_spGetOutletSettings]
@PropertyId INT
AS 
SET NOCOUNT ON

SELECT	PropertyId, Description AS PropertyName, OutletServer AS ServerName, OutletDatabase AS DatabaseName, code AS OutletCode, 1 AS IsRestaurant
FROM	Location_Ref
WHERE	Active = 1 AND OutletServer != '' AND PropertyId = @PropertyId

GO

