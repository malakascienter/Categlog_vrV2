-- =============================================
-- Author:		BANU
-- ALTER date: 19/03/2019
-- Description:	PAYMENTWISE DETAILS REPORT
-- =============================================
--- Report_PaymentMethodDetails '01/02/2019','01/02/2019','001,002'
CREATE PROCEDURE [dbo].[Report_PaymentMethodDetails] (   
  @FromDate		VARCHAR(10),    
  @ToDate		VARCHAR(10),    
  @Outlet		VARCHAR(MAX),
  @PropertyId	VARCHAR(2)
)    
AS  
BEGIN 
	SELECT L.description AS 'Outlet', PM.Description AS 'PaymentTypeDesc', SUM(PT.ActualAmt) AS 'Amount', COUNT(PT.OrderNo) AS 'NoOfBills'  
	FROM PayTrans PT    
	INNER JOIN PaymentTypes PM ON PT.PayCode = PM.PayCode AND PT.PropertyId=PM.PropertyId
	INNER JOIN Location_Ref L ON PT.Outlet = L.code   AND PT.PropertyId=L.PropertyId 
	WHERE  (PT.OrderDate >= CONVERT(datetime,@Fromdate,103)) 
		AND (PT.OrderDate <= CONVERT(datetime,@ToDate,103))   
		AND PT.Outlet IN ( SELECT * FROM STRING_SPLIT(@Outlet,',')) AND PT.PropertyId=@PropertyId
		AND (OrderNo NOT IN (
				SELECT	PayTrans.OrderNo
				FROM	PayTrans 
					INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
				WHERE	((NoValue = 1) AND OrderDate >= CONVERT(DATETIME,@FromDate,103) 
		AND  OrderDate <= CONVERT(DATETIME,@ToDate,103) )
					AND (PayTrans.PayCode <> 'BR')  
					AND PayTrans.PropertyId = @PropertyId)
					
				)
	GROUP BY L.description,  PM.Description
END

GO

