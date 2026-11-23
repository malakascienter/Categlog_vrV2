
CREATE PROCEDURE [dbo].[Sync_spInsertBillChargeDetail]
@PropertyID INT,
@OrderNo VARCHAR(10),
@OrderDate DATETIME,
@Outlet VARCHAR(3)

AS
SET NOCOUNT ON
SET DATEFORMAT DMY

DECLARE @OrderType VARCHAR(5), @NetAmount NUMERIC(22,10), @SubAmount NUMERIC(22,10), @ServiceCharge NUMERIC(22,10), @Tax1  NUMERIC(22,10),@Tax2  NUMERIC(22,10),@Tax3  NUMERIC(22,10),@Tax4  NUMERIC(22,10),
		@ChargeHeaderID INT, @ResNetVal NUMERIC(18,10), @ServiceChargePer NUMERIC(18,10), @TaxPer1  NUMERIC(22,10),@TaxPer2  NUMERIC(22,10),@TaxPer3  NUMERIC(22,10),@TaxPer4  NUMERIC(22,10)
		
BEGIN TRY
	BEGIN TRAN

		SELECT	@OrderType = OrderType, @SubAmount = Subtotal, @ServiceCharge = ServiceCharge, @Tax1 = TaxVal1, @Tax2 = TaxVal2, @Tax3 = TaxVal3, @Tax4 = TaxVal4,
				@NetAmount = (Subtotal + ServiceCharge + TaxVal1 + TaxVal2 + TaxVal3 + TaxVal4)
		FROM	BillHeader
		WHERE	PropertyID = @PropertyID AND OrderNo = @OrderNo AND OrderDate = @OrderDate AND Outlet = @Outlet

		SELECT	@ChargeHeaderID = ChargeHeaderID FROM Gen_SyncOrderType WHERE PropertyID = @PropertyID AND OrderType = @OrderType 
		SELECT	@ResNetVal = ResNetVal FROM Gen_SyncChargeGroupHeader WHERE PropertyID = @PropertyID AND ChargeHeaderID = @ChargeHeaderID



		SET @ServiceChargePer = (SELECT TOP (1) ISNULL(ActualPercentage,0) FROM  Gen_SyncChargeGroupDetail WHERE ChargeHeaderID = @ChargeHeaderID AND ChargeTypeID = 1)	
		SET @TaxPer1 = (SELECT TOP (1) ISNULL(ActualPercentage,0) FROM  Gen_SyncChargeGroupDetail WHERE ChargeHeaderID = @ChargeHeaderID AND ChargeTypeID = 2)
		SET @TaxPer2 = (SELECT TOP (1) ISNULL(ActualPercentage,0) FROM  Gen_SyncChargeGroupDetail WHERE ChargeHeaderID = @ChargeHeaderID AND ChargeTypeID = 3)
		SET @TaxPer3 = (SELECT TOP (1) ISNULL(ActualPercentage,0) FROM  Gen_SyncChargeGroupDetail WHERE ChargeHeaderID = @ChargeHeaderID AND ChargeTypeID = 4)
		SET @TaxPer4 = (SELECT TOP (1) ISNULL(ActualPercentage,0) FROM  Gen_SyncChargeGroupDetail WHERE ChargeHeaderID = @ChargeHeaderID AND ChargeTypeID = 5)


		SET @SubAmount = ISNULL(@NetAmount / @ResNetVal,0)
		SET @ServiceCharge = ISNULL(@SubAmount * @ServiceChargePer,0)
		SET @Tax1 = ISNULL(@SubAmount * @TaxPer1,0)
		SET @Tax2 = ISNULL(@SubAmount * @TaxPer2,0)
		SET @Tax3 = ISNULL(@SubAmount * @TaxPer3,0)
		SET @Tax4 = ISNULL(@SubAmount * @TaxPer4,0)

		UPDATE	BillHeader SET Subtotal = @SubAmount, ServiceCharge = @ServiceCharge, TaxVal1 = @Tax1, TaxVal2 = @Tax2, TaxVal3 = @Tax3, TaxVal4 = @Tax4
		WHERE	PropertyID = @PropertyID AND OrderNo = @OrderNo AND OrderDate = @OrderDate AND Outlet = @Outlet

		UPDATE	BillTrans SET ResNetVal = @ResNetVal, ChargeHeaderID = @ChargeHeaderID, Rate = Rate * ResNetVal / @ResNetVal
		WHERE	PropertyID = @PropertyID AND OrderNo = @OrderNo AND OrderDate = @OrderDate AND Outlet = @Outlet

		DELETE	FROM POS_BillChargeDetail 
		WHERE	OrderNo = @OrderNo AND OrderDate = @OrderDate AND Outlet = @Outlet

		INSERT INTO POS_BillChargeDetail
				(PropertyId, OrderNo, OrderDate, Outlet, MenuItemID, RefItemID, ItemSequence, SortSeq, ChargeHeaderID, ChargeTypeID, ChargeTypeSequence, ActualPercentage, ChargeAmount)
		SELECT	@PropertyID, @OrderNo, @OrderDate, @Outlet, T.MainMenuCode, T.RefItemCode, T.ItemSeq, T.SortSeq, T.ChargeHeaderID, C.ChargeTypeID,C.ChargeTypeSequence, C.ActualPercentage, NetAmount * C.ActualPercentage
		FROM	BillTrans AS T INNER JOIN Gen_SyncChargeGroupDetail AS C ON T.ChargeHeaderID = C.ChargeHeaderID
		WHERE	T.OrderNo = @OrderNo AND T.OrderDate = @OrderDate AND T.Outlet = @Outlet

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

