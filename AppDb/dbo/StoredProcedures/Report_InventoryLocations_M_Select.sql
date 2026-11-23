CREATE PROCEDURE [dbo].[Report_InventoryLocations_M_Select] 
AS
BEGIN
	SELECT      code, description
	FROM        Location_Ref
	WHERE		(Active = 1) 
	ORDER BY	description
END

GO

