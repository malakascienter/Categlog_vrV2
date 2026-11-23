
-- =============================================
-- Author:		Banu
-- ALTER date: 
-- Description:	GROSS ANALYZE REPORT
-- =============================================
--Report_PaymentWiseDetails '01/07/2020','09/07/2020','S01,s02','2'
CREATE procedure [dbo].[Report_PaymentWiseDetailsOnlyAdvance] (    
     
  @FromDate as varchar(20),    
  @ToDate as varchar(20),    
  @Outlet varchar(MAX),
  @PropertyId INT
)    
    
 as    
   
SELECT       
Location_Ref.description AS Outlet, 
BillHeader.OrderNo, 
BillHeader.OrderDate, 
'Advance' AS Expr1,
PayTrans.ActualAmt,
PayTrans.Remark, 
W.Name  AS UserID, 
'Restaurant' AS BType    
FROM   BillHeader 
INNER JOIN PayTrans ON BillHeader.OrderNo = PayTrans.OrderNo AND BillHeader.OrderDate = PayTrans.OrderDate AND BillHeader.Outlet = PayTrans.Outlet   AND PayTrans.PropertyId=@PropertyId 
INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode AND PaymentTypes.PropertyId=@PropertyId
INNER JOIN Location_Ref ON BillHeader.Outlet = Location_Ref.code  AND Location_Ref.PropertyId=@PropertyId  
INNER JOIN Waiter  W ON PayTrans.UserID = W.Code
WHERE     
(BillHeader.OrderDate >= convert(datetime,@Fromdate,103)) 
AND (BillHeader.OrderDate <= convert(datetime,@ToDate,103))   
AND BillHeader.Outlet IN ( SELECT * FROM string_split(@Outlet,','))    
AND BillHeader.PropertyId=@PropertyId
AND PayTrans.Remark = 'Advance Amount'

GO

