-- =============================================
-- Author:      Ravindu
-- Create date: 2026-03-31
-- Description: Get order details with 4 separate JSON sections
--              OrderDetails, ItemDetails, DiscountDetails, PaymentDetails
-- =============================================
-- EXEC [dbo].[SPO_GetOrderDetailsForOrderInquery] 2113,1
-- =============================================
CREATE   PROCEDURE [dbo].[SPO_GetOrderDetailsForOrderInquery]
(
    @OrderId INT,
    @PropertyId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    -- =============================================
    -- Variables to hold each section
    -- =============================================
    DECLARE @OrderDetails    NVARCHAR(MAX);
    DECLARE @ItemDetails     NVARCHAR(MAX);
    DECLARE @DiscountDetails NVARCHAR(MAX);
    DECLARE @PaymentDetails  NVARCHAR(MAX);
    DECLARE @TransferDetails NVARCHAR(MAX);

    -- =============================================
    -- SECTION 1 : Order Details
    -- =============================================
    SELECT @OrderDetails = (
        SELECT
            OH.OrderId,
            OH.InvoiceNo,
            CAST(OH.CreatedDate AS DATE)    AS CreatedDate,
            OH.CreatedBy,
            OH.OrderOutlet                  AS OrderOutletCode,
            LR.description                  AS OrderOutletName,
            OH.DeliveryDate,
            OH.DeliveryTime,
            OH.DeliveryOutlet               AS DeliveryOutletCode,
            L.description                   AS DeliveryOutletName,
            C.CustomerName,
            C.MobileNumber,
            OT.MiniumAdvancePercentage,
            OT.PayBeforeDays,
            CASE OH.Status
                WHEN 'C' THEN 'Approved'
                WHEN 'X' THEN 'Cancel'
                ELSE          'Not Approved'
            END                             AS Status,
            CASE dbo.fn_SPO_IsOrderDispatched(OH.PropertyId, OH.OrderId)
                WHEN 1 THEN 'Dispatched'
                ELSE        'Not Dispatched'
            END                             AS DispatchStatus
        FROM SPO_OrderHeader    AS OH
        INNER JOIN SPO_OrderType    AS OT  ON OT.ID    = OH.OrderTypeId
        INNER JOIN Location_Ref     AS L   ON L.code   = OH.DeliveryOutlet
        INNER JOIN SPO_Customer     AS C   ON C.ID     = OH.CustomerId
        INNER JOIN Location_Ref     AS LR  ON LR.code  = OH.OrderOutlet
        WHERE OH.OrderId = @OrderId AND OH.PropertyId = @PropertyId
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    );

    -- =============================================
    -- SECTION 2 : Item Details
    -- =============================================
    SELECT @ItemDetails = (
        SELECT
            OD.ItemCode,
            OD.ItemName,
            OD.Qty                          AS Quantity,
            OD.Price,
            OD.TotalAmount,
            MM.Category                     AS CategoryCode,
            OH.TotalAmount                  AS OrderTotalAmount,
            OH.NetAmount                    AS OrderNetAmount
        FROM SPO_OrderDetails   AS OD
        INNER JOIN SPO_OrderHeader  AS OH  ON OH.OrderId  = OD.OrderId
        INNER JOIN MainMenu         AS MM  ON MM.ItemCode = OD.ItemCode
        WHERE OD.OrderId = @OrderId AND OH.PropertyId = @PropertyId
        FOR JSON PATH
    );

    -- =============================================
    -- SECTION 3 : Discount Details
    -- =============================================
    SELECT @DiscountDetails = (
        SELECT
            DH.Description                                          AS DiscountName,
            OD.TotalDiscount,
            dbo.fn_SPO_GetDiscountApprovalAmount(@OrderId, 1)       AS ApprovedDiscount,
            dbo.fn_SPO_GetDiscountApprovalAmount(@OrderId, 0)       AS NonApprovedDiscount
        FROM (
            SELECT
                OD.DiscountType,
                SUM(OD.Discount) AS TotalDiscount
            FROM SPO_OrderDetails AS OD
            INNER JOIN SPO_OrderHeader AS OH ON OH.OrderId = OD.OrderId
            WHERE OD.OrderId    = @OrderId
              AND OH.PropertyId = @PropertyId
            GROUP BY OD.DiscountType
        ) AS OD
        INNER JOIN DiscountHeader AS DH ON DH.Id = OD.DiscountType
        FOR JSON PATH
    );

    -- =============================================
    -- SECTION 4 : Payment Details
    -- =============================================
    SELECT @PaymentDetails = (
        SELECT
            OH.TotalAmount,
            OH.NetAmount,
            dbo.fn_SPO_GetBalanceAmount(OH.OrderId)             AS BalanceAmount,
            dbo.fn_SPO_GetPaidAmount(OH.OrderId)                AS AdvanceAmount,
            dbo.fn_SPO_GetDiscountApprovalAmount(OH.OrderId, 1) AS ApprovedDiscount,
            OT.MiniumAdvancePercentage,
            OT.PayBeforeDays
        FROM SPO_OrderHeader    AS OH
        INNER JOIN SPO_OrderType AS OT ON OT.ID = OH.OrderTypeId
        WHERE OH.OrderId = @OrderId AND OH.PropertyId = @PropertyId
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    );

    -- =============================================
    -- SECTION 5: Transfer Rquest & Transfer Note
    -- =============================================
    DROP TABLE IF EXISTS #TempStockItemHeaders;
    SELECT SIH.StockItemCode, SIH.Name, SIH.Id
    INTO #TempStockItemHeaders
    FROM SPO_OrderHeader        AS OH
    INNER JOIN SPO_OrderDetails AS OD  ON OD.OrderId           = OH.OrderId
    INNER JOIN MainMenu         AS MM  ON MM.ItemCode           = OD.ItemCode
    INNER JOIN StockItemHeaders AS SIH ON SIH.Id                = MM.StockItemId
    INNER JOIN StockItemDetails AS SID ON SID.StockItemHeaderID = SIH.Id
    INNER JOIN Location_Ref     AS LR  ON LR.code               = OH.DeliveryOutlet
    WHERE OH.OrderId = @OrderId AND OH.PropertyId = @PropertyId
    GROUP BY SIH.StockItemCode, SIH.Name, SIH.Id;

    DROP TABLE IF EXISTS #TempTransferDetails;
    SELECT
        TSIH.Id             AS StockItemId,
        TSIH.StockItemCode  AS Itemcode,
        TSIH.Name           AS ItemName,
        CASE
            WHEN STH.IsTrasferIn = 1 THEN 'true'
            ELSE 'false'
        END                                     AS sent,
        ISNULL(STH.DocumentNo, 'N/A')           AS TransferOutNo,
        ISNULL(RH.DocumentNo,  'N/A')           AS TRNumber,
        CASE
            WHEN (
                SELECT SUM(DD.IssuedQuantity)
                FROM Categlog_vrV2..RequestDetails DD
                WHERE DD.RequestHeaderID = RH.Id
            ) > 0 THEN 'Approved'
            ELSE 'Pending'
        END                                     AS TRStatus
    INTO #TempTransferDetails
    FROM #TempStockItemHeaders          TSIH
    LEFT JOIN SPO_OrderHeader           OH
        ON  OH.OrderId    = @OrderId
        AND OH.PropertyId = @PropertyId
    LEFT JOIN StockTransactionDetails   STD
        ON  STD.StockItemID             = TSIH.Id
    LEFT JOIN StockTransactionHeaders   STH
        ON  STH.Id                      = STD.StockTransactionHeaderID
        AND STH.TransactionType         = 'TO'
    LEFT JOIN RequestHeaders            RH
        ON  RH.Id                       = STH.ReferenceID
        AND RH.RequestType              = 'RT'
        AND RH.JobNo                    = OH.InvoiceNo         
    LEFT JOIN RequestDetails            RD
        ON  RD.RequestHeaderID          = RH.Id
        AND RD.StockItemID              = TSIH.Id
    WHERE
        STH.TransactionType = 'TO'
        AND RH.RequestType  = 'RT'
        AND RH.JobNo        = OH.InvoiceNo;        

    SELECT @TransferDetails = (
        SELECT
            T1.Id               AS StockItemId,
            T1.StockItemCode    AS Itemcode,
            T1.Name             AS ItemName,
            T2.sent,
            T2.TransferOutNo,
            T2.TRNumber,
            T2.TRStatus
        FROM #TempStockItemHeaders  T1
        LEFT JOIN #TempTransferDetails T2 ON T2.StockItemId = T1.Id
        FOR JSON PATH
    );

    -- =============================================
    -- Final : Combine all sections into one JSON
    -- =============================================
    SELECT (
        SELECT
            JSON_QUERY(@OrderDetails)    AS OrderDetails,
            JSON_QUERY(@ItemDetails)     AS ItemDetails,
            JSON_QUERY(@DiscountDetails) AS DiscountDetails,
            JSON_QUERY(@PaymentDetails)  AS PaymentDetails,
            JSON_QUERY(@TransferDetails) AS TransferDetails
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ) AS Result;

END

GO

