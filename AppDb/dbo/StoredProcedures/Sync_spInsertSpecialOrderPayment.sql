
CREATE PROCEDURE [dbo].[Sync_spInsertSpecialOrderPayment]
@PropertyID INT,
@SpecialOrderPaymentXml VARCHAR(MAX)

AS
SET DATEFORMAT DMY
DECLARE @tSpecialOrderPaymentXml XML

SET @tSpecialOrderPaymentXml = REPLACE(@SpecialOrderPaymentXml,'encoding="utf-8"','encoding="ISO-8859-9"') 


BEGIN TRY
	BEGIN TRAN
		DECLARE @ID BIGINT, @OutletCode VARCHAR(30), @OrderDate DATE

		SELECT	SpecialOrderPayment.element.value('@ID','BIGINT') AS ID,
				SpecialOrderPayment.element.value('@OutletCode','VARCHAR(30)') AS OutletCode,
				CONVERT(DATETIME,SpecialOrderPayment.element.value('@OrderDate','VARCHAR(30)'),103) AS OrderDate INTO #SpecialOrder
		FROM	@tSpecialOrderPaymentXml.nodes('/root/SpecialOrder/Payment') AS SpecialOrderPayment(element)

		WHILE EXISTS (SELECT ID FROM #SpecialOrder)
			BEGIN
				SELECT	@ID = ID, @OutletCode = OutletCode, @OrderDate = OrderDate FROM	#SpecialOrder
				DELETE	FROM POS_SpecialOrderPayment WHERE ID = @ID AND OutletCode = @OutletCode AND OrderDate = @OrderDate
				DELETE	FROM #SpecialOrder WHERE ID = @ID AND OutletCode = @OutletCode AND OrderDate = @OrderDate
			END
		
		INSERT INTO POS_SpecialOrderPayment 
					(ID, BillHeaderID, OrderNo, OrderDate, OrderAmount, PayCode, PayAmount, UserName, Remarks, 
					OutletCode, SettlementType, ReceiptNo, SysDate, IsAdvance, ShiftID, TenderedAmount)
		SELECT	SpecialOrderPayment.element.value('@ID','BIGINT'),
				SpecialOrderPayment.element.value('@BillHeaderID','BIGINT'),
				SpecialOrderPayment.element.value('@OrderNo','VARCHAR(20)'),
				CONVERT(VARCHAR(50),SpecialOrderPayment.element.value('@OrderDate','VARCHAR(30)'),103),
				SpecialOrderPayment.element.value('@OrderAmount','NUMERIC(18,4)'),
				SpecialOrderPayment.element.value('@PayCode','VARCHAR(3)'), 
				SpecialOrderPayment.element.value('@PayAmount','NUMERIC(18,4)'),
				SpecialOrderPayment.element.value('@UserName','VARCHAR(20)'),
				SpecialOrderPayment.element.value('@Remarks','VARCHAR(250)'),
				SpecialOrderPayment.element.value('@OutletCode','VARCHAR(5)'),
				SpecialOrderPayment.element.value('@SettlementType','VARCHAR(1)'),
				SpecialOrderPayment.element.value('@ReceiptNo','VARCHAR(10)'),
				CONVERT(VARCHAR(50),SpecialOrderPayment.element.value('@SysDate','VARCHAR(30)'),103),
				SpecialOrderPayment.element.value('@IsAdvance','BIT'),
				SpecialOrderPayment.element.value('@ShiftID','BIGINT'),
				SpecialOrderPayment.element.value('@TenderedAmount','NUMERIC(18,4)')				
		FROM	@tSpecialOrderPaymentXml.nodes('/root/SpecialOrder/Payment') AS SpecialOrderPayment(element)

	COMMIT TRAN 
END TRY

BEGIN CATCH
	ROLLBACK TRAN
	DECLARE @Msg NVARCHAR(200)
	SET @Msg = ERROR_MESSAGE()
	INSERT INTO POS_DatabaseErrorLog (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)	
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),@Msg)
	RAISERROR(@Msg,16,1)
END CATCH

GO

