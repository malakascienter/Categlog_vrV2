CREATE PROCEDURE [dbo].[SP_GetallLaborUnits] 
	-- Add the parameters for the stored procedure here
	
	@LabourUnitid INT

AS
BEGIN
	SELECT        * 
FROM          LaborUnits
WHERE     LaborUnits.Id  = @LabourUnitid ORDER BY LaborUnitName asc
END

GO

