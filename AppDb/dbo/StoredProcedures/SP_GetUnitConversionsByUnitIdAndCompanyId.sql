-- =============================================
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetUnitConversionsByUnitIdAndCompanyId]
	@UnitId INT,
	@PropertyId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT ID as Id, Name as Name,1 as Value FROM Units WHERE ID = @UnitId
	UNION
	select UC.FromUnitID as Id, U.Name,Value as Name
	from UnitConversions UC INNER JOIN Units U ON UC.FromUnitID = U.ID
	WHERE UC.ToUnitID = @UnitId AND UC.CompanyId = @PropertyId
	
	UNION
	select UC.ToUnitID as Id, U.Name as Name,Value
	from UnitConversions UC INNER JOIN Units U ON UC.ToUnitID = U.ID
	WHERE UC.FromUnitID = @UnitId AND UC.CompanyId = @PropertyId


	--SELECT  ToUnitID AS UnitID,ToUnitName AS Unitname,Value FROM dbo.UnitConversions WHERE FromUnitID=@unitID UNION ALL
	--SELECT FromUnitID AS UnitID,FromUnitName AS Unitname ,Value FROM dbo.UnitConversions  WHERE ToUnitID=@unitID UNION
	--SELECT Id,Name,1  UnitID FROM dbo.Units WHERE Id=@unitID


END

GO

