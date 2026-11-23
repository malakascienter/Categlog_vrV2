--[dbo].[SP_GetIvoiceById] 7570
CREATE PROCEDURE [dbo].[SP_GetIvoiceById] --1096
	@Id INT
	
AS



BEGIN
        DECLARE @CustomerID INT,@ISVat BIT

		SELECT @CustomerID=CustomerID FROM dbo.Temp_InvoiceHeader WHERE ID=@Id

		SELECT @ISVat=IsVat FROM dbo.Customers WHERE Id=@CustomerID

		IF(@ISVat=1)
		BEGIN 


		SELECT D.ID, D.TaxTotal AS 'Tax', D.TotalDiscount AS 'Discount', D.NetTotal AS 'Net',C.CustomerName AS 'CustomerName',AddLine1+CASE WHEN AddLine2='' THEN '' ELSE ','+AddLine2 END+CASE WHEN AddLine3='' THEN '' ELSE ','+AddLine3 END AS 'CustormerAddress',D.CustomerID
		FROM [dbo].[Temp_InvoiceHeader] AS D
		INNER JOIN Customers AS C ON D.CustomerID =C.Id
		WHERE  D.ID =@Id

		END 

		ELSE 
		BEGIN

		SELECT D.ID, 0 AS 'Tax', D.TotalDiscount AS 'Discount', D.NetTotal AS 'Net',C.CustomerName AS 'CustomerName',AddLine1+CASE WHEN AddLine2='' THEN '' ELSE ','+AddLine2 END+CASE WHEN AddLine3='' THEN '' ELSE ','+AddLine3 END AS 'CustormerAddress',D.CustomerID
		FROM [dbo].[Temp_InvoiceHeader] AS D
		INNER JOIN Customers AS C ON D.CustomerID =C.Id
		WHERE  D.ID =@Id


		END 


		--SELECT * FROM dbo.Temp_InvoiceHeader


END

GO

