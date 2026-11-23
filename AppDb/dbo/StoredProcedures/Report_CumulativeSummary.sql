-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
--[Report_CumulativeSummary] '26/06/2020','26/06/2020','D01',1
CREATE procedure [dbo].[Report_CumulativeSummary]
(
 @FromDate varchar(10),
 @Todate varchar(10),
 @outlet char(3),
 @PropertyId VARCHAR(2)

)

as

select WeekDayName,OrderDate,Name as OrderType,aa,ID from

(

SELECT        DATENAME(DW, BillHeader.OrderDate) AS WeekDayName,
			 convert(date,BillHeader.OrderDate) AS OrderDate, 
			COUNT(BillHeader.OrderNo) AS aa, 
			POSOrderTypes.Name,
			'Dockets' as id
FROM            BillHeader 
				--INNER JOIN  PayTrans ON BillHeader.OrderNo = PayTrans.OrderNo AND BillHeader.Outlet = PayTrans.Outlet AND BillHeader.OrderDate = PayTrans.OrderDate AND BillHeader.PropertyId=PayTrans.PropertyId
						-- INNER JOIN   PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode  AND PayTrans.PropertyId=PaymentTypes.PropertyId
						 INNER JOIN   POSOrderTypes ON BillHeader.OrderType = POSOrderTypes.Code AND POSOrderTypes.PropertyId=BillHeader.PropertyId

						  where 
						  --PaymentTypes.NoValue=0  and 
						  BillHeader.PropertyId=@PropertyId
						  and BillHeader.Outlet =@outlet 
						  and BillHeader.OrderDate >=convert(datetime,@FromDate,103) 
						  and BillHeader.OrderDate <=convert(datetime,@Todate,103) 
						  AND ( BillHeader.OrderNo NOT IN (
								SELECT	PayTrans.OrderNo
								FROM	PayTrans 
								INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
								WHERE	((NoValue = 1) AND PayTrans.OrderDate >= CONVERT(DATETIME,@FromDate,103) 
								AND  PayTrans.OrderDate <= CONVERT(DATETIME,@ToDate,103) )
								AND (PayTrans.PayCode <> 'BR')  
								AND PayTrans.PropertyId = @PropertyId
								AND PayTrans.Outlet =@outlet )
					
								)
GROUP BY  BillHeader.OrderDate, BillHeader.OrderType, POSOrderTypes.Name


union all

SELECT      
		DATENAME(DW, BillHeader.OrderDate) AS WeekDayName,
		convert(date,BillHeader.OrderDate) AS OrderDate, 
		SUM(BillHeader.Subtotal + BillHeader.TaxVal1 + BillHeader.TaxVal2 + BillHeader.TaxVal3 + BillHeader.TaxVal4+BillHeader.ServiceCharge) AS aa,
		POSOrderTypes.Name,
		'Net Sales' as id
	FROM            BillHeader 
	--INNER JOIN  PayTrans ON BillHeader.OrderNo = PayTrans.OrderNo AND BillHeader.Outlet = PayTrans.Outlet AND BillHeader.OrderDate = PayTrans.OrderDate AND BillHeader.PropertyId=PayTrans.PropertyId
	--INNER JOIN  PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode AND PayTrans.PropertyId=PaymentTypes.PropertyId
	INNER JOIN  POSOrderTypes ON BillHeader.OrderType = POSOrderTypes.Code AND POSOrderTypes.PropertyId=BillHeader.PropertyId

	where 
	--PaymentTypes.NoValue=0 and
	BillHeader.Outlet =@outlet 
	and BillHeader.OrderDate >=convert(datetime,@FromDate,103) 
	and BillHeader.OrderDate <=convert(datetime,@Todate,103) 
	and BillHeader.PropertyId=@PropertyId
	AND (	BillHeader.OrderNo NOT IN (
			SELECT	PayTrans.OrderNo
			FROM	PayTrans 
			INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
			WHERE	((NoValue = 1) AND OrderDate >= CONVERT(DATETIME,@FromDate,103) 
			AND  OrderDate <= CONVERT(DATETIME,@ToDate,103) )
			AND (PayTrans.PayCode <> 'BR')  
			AND PayTrans.PropertyId = @PropertyId
			AND PayTrans.Outlet =@outlet 
					)
					
			)
GROUP BY  BillHeader.OrderDate, BillHeader.OrderType, POSOrderTypes.Name) as aa order by OrderDate,name,ID

GO

