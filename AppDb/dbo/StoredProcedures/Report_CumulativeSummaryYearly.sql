
-- =============================================
-- Author:		BANU
-- ALTER date: 12/11/2018
-- Description:	REPORT CUMULATIVE SALES SUMMARY 
-- =============================================
----EXECUTE Report_CumulativeSummaryYearly '001',2018,'T,R,Y,D,I,P'
CREATE PROCEDURE [dbo].[Report_CumulativeSummaryYearly]        
(      
 @Outlet char(3),      
 @FromYear INT,      
 @OrderType VARCHAR(MAX),
 @PropertyId VARCHAR(2)
)          
AS      
BEGIN      
      
      
SELECT SUM(Qty) AS Qty, SUM(Value) AS Value, OrderType, Month_Name, Month_No,GrpOrder, Year FROM(        
    
 ------------SELECTED ORDER TYPE ONLY     
  SELECT    COUNT(BillHeader.OrderNo) AS Qty, SUM(BillHeader.Subtotal+BillHeader.TaxVal1+BillHeader.TaxVal2+BillHeader.TaxVal3+BillHeader.TaxVal4+BillHeader.ServiceCharge) AS Value, POSOrderTypes.Name AS OrderType, 1 AS GrpOrder,       
    DATENAME(MONTH,BillHeader.OrderDate) AS Month_Name, MONTH(BillHeader.OrderDate) AS Month_No, YEAR(BillHeader.OrderDate) AS Year      
  FROM   BillHeader      
   LEFT OUTER JOIN POSOrderTypes ON BillHeader.OrderType = POSOrderTypes.Code   AND BillHeader.PropertyId=POSOrderTypes.PropertyId   
  WHERE
  BillHeader.Outlet =@Outlet  
  AND BillHeader.PropertyId=@PropertyId     
  AND YEAR(BillHeader.OrderDate) = @FromYear      
  AND BillHeader.OrderType IN (SELECT * FROM STRING_SPLIT(@OrderType,','))   
  AND ( BillHeader.OrderNo NOT IN (
								SELECT	PayTrans.OrderNo
								FROM	PayTrans 
								INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
								WHERE	((PaymentTypes.NoValue = 1) 
								AND YEAR(PayTrans.OrderDate) = @FromYear     )
								AND (PayTrans.PayCode <> 'BR')  
								AND PayTrans.PropertyId = @PropertyId
								AND PayTrans.Outlet =@Outlet 
					
								)
		)
  GROUP BY   POSOrderTypes.Name, Month(BillHeader.OrderDate), DATENAME(MONTH,BillHeader.OrderDate),YEAR(BillHeader.OrderDate)      
      
 --UNION ALL       
      
 --------------OTHER ALL ORDER TYPES    
 -- SELECT    COUNT(BillHeader.OrderNo) AS Qty, SUM(BillHeader.Subtotal) AS Value, 'Other' AS OrderType, 2 AS GrpOrder,       
 --   DATENAME(MONTH,BillHeader.OrderDate) AS Month_Name, MONTH(BillHeader.OrderDate) AS Month_No, YEAR(BillHeader.OrderDate) AS Year      
 -- FROM   BillHeader       
 --  LEFT OUTER JOIN POSOrderTypes ON BillHeader.OrderType = POSOrderTypes.Code      
 -- WHERE BillHeader.Outlet =@Outlet       
 -- AND YEAR(BillHeader.OrderDate) = @FromYear      
 -- AND BillHeader.OrderType != @OrderType       
 -- GROUP BY  Month(BillHeader.OrderDate),DATENAME(MONTH,BillHeader.OrderDate) , YEAR(BillHeader.OrderDate)      
      
 ) MAIN      
 GROUP BY OrderType,Month_Name,Month_No,Year,GrpOrder      
END

GO

