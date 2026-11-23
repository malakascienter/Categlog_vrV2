-- EXEC SP_Select_EbillDetails '000988','2022-01-13','TBR','BK'
CREATE PROCEDURE [dbo].[SP_Select_EbillDetails]
@OrderNo varchar(6),
@OrderDate DATETIME,
@Outlet VARCHAR(3),
@PropertyId INT

AS
BEGIN

	IF OBJECT_ID(N'tempdb..#TempBillTran') IS NOT NULL
	BEGIN
	DROP TABLE #TempBillTran
	END
	IF OBJECT_ID(N'tempdb..#TempPayTran') IS NOT NULL
	BEGIN
	DROP TABLE #TempPayTran
	END

	


	DECLARE @BillDetails VARCHAR(MAX)
	DECLARE @PayDetails VARCHAR(MAX)
	SET @BillDetails = '';
	SET @PayDetails = '';
	CREATE TABLE #TempBillTran(Description VARCHAR(200),Qty Decimal(18,5),Rate DECIMAL(18,5),ItemSeq INT,SortSeq INT)
	CREATE TABLE #TempPayTran(Description VARCHAR(200),ActualAmt Decimal(18,5))

	DECLARE @SystemActualAmt Decimal(18,5)

	INSERT INTO #TempPayTran(Description,ActualAmt)
	SELECT PS.Description,SUM(PT.ActualAmt)
	FROM BillHeader BH INNER JOIN PayTrans PT ON BH.OrderNo = PT.OrderNo AND BH.OrderDate = PT.OrderDate AND BH.Outlet = PT.Outlet AND BH.PropertyId = PT.PropertyId
	INNER JOIN PaymentTypes PS ON PT.PayCode = PS.PayCode AND PT.PropertyId=PS.PropertyId
	WHERE BH.OrderNo =  @OrderNo AND BH.OrderDate = @OrderDate AND BH.Outlet =  @Outlet AND PT.Remark <> 'System' AND BH.PropertyId = @PropertyId
	GROUP BY PS.Description

	SELECT @SystemActualAmt = ISNULL(SUM(PT.ActualAmt),0)
	FROM BillHeader BH INNER JOIN PayTrans PT ON BH.OrderNo = PT.OrderNo AND BH.OrderDate = PT.OrderDate AND BH.Outlet = PT.Outlet AND BH.PropertyId = PT.PropertyId
	INNER JOIN PaymentTypes PS ON PT.PayCode = PS.PayCode AND PT.PropertyId=PS.PropertyId
	WHERE BH.OrderNo =  @OrderNo AND BH.OrderDate = @OrderDate AND BH.Outlet =  @Outlet AND PT.Remark = 'System' AND BH.PropertyId = @PropertyId


	IF( (SELECT COUNT(*) FROM #TempPayTran) > 0 )
	BEGIN
	
	 	UPDATE TOP(1) #TempPayTran
		SET ActualAmt = ActualAmt + ISNULL(@SystemActualAmt,0)
	
	END





	INSERT INTO #TempBillTran(Description,Qty,Rate,ItemSeq,SortSeq)
	SELECT MM.Description,BT.Qty,BT.Rate ,BT.ItemSeq,BT.SortSeq
	FROM BillTrans BT INNER JOIN MainMenu MM ON BT.MainMenuCode = MM.ItemCode AND BT.PropertyId = MM.PropertyId
	INNER JOIN BillHeader BH ON BT.OrderNo = BH.OrderNo AND BT.OrderDate = BH.OrderDate AND BT.Outlet = BH.Outlet AND BH.PropertyId = BT.PropertyId
	WHERE BH.OrderNo =  @OrderNo AND BH.OrderDate = @OrderDate AND BH.Outlet =  @Outlet AND BH.PropertyId = @PropertyId
	Order By BT.ItemSeq,BT.SortSeq

	DECLARE @ItemDescription VARCHAR(200)
	DECLARE @Qty Decimal(18,5)
	DECLARE @Rate Decimal(18,5)
	DECLARE @SubAmount Decimal(18,5) = 0
	DECLARE @Seq INT = 0
	DECLARE @Discount Decimal(18,5) = 0
	DECLARE @DiscountName VARCHAR(200)
	DECLARE @Vat Decimal(18,5) = 0
	DECLARE @VatCJ Decimal(18,5) = 0
	DECLARE @SC Decimal(18,5) = 0
	DECLARE @SCDF Decimal(18,5) = 0
	DECLARE @TDL Decimal(18,5) = 0
	DECLARE @NBT Decimal(18,5) = 0
	DECLARE @SubTotal Decimal(18,5) = 0
	Declare @DisAmt Decimal(18,5) = 0
	DECLARE @SSCL Decimal(18,5) = 0

WHILE EXISTS( SELECT * FROM #TempBillTran )
BEGIN
	
	SET @Seq = @Seq + 1;

	SELECT TOP (1) @ItemDescription =Description,@Qty = Qty , @Rate = Rate FROM #TempBillTran
	SET @SubAmount = @SubAmount + (@Rate*@Qty)

	SET @BillDetails = @BillDetails + '<tr style="box-sizing: border-box;">'

	SET @BillDetails = @BillDetails + '<td style="  text-align: left;padding: 8px;box-sizing: border-box;">'
	SET @BillDetails = @BillDetails + CONVERT(VARCHAR(MAX),@Seq)
	SET @BillDetails = @BillDetails + '</td>'

	SET @BillDetails = @BillDetails + '<td style="  text-align: left;padding: 8px;box-sizing: border-box;">'
	SET @BillDetails = @BillDetails + @ItemDescription
	SET @BillDetails = @BillDetails + '</td>'

	SET @BillDetails = @BillDetails + '<td style="  text-align: right;padding: 8px;box-sizing: border-box;">'
	SET @BillDetails = @BillDetails +  FORMAT(CONVERT(DECIMAL(18,5),@Qty ),'#,0.00')
	SET @BillDetails = @BillDetails + '</td>'

	SET @BillDetails = @BillDetails + '<td style="  text-align: right;padding: 8px;box-sizing: border-box;">'
	SET @BillDetails = @BillDetails + FORMAT(CONVERT(DECIMAL(18,5),@Rate ),'#,0.00') 
	SET @BillDetails = @BillDetails + '</td>'

	SET @BillDetails = @BillDetails + '<td style="  text-align: right;padding: 8px;box-sizing: border-box;">'
	SET @BillDetails = @BillDetails + FORMAT(CONVERT(DECIMAL(18,5),@Rate*@Qty ),'#,0.00') 
	SET @BillDetails = @BillDetails + '</td>'
	
	SET @BillDetails = @BillDetails + ' </tr>'

	DELETE TOP (1)
	FROM #TempBillTran

END




--IF EXISTS( SELECT * FROM BillHeader BH INNER JOIN DiscountHeader D ON BH.discode = D.Code
--		   WHERE BH.OrderNo =  @OrderNo AND BH.OrderDate = @OrderDate AND BH.Outlet =  @Outlet )


SELECT @SubTotal = SUM(BH.Subtotal), @DisAmt = SUM(BH.Discount),@SC = SUM(BH.ServiceCharge),@SSCL =  SUM(BH.TaxVal2),
@Vat = SUM(BH.TaxVal1),
@TDL = SUM(BH.TaxVal3),@VatCJ =  SUM(BH.TaxVal1)
FROM BillHeader BH WHERE BH.OrderNo =  @OrderNo AND BH.OrderDate = @OrderDate AND BH.Outlet =  @Outlet AND BH.PropertyId = @PropertyId
GROUP BY BH.OrderNo






 
	SET @BillDetails = @BillDetails + '<tr style="box-sizing: border-box;">'

	SET @BillDetails = @BillDetails + '<td style="font-weight: bold;  text-align: left;padding: 8px;box-sizing: border-box;">Sub Amount</td>'

	SET @BillDetails = @BillDetails + '<td style="  text-align: left;padding: 8px;box-sizing: border-box;"></td>'

	SET @BillDetails = @BillDetails + '<td style="  text-align: left;padding: 8px;box-sizing: border-box;"></td>'

	SET @BillDetails = @BillDetails + '<td style="  text-align: left;padding: 8px;box-sizing: border-box;"></td>'

	SET @BillDetails = @BillDetails + '<td style="border-top: double;font-weight: bold;  text-align: right;padding: 8px;box-sizing: border-box;">'

	SET @BillDetails = @BillDetails + FORMAT(CONVERT(DECIMAL(18,5),ROUND(@SubTotal,2) ),'#,0.00') 


	
	SET @BillDetails = @BillDetails + '</td>'
	
	SET @BillDetails = @BillDetails + ' </tr>'





IF ( @DisAmt > 0 )
BEGIN

	SELECT @Discount = SUM(BH.Discount),@DiscountName ='Discount' FROM BillHeader BH WHERE BH.OrderNo =  @OrderNo AND BH.OrderDate = @OrderDate AND BH.Outlet =  @Outlet AND BH.PropertyId = @PropertyId
	
	SET @BillDetails = @BillDetails + '<tr style="box-sizing: border-box;">'

	SET @BillDetails = @BillDetails + '<td style="font-weight: bold;  text-align: left;padding: 8px;box-sizing: border-box;">'
	SET @BillDetails = @BillDetails +  @DiscountName
	SET @BillDetails = @BillDetails + '</td>'

	SET @BillDetails = @BillDetails + '<td style="  text-align: left;padding: 8px;box-sizing: border-box;"></td>'

	SET @BillDetails = @BillDetails + '<td style="  text-align: left;padding: 8px;box-sizing: border-box;"></td>'

	SET @BillDetails = @BillDetails + '<td style="  text-align: left;padding: 8px;box-sizing: border-box;"></td>'

	SET @BillDetails = @BillDetails + '<td style="font-weight: bold;  text-align: right;padding: 8px;box-sizing: border-box;">'
	SET @BillDetails = @BillDetails +  FORMAT(CONVERT(DECIMAL(18,5),@Discount ),'#,0.00') 
	SET @BillDetails = @BillDetails + '</td>'
	
	SET @BillDetails = @BillDetails + ' </tr>'


END





IF( @SC > 0 )
	BEGIN

		SET @BillDetails = @BillDetails + '<tr style="box-sizing: border-box;">'

		SET @BillDetails = @BillDetails + '<td style="font-weight: bold;  text-align: left;padding: 8px;box-sizing: border-box;">Service Charge</td>'

		SET @BillDetails = @BillDetails + '<td style="  text-align: left;padding: 8px;box-sizing: border-box;"></td>'

		SET @BillDetails = @BillDetails + '<td style="  text-align: left;padding: 8px;box-sizing: border-box;"></td>'

		SET @BillDetails = @BillDetails + '<td style="  text-align: left;padding: 8px;box-sizing: border-box;"></td>'

		SET @BillDetails = @BillDetails + '<td style="font-weight: bold;  text-align: right;padding: 8px;box-sizing: border-box;">'
		SET @BillDetails = @BillDetails +  FORMAT(CONVERT(DECIMAL(18,5),@SC ),'#,0.00') 
		SET @BillDetails = @BillDetails + '</td>'
		
		SET @BillDetails = @BillDetails + ' </tr>'
		
 

END

IF( @NBT > 0 )
BEGIN

	SET @BillDetails = @BillDetails + '<tr style="box-sizing: border-box;">'

	SET @BillDetails = @BillDetails + '<td style="font-weight: bold;  text-align: left;padding: 8px;box-sizing: border-box;">NBT</td>'

	SET @BillDetails = @BillDetails + '<td style="  text-align: left;padding: 8px;box-sizing: border-box;"></td>'

	SET @BillDetails = @BillDetails + '<td style="  text-align: left;padding: 8px;box-sizing: border-box;"></td>'

	SET @BillDetails = @BillDetails + '<td style="  text-align: left;padding: 8px;box-sizing: border-box;"></td>'

	SET @BillDetails = @BillDetails + '<td style="font-weight: bold;  text-align: right;padding: 8px;box-sizing: border-box;">'
	SET @BillDetails = @BillDetails +  FORMAT(CONVERT(DECIMAL(18,5),@NBT ),'#,0.00') 
	SET @BillDetails = @BillDetails + '</td>'
	
	SET @BillDetails = @BillDetails + ' </tr>'
 

END


IF( @SSCL > 0 )
BEGIN

	SET @BillDetails = @BillDetails + '<tr style="box-sizing: border-box;">'

	SET @BillDetails = @BillDetails + '<td style="font-weight: bold;  text-align: left;padding: 8px;box-sizing: border-box;">SSCL</td>'

	SET @BillDetails = @BillDetails + '<td style="  text-align: left;padding: 8px;box-sizing: border-box;"></td>'

	SET @BillDetails = @BillDetails + '<td style="  text-align: left;padding: 8px;box-sizing: border-box;"></td>'

	SET @BillDetails = @BillDetails + '<td style="  text-align: left;padding: 8px;box-sizing: border-box;"></td>'

	SET @BillDetails = @BillDetails + '<td style="font-weight: bold;  text-align: right;padding: 8px;box-sizing: border-box;">'
	SET @BillDetails = @BillDetails +  FORMAT(CONVERT(DECIMAL(18,5),@SSCL ),'#,0.00') 
	SET @BillDetails = @BillDetails + '</td>'
	
	SET @BillDetails = @BillDetails + ' </tr>'
 

END

IF( @TDL > 0 )
BEGIN

	SET @BillDetails = @BillDetails + '<tr style="box-sizing: border-box;">'

	SET @BillDetails = @BillDetails + '<td style="font-weight: bold;  text-align: left;padding: 8px;box-sizing: border-box;">TDL</td>'

	SET @BillDetails = @BillDetails + '<td style="  text-align: left;padding: 8px;box-sizing: border-box;"></td>'

	SET @BillDetails = @BillDetails + '<td style="  text-align: left;padding: 8px;box-sizing: border-box;"></td>'

	SET @BillDetails = @BillDetails + '<td style="  text-align: left;padding: 8px;box-sizing: border-box;"></td>'

	SET @BillDetails = @BillDetails + '<td style="font-weight: bold;  text-align: right;padding: 8px;box-sizing: border-box;">'
	SET @BillDetails = @BillDetails +  FORMAT(CONVERT(DECIMAL(18,5),@TDL ),'#,0.00') 
	SET @BillDetails = @BillDetails + '</td>'
	
	SET @BillDetails = @BillDetails + ' </tr>'
 

END

IF( @Vat > 0 )
BEGIN

	SET @BillDetails = @BillDetails + '<tr style="box-sizing: border-box;">'

	SET @BillDetails = @BillDetails + '<td style="font-weight: bold;  text-align: left;padding: 8px;box-sizing: border-box;">VAT</td>'

	SET @BillDetails = @BillDetails + '<td style="  text-align: left;padding: 8px;box-sizing: border-box;"></td>'

	SET @BillDetails = @BillDetails + '<td style="  text-align: left;padding: 8px;box-sizing: border-box;"></td>'

	SET @BillDetails = @BillDetails + '<td style="  text-align: left;padding: 8px;box-sizing: border-box;"></td>'

	SET @BillDetails = @BillDetails + '<td style="font-weight: bold;  text-align: right;padding: 8px;box-sizing: border-box;">'
	SET @BillDetails = @BillDetails +  FORMAT(CONVERT(DECIMAL(18,5),@Vat ),'#,0.00') 
	SET @BillDetails = @BillDetails + '</td>'
	
	SET @BillDetails = @BillDetails + ' </tr>'
 

END


	SET @BillDetails = @BillDetails + '<tr style="box-sizing: border-box;">'

	SET @BillDetails = @BillDetails + '<td style="font-weight: bold;  text-align: left;padding: 8px;box-sizing: border-box;">Net Amount</td>'

	SET @BillDetails = @BillDetails + '<td style="  text-align: left;padding: 8px;box-sizing: border-box;"></td>'

	SET @BillDetails = @BillDetails + '<td style="  text-align: left;padding: 8px;box-sizing: border-box;"></td>'

	SET @BillDetails = @BillDetails + '<td style="  text-align: left;padding: 8px;box-sizing: border-box;"></td>'

	SET @BillDetails = @BillDetails + '<td style="border-bottom: double;border-top: double;font-weight: bold;  text-align: right;padding: 8px;box-sizing: border-box;">'
	
	SET @BillDetails = @BillDetails +  FORMAT(CONVERT(DECIMAL(18,5),ROUND(@SubTotal + @Vat + @NBT +@SSCL + @TDL+@SC,2) ),'#,0.00') 


	SET @BillDetails = @BillDetails + '</td>'
	
	SET @BillDetails = @BillDetails + ' </tr>'



DECLARE @ActualAmt Decimal(18,5) = 0
DECLARE @PaymentTypes VARCHAR(200)
WHILE EXISTS( SELECT * FROM #TempPayTran )
BEGIN
	


	SELECT TOP (1) @PaymentTypes =Description,@ActualAmt = ActualAmt FROM #TempPayTran


	SET @PayDetails = @PayDetails + '<tr style="box-sizing: border-box;">'

	SET @PayDetails = @PayDetails + '<td style=" text-align: left;padding: 8px;box-sizing: border-box;">'
	SET @PayDetails = @PayDetails + @PaymentTypes
	SET @PayDetails = @PayDetails + '</td>'

	SET @PayDetails = @PayDetails + '<td style=" text-align: right;padding: 8px;box-sizing: border-box;">'
	SET @PayDetails = @PayDetails + FORMAT(CONVERT(DECIMAL(18,5),@ActualAmt ),'#,0.00') 
	SET @PayDetails = @PayDetails + '</td>'

	
	SET @PayDetails = @PayDetails + ' </tr>'

	DELETE TOP (1)
	FROM #TempPayTran

END


	


SELECT @BillDetails AS BillDetails,@PayDetails as PaymentDetails

	IF OBJECT_ID(N'tempdb..#TempBillTran') IS NOT NULL
	BEGIN
	DROP TABLE #TempBillTran
	END

	IF OBJECT_ID(N'tempdb..#TempPayTran') IS NOT NULL
	BEGIN
	DROP TABLE #TempPayTran
	END


END

GO

