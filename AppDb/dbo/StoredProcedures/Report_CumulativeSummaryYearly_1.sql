
-- =============================================
-- Author:		BANU
-- ALTER date: 12/11/2018
-- Description:	REPORT CUMULATIVE SALES SUMMARY 
-- =============================================
CREATE PROCEDURE [dbo].[Report_CumulativeSummaryYearly_1]        
(      
 @Outlet char(3),      
 @FromYear INT,      
 @OrderType CHAR(1)      
)          
AS      
BEGIN      
      
      
SELECT SUM(Qty) AS Qty, SUM(Value) AS Value, OrderType, Month_Name, Month_No,GrpOrder, Year FROM(        
    
 ------------SELECTED ORDER TYPE ONLY     
  SELECT    COUNT(BillHeader.OrderNo) AS Qty, SUM(BillHeader.Subtotal) AS Value, POSOrderTypes.Name AS OrderType, 1 AS GrpOrder,       
    DATENAME(MONTH,BillHeader.OrderDate) AS Month_Name, MONTH(BillHeader.OrderDate) AS Month_No, YEAR(BillHeader.OrderDate) AS Year      
  FROM   BillHeader      
   LEFT OUTER JOIN POSOrderTypes ON BillHeader.OrderType = POSOrderTypes.Code      
  WHERE BillHeader.Outlet =@Outlet       
  AND YEAR(BillHeader.OrderDate) = @FromYear      
  AND BillHeader.OrderType = @OrderType       
  GROUP BY   POSOrderTypes.Name, Month(BillHeader.OrderDate), DATENAME(MONTH,BillHeader.OrderDate),YEAR(BillHeader.OrderDate)      
      
 UNION ALL       
      
 ------------OTHER ALL ORDER TYPES    
  SELECT    COUNT(BillHeader.OrderNo) AS Qty, SUM(BillHeader.Subtotal) AS Value, 'Other' AS OrderType, 2 AS GrpOrder,       
    DATENAME(MONTH,BillHeader.OrderDate) AS Month_Name, MONTH(BillHeader.OrderDate) AS Month_No, YEAR(BillHeader.OrderDate) AS Year      
  FROM   BillHeader       
   LEFT OUTER JOIN POSOrderTypes ON BillHeader.OrderType = POSOrderTypes.Code      
  WHERE BillHeader.Outlet =@Outlet       
  AND YEAR(BillHeader.OrderDate) = @FromYear      
  AND BillHeader.OrderType != @OrderType       
  GROUP BY  Month(BillHeader.OrderDate),DATENAME(MONTH,BillHeader.OrderDate) , YEAR(BillHeader.OrderDate)      
      
 ) MAIN      
 GROUP BY OrderType,Month_Name,Month_No,Year,GrpOrder      
END

GO

