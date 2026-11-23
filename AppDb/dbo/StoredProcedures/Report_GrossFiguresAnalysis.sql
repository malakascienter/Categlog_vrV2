

-- =============================================
-- Author:		
-- Create date: 
-- Description:	Gross Figures Analysis REPORT
-- =============================================
----exec Report_GrossFiguresAnalysis '01/06/2020', '24/06/2020','D01,D02',1
 CREATE PROCEDURE [dbo].[Report_GrossFiguresAnalysis]   -- Gross Figures Analysis
(

 @FromDate varchar(10),
 @ToDate varchar(10),
 @Outlet varchar(max),
 @PropertyId INT
)

AS

-- declare @FromDate varchar(10),
-- @ToDate varchar(10),
-- @Outlet char(3)

--set @FromDate ='01/06/2018'
--set @ToDate ='04/07/2018'
--set @Outlet ='XXX'


Declare @table table
(
	OrderID int,
	Description    varchar(200),
	Amount	money,
	IsBlankLine bit,
	IsBold bit,
	IsItalic bit,
	IsaHeader bit,
	OtherValue varchar(100),
	Outlet varchar(3)
)

Declare @GrossSales money =0,
		@NetSales money =0,
		@TAX1 MONEY=0,
		@TAX2 MONEY=0,
		@TAX3 MONEY=0,
		@TAX4 MONEY=0,
		@SC money=0,
		@VOIDGrossSales money =0,
		@VOIDNetSales money =0,
		@VOIDTAX1 MONEY=0,
		@VOIDTAX2 MONEY=0,
		@VOIDTAX3 MONEY=0,
		@VOIDTAX4 MONEY=0,
		@VOIDSC money=0,
		@VOIDDiscounts money=0,
		@Discounts money=0,
		@Voucher money=0,
		@OPENINGFLOAT MONEY=0,
		@CLOSINGFLOAT MONEY=0,
		@ADVANCE MONEY=0,
		@NUMBEROFVOIDS MONEY=0,
		@NUMBEROFORDERS MONEY=0,
		@TotalStaffDiscount money=0,
		@ExpectedBankDposit money=0,
		@ActualBankDeposit money=0,
	 @count INT,
	 @increment int = 1,
	 @CurOutlet varchar(3),
	 @DayendEnteredAmount money=0 ;

	 select @count = COUNT(*) FROM string_split(@Outlet,',')
WHILE(@increment <= @count)
BEGIN
		Select @CurOutlet = value from 
		(select value,ROW_NUMBER() over (order by value asc) AS RowNumber  FROM string_split(@Outlet,',') )T
		where RowNumber = @increment
			
			select 
			@NUMBEROFORDERS =isnull(count(OrderNo),0),
			@NetSales=isnull(sum(subtotal),0),
			@TAX1 = isnull(sum(TaxVal1),0) ,
			@TAX2=isnull(sum(TaxVal2),0),
			@tax3=isnull(sum(TaxVal3),0),
			@tax4=isnull(sum(taxval4),0),
			@SC=isnull(sum(Servicecharge),0), 
			@GrossSales=isnull(sum(subtotal+TaxVal1+TaxVal2+taxval3+TaxVal4 + Discount + servicecharge),0),
			@Discounts=isnull(sum(Discount),0) 
			from BillHeader 
			where 
			orderdate>=convert(datetime,@FromDate,103) 
			and orderdate<=convert(datetime,@ToDate,103) 
			and outlet= @CurOutlet 
			and PropertyId=@PropertyId
		 AND (OrderNo NOT IN (
				SELECT	PayTrans.OrderNo
				FROM	PayTrans 
					INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
				WHERE	((NoValue = 1) AND OrderDate >= CONVERT(DATETIME,@FromDate,103) 
		AND  OrderDate <= CONVERT(DATETIME,@ToDate,103) )
					AND (PayTrans.PayCode <> 'BR')  
					AND PayTrans.PropertyId = @PropertyId)
					
				)

			insert into @table select 0,'BANKING SECTION',@GrossSales,0,0,0,1,'',@CurOutlet
			insert into @table select 1,'GROSS SALES',@GrossSales,0,0,0,0,'',@CurOutlet
			insert into @table select 2,'DISCOUNT',@Discounts ,0,0,0,0,'',@CurOutlet
			insert into @table select 3,'TOTAL SALES',@GrossSales-(@Discounts+@Voucher),0,0,0,0,'',@CurOutlet
			

			DECLARE @AccumulatedSales AS NUMERIC(18,4), @AccumulatedBanking AS NUMERIC(18,4)
			DECLARE @StartDate DATETIME

			SET @StartDate = (SELECT DATEADD(S,0,DATEADD(mm, DATEDIFF(m,0,convert(datetime,@ToDate,103)),0)))
			
			SELECT	@AccumulatedSales = ISNULL(SUM(Subtotal + TaxVal1 + TaxVal2 + TaxVal3 + TaxVal4),0)
			FROM	BillHeader
			WHERE	OrderDate BETWEEN CONVERT(DATETIME, @StartDate, 103) and convert(datetime,@ToDate,103) AND Outlet = @CurOutlet

			SELECT @AccumulatedBanking = ISNULL(SUM(DenoAmount),0) 
			FROM BankwiseDeposit 
			WHERE TransDate BETWEEN convert(datetime,@StartDate,103) and convert(datetime,@ToDate,103) AND OutletCode = @CurOutlet

			--insert into @table select 14,'ACCUMULATED CASH IN HAND OUT OF SALE',@AccumulatedSales - @AccumulatedBanking ,0,0,0,0,'',@CurOutlet
			--------------------------------------------------------------


			





			--insert into @table select 19,'LESS TOTAL ACTUAL BANKING (EFTPOS & CASH)',@ActualBankDeposit,0,0,0,0,'',@CurOutlet
			--insert into @table select 12,'',0,1,0,0,0,''
			--insert into @table select 13,'TOTAL OVERBANK / (UNDERBANK)',@ActualBankDeposit-@ExpectedBankDposit,0,0,0,0,''

			insert into @table select 20,'BANKING',0,0,0,0,1,'',@CurOutlet
			--keep 15-50 for banking

			insert into @table 
			select 21,b.Description , isnull(sum(a.ActualAmt),0),0,0,0,0,'',@CurOutlet 
			from 
			PayTrans as a,PaymentTypes as b 
			where 
			a.PropertyId=b.PropertyId 
			and a.PropertyId=@PropertyId 
			and	a.PayCode=b.PayCode 
			and a.orderdate>=convert(datetime,@FromDate,103) 
			and a.orderdate<=convert(datetime,@ToDate,103) 
			and a.outlet= @CurOutlet 
			group by b.Description

			--SELECT @DayendEnteredAmount = TotCash FROM DayeEndSummaryHeader WHERE Date1 BETWEEN convert(datetime,@FromDate,103) and convert(datetime,@ToDate,103) AND Outlet = @CurOutlet
			--insert into @table SELECT 22,'ACTUAL CASH', @DayendEnteredAmount,0,0,0,0,'',@CurOutlet 

			select @DayendEnteredAmount = @DayendEnteredAmount - isnull(sum(a.ActualAmt),0)
			from 
			PayTrans as a,
			PaymentTypes as b
			where 
			a.PropertyId=b.PropertyId 
			and a.PropertyId=@PropertyId 
			and	a.PayCode=b.PayCode 
			and a.orderdate>=convert(datetime,@FromDate,103) 
			and a.orderdate<=convert(datetime,@ToDate,103) 
			and a.outlet= @CurOutlet
			group by b.Description

			--insert into @table SELECT 23,'VARIANCE', @DayendEnteredAmount ,0,0,0,0,'',@CurOutlet 

			

			

			insert into @table select 51,'ADJUSTED NET SALES',0,0,0,0,1,'',@CurOutlet
			
			insert into @table select 52,'TOTAL SALE',@GrossSales,0,0,0,0,'',@CurOutlet

			
			--insert into @table select 52,'LESS PROMO EXCL TAX',@Discounts,0,0,0,0,'',@CurOutlet --2020-6-27 CHIRAJ CHANGED FOR dOLPIN
			
			--insert into @table select 53,'LESS VAT ON PROMO',0,0,0,0,0,'',@CurOutlet
			insert into @table select 54,'SALES INCLUDING TAX',@GrossSales-(@Discounts+@Voucher),0,0,0,0,'',@CurOutlet

			--select @TAX1 = isnull(sum(TaxVal1),0) ,@TAX2=isnull(sum(TaxVal2),0),@tax3=isnull(sum(TaxVal3),0),@tax4=isnull(sum(taxval4),0),@SC=isnull(sum(Servicecharge),0) from BillHeader where orderdate>=convert(datetime,@FromDate,103) and orderdate<=convert(datetime,@ToDate,103) and outlet= case when @outlet='XXX' then outlet else @outlet end

			if @TAX1 >0
			begin
				insert into @table select 55,'VAT',@TAX1,0,0,0,0,'',@CurOutlet
			end
			if @TAX2 >0
			begin
				insert into @table select 55,'NBT',@TAX2,0,0,0,0,'',@CurOutlet
			end

			if @TAX3 >0
			begin
				insert into @table select 55,'TDL',@TAX3,0,0,0,0,'',@CurOutlet
			end

			if @TAX4 >0
			begin
				insert into @table select 55,'TAX 4',@TAX4,0,0,0,0,'',@CurOutlet
			end

			if @SC >0
			begin
				insert into @table select 55,'SERVICE CHARGE',@SC,0,0,0,0,'',@CurOutlet
			end



			insert into @table select 56,'ADJUSTED NET SALES',@NetSales,0,0,0,0,'',@CurOutlet

			insert into @table select 57,'DISCOUNT BREAKDOWN',0,0,0,0,1,'',@CurOutlet

			select  
			@NUMBEROFVOIDS = ISNULL(COUNT(ORDERNO) ,0), 
			@VOIDNetSales=isnull(sum(subtotal),0),
			@VOIDTAX1 = isnull(sum(TaxVal1),0) ,
			@VOIDTAX2=isnull(sum(TaxVal2),0),
			@VOIDtax3=isnull(sum(TaxVal3),0),
			@VOIDtax4=isnull(sum(taxval4),0),
			@VOIDSC=isnull(sum(Servicecharge),0), 
			@VOIDGrossSales=isnull(sum(subtotal+ServiceCharge+TaxVal1+TaxVal2+taxval3+TaxVal4),0),
			@VOIDDiscounts=isnull(sum(Discount),0) 
			from VOIDBillHeader 
			where 
			PropertyId=@PropertyId 
			and orderdate>=convert(datetime,@FromDate,103) 
			and orderdate<=convert(datetime,@ToDate,103) 
			and outlet= @CurOutlet


			insert into @table select 58,'NUMBER OF REFUNDS & VOIDS',@NUMBEROFVOIDS,0,0,0,0,'',@CurOutlet
			insert into @table select 59,'VALUE REFUND AND VOIDS',@VOIDGrossSales,0,0,0,0,'',@CurOutlet
			insert into @table select 60,'TOTAL VALUE OF REFUNDS',0,0,0,0,0,'',@CurOutlet
			insert into @table select 61,'TOTAL VALUE OF VOIDS',@VOIDGrossSales,0,0,0,0,'',@CurOutlet
			insert into @table select 62,'TOTAL GROSS SALES',@GrossSales,0,0,0,0,'',@CurOutlet

			--Staff Meal

			insert into @table 
			select 
			64,b.Description , 
			isnull(sum(a.ActualAmt),0),0,0,0,0,'',@CurOutlet
			from 
			PayTrans as a,PaymentTypes as b 
			where
			a.PropertyId=b.PropertyId 
			and a.PropertyId=@PropertyId 
			and a.PayCode=b.PayCode 
			and b.IsStaffMeal=1 
			and a.orderdate>=convert(datetime,@FromDate,103) 
			and a.orderdate<=convert(datetime,@ToDate,103) 
			and a.outlet= @CurOutlet group by b.Description

			--insert into @table select 64,'STAFF MEAL',0,0,0,0,0,''
			select @TotalStaffDiscount = isnull(sum(Amount),0) from @table where OrderID =64

			insert into @table select 65,'TOTAL DISCOUNT',@TotalStaffDiscount,0,0,0,0,'',@CurOutlet


			insert into @table select 66,'SALE TYPE BREAKDOWN',0,0,0,0,1,'',@CurOutlet

			insert into @table select 67,'TOTAL CUSTOMERS',@NUMBEROFORDERS,0,0,0,0,'',@CurOutlet
			insert into @table select 68,'TOTAL GROSS SALE',@GrossSales,0,0,0,0,'',@CurOutlet
			if @NUMBEROFORDERS >0
			begin
			insert into @table select 69,'AVERAGE SALES',@GrossSales/@NUMBEROFORDERS,0,0,0,0,'',@CurOutlet
			end


			insert into @table 
			SELECT	314 + ROW_NUMBER() OVER (ORDER BY T.Name),T.Name, COUNT(B.OrderNo) AS BillCount,0,0,0,0,'',@CurOutlet
			FROM	BillHeader AS B INNER JOIN POSOrderTypes AS T ON B.OrderType = T.Code and t.PropertyId = b.PropertyId
			WHERE	B.Subtotal != 0 AND B.Outlet = @CurOutlet AND B.OrderDate BETWEEN CONVERT(DATETIME,@FromDate,103) AND CONVERT(DATETIME,@ToDate,103)
			GROUP BY T.Name

			SET @increment = @increment + 1;

END





IF OBJECT_ID('tempdb..#BDTable') IS NOT NULL
DROP TABLE #BDTable


		
IF OBJECT_ID('tempdb..#BHTable') IS NOT NULL
DROP TABLE #BHTable
		

select OrderID ,T.Description    ,Amount	,IsBlankLine ,IsBold ,IsItalic ,IsaHeader ,OtherValue ,Outlet  ,L.description AS OutletDes
from @table T
left outer join Location_Ref L ON T.Outlet = L.code AND L.PropertyId=@PropertyId

GO

