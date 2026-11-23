
CREATE PROCEDURE [dbo].[Report_GiftVoucherSalesPaymentDetail](          
 @FromDate	VARCHAR(10),        
 @ToDate	VARCHAR(10),
 @Outlet    VARCHAR(MAX),
 @PropertyId VARCHAR(2)
)        
AS        
BEGIN         


SELECT       L.description As Outlet, SaleDate,SaleOrderNo,CONCAT(TypePrefix,'-',Amount) AS Description,Amount,COUNT(*) AS Qty,Amount*COUNT(*) as TotalAmount,
GVT.ActualAmt AS PayAmt,PT.Description AS PayType
FROM            POS_GiftVoucher GV
INNER JOIN Location_Ref L ON L.code = GV.SaleOutlet AND L.PropertyId = GV.PropertyId
INNER JOIN POS_GiftVoucherPayTrans GVT ON GV.SaleDate = GVT.DocDate AND GV.SaleOrderNo = GVT.DocNo AND GV.SaleOutlet = GVT.Outlet AND GV.PropertyId = GVT.PropertyId
INNER JOIN PaymentTypes PT ON GVT.PayCode = PT.PayCode AND GVT.PropertyId = PT.PropertyId
WHERE GV.SaleOutlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))  AND GV.PropertyId=@PropertyId   
AND GV.SaleDate >= CONVERT(DATETIME,@FromDate,103) AND GV.SaleDate <= CONVERT(DATETIME,@ToDate,103)  AND ISNULL(GV.SaleOrderNo,'') <> ''
GROUP BY  SaleDate,SaleOrderNo,TypePrefix,Amount,L.description
,GVT.ActualAmt,PT.Description


END;

GO

