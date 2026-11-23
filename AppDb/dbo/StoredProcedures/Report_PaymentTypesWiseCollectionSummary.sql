-- =============================================
-- Author:		Report_CollectionSummary
-- Create date: 2021-07-07
-- Description:	Payment Wise Collection Summary
-- =============================================
-- Report_PaymentTypesWiseCollectionSummary '2025-08-05', '124'
CREATE PROCEDURE [dbo].[Report_PaymentTypesWiseCollectionSummary] 
	@Date	varchar(10),
	@Outlet	VARCHAR(100)
AS
BEGIN

	DECLARE @TampPaymentTypes TABLE (
		PaymentCode		VARCHAR(10),
		PaymentName		VARCHAR(100),
		PercOnTotal		DECIMAL(18,4),
		CashSale		DECIMAL(18,4) DEFAULT 0,
		Advance			DECIMAL(18,4) DEFAULT 0,
		Total			DECIMAL(18,4)
	)

	DECLARE @TotalCashSale DECIMAL(18,4) = (SELECT SUM(PT.ActualAmt) FROM PayTrans PT WHERE CONVERT(DATE, PT.OrderDate) = CONVERT(DATETIME,@Date,103) AND PT.Outlet = @Outlet)

	INSERT	INTO @TampPaymentTypes
	SELECT	PayCode, Description, 0, 0, 0, 0
	FROM	PaymentTypes
	
	SELECT		PT.PayCode AS PayCode, SUM(PT.ActualAmt) AS ActualAmt
	INTO		#TempPayTrans
	FROM		PayTrans PT
	WHERE		CONVERT(DATE, PT.OrderDate) = CONVERT(DATETIME,@Date,103) AND PT.Outlet = @Outlet 
	GROUP BY	PT.PayCode

	SELECT		SPO.PayCode AS PayCode,  SUM(SPO.PayAmount) AS AdvanceAmount
	INTO		#TempAdvances
	FROM		POS_SpecialOrderPayment SPO INNER JOIN OrderTaking..PaymentDetails SPOD ON SPO.ReceiptNo = SPOD.ADVReceiptNo
	WHERE		CONVERT(DATE, SPO.OrderDate) = CONVERT(DATETIME,@Date,103) AND SPO.OutletCode = @Outlet AND SPOD.SettlementType = 'A'
	GROUP BY	SPO.PayCode
	
	UPDATE		TPTT
	SET			TPTT.CashSale = TPT.ActualAmt
	FROM		@TampPaymentTypes TPTT
	INNER JOIN	#TempPayTrans TPT ON TPT.PayCode = TPTT.PaymentCode

	UPDATE		TPTT
	SET			TPTT.Advance = TA.AdvanceAmount
	FROM		@TampPaymentTypes TPTT
	INNER JOIN	#TempAdvances TA ON TA.PayCode = TPTT.PaymentCode

	UPDATE	@TampPaymentTypes
	SET		PercOnTotal = CashSale / @TotalCashSale * 100,
			Total = CashSale + Advance

	SELECT	* 
	FROM	@TampPaymentTypes
	WHERE	CashSale > 0
END

GO

