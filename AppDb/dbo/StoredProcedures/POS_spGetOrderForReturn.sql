
CREATE PROCEDURE [dbo].[POS_spGetOrderForReturn]
@PropertyId INT,
@OutletID INT,
@OrderNo VARCHAR(20),
@OrderDate DATETIME
AS 
SET NOCOUNT ON

BEGIN TRY
	BEGIN TRAN

		SELECT	I.OrderDate, I.Outlet, I.MainMenuCode, S.ApperOnInv, I.Qty, I.ReturnQuantity, I.Rate,
				(((Rate * Qty)* BillDisPer)/(100) + BillDisVal) /I.Qty AS DiscountPerItem INTO #Return
		FROM	BillTrans AS I INNER JOIN MainMenu AS S ON I.PropertyId = S.PropertyId AND I.MainMenuCode = S.ItemCode
		WHERE	I.PropertyId = @PropertyId AND I.Outlet = @OutletID AND I.OrderNo = @OrderNo AND OrderDate = @OrderDate


		SELECT	OrderDate, Outlet, MainMenuCode, ApperOnInv, Qty, ReturnQuantity, Rate, DiscountPerItem, Qty * (Rate - DiscountPerItem) AS LineAmount
		FROM	#Return

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

