

CREATE PROCEDURE [dbo].[Sync_spInsertGetGiftVoucherSales]
@PropertyId INT,
@DocNo VARCHAR(10),
@DocDate DATETIME,
@Outlet VARCHAR(3),
@HeaderXml VARCHAR(MAX),
@DetailXml VARCHAR(MAX),
@PaymentXml VARCHAR(MAX)


AS
SET DATEFORMAT DMY
DECLARE @tHeaderXml XML, @tDetailXml XML, @tPaymentXml XML, @tKottXmlXml XML, @tChargeXml XML, @tOpenMenu XML, @tCustomerDetailsXml XML, @tEBillOrderXml XML, @tPaymentCurrencyXml XML

INSERT INTO XmlTemp(sXmlH, sXmlD, sXmlP)VALUES(@HeaderXml,@DetailXml,@PaymentXml)

SET @tHeaderXml = REPLACE(@HeaderXml,'encoding="utf-8"','encoding="ISO-8859-9"') 
SET @tDetailXml = REPLACE(@DetailXml,'encoding="utf-8"','encoding="ISO-8859-9"')
SET @tPaymentXml = @PaymentXml

BEGIN TRY
	BEGIN TRAN
		DELETE FROM POS_GiftVoucherHeader WHERE DocNo = @DocNo AND DocDate = @DocDate AND Outlet = @Outlet AND PropertyId = @PropertyId
		DELETE FROM POS_GiftVoucherTrans WHERE DocNo = @DocNo AND DocDate = @DocDate AND Outlet = @Outlet AND PropertyId = @PropertyId
		DELETE FROM POS_GiftVoucherPayTrans WHERE DocNo = @DocNo AND DocDate = @DocDate AND Outlet = @Outlet AND PropertyId = @PropertyId
		

		INSERT INTO POS_GiftVoucherHeader
			(PropertyId, DocNo, DocDate, Outlet, SubTotal, Remarks, SysDate, UserID)

		 SELECT	@PropertyId,
				Header.element.value('@DocNo','VARCHAR(10)'), 
				CONVERT(VARCHAR(50),Header.element.value('@DocDate','VARCHAR(30)'),103),
				Header.element.value('@Outlet','VARCHAR(50)'),
				Header.element.value('@SubTotal','NUMERIC(18,8)'), 
				Header.element.value('@Remarks','VARCHAR(100)'),
				CONVERT(VARCHAR(50),Header.element.value('@SysDate','VARCHAR(30)'),103), 
				Header.element.value('@UserID','VARCHAR(20)')
		FROM	@tHeaderXml.nodes('/root/Header/GVHeader') AS Header(element)    

		INSERT INTO POS_GiftVoucherTrans
			(PropertyId, DocNo, DocDate, Outlet, GiftVoucherCode, VoucherNo, Quantity, UnitValue, SysDate, UserID)
			
		SELECT	@PropertyId,
				Detail.element.value('@DocNo','VARCHAR(10)'), 
				CONVERT(VARCHAR(50),Detail.element.value('@DocDate','VARCHAR(30)'),103),
				Detail.element.value('@Outlet','VARCHAR(50)'),
				Detail.element.value('@GiftVoucherCode','VARCHAR(10)'),
				Detail.element.value('@VoucherNo','INT'), 
				Detail.element.value('@Quantity','INT'), 
				Detail.element.value('@UnitValue','NUMERIC(18,8)'), 
				CONVERT(VARCHAR(50),Detail.element.value('@SysDate','VARCHAR(30)'),103),
				Detail.element.value('@UserID','VARCHAR(20)')
		FROM	@tPaymentXml.nodes('/root/Details/GVDetails') AS Detail(element)   


		INSERT INTO POS_GiftVoucherPayTrans
			(PropertyId, DocNo, DocDate, PayCode, Outlet, ShiftID, Total, Tendered, ActualAmt, Remark, UserID, SysDate)

		SELECT	@PropertyId,
				Payment.element.value('@DocNo','VARCHAR(10)'), 
				CONVERT(VARCHAR(50),Payment.element.value('@DocDate','VARCHAR(30)'),103),
				Payment.element.value('@PayCode','VARCHAR(5)'),
				Payment.element.value('@Outlet','VARCHAR(50)'),
				Payment.element.value('@ShiftID','INT'),
				Payment.element.value('@Total','NUMERIC(18,8)'), 
				Payment.element.value('@Tendered','NUMERIC(18,8)'), 
				Payment.element.value('@ActualAmt','NUMERIC(18,8)'), 
				Payment.element.value('@Remark','VARCHAR(100)'),
				Payment.element.value('@UserID','VARCHAR(20)'),
				CONVERT(VARCHAR(50),Payment.element.value('@SysDate','VARCHAR(30)'),103)
		FROM	@tPaymentXml.nodes('/root/Payment/GVPayment') AS Payment(element)   

		
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

