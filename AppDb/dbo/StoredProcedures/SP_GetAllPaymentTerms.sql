--EXEC [SP_GetAllPaymentTerms] 1
CREATE PROCEDURE [dbo].[SP_GetAllPaymentTerms]
	@CompanyId INT 
AS
BEGIN
	SELECT * FROM paymenttypes 
	WHERE Propertyid = @CompanyId   AND active = 1
	ORDER BY ID DESC 
END

GO

