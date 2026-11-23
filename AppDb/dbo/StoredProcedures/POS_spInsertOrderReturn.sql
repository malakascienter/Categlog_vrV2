CREATE PROCEDURE [dbo].[POS_spInsertOrderReturn]
@PropertyId INT,
@BusinessDate DATE,
@UserID VARCHAR(20),
@ShiftNo INT, 
@Station VARCHAR(100), 
@Outlet VARCHAR(5),
@ReturnAmount NUMERIC(18,8),
@ReturnReason VARCHAR(250),
@OrderNo VARCHAR(20),
@OrderOutlet VARCHAR(5),
@OrderDate DATE,
@xmlSalesReturn VARCHAR(MAX),
@ReturnNo VARCHAR(20) OUTPUT
AS
SET NOCOUNT ON
SET DATEFORMAT DMY
DECLARE @ReturnHeaderID BIGINT, @xmltSalesReturn XML

BEGIN TRY
	BEGIN TRAN
		SET @xmltSalesReturn = @xmlSalesReturn

		--SELECT @InvHeaderID = InvHeaderID, @InvoiceDate = BusinessDate FROM POS_InvoiceHeader WHERE CompanyID = @CompanyID AND InvoiceNo = @InvoiceNo AND LocationID = @InvoiceLocationID
		SELECT @ReturnNo = RIGHT(REPLICATE('0',10) + LTRIM(ISNULL(MAX(CAST(ReturnNo AS BIGINT)),0) + 1), 10) FROM POS_OrderReturnHeader

--Insert Sales Return Header----------------------------------------------------------------------
		INSERT INTO POS_OrderReturnHeader
			(PropertyId, ReturnNo, BusinessDate, InsertDateTime, UserID, ShiftNo, Station, Outlet, ReturnAmount, ReturnReason, OrderNo, OrderDate, OrderOutlet, OrderSysdate)
		VALUES
			(@PropertyId, @ReturnNo, @BusinessDate, GETDATE(), @UserID, @ShiftNo, @Station, @Outlet, @ReturnAmount, @ReturnReason, @OrderNo, @OrderDate, @OrderOutlet, GETDATE())

			SET @ReturnHeaderID = SCOPE_IDENTITY()
-------------------------------------------------------------------------------------------------

--Insert Sales Return Detail---------------------------------------------------------------------
		INSERT INTO POS_OrderReturnDetail
			(ReturnHeaderID, PropertyId, Outlet, ReturnNo, BusinessDate, InsertDateTime, MainMenuCode, Quantity, ReturnPrice)
		SELECT
			@ReturnHeaderID, @PropertyId, @UserID, @ReturnNo, @BusinessDate, GETDATE(),
				PaymentDetails.element.value('@MainMenuCode','VARCHAR(20)'),
				PaymentDetails.element.value('@Quantity','NUMERIC(18,8)'),
				PaymentDetails.element.value('@ReturnPrice','NUMERIC(18,8)')
		FROM	@xmltSalesReturn.nodes('/root/SalesReturn/ReturnDetail') AS PaymentDetails(element)    
-------------------------------------------------------------------------------------------------

--Update Invoice Detail--------------------------------------------------------------------------
		UPDATE	I SET I.ReturnQuantity = I.ReturnQuantity + R.element.value('@Quantity','NUMERIC(18,8)')
		FROM	BillTrans I INNER JOIN @xmltSalesReturn.nodes('/root/SalesReturn/ReturnDetail') AS R(element) ON I.MainMenuCode = R.element.value('@MainMenuCode','VARCHAR(20)')
		WHERE	I.PropertyId = @PropertyId AND I.OrderDate = @OrderDate AND Outlet = @OrderOutlet AND OrderNo = @OrderNo 
-------------------------------------------------------------------------------------------------

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

