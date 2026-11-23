-- EXEC SP_Select_EbillDetailsJson '000988','2022-01-13','TBR','BK'
CREATE PROCEDURE [dbo].[SP_Select_EbillDetailsJson]
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
	IF OBJECT_ID(N'tempdb..#TempChargeDetails') IS NOT NULL
	BEGIN
	DROP TABLE #TempChargeDetails
	END

	


	DECLARE @BillDetails VARCHAR(MAX)
	DECLARE @PayDetails VARCHAR(MAX)
	DECLARE @ChargeDetails VARCHAR(MAX)
	SET @BillDetails = '';
	SET @PayDetails = '';
	SET @ChargeDetails = '';

	CREATE TABLE #TempBillTran(Description VARCHAR(200),Qty Decimal(18,5),Rate DECIMAL(18,5),ItemSeq INT,SortSeq INT)
	CREATE TABLE #TempChargeDetails(Description VARCHAR(200),Amount Decimal(18,5),Seq INT)
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




SELECT @SubTotal = SUM(BH.Subtotal), @DisAmt = SUM(BH.Discount),@SC = SUM(BH.ServiceCharge),@SSCL =  SUM(BH.TaxVal2),
@Vat = SUM(BH.TaxVal1),
@TDL = SUM(BH.TaxVal3),@VatCJ =  SUM(BH.TaxVal1)
FROM BillHeader BH WHERE BH.OrderNo =  @OrderNo AND BH.OrderDate = @OrderDate AND BH.Outlet =  @Outlet AND BH.PropertyId = @PropertyId
GROUP BY BH.OrderNo




	INSERT INTO #TempChargeDetails(Description,Amount,Seq)
	VALUES('Sub Amount',@SubTotal,1)
 
IF ( @DisAmt > 0 )
BEGIN

	SELECT @Discount = SUM(BH.Discount),@DiscountName ='Discount' FROM BillHeader BH WHERE BH.OrderNo =  @OrderNo AND BH.OrderDate = @OrderDate AND BH.Outlet =  @Outlet AND BH.PropertyId = @PropertyId
	
	INSERT INTO #TempChargeDetails(Description,Amount,Seq)
	VALUES(@DiscountName,@Discount,2)

END





IF( @SC > 0 )
BEGIN

	INSERT INTO #TempChargeDetails(Description,Amount,Seq)
	VALUES('Service Charge',@SC,3)


END

IF( @NBT > 0 )
BEGIN

	INSERT INTO #TempChargeDetails(Description,Amount,Seq)
	VALUES('NBT',@NBT,4)


END


IF( @SSCL > 0 )
BEGIN

	INSERT INTO #TempChargeDetails(Description,Amount,Seq)
	VALUES('SSCL',@SSCL,5)


END

IF( @TDL > 0 )
BEGIN

	INSERT INTO #TempChargeDetails(Description,Amount,Seq)
	VALUES('TDL',@TDL,6)
 

END

IF( @Vat > 0 )
BEGIN

	INSERT INTO #TempChargeDetails(Description,Amount,Seq)
	VALUES('VAT',@Vat,7)

END


	INSERT INTO #TempChargeDetails(Description,Amount,Seq)
	VALUES('Net Amount',@SubTotal + @Vat + @NBT +@SSCL + @TDL+@SC,8)


	SET @BillDetails = (SELECT * FROM #TempBillTran FOR JSON AUTO ) 
	SET @PayDetails = (SELECT * FROM #TempPayTran FOR JSON AUTO ) 
	SET @ChargeDetails = (SELECT * FROM #TempChargeDetails FOR JSON AUTO ) 
	

	SELECT @BillDetails AS BillDetails,@PayDetails as PaymentDetails,@ChargeDetails AS ChargeDetails


	IF OBJECT_ID(N'tempdb..#TempBillTran') IS NOT NULL
	BEGIN
	DROP TABLE #TempBillTran
	END

	IF OBJECT_ID(N'tempdb..#TempPayTran') IS NOT NULL
	BEGIN
	DROP TABLE #TempPayTran
	END

	IF OBJECT_ID(N'tempdb..#TempChargeDetails') IS NOT NULL
	BEGIN
	DROP TABLE #TempChargeDetails
	END


END

GO

