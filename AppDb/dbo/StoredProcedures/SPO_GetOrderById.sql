
CREATE PROCEDURE [dbo].[SPO_GetOrderById]
    @OrderId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Get Order Header
    SELECT 
        OrderId, CustomerId, MobileNo, OrderTypeId, DeliveryDate, 
        DeliveryTime, DeliveryOutlet, Discount, OrderRemark, TotalAmount,
        CreatedDate, Status
    FROM SPO_OrderHeader 
    WHERE OrderId = @OrderId;

    -- Get Order Details
    SELECT 
        ItemCode, ItemName, Price, Qty, Discount, 
        TotalAmount, ItemRemark
    FROM SPO_OrderDetails 
    WHERE OrderId = @OrderId;
END

GO

