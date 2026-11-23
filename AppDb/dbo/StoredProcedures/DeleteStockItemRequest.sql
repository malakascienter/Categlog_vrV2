 

create procedure [dbo].[DeleteStockItemRequest] (@RequestID INT,@UserID INT )
AS

INSERT INTO [dbo].[CancelStockItemRequest] (Id, PropertyId, ItemCode, ItemDescription, CategoryId, SubCategoryId, SubCategory2Id, Remarks, ItemUnit, Approved, CanceledUserID)
SELECT Id, PropertyId, ItemCode, ItemDescription, CategoryId, SubCategoryId, SubCategory2Id, Remarks, ItemUnit, Approved, @UserID
FROM [dbo].[TempStockItemRequest]
where Id= @RequestID


delete from [dbo].[TempStockItemRequest]
where Id= @RequestID

GO

