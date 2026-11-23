-- =============================================
-- Author:		Chiraj
-- Create date: 2020-07-06
-- Description:	Report_Consolidate_sales_TaxBreakDown
-- =============================================
--Report_Consolidate_sales_TaxBreakDown  '01/07/2020','06/07/2020','s02','2'
CREATE PROCEDURE [dbo].[Report_Consolidate_sales_TaxBreakDown]
 @FromDate	VARCHAR(10),        
 @ToDate	VARCHAR(10),
 @Outlet    VARCHAR(MAX),
 @PropertyId VARCHAR(2)
AS
BEGIN

	SET NOCOUNT ON;
	Select --BH.OrderNo 
	SUM(BH.Subtotal+BH.TaxVal1+BH.TaxVal2+BH.TaxVal3+BH.TaxVal4+BH.ServiceCharge) AS 'SubTotal'
	,SUM(BH.TaxVal1+BH.TaxVal2+BH.TaxVal3+BH.TaxVal4)AS 'TAX'	
	,SUM(BH.ServiceCharge) AS ServiceCharge
	,Sum(BH.pax) As Covers
	,L.description AS Outlet
	,L.code
	
	from BillHeader AS BH	
	INNER JOIN Location_Ref AS L ON L.code=BH.Outlet AND L.PropertyId=Bh.PropertyId
	--INNER JOIN paytrans P on p.orderno = BH.orderno
	--INNER JOIN paymenttypes T on P.paycode = t.paycode

	where
	BH.PropertyId=@PropertyId AND BH.OrderDate >= CONVERT(DATETIME,@FromDate,103) 
	AND BH.MealEntitlement<>'B'
	AND BH.OrderDate <= CONVERT(DATETIME,@ToDate,103)
	AND BH.Outlet=@Outlet-- IN (SELECT * FROM STRING_SPLIT(@Outlet,',')) 
	--And (T.novalue <> 1 or T.paycode = 'BR') and BH.Subtotal>0
	AND (OrderNo NOT IN (
				SELECT	PayTrans.OrderNo
				FROM	PayTrans 
					INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
				WHERE	((NoValue = 1) AND OrderDate >= CONVERT(DATETIME,@FromDate,103) 
		AND  OrderDate <= CONVERT(DATETIME,@ToDate,103) )
					AND (PayTrans.PayCode <> 'BR')  
					AND PayTrans.PropertyId = @PropertyId)
					
				)
	GROUP BY L.description,L.code
	--HAVING SUM(BH.Subtotal+BH.TaxVal1+BH.TaxVal2+BH.TaxVal3+BH.TaxVal2+BH.ServiceCharge)>0
END

GO

