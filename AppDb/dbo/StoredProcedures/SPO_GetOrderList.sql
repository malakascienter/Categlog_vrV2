-- =============================================
-- Author:		Ravindu
-- Create date: 2026-02-27
-- Description:	Get Order list in SPO
-- =============================================
-- EXEC [dbo].[SPO_GetOrderList] 1,'DER',1
CREATE    PROCEDURE [dbo].[SPO_GetOrderList]
(
	 @PropertyId INT,
	 @DeliveryOutletCode VARCHAR(5) = NULL,
     @IsTodayDispatch BIT = NULL
)
AS
BEGIN  
    SELECT
        OH.OrderId,
        OH.InvoiceNo,
        CAST(OH.CreatedDate AS DATE) AS CreatedDate,
        OH.CreatedBy,
        OH.OrderOutlet AS OderOutletCode,
        LR.description  AS OderOutletName,
        OH.DeliveryDate,
        OH.DeliveryOutlet,
        L.description AS DeliveryOutletName,
        C.CustomerName,
        C.MobileNumber,
        OH.TotalAmount,
        OH.NetAmount,
        dbo.fn_SPO_GetBalanceAmount(OH.OrderId) AS BalanceAmount,
        dbo.fn_SPO_GetDiscountApprovalAmount(OH.OrderId,1) AS ApprovedDiscount,
        dbo.fn_SPO_GetDiscountApprovalAmount(OH.OrderId,0) AS NonApprovedDiscount,
        dbo.fn_SPO_GetPaidAmount(OH.OrderId) AS AdvanceAmount,
        OT.MiniumAdvancePercentage,
        OT.PayBeforeDays
    FROM SPO_OrderHeader AS OH
    INNER JOIN SPO_OrderType    AS OT ON OT.ID          = OH.OrderTypeId
    INNER JOIN Location_Ref     AS L  ON L.code         = OH.DeliveryOutlet
    INNER JOIN SPO_Customer     AS C  ON C.ID           = OH.CustomerId
    INNER JOIN Location_Ref     AS LR ON LR.code        = OH.OrderOutlet
    WHERE OH.Status     = 'C'
      AND OH.PropertyId = @PropertyId
      AND (OH.DeliveryOutlet = @DeliveryOutletCode OR @DeliveryOutletCode IS NULL)
      AND (
            @IsTodayDispatch IS NULL
            OR @IsTodayDispatch = 0
            OR (
                @IsTodayDispatch = 1
                AND OH.DeliveryDate = CAST(GETDATE() AS DATE)
               )
          )
END

GO

