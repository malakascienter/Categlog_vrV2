
CREATE PROCEDURE [dbo].[SP_Select_PropertyWiseSuppliers]
	@PropertyId	INT,
	@isActive INT = -1
AS
BEGIN
	
	SET NOCOUNT ON;
	
	SELECT ID,Name
	FROM dbo.Suppliers
	WHERE PropertyID = @PropertyID AND
	dbo.Suppliers.IsActive = CASE WHEN 	@IsActive = -1 THEN dbo.Suppliers.isActive ELSE @isActive END

	
END

GO

