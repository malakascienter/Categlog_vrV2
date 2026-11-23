--EXEC [BTSingaporeTXTGenerate] '3',1,'107','2022-10-09'
CREATE PROCEDURE [dbo].[BTSingaporeTXTGenerate]
@Type VARCHAR(10),
@PropertyId INT,
@Outlet VARCHAR(10),
@BusinessDate DATETIME
AS
BEGIN

IF OBJECT_ID(N'tempdb..#TempBillTransType1') IS NOT NULL
BEGIN
DROP TABLE #TempBillTransType1
END
IF OBJECT_ID(N'tempdb..#TempBillTransType2') IS NOT NULL
BEGIN
DROP TABLE #TempBillTransType2
END
IF OBJECT_ID(N'tempdb..#TempBillTransType3') IS NOT NULL
BEGIN
DROP TABLE #TempBillTransType3
END


IF( @Type = '3' )--details 
BEGIN

SELECT * INTO  #TempBillTransType1 FROM (

			SELECT	
					0 AS Id,
					0 AS ParentId,
					'12009' AS OutletCode,
					'BT Maharagama' AS OutletName,
					'12009' AS StalllCode,
					'BTR7' AS StallName,
					concat(B.PropertyId,B.OrderNo,REPLACE(REPLACE(CONVERT(VARCHAR,B.OrderDate,12), ' ',''), ',',''),B.Outlet) AS Checknum,
					CONVERT(varchar,B.OrderDate,106) AS Busidate,
					CONCAT(CONVERT(varchar,B.OrderDate,106),' ', CONVERT(varchar,B.OrderTime,8)) AS TransactionDate,
					BH.ItemSeq AS ItemSeq,
					C.Code  AS CategoryCode,
					C.Description AS CategoryName,
					'' AS SubCategoryCode,
					'' AS SubCategoryName,
					'' AS ReportGroupCode,
					'' AS ReportGroupname,
					M.ItemCode AS ItemID,
					M.Description AS ItemName,
					BH.Qty AS Quantity,
					'Sales' AS TransactionType,
					(BH.ActualPrice*BH.Qty) AS GrossSales,
					(BH.DisCode) AS DiscountCode,
					(((BH.[Qty]*BH.[Rate])*BH.[DisPerc])/(100)) AS DiscountAmt,
					(BH.Rate*BH.Qty) AS Sales,
					(SELECT SUM(BCD.ChargeAmount) FROM POS_BillChargeDetail BCD  
					 WHERE BCD.OrderNo = BH.OrderNo AND BCD.OrderDate = BH.OrderDate 
					 AND BCD.Outlet =  BH.Outlet AND BCD.PropertyId = BH.PropertyId 
					 AND BCD.MenuItemID = BH.MainMenuCode AND BCD.RefItemID = BH.RefItemCode AND BCD.ItemSequence = BH.ItemSeq AND BCD.SortSeq = BH.SortSeq AND BCD.ChargeTypeID <> 1  ) AS Tax,
					(SELECT SUM(BCD.ChargeAmount) FROM POS_BillChargeDetail BCD  
					 WHERE BCD.OrderNo = BH.OrderNo AND BCD.OrderDate = BH.OrderDate 
					 AND BCD.Outlet =  BH.Outlet AND BCD.PropertyId = BH.PropertyId 
					 AND BCD.MenuItemID = BH.MainMenuCode AND BCD.RefItemID = BH.RefItemCode AND BCD.ItemSequence = BH.ItemSeq AND BCD.SortSeq = BH.SortSeq AND BCD.ChargeTypeID = 1  ) AS SrvcCharge,
					(BH.NetAmount) AS NetSales,
					(0) AS IsSetItem,
					(0) AS IsStaffMeal,
					(0) AS IsRawWastage,
					(0) AS IsSemiWastage,
					(0) AS IsWastage,
					(0) AS IsSpoilage,
					(0) AS IsSampling,
					(0) AS Taxable,
					(0) AS Void,
					('') AS VoidRemarks
			FROM BillTrans BH INNER JOIN Location_Ref L ON BH.Outlet = L.code
			INNER JOIN BillHeader B ON BH.OrderNo = B.OrderNo AND BH.Orderdate = B.OrderDate AND BH.Outlet = B.Outlet AND BH.PropertyId = B.PropertyId
			INNER JOIN MainMenu M ON BH.MainMenuCode = m.ItemCode AND BH.PropertyId = M.PropertyId
			INNER JOIN Category C ON M.Category = C.Code AND C.PropertyId = M.PropertyId
			WHERE BH.Outlet = @Outlet AND BH.OrderDate = @BusinessDate

			UNION ALL 

			
			SELECT	
					0 AS Id,
					0 AS ParentId,
					'12009' AS OutletCode,
					'BT Maharagama' AS OutletName,
					'12009' AS StalllCode,
					'BTR7' AS StallName,
					concat(BH.PropertyId,BH.OrderNo,REPLACE(REPLACE(CONVERT(VARCHAR,BH.OrderDate,12), ' ',''), ',',''),BH.Outlet) AS Checknum,
					CONVERT(varchar,BH.OrderDate,106) AS Busidate,
					CONCAT(CONVERT(varchar,BH.OrderDate,106),' ', CONVERT(varchar,BH.OrderTime,8)) AS TransactionDate,
					1 AS ItemSeq,
					''  AS CategoryCode,
					'' AS CategoryName,
					'' AS SubCategoryCode,
					'' AS SubCategoryName,
					'' AS ReportGroupCode,
					'' AS ReportGroupname,
					PT.PayCode AS ItemID,
					PT.Description AS ItemName,
					1 AS Quantity,
					'Tender' AS TransactionType,
					(BH.ActualAmt) AS GrossSales,
					('') AS DiscountCode,
					(0) AS DiscountAmt,
					(BH.ActualAmt) AS Sales,
					(0) AS Tax,
					(0) AS SrvcCharge,
					(BH.ActualAmt) AS NetSales,
					(0) AS IsSetItem,
					(0) AS IsStaffMeal,
					(0) AS IsRawWastage,
					(0) AS IsSemiWastage,
					(0) AS IsWastage,
					(0) AS IsSpoilage,
					(0) AS IsSampling,
					(0) AS Taxable,
					(0) AS Void,
					('') AS VoidRemarks
			FROM PayTrans BH 
			INNER JOIN PaymentTypes PT ON BH.PayCode = PT.PayCode AND BH.PropertyId = PT.PropertyId
			WHERE BH.Outlet = @Outlet AND BH.OrderDate = @BusinessDate

			) AS A

	--GROUP BY A.OutletCode,A.OutletName,A.StalllCode,A.StallName,A.Busidate,A.TransactionDate

	SELECT CONCAT(
							--BH.Id,'|',--Id
							(row_number() OVER (ORDER BY BH.OutletCode)) ,'|',--Id
							BH.ParentId,'|',--ParentId
							BH.OutletCode,'|',--OutletCode
							BH.OutletName,'|',--OutletName
							BH.StalllCode ,'|',--StalllCode
							BH.StallName ,'|',--StallName
							BH.Checknum ,'|',--Checknum
							--BH.Checknum ,'|',--Checknum
							CONVERT(varchar,BH.Busidate,106),'|',--Busidate
							(BH.TransactionDate),'|',--TransactionDate
							(BH.ItemSeq),'|',--ItemSeq
							(BH.CategoryCode),'|',--CategoryCode
							(BH.CategoryName),'|',--CategoryName
							(BH.SubCategoryCode),'|',--SubCategoryCode
							(BH.SubCategoryName),'|',--SubCategoryName
							(BH.ReportGroupCode),'|',--ReportGroupCode
							(BH.ReportGroupname),'|',--ReportGroupname
							(BH.ItemID),'|',--ItemID
							(BH.ItemName),'|',--ItemName
							(BH.Quantity),'|',--Quantity
							(BH.TransactionType),'|',--TransactionType
							(BH.GrossSales),'|',--GrossSales
							(BH.DiscountCode),'|',--DiscountCode
							(BH.DiscountAmt),'|',--DiscountAmt
							(BH.Sales),'|',--Sales
							(BH.Tax),'|',--Tax
							(BH.SrvcCharge),'|',--SrvcCharge
							(BH.NetSales),'|',--NetSales
							(BH.IsSetItem),'|',--IsSetItem
							(BH.IsStaffMeal),'|',--IsStaffMeal
							(BH.IsRawWastage),'|',--IsRawWastage
							(BH.IsSemiWastage),'|',--IsSemiWastage
							(BH.IsWastage),'|',--IsWastage
							(BH.IsSpoilage),'|',--IsSpoilage
							(BH.IsSampling),'|',--IsSampling
							(BH.Taxable),'|',--Taxable
							(BH.Void),'|',--Void
							(BH.VoidRemarks),'|'--VoidRemarks
							) AS Detail	,CONCAT('12009','_',REPLACE(REPLACE(CONVERT(VARCHAR,BH.Busidate,106), ' ',''), ',',''),'_','Details','_',REPLACE(REPLACE(CONVERT(VARCHAR,getdate(),106), ' ',''), ',',''),REPLACE(REPLACE(CONVERT(VARCHAR,getdate(),24), ' ',''), ':','') ) AS [FileName]
			FROM #TempBillTransType1 BH 
	--GROUP BY BH.OutletCode,BH.OutletName,BH.StalllCode,BH.StallName,BH.Busidate
 

END
ELSE IF( @Type = '2' )--check summery
BEGIN

	SELECT	
					'12009' AS OutletCode,
					'BT Maharagama' AS OutletName,
					'12009' AS StalllCode,
					'BTR7' AS StallName,
					concat(BH.PropertyId,BH.OrderNo,REPLACE(REPLACE(CONVERT(VARCHAR,BH.OrderDate,12), ' ',''), ',',''),BH.Outlet) AS Checknum,
					CONVERT(varchar,BH.OrderDate,106) AS Busidate,
					CONCAT(CONVERT(varchar,BH.starttime,106),' ', CONVERT(varchar,BH.starttime,8)) AS CheckOpenTime,
					CONCAT(CONVERT(varchar,BH.endtime,106),' ', CONVERT(varchar,BH.endtime,8))  AS CheckCloseTime,
					SUM(BH.Subtotal+BH.Discount+BH.ServiceCharge+BH.TaxVal1+BH.TaxVal2+BH.TaxVal3+BH.TaxVal4) AS GrossSales,
					SUM(BH.Discount)  AS DiscountAmt,
					SUM(BH.Subtotal) AS Sales,
					SUM(BH.TaxVal1+BH.TaxVal2+BH.TaxVal3+BH.TaxVal4) AS Tax,
					SUM(BH.ServiceCharge) AS ServiceCharge,
					SUM(BH.Subtotal) AS NetSales,
					(SELECT SUM(ActualAmt) 
					 FROM PayTrans P1 INNER JOIN PaymentTypes PT ON P1.PayCode = PT.PayCode AND P1.PropertyId = PT.PropertyId 
					 WHERE P1.OrderNo = BH.OrderNo AND P1.Outlet = BH.Outlet AND P1.OrderDate = BH.OrderDate AND P1.PropertyId = BH.PropertyId AND PT.CreditCard = 1) AS CreditCardSales,
					SUM(0) AS VoucherSales,
					SUM(0) AS StaffMealAmt,
					SUM(0) AS Rounding,
					SUM(0) AS RawWastageAmt,
					SUM(0) AS SemiWastageAmt,
					SUM(0) AS WastageAmt,
					SUM(0) AS SpoilageAmt,
					SUM(0) AS SamplingAmt,
					(SELECT SUM(Qty) FROM BillTrans where Outlet = BH.Outlet AND OrderNo = BH.OrderNo AND OrderDate = BH.OrderDate AND PropertyId = BH.PropertyId)  AS Quantity,
					SUM(0) AS NoOfPax,
					SUM(0) AS NoOfAdult,
					SUM(0) AS NoOfChild,
					BH.POSNo AS POSId,
					BH.Waiter AS EmployeeCode,
					BH.Waiter AS Employeename,
					1 AS IsValid,
					0 AS Overring,
					(SELECT COUNT(OrderNo) FROM VoidBillHeader WHERE PropertyId = @PropertyId AND Outlet = @Outlet AND OrderDate = @BusinessDate) AS Cancel,
					'' AS Remarks
			INTO #TempBillTransType2
			FROM BillHeader BH INNER JOIN Location_Ref L ON BH.Outlet = L.code
			WHERE BH.Outlet = @Outlet AND BH.OrderDate = @BusinessDate
			GROUP BY L.code,L.description,BH.OrderNo,BH.Outlet,BH.OrderDate,BH.PropertyId,BH.POSNo,BH.Waiter,BH.Id,BH.starttime,BH.endtime

	SELECT CONCAT(
							BH.OutletCode,'|',--OutletCode
							BH.OutletName,'|',--OutletName
							BH.StalllCode,'|',--StalllCode
							BH.StallName,'|',--StallName
							BH.Checknum,'|',--Checknum
							CONVERT(varchar,BH.Busidate,106),'|',--Busidate
							CONVERT(varchar,BH.CheckOpenTime,106),'|',--CheckOpenTime
							CONVERT(varchar,BH.CheckCloseTime,106),'|',--CheckCloseTime
							SUM(BH.GrossSales),'|',--GrossSales
							SUM(BH.DiscountAmt),'|',--DiscountAmt
							SUM(BH.Sales),'|',--Sales
							SUM(BH.Tax),'|',--Tax
							SUM(BH.ServiceCharge),'|',--ServiceCharge
							SUM(BH.NetSales),'|',--NetSales
							SUM(BH.CreditCardSales),'|',--CreditCardSales
							SUM(BH.VoucherSales),'|',--VoucherSales
							SUM(BH.StaffMealAmt),'|',--StaffMealAmt
							SUM(BH.Rounding),'|',--Rounding
							SUM(BH.RawWastageAmt),'|',--RawWastageAmt
							SUM(BH.SemiWastageAmt),'|',--SemiWastageAmt
							SUM(BH.WastageAmt),'|',--WastageAmt
							SUM(BH.SpoilageAmt),'|',--SpoilageAmt
							SUM(BH.SamplingAmt),'|',--SamplingAmt
							SUM(BH.Quantity),'|',--Quantity
							SUM(BH.NoOfPax),'|',--NoOfPax
							SUM(BH.NoOfAdult),'|',--NoOfAdult
							SUM(BH.NoOfChild),'|',--NoOfChild
							(BH.POSId),'|',--POSId
							(BH.EmployeeCode),'|',--EmployeeCode
							(BH.Employeename),'|',--Employeename
							(BH.IsValid),'|',--IsValid
							(BH.Overring),'|',--Overring
							(BH.Cancel),'|',--Cancel
							(BH.Remarks),'|'--Cancel
							) AS CheckSummary	,CONCAT('12009','_',REPLACE(REPLACE(CONVERT(VARCHAR,BH.Busidate,106), ' ',''), ',',''),'_','Check','_',REPLACE(REPLACE(CONVERT(VARCHAR,getdate(),106), ' ',''), ',',''),REPLACE(REPLACE(CONVERT(VARCHAR,getdate(),24), ' ',''), ':','') ) AS [FileName]
			FROM #TempBillTransType2 BH 
			GROUP BY BH.OutletCode,BH.OutletName,BH.StalllCode,BH.StallName,BH.Checknum,BH.POSId,BH.EmployeeCode,BH.Employeename,BH.IsValid,BH.Overring,BH.Cancel,BH.Remarks,BH.CheckOpenTime,BH.CheckCloseTime,BH.Busidate

END
ELSE IF( @Type = '1' )--daily summery
BEGIN

	SELECT	
					'12009' AS OutletCode,
					'BT Maharagama' AS OutletName,
					'12009' AS StalllCode,
					'BTR7' AS StallName,
					CONVERT(varchar,BH.OrderDate,106) AS Busidate,
					SUM(BH.Subtotal+BH.Discount+BH.ServiceCharge+BH.TaxVal1+BH.TaxVal2+BH.TaxVal3+BH.TaxVal4) AS GrossSales,
					SUM(BH.Discount)  AS DiscountAmt,
					SUM(BH.Subtotal) AS Sales,
					SUM(BH.TaxVal1+BH.TaxVal2+BH.TaxVal3+BH.TaxVal4) AS Tax,
					SUM(BH.ServiceCharge) AS ServiceCharge,
					SUM(BH.Subtotal) AS NetSales,
					(SELECT SUM(ActualAmt) 
					 FROM PayTrans P1 INNER JOIN PaymentTypes PT ON P1.PayCode = PT.PayCode AND P1.PropertyId = PT.PropertyId 
					 WHERE P1.OrderNo = BH.OrderNo AND P1.Outlet = BH.Outlet AND P1.OrderDate = BH.OrderDate AND P1.PropertyId = BH.PropertyId AND PT.CreditCard = 1) AS CreditCardSales,
					SUM(0) AS VoucherSales,
					SUM(0) AS StaffMealAmt,
					SUM(0) AS Rounding,
					SUM(0) AS RawWastageAmt,
					SUM(0) AS SemiWastageAmt,
					SUM(0) AS WastageAmt,
					SUM(0) AS SpoilageAmt,
					SUM(0) AS SamplingAmt,
					SUM(0) AS OthersAmt,
					0 AS TotalQty,
					COUNT(BH.OrderNo) AS TotalTransaction,
					COUNT(BH.OrderNo) AS ValidTransactionCount,
					SUM(0) AS InvalidTransactionCount,
					SUM(0) AS OverringTransactionCount,
					(SELECT COUNT(OrderNo) FROM VoidBillHeader WHERE PropertyId = @PropertyId AND Outlet = @Outlet AND OrderDate = @BusinessDate) AS CancelTransactionCount,
					SUM(0) AS NoOfPax,
					SUM(0) AS NoOfAdult,
					SUM(0) AS NoOfChild
			INTO #TempBillTransType3
			FROM BillHeader BH INNER JOIN Location_Ref L ON BH.Outlet = L.code
			WHERE BH.Outlet = @Outlet AND BH.OrderDate = @BusinessDate
			GROUP BY L.code,L.description,BH.OrderNo,BH.Outlet,BH.OrderDate,BH.PropertyId

	SELECT CONCAT(
							BH.OutletCode,'|',--OutletCode
							BH.OutletName,'|',--OutletName
							BH.StalllCode,'|',--StalllCode
							BH.StallName,'|',--StallName
							CONVERT(varchar,BH.Busidate,106),'|',--Busidate
							SUM(BH.GrossSales),'|',--GrossSales
							SUM(BH.DiscountAmt),'|',--DiscountAmt
							SUM(BH.Sales),'|',--Sales
							SUM(BH.Tax),'|',--Tax
							SUM(BH.ServiceCharge),'|',--ServiceCharge
							SUM(BH.NetSales),'|',--NetSales
							SUM(BH.CreditCardSales),'|',--CreditCardSales
							SUM(BH.VoucherSales),'|',--VoucherSales
							SUM(BH.StaffMealAmt),'|',--StaffMealAmt
							SUM(BH.Rounding),'|',--Rounding
							SUM(BH.RawWastageAmt),'|',--RawWastageAmt
							SUM(BH.SemiWastageAmt),'|',--SemiWastageAmt
							SUM(BH.WastageAmt),'|',--WastageAmt
							SUM(BH.SpoilageAmt),'|',--SpoilageAmt
							SUM(BH.SamplingAmt),'|',--SamplingAmt
							SUM(BH.OthersAmt),'|',--OthersAmt
							SUM(BH.TotalQty),'|',--TotalQty
							SUM(BH.TotalTransaction),'|',--TotalTransaction
							SUM(BH.ValidTransactionCount),'|',--ValidTransactionCount
							SUM(BH.InvalidTransactionCount),'|',--InvalidTransactionCount
							SUM(BH.OverringTransactionCount),'|',--OverringTransactionCount
							SUM(BH.CancelTransactionCount),'|',--CancelTransactionCount
							SUM(BH.NoOfPax),'|',--NoOfPax
							SUM(BH.NoOfAdult),'|'--,--NoOfAdult
							--SUM(BH.NoOfChild),'|'--NoOfChild
							) AS DailySummary	,CONCAT('12009','_',REPLACE(REPLACE(CONVERT(VARCHAR,BH.Busidate,106), ' ',''), ',',''),'_','Daily','_',REPLACE(REPLACE(CONVERT(VARCHAR,getdate(),106), ' ',''), ',',''),REPLACE(REPLACE(CONVERT(VARCHAR,getdate(),24), ' ',''), ':','') ) AS [FileName]
			FROM #TempBillTransType3 BH 
			GROUP BY BH.OutletCode,BH.OutletName,BH.StalllCode,BH.StallName,BH.Busidate


END

IF OBJECT_ID(N'tempdb..#TempBillTransType1') IS NOT NULL
BEGIN
DROP TABLE #TempBillTransType1
END
IF OBJECT_ID(N'tempdb..#TempBillTransType2') IS NOT NULL
BEGIN
DROP TABLE #TempBillTransType2
END
IF OBJECT_ID(N'tempdb..#TempBillTransType3') IS NOT NULL
BEGIN
DROP TABLE #TempBillTransType3
END

END

GO

