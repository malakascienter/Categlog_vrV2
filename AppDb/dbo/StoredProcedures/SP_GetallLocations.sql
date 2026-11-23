-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in

CREATE PROCEDURE [dbo].[SP_GetallLocations] 
	-- Add the parameters for the stored procedure here
	
	@Propertyid INT

AS
BEGIN
	SELECT        * 
FROM           Locations
WHERE     Locations.companyid  = @Propertyid 
          AND IsActive = 1

ORDER BY NAME asc
END

GO

