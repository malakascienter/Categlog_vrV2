CREATE PROCEDURE SupplierExpense_M_Delete
    @Id INT,
    @PropertyId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM SupplierExpense 
    WHERE Id = @Id AND PropertyId = @PropertyId;
END

GO

