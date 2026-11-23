CREATE PROCEDURE [dbo].[SupplierExpense_M_Select_ById]
    @Id INT,
    @PropertyId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        E.Id,
        E.SupplierId,
        S.Name SupplierName,
        E.PropertyId,
        E.TxnDate,
        E.Amount,
        E.Remark,
        E.CreatedUserId,
        E.CreatedDateTime,
        E.EditedUserId,
        E.EditedDateTime,
		E.InvoiceNo
    FROM SupplierExpense E INNER JOIN Suppliers S ON E.SupplierId = S.ID
    WHERE E.Id = @Id AND E.PropertyId = @PropertyId;
END

GO

