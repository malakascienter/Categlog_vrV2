-- SelectDefaultLocation 1
create PROCEDURE SelectDefaultLocation
	@CompanyId INT
AS
BEGIN
	SELECT DefaultLocationId FROM ProductionSetting WHERE CompanyId = @CompanyId
END

GO

