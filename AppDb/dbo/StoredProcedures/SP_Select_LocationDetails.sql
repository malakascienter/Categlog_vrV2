CREATE PROCEDURE [dbo].[SP_Select_LocationDetails]
	@CompanyID int = '',
	@IsActive BIT = ''
AS
BEGIN

SELECT      Locations.Id,Locations.Code,Locations.Name
FROM         Locations 
WHERE Locations.CompanyID=CASE WHEN @CompanyID ='' THEN  Locations.CompanyID ELSE @CompanyID END 
AND Locations.IsActive=case when @IsActive ='' THEN Locations.IsActive ELSE @IsActive END 
ORDER BY Name


END

GO

