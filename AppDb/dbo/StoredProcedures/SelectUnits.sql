
create PROCEDURE [dbo].[SelectUnits]
AS
BEGIN
	SELECT Id,Code,Name,LocationID,CompanyId,IsActive
	FROM Units
END

GO

