create PROCEDURE [dbo].[SelectCustomerDocuments] (@CustomerID int, @type int)

AS
BEGIN

	SET NOCOUNT ON;
	SELECT c.*,isnull(d.Submited,0) Submited, d.documentPathId, d.DocumentID FROM CustomersDocuments c
	left outer join CustomerWiseDocuments d on d.DocumentID= c.ID and d.CustomerID= @CustomerID
	WHERE c.Type=@type 

END

--select * from CustomerWiseDocuments
--select * from CustomersDocuments

GO

