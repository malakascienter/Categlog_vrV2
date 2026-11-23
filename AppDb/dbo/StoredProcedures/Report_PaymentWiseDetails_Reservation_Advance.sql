

CREATE procedure [dbo].[Report_PaymentWiseDetails_Reservation_Advance] (    
     
  @FromDate as varchar(20),    
  @ToDate as varchar(20),    
  @Outlet varchar(MAX),
  @PropertyId INT
)    
    
AS    
   
SELECT       
Location_Ref.description AS Outlet, 
A.DocNo AS OrderNo, 
A.DocDate AS OrderDate, 
PaymentTypes.Description AS Expr1,
A.ActualAmount AS ActualAmt,
A.Remarks AS Remark, 
A.UserName  AS UserID, 
'Reservation' AS BType    
FROM   [POS_AdvancePayment] A
INNER JOIN PaymentTypes ON A.PayCode = PaymentTypes.PayCode AND A.PropertyId = PaymentTypes.PropertyId
INNER JOIN Location_Ref ON A.OutletCode = Location_Ref.code  AND A.PropertyId = Location_Ref.PropertyId
WHERE     
(A.DocDate >= convert(datetime,@Fromdate,103)) 
AND (A.DocDate <= convert(datetime,@ToDate,103))   
AND A.OutletCode IN ( SELECT * FROM string_split(@Outlet,','))    
AND A.PropertyId = @PropertyId

GO

