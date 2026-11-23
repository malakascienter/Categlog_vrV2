-- =============================================
-- Author:		Ravindu
-- Create date: 2026-02-20
-- Description:	get all order by customer type 3,1
-- =============================================
-- EXEC [dbo].[SPO_GetAllOrderTypesByCustomerType] 1,3
CREATE   PROCEDURE [dbo].[SPO_GetAllOrderTypesByCustomerType]
    @PropertyId INT,
    @CustomerTypeId BIGINT 
AS
BEGIN
    SET NOCOUNT ON;

    ------------------------------------------------------------------
    -- Dont change select order; used in backend api multi.ReadAsync
    ------------------------------------------------------------------

    -- First result set: Order Types (filter by property and customer type)
    SELECT 
        ot.ID AS OrderTypeId,
        ot.OrderTypeName,
        ot.IsActive AS IsActive
    FROM [dbo].[SPO_OrderType] ot
    INNER JOIN [dbo].[SPO_OrderTypeWiseCustomer] otwc
        ON ot.ID = otwc.OrderTypeID
    WHERE ot.PropertyId = @PropertyId AND  otwc.CustomerTypeID = @CustomerTypeId
    GROUP BY ot.ID, ot.OrderTypeName, ot.IsActive
    ORDER BY ot.ID;

    -- Second result set: Customer Type Mappings (filtered by customer type)
    SELECT 
        otwc.OrderTypeID,
        otwc.CustomerTypeID AS CustomerTypeId,
        otwc.PriceTypeId,
        ct.CustomerTypeName 
    FROM [dbo].[SPO_OrderTypeWiseCustomer] otwc
    INNER JOIN [dbo].[SPO_OrderType] ot 
        ON otwc.OrderTypeID = ot.ID
    INNER JOIN SPO_CustomerType CT 
        ON CT.ID = otwc.CustomerTypeID
    WHERE ot.PropertyId = @PropertyId AND otwc.CustomerTypeID = @CustomerTypeId
    ORDER BY otwc.OrderTypeID, otwc.CustomerTypeID;

    -- Third result set: Outlet Mappings (filtered by customer type)
    SELECT 
        otwcod.OrderTypeID,
        otwcod.CustomerTypeID,
        otwcod.OutletCode,
        otwcod.PriceTypeID AS PriceTypeId
    FROM [dbo].[SPO_OrderTypeWiseCustomerWiseOutletWiseDetails] otwcod
    INNER JOIN [dbo].[SPO_OrderType] ot 
        ON otwcod.OrderTypeID = ot.ID
    WHERE ot.PropertyId = @PropertyId AND otwcod.CustomerTypeID = @CustomerTypeId
    ORDER BY otwcod.OrderTypeID, otwcod.CustomerTypeID, otwcod.OutletCode;
END

GO

