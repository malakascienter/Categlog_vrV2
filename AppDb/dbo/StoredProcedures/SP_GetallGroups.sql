CREATE PROCEDURE [dbo].[SP_GetallGroups] 
	-- Add the parameters for the stored procedure here

AS
BEGIN
	SELECT        * 
FROM           AltItemGroups
--WHERE     AltItemGroups.ID  = @GroupId ORDER BY Description asc
END

GO

