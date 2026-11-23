
-- EXEC [dbo].[SPO_GetAllOrderTypes] 1
CREATE   PROCEDURE [dbo].[SPO_GetAllOrderTypes]
    @PropertyId INT
AS
BEGIN
    SET NOCOUNT ON;

	------------------------------------------------------------------
	--Dont change select order this use in backend api multi.ReadAsync
	------------------------------------------------------------------

    -- First result set: Order Types
    SELECT 
        ot.ID AS OrderTypeId,
        ot.OrderTypeName,
        ot.IsActive AS IsActive,
        ot.MiniumOrderValue         AS MinimumOrderValue,        
        ot.MiniumAdvancePercentage  AS MinimumAdvancePercentage,
        ot.PlaceOrderBeforeDays,                                 
        ot.AmmendmentBeforeDays,                                
        ot.PayBeforeDays,                                       
        ot.IsAllowAmendment         AS AllowAmendment,          
        ot.IsCreditLimitApply       AS CreditLimitApply,        
        ot.IsAllowDiscounts         AS AllowDiscounts,
        ot.IsOrderApproval AS OrderApproval,
        ot.CancelOrderDocCharge
    FROM [dbo].[SPO_OrderType] ot
    WHERE ot.PropertyId = @PropertyId
    ORDER BY ot.ID;

    -- Second result set: Customer Type Mappings
    SELECT 
        otwc.OrderTypeID,
        otwc.CustomerTypeID AS CustomerTypeId,
        otwc.PriceTypeId,
        ct.CustomerTypeName,
        otwc.IsOutletWisePrice AS OutletWisePrice
    FROM [dbo].[SPO_OrderTypeWiseCustomer] otwc
    INNER JOIN [dbo].[SPO_OrderType] ot ON otwc.OrderTypeID = ot.ID
	INNER JOIN SPO_CustomerType CT ON CT.ID = otwc.CustomerTypeID
    WHERE ot.PropertyId = @PropertyId
    ORDER BY otwc.OrderTypeID, otwc.CustomerTypeID;

    -- Third result set: Outlet Mappings
    SELECT 
        otwcod.OrderTypeID,
        otwcod.CustomerTypeID,
        otwcod.OutletCode,
        otwcod.PriceTypeID AS PriceTypeId
    FROM [dbo].[SPO_OrderTypeWiseCustomerWiseOutletWiseDetails] otwcod
    INNER JOIN [dbo].[SPO_OrderType] ot ON otwcod.OrderTypeID = ot.ID
    WHERE ot.PropertyId = @PropertyId
    ORDER BY otwcod.OrderTypeID, otwcod.CustomerTypeID, otwcod.OutletCode;
END

GO

