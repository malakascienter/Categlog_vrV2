create procedure [dbo].[DeleteSupplierRequest](@RequestID int, @userID int )
as


INSERT INTO CancelSuppliersRequest  (Id, PropertyID, Name, Address1, Email, Telephone1, IsApprove, CreatedUserID, LastModUserID, CreatedDate, LastModDate, VatNo, logDate, CancelledUserID)
SELECT Id, PropertyID, Name, Address1, Email, Telephone1, IsApprove, CreatedUserID, LastModUserID, CreatedDate, LastModDate, VatNo, GETDATE(), @userID
FROM [dbo].[SuppliersRequest]
where id= @RequestID

delete from [dbo].[SuppliersRequest]
where id= @RequestID

GO

