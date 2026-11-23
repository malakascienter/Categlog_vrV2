create PROCEDURE SelectCompanies
AS
BEGIN
	SELECT CompanyID,Code,Name,OtherBusinessName1 FROM Companies
END

GO

