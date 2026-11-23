
-- =============================================
-- Author:		Banu
-- ALTER date: 06/12/2018
-- Description:	Discount Report
-- =============================================
----EXEC Report_Discount 'S01,S02','01/07/2020','09/07/2020',2
CREATE PROCEDURE [dbo].[Report_Discount]
	 @Outlet VARCHAR(MAX),
	 @FromDate VARCHAR(20),      
	 @ToDate VARCHAR(20),
	 @PropertyId VARCHAR(2)
AS
BEGIN
	SELECT L.description, SUM(BH.Subtotal) AS SubTotal, SUM(BH.TaxVal1+BH.TaxVal2+BH.TaxVal3+BH.TaxVal4) AS Tax,      
		BH.OrderNo, BH.OrderDate, BH.pax AS 'Pax', SUM(BH.Discount) AS Discount, SUM(BH.ServiceCharge) AS ServiceCharge ,DH.Description AS Reason  ,W.Name AS Users     
	FROM BillHeader BH    
	INNER JOIN DiscountHeader AS DH ON BH.discode=DH.Code --AND DH.PropertyId=BH.PropertyId
	INNER JOIN PayTrans PT ON BH.OrderNo = PT.OrderNo AND BH.OrderDate = PT.OrderDate AND BH.Outlet = PT.Outlet    AND PT.PropertyId=BH.PropertyId    
	INNER JOIN PaymentTypes PYT ON PT.PayCode = PYT.PayCode  AND PYT.PropertyId=PT.PropertyId     
	INNER JOIN Location_Ref L ON BH.Outlet = L.code   AND   L.PropertyId=BH.PropertyId	    
	INNER JOIN Waiter W ON BH.UserID = W.Code
	WHERE  
	BH.PropertyId=@PropertyId
	AND (BH.OrderDate >= CONVERT(DATETIME,@FromDate,103)) 
	AND (BH.OrderDate <= CONVERT(DATETIME,@ToDate,103))     
	AND BH.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))       
	GROUP BY BH.OrderNo,BH.OrderDate, L.description,DH.Description ,BH.pax,W.Name
	HAVING SUM(BH.Discount) > 0 
	ORDER BY L.description , BH.OrderNo  
END

GO

