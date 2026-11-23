
-- =============================================
-- Author:		Banu
-- ALTER date: 11/12/2018
-- Description:	Report Product Analysis in HotelRes
-- =============================================
------exec Report_ProductAnalysis '26/06/2020','26/06/2020','D01','B,D01','R,T,Y,D,P','2',1
CREATE PROCEDURE [dbo].[Report_ProductAnalysis] (
	@FromDate varchar(10), 
	@ToDate varchar(10),
	@Outlet VARCHAR(MAX),
	@MainMenuCategory VARCHAR(MAX),
	@OrderType VARCHAR(MAX),
	@MealType VARCHAR(MAX),
	@PropertyId VARCHAR(2)
)
AS  
BEGIN    
 SET NOCOUNT ON;  
 --set dateformat dmy 
  
 --------SELECT * FROM(  
	-------- select ItemCode, CatDescription, ItemDescription, sum(Qty) Qty, SellPrice, sum(Qty)*SellPrice TotSales, Outlet, OutletDes   from (  
	--------	select BT.MainMenuCode AS ItemCode,--+ ' ' + BT.SubMenuCode ItemCode,
	--------	 CT.Description CatDescription, Mn.Description AS ItemDescription, BT.Qty,  
	--------		BT.Rate AS SellPrice ,BT.Outlet,L.description AS OutletDes 
	--------	from BillHeader BH 
	--------	inner join BillTrans BT on BH.orderno =BT.OrderNo and BH.outlet=BT.Outlet AND BH.OrderDate =BT.OrderDate  
	--------	inner join MainMenu MN on BT.MainMenuCode = MN.ItemCode 
	--------	inner join Location_Ref L on BH.Outlet = L.code
	--------	inner join --SubMenu SM on BT.MainMenuCode = SM.MainMenuCode and BT.SubMenuCode = SM.SubMenuCode inner join  
	--------	Category CT on MN.Category = CT.Code 
	--------	where BH.OrderDate >= convert(datetime,@FromDate,103) 
	--------		 AND BH.OrderDate <= convert(datetime,@ToDate ,103)
	--------		 AND BH.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))
	--------		 AND CT.Code IN (SELECT * FROM STRING_SPLIT(@MainMenuCategory,','))
	--------		 AND BT.OrderType IN (SELECT * FROM STRING_SPLIT(@OrderType,','))
	--------		 --AND BT.Rate != 0
	--------		 --AND MN.IsMainPage = 0
	--------		 --AND LEN(LTRIM(RTRIM(BT.MainMenuCode))) < 4
 --------) DT group by ItemCode, ItemDescription, SellPrice, CatDescription ,Outlet, OutletDes) ItemWise  
 --------cross join  
 --------(select sum(Subtotal + TaxVal + Discount) GrossSale, sum(TaxVal) TaxVal, sum(Discount) Discount, sum(Subtotal + TaxVal) NetSale       
 --------,count(*) TicketCount,sum(Subtotal+Discount+ TaxVal)/count(*) TicketAvg from (  
 --------select Subtotal,Discount,TaxVal1+  TaxVal2+ TaxVal3+ TaxVal4 TaxVal from BillHeader  
	--------where  orderdate>= convert(datetime,@FromDate,103) 
	-------- and orderdate<= convert(datetime,@ToDate ,103) AND 
	-------- Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))  
	-------- AND OrderType IN (SELECT * FROM STRING_SPLIT(@OrderType,','))
	-------- ) SumVal   ) ss  
 
  SELECT * FROM(  
	 select ItemCode, CatDescription, ItemDescription, sum(Qty) Qty, SellPrice, sum(Qty)*SellPrice TotSales, Outlet, OutletDes ,ItemCategory  from (  
		select BT.MainMenuCode AS ItemCode,--+ ' ' + BT.SubMenuCode ItemCode,
		 CT.Description CatDescription, Mn.Description AS ItemDescription, BT.Qty,  
			BT.Rate AS SellPrice ,BT.Outlet,L.description AS OutletDes ,IC.Name as ItemCategory
		from BillHeader BH 
		inner join BillTrans BT on BH.orderno =BT.OrderNo and BH.outlet=BT.Outlet AND BH.OrderDate =BT.OrderDate  AND BT.PropertyId=BH.PropertyId
		inner join MainMenu MN on BT.MainMenuCode = MN.ItemCode AND MN.PropertyId=BT.PropertyId
		inner join Location_Ref L on BH.Outlet = L.code AND L.PropertyId=BH.PropertyId
		inner join ItemCategory IC on MN.ItemCategory = IC.Id  
		inner join --SubMenu SM on BT.MainMenuCode = SM.MainMenuCode and BT.SubMenuCode = SM.SubMenuCode inner join  
		Category CT on MN.Category = CT.Code 
		where BH.OrderDate >= convert(datetime,@FromDate,103) 
			 AND BH.OrderDate <= convert(datetime,@ToDate ,103)
			 AND BH.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))
			 AND CT.CatgId IN (SELECT * FROM STRING_SPLIT(@MainMenuCategory,','))
			 AND BT.OrderType IN (SELECT * FROM STRING_SPLIT(@OrderType,','))
			 AND MN.ItemCategory IN (SELECT * FROM STRING_SPLIT(@MealType,','))
			 AND  BH.PropertyId=@PropertyId
			  AND ( BH.OrderNo NOT IN (
								SELECT	PayTrans.OrderNo
								FROM	PayTrans 
								INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
								WHERE	((PaymentTypes.NoValue = 1) 
								AND PayTrans.OrderDate >=CONVERT(DATETIME,@Fromdate,103) 
								AND PayTrans.OrderDate <=CONVERT(DATETIME,@Todate,103)  
								AND (PayTrans.PayCode <> 'BR')  
								AND PayTrans.PropertyId = @PropertyId
								 )
					
								)
		)
 ) DT group by ItemCode, ItemDescription, SellPrice, CatDescription ,Outlet, OutletDes,ItemCategory) ItemWise  
 cross join  
 (select 
 sum(Subtotal + TaxVal + Discount + ServiceCharge) GrossSale,
 SUM(ServiceCharge) AS ServiceCharge,
 sum(TaxVal) TaxVal, sum(Discount) Discount,
 sum(Subtotal + TaxVal+ServiceCharge) NetSale       
 ,count(*) TicketCount,
 sum(Subtotal+Discount+ TaxVal+ServiceCharge)/count(*) TicketAvg 
 from (  
	select Subtotal,Discount,TaxVal1+  TaxVal2+ TaxVal3+ TaxVal4  TaxVal,ServiceCharge from BillHeader  
	where  orderdate>= convert(datetime,@FromDate,103) 
	 and orderdate<= convert(datetime,@ToDate ,103) AND 
	 Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))  
	 AND OrderType IN (SELECT * FROM STRING_SPLIT(@OrderType,',')) AND PropertyId=@PropertyId
	  AND ( BillHeader.OrderNo NOT IN (
								SELECT	PayTrans.OrderNo
								FROM	PayTrans 
								INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
								WHERE	((PaymentTypes.NoValue = 1) 
								AND PayTrans.OrderDate >=CONVERT(DATETIME,@Fromdate,103) 
								AND PayTrans.OrderDate <=CONVERT(DATETIME,@Todate,103)  
								AND (PayTrans.PayCode <> 'BR')  
								AND PayTrans.PropertyId = @PropertyId
								 )
					
								)
		)

	 ) SumVal   ) ss
END

GO

