CREATE PROCEDURE [dbo].[POS_spGetOrderReturn]
@PropertyId INT,
@ReturnNo VARCHAR(20)
AS
SET DATEFORMAT DMY 
SET NOCOUNT ON

BEGIN TRY
	BEGIN TRAN

		SELECT	ReturnHeaderID, ReturnNo, BusinessDate, UserID, U.Name UserName, ShiftNo, Station, Outlet, L.description AS OutletName,
				ReturnAmount, ReturnReason, OrderNo, OrderDate, OrderOutlet, I.description AS OrderOutletName,
				RedeemOrderNo, RedeemOrderDate, RedeemOutlet, R.description AS  RedeemOutletName,  RedeemUserID
		FROM    POS_OrderReturnHeader H INNER JOIN Waiter U ON H.UserID = U.Code
				INNER JOIN Location_Ref L ON H.Outlet = L.code
				INNER JOIN Location_Ref I ON H.OrderOutlet = I.code
				LEFT JOIN Location_Ref R ON H.RedeemOutlet = R.code
		WHERE	H.PropertyId = @PropertyId AND ReturnNo = @ReturnNo

		SELECT  MainMenuCode, M.ApperOnInv, Quantity, ReturnPrice
		FROM    POS_OrderReturnDetail D INNER JOIN MainMenu M ON D.MainMenuCode = M.ItemCode AND D.PropertyId = M.PropertyId
		WHERE	D.PropertyId = @PropertyId AND ReturnNo = @ReturnNo

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

