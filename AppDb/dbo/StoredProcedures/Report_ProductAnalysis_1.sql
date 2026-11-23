
-- =============================================
-- Author:		Banu
-- ALTER date: 11/12/2018
-- Description:	Report Product Analysis in HotelRes
-- =============================================
------exec ReportProductAnalysis '01/11/2018','30/11/2018','001,002'
CREATE PROCEDURE [dbo].[Report_ProductAnalysis_1] (
	@FromDate varchar(10), 
	@ToDate varchar(10),
	@Outlet NVARCHAR(MAX))  
AS  
BEGIN    
 SET NOCOUNT ON;  
 --set dateformat dmy  
 SELECT * FROM(  
	 select ItemCode, CatDescription, ItemDescription, sum(Qty) Qty, SellPrice, sum(Qty)*SellPrice TotSales, Outlet, OutletDes   from (  
		select BT.MainMenuCode AS ItemCode,--+ ' ' + BT.SubMenuCode ItemCode,
		 CT.Description CatDescription, Mn.Description AS ItemDescription, BT.Qty,  
			BT.Rate AS SellPrice ,BT.Outlet,L.description AS OutletDes 
		from BillHeader BH 
		inner join BillTrans BT on BH.orderno =BT.OrderNo and BH.outlet=BT.Outlet AND BH.OrderDate =BT.OrderDate  
		inner join MainMenu MN on BT.MainMenuCode = MN.ItemCode 
		inner join Location_Ref L on BH.Outlet = L.code
		inner join --SubMenu SM on BT.MainMenuCode = SM.MainMenuCode and BT.SubMenuCode = SM.SubMenuCode inner join  
		Category CT on MN.Category = CT.Code 
		where BH.OrderDate >= convert(datetime,@FromDate,103) and BH.OrderDate <= convert(datetime,@ToDate ,103) AND BH.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,',') ) 
 ) DT group by ItemCode, ItemDescription, SellPrice, CatDescription ,Outlet, OutletDes) ItemWise  
 cross join  
 (select sum(Subtotal + TaxVal + Discount) GrossSale, sum(TaxVal) TaxVal, sum(Discount) Discount, sum(Subtotal + TaxVal) NetSale       
 ,count(*) TicketCount,sum(Subtotal+Discount+ TaxVal)/count(*) TicketAvg from (  
 select Subtotal,Discount,TaxVal1+  TaxVal2+ TaxVal3+ TaxVal4 TaxVal from BillHeader  where  orderdate>= convert(datetime,@FromDate,103)  and orderdate<= convert(datetime,@ToDate ,103) AND Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,',')) ) SumVal   ) ss  
 
  
END

GO

