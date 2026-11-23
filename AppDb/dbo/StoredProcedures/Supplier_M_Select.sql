CREATE PROCEDURE Supplier_M_Select
    @PropertyId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        Id,
        Name
    FROM Suppliers
    --WHERE PropertyId = @PropertyId
	ORDER BY Name 

END

GO

