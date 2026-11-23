CREATE PROCEDURE [dbo].[SP_GetallCostTypes] 
	-- Add the parameters for the stored procedure here
	
	@Propertyid INT

AS
BEGIN
	SELECT        * 
FROM           CostTypes
WHERE     CostTypes.PropertyID  = @Propertyid ORDER BY Description asc
END

GO

