CREATE PROCEDURE [dbo].[SP_GetUnitCoversion] 
	@unitID INT
AS
BEGIN
	
SELECT  ToUnitID AS UnitID,ToUnitName AS Unitname,Value FROM dbo.UnitConversions WHERE FromUnitID=@unitID UNION ALL
SELECT FromUnitID AS UnitID,FromUnitName AS Unitname ,Value FROM dbo.UnitConversions  WHERE ToUnitID=@unitID UNION
SELECT Id,Name,1  UnitID FROM dbo.Units WHERE Id=@unitID

END

GO

