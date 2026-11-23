

CREATE PROCEDURE GetCompanySettings
@CompanyId INT
AS
BEGIN

SELECT CS.CompanyID AS CompanyId,CS.ThresholdPercentage FROM Companies AS CS WHERE CS.CompanyId=@CompanyId

END

GO

