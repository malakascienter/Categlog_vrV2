-- =============================================
-- Author:		Nivesh
-- Create date: 2025-12-30
-- Description:	Get Order recall data
-- =============================================
CREATE   PROCEDURE [dbo].[SPO_SP_GetOrderRecallData] 
    @OrderID INT,
    @OrderDetailJSON NVARCHAR(MAX) OUTPUT 
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IsItemWiseDiscount BIT = 0;
    DECLARE @TotalItemDiscount  DECIMAL(18,2) = 0; 

    SELECT @IsItemWiseDiscount = IsItemWiseDiscount
    FROM SPO_OrderHeader
    WHERE OrderId = @OrderID;

    IF (@IsItemWiseDiscount = 0)
    BEGIN
        SELECT @TotalItemDiscount = ISNULL(SUM(OD.Discount), 0)
        FROM SPO_OrderDetails OD
        WHERE OD.OrderId  = @OrderID
        AND   OD.ItemCode = OD.RefItemCode
    END
    -- ============================================================

    SET @OrderDetailJSON =
    JSON_QUERY((
        SELECT 
            OH.OrderId,
            OH.CustomerId,
            OH.MobileNo,
            OH.OrderTypeId,
            CONVERT(VARCHAR(10), OH.DeliveryDate, 23)   AS DeliveryDate,
            CONVERT(VARCHAR(8),  OH.DeliveryTime, 108)  AS DeliveryTime,
            OH.DeliveryOutlet,
            OH.OrderOutlet,
            OH.OrderRemark,
            OH.TotalAmount,
            OH.NetAmount,
            OH.AmendCount,
            OH.LastAmendUser,
            OH.LastAmendDate,
            OH.IsAmend,
            OH.IsItemWiseDiscount,
            JSON_QUERY(OH.TotalBillDiscountJSON) AS TotalBillDiscount,

            --   IsItemWiseDiscount = 0 → sum of all item discounts
            --   IsItemWiseDiscount = 1 → 0 (each item carries its own)
            CASE 
                WHEN @IsItemWiseDiscount = 0 THEN @TotalItemDiscount
                ELSE 0                                          
            END AS Discount,

            (
                SELECT 
                    OD.OrderDetailId,
                    OD.OrderId,
                    OD.ItemCode,
                    OD.ItemName,
                    OD.Price,
                    OD.Qty,
                    OD.TotalAmount,
                    OD.ItemRemark,

                    CASE 
                        WHEN @IsItemWiseDiscount = 1 THEN OD.Discount
                        ELSE 0
                    END AS Discount,

                    CASE 
                        WHEN @IsItemWiseDiscount = 1 THEN OD.DiscountType
                        ELSE 0
                    END AS DiscountType,
                    (
                        SELECT
                            SUB.ItemCode,
                            SUB.ItemName,
                            ''   AS LevelName,
                            0.00 AS AddRate
                        FROM SPO_OrderDetails SUB
                        WHERE SUB.OrderId     = @OrderID
                        AND   SUB.RefItemCode = OD.ItemCode
                        AND   SUB.ItemCode   != OD.ItemCode
                        FOR JSON PATH
                    ) AS SetMenuSubItems

                FROM SPO_OrderDetails OD
                WHERE OD.OrderId  = @OrderID
                AND   OD.ItemCode = OD.RefItemCode
                FOR JSON PATH
            ) AS ItemList

        FROM SPO_OrderHeader OH
        WHERE OH.OrderId = @OrderID
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ));
END

GO

