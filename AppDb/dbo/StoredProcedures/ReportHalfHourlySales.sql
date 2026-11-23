
-- =============================================
-- Author:		
-- ALTER date: 
-- Description:	Generate HALF HOURLY SALES REPORT
-- ============================================= 
CREATE PROCEDURE [dbo].[ReportHalfHourlySales] (@FromDate varchar(10), @ToDate varchar(10),@Outlet varchar(3))  
AS  
BEGIN  
  
 SET NOCOUNT ON;  
 --set dateformat dmy   
  
 select Orderdate,OrdTime, count(*) OrdCount, sum(GrossSale) GrossSale, sum(Discount) Discount, sum(Tax) Tax, sum(NetSale) NetSale,Order_HOUR   from(  
 select orderdate,OrderNo, OrdTime, GrossSale , Discount, Tax , NetSale,Order_HOUR  from(  
 select  orderdate, OrderNo,cast(datepart(HOUR,ordertime) as varchar) + ':'+ case when datepart(MINUTE,ordertime)>30 then '30' else '00' end OrdTime,datepart(HOUR,ordertime) AS Order_HOUR,  
 Subtotal + Discount + TaxVal1 + TaxVal2 + TaxVal3 + TaxVal4 GrossSale, Discount,TaxVal1+ TaxVal2+ TaxVal3+ TaxVal4 Tax , (Subtotal) NetSale -- - Discount - (TaxVal1+ TaxVal2+ TaxVal3+ TaxVal4)  
  from BillHeader where Outlet=@Outlet and orderdate>=convert(datetime,@FromDate,103) and orderdate<=convert(datetime,@ToDate,103) ) Sales  
 ) GSales group by Orderdate, OrdTime,Order_HOUR order by Orderdate,Order_HOUR,OrdTime  
  
  
 --order time, order count, gross, discount,tax, net sales cumulative  
  
END

GO

