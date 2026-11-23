-- =============================================
-- Author:      Ravindu
-- Create date: 2026-03-31
-- Description: Get order list for order inquiry
--              Default: top 50 latest orders
--              With @SearchTerm: universal search across all key columns
-- =============================================
-- EXEC [dbo].[SPO_GetOrdersForOrderInquery] 1
--
-- Universal search:
-- EXEC [dbo].[SPO_GetOrdersForOrderInquery] 1, 'INV-001'
-- EXEC [dbo].[SPO_GetOrdersForOrderInquery] 1, 'Bambala'
-- EXEC [dbo].[SPO_GetOrdersForOrderInquery] 1, ''
-- EXEC [dbo].[SPO_GetOrdersForOrderInquery] 1, '0702375050'
-- =============================================
CREATE   PROCEDURE [dbo].[SPO_GetOrdersForOrderInquery]
(
    @PropertyId  INT,
    @SearchTerm  NVARCHAR(200) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Normalise: treat blank string same as NULL
    SET @SearchTerm = NULLIF(LTRIM(RTRIM(@SearchTerm)), '');

    -- Pre-compute search term once for reuse
    DECLARE @Like NVARCHAR(202) = N'%' + @SearchTerm + N'%';

    SELECT TOP (CASE WHEN @SearchTerm IS NULL THEN 50 ELSE 2147483647 END)
        OH.OrderId,
        OH.InvoiceNo,
        OT.OrderTypeName,
        CASE OH.Status
            WHEN 'C' THEN 'Approved'
            WHEN 'X' THEN 'Cancel'
            ELSE          'Not Approved'
        END                                                        AS Status,
        C.CustomerName,
        C.MobileNumber,
        L.description                                              AS OrderOutlet,
        LR.description                                             AS DeliveryOutlet,
        OH.DeliveryDate,
        OH.NetAmount,
        dbo.fn_SPO_GetBalanceAmount(OH.OrderId)                    AS BalanceAmount,
        CASE dbo.fn_SPO_IsOrderDispatched(OH.PropertyId, OH.OrderId)
            WHEN 1 THEN 'Dispatched'
            ELSE        'Not Dispatched'
        END                                                        AS DispatchStatus
    FROM       SPO_OrderHeader  AS OH
    LEFT JOIN  SPO_OrderType    AS OT  ON OT.ID   = OH.OrderTypeId
    LEFT JOIN  SPO_Customer     AS C   ON C.ID    = OH.CustomerId
    LEFT JOIN  Location_Ref     AS L   ON L.code  = OH.OrderOutlet
    LEFT JOIN  Location_Ref     AS LR  ON LR.code = OH.DeliveryOutlet
    WHERE
        OH.PropertyId = @PropertyId
        AND
        (
            @SearchTerm IS NULL          -- no filter → return top 50
            OR OH.InvoiceNo              LIKE @Like
            OR C.CustomerName            LIKE @Like
            OR C.MobileNumber            LIKE @Like
            OR OT.OrderTypeName          LIKE @Like
            OR L.description             LIKE @Like
            OR LR.description            LIKE @Like
            OR CASE OH.Status
                   WHEN 'C' THEN 'Approved'
                   WHEN 'X' THEN 'Cancel'
                   ELSE          'Not Approved'
               END                       LIKE @Like
            OR CASE dbo.fn_SPO_IsOrderDispatched(OH.PropertyId, OH.OrderId)
                   WHEN 1 THEN 'Dispatched'
                   ELSE        'Not Dispatched'
               END                       LIKE @Like
            OR CONVERT(NVARCHAR(10), OH.DeliveryDate, 120) LIKE @Like
        )
    ORDER BY
        OH.OrderId DESC;
END

GO

