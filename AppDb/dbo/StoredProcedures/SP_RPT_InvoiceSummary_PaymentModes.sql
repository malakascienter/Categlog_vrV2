-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-02-07
-- Description:	Invoice Summary - Payment Mode Report
-- [dbo].[SP_RPT_InvoiceSummary_PaymentModes] '12','2025/02/10','2025/02/10',1

-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_InvoiceSummary_PaymentModes]
@LocationID VARCHAR(MAX),
@FromDate DATE,
@ToDate DATE,
@PropertyID INT
AS
BEGIN
SET NOCOUNT ON;

IF OBJECT_ID(N'tempdb..#TempSelectBill') IS NOT NULL
BEGIN
DROP TABLE #TempSelectBill
END
IF OBJECT_ID(N'tempdb..#TempBill') IS NOT NULL
BEGIN
DROP TABLE #TempBill
END

	 CREATE TABLE #TempSelectBill(
			
			InvoiceNo VARCHAR(MAX) ,
			BusinessDate DATE,
			OrderTime VARCHAR(MAX),
			LocationName varchar(30) NULL,
			Discount money,
			SubAmount money,
			NetAmount money,
			SC money,
			SSCL money,
			VAT money,
			PaymentType [varchar](150) NULL, 
			ActualAmt money,
			PropertyId INT
		);



	SELECT distinct IH.InvoiceNo,IH.BusinessDate,--CONVERT(VARCHAR(8),IH.InsertDateTime,108) OrderTime
	FORMAT(IH.InsertDateTime, 'hh:mm tt')OrderTime
	,LO.Name LocationName
	,IH.Discount
	,IH.SubAmount,IH.NetAmount
	,(SELECT SUM(ChargeAmount) FROM POS_InvoiceChargeDetail PC WHERE PC.InvHeaderID = IH.InvHeaderID AND PC.BusinessDate = IH.BusinessDate AND PC.LocationID = IH.LocationID  AND PC.ChargeTypeID =1) AS 'SC',
	(SELECT SUM(ChargeAmount) FROM POS_InvoiceChargeDetail PC WHERE PC.InvHeaderID = IH.InvHeaderID AND PC.BusinessDate = IH.BusinessDate AND PC.LocationID = IH.LocationID  AND PC.ChargeTypeID =2) AS 'SSCL',
	(SELECT SUM(ChargeAmount) FROM POS_InvoiceChargeDetail PC WHERE PC.InvHeaderID = IH.InvHeaderID AND PC.BusinessDate = IH.BusinessDate AND PC.LocationID = IH.LocationID  AND PC.ChargeTypeID =3) AS 'VAT',
	PA.Description AS PaymentType, PT.ActualAmount AS ActualAmt,IH.CompanyID PropertyId
	 INTO #TempBill	
	FROM POS_InvoiceHeader IH
	INNER JOIN Locations LO ON LO.Id = IH.LocationID
	INNER JOIN POS_InvoicePayment PT ON PT.InvHeaderID = IH.InvHeaderID AND PT.BusinessDate = IH.BusinessDate AND PT.LocationID = IH.LocationID
	INNER JOIN PaymentTypes PA ON PA.PayCode = PT.PayCode  AND PA.PropertyId = IH.CompanyID
	WHERE IH.LocationID IN (SELECT * FROM string_split(@LocationID,N','))  AND IH.BusinessDate BETWEEN @FromDate AND @ToDate AND IH.CompanyID =@PropertyID

	


	
	 

	  DECLARE @OrderNoT VARCHAR(MAX)
	  DECLARE @OrderDateT Date
	  DECLARE @OutletT varchar(30)

	 WHILE EXISTS  (SELECT * FROM #TempBill)
	 BEGIN
	 
	 SELECT TOP 1  @OrderNoT = InvoiceNo,@OrderDateT = BusinessDate,@OutletT = LocationName FROM #TempBill
		IF EXISTS( SELECT * FROM #TempSelectBill WHERE InvoiceNo = @OrderNoT AND BusinessDate = @OrderDateT AND LocationName = @OutletT )
		BEGIN
		
		 INSERT INTO #TempSelectBill (InvoiceNo,BusinessDate,OrderTime ,LocationName ,Discount ,SubAmount ,NetAmount ,SC ,SSCL ,VAT ,PaymentType ,ActualAmt,PropertyId )
		 SELECT TOP 1  InvoiceNo,BusinessDate,OrderTime,LocationName,0,0,0,0,0,0,PaymentType,ActualAmt,PropertyId FROM #TempBill
		
		END
		ELSE
		BEGIN
		
		 INSERT INTO #TempSelectBill (InvoiceNo,BusinessDate,OrderTime ,LocationName ,Discount ,SubAmount ,NetAmount ,SC ,SSCL ,VAT ,PaymentType ,ActualAmt,PropertyId )
		 SELECT TOP 1 InvoiceNo,BusinessDate,OrderTime ,LocationName ,ISNULL(Discount,0) Discount,SubAmount ,NetAmount ,ISNULL(SC,0) SC ,ISNULL(SSCL,0)SSCL ,ISNULL(VAT,0) VAT ,PaymentType ,ActualAmt,PropertyId FROM #TempBill
		
		END




		DELETE TOP (1) FROM   #TempBill

	 END 


	 SELECT InvoiceNo,BusinessDate,OrderTime ,LocationName ,Discount  ,NetAmount ,SC ,SSCL ,VAT ,PaymentType ,ActualAmt,PropertyId ,
	 (SubAmount)-(SC+SSCL+VAT) SubAmount
	 FROM #TempSelectBill T 
	 Order by T.InvoiceNo

IF OBJECT_ID(N'tempdb..#TempSelectBill') IS NOT NULL
BEGIN
DROP TABLE #TempSelectBill
END
IF OBJECT_ID(N'tempdb..#TempBill') IS NOT NULL
BEGIN
DROP TABLE #TempBill
END

    
END

GO

