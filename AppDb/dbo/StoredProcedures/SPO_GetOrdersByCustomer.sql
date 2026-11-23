
CREATE PROCEDURE [dbo].[SPO_GetOrdersByCustomer]
    @CustomerId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        OrderId, CustomerId, MobileNo, OrderTypeId, DeliveryDate, 
        DeliveryTime, DeliveryOutlet, Discount, OrderRemark, TotalAmount,
        CreatedDate, Status
    FROM SPO_OrderHeader 
    WHERE CustomerId = @CustomerId
    ORDER BY CreatedDate DESC;
END

GO

