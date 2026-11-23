-- =============================================
-- Author:		Ravindu
-- Create date: 2026-03-05
-- Description:	Get Order Details
-- =============================================
-- EXEC [dbo].[SPO_GetOrderDetails] 2087
CREATE   PROCEDURE [dbo].[SPO_GetOrderDetails]
    @OrderId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        OH.OrderId,
        OH.InvoiceNo,
        CAST(OH.CreatedDate AS DATE)                        AS CreatedDate,
        OH.CreatedBy,
        OH.OrderOutlet                                      AS OderOutletCode,
        LR.description                                      AS OderOutletName,
        OH.DeliveryDate,
        OH.DeliveryOutlet,
        L.description                                       AS DeliveryOutletName,
        C.CustomerName,
        C.MobileNumber,
        OH.TotalAmount,
        OH.NetAmount,
        dbo.fn_SPO_GetBalanceAmount(OH.OrderId)             AS BalanceAmount,
        dbo.fn_SPO_GetDiscountApprovalAmount(OH.OrderId, 1) AS ApprovedDiscount,
        dbo.fn_SPO_GetDiscountApprovalAmount(OH.OrderId, 0) AS NonApprovedDiscount,
        dbo.fn_SPO_GetPaidAmount(OH.OrderId) AS AdvanceAmount,
        OT.MiniumAdvancePercentage,
        OT.PayBeforeDays,
        (
            SELECT
                OD.ItemCode,
                OD.ItemName,
                OD.Qty          AS Quantity,
                OD.Price,
                OD.TotalAmount,
                MM.Category     AS CategoryCode,
                ISNULL(DH.Code, '') AS DiscountCode
            FROM SPO_OrderDetails AS OD
            INNER JOIN MainMenu       AS MM ON MM.ItemCode = OD.ItemCode
            LEFT JOIN  DiscountHeader AS DH ON CONVERT(VARCHAR(MAX), DH.Id) = OD.DiscountType
            WHERE OD.OrderId = OH.OrderId
            FOR JSON PATH
        ) AS OrderDetail
    FROM SPO_OrderHeader    AS OH
    INNER JOIN SPO_OrderType    AS OT ON OT.ID      = OH.OrderTypeId
    INNER JOIN Location_Ref     AS L  ON L.code     = OH.DeliveryOutlet
    INNER JOIN SPO_Customer     AS C  ON C.ID       = OH.CustomerId
    INNER JOIN Location_Ref     AS LR ON LR.code    = OH.OrderOutlet
    WHERE OH.OrderId = @OrderId
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END

GO

