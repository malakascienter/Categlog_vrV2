
-- [dbo].[SP_GetUnitCoversion_WithPropertyID]  26,1
CREATE PROCEDURE [dbo].[SP_GetUnitCoversion_WithPropertyID] 
	@unitID INT,
	@PropertyID INT
AS
BEGIN
	
	SELECT  ToUnitID AS UnitID,ToUnitName AS Unitname,Value 
	FROM dbo.UnitConversions WHERE FromUnitID=@unitID AND CompanyId = @PropertyID
	UNION ALL
	SELECT FromUnitID AS UnitID,FromUnitName AS Unitname ,Value 
	FROM dbo.UnitConversions  WHERE ToUnitID=@unitID AND CompanyId = @PropertyID
	UNION
	SELECT Id,Name,1  UnitID FROM dbo.Units WHERE Id=@unitID 
END

GO

