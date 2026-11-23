
-- =============================================

CREATE PROCEDURE [dbo].[Api_Update_OrderStatus_UberEat] 
	@OrderDetails NVARCHAR(MAX)
AS
BEGIN TRY
BEGIN TRANSACTION
SET DATEFORMAT dmy

	SET NOCOUNT ON;	


	IF OBJECT_ID(N'tempdb..#TempOrderDetail') IS NOT NULL
	BEGIN
	DROP TABLE #TempOrderDetail
	END


	SELECT [OrderId],[Action],Reason
	INTO #TempOrderDetail
	FROM   
	OpenJson(@OrderDetails)  
	WITH  
	(  
		OrderId VARCHAR(500) '$.OrderId',
		Action  VARCHAR(50)  '$.Action',
		Reason  VARCHAR(250)  '$.Reason'
	)
	
	DECLARE @Action VARCHAR(50),@Reason VARCHAR(250)
	SELECT TOP(1) @Action = [Action],@Reason = Reason FROM #TempOrderDetail

	IF( @Action = 'ACCEPT')
	BEGIN

		UPDATE P
		SET IsAccept = 1,
		AcceptTime = GETDATE()
		FROM POS_OutsideOrders P INNER JOIN #TempOrderDetail T ON P.OutsideOrderId = T.OrderId

	END  
	ELSE IF( @Action = 'DENY')
	BEGIN

		UPDATE P
		SET IsDeny = 1,
		DenyTime = GETDATE(),
		DenyReason = @Reason
		FROM POS_OutsideOrders P INNER JOIN #TempOrderDetail T ON P.OutsideOrderId = T.OrderId

	END 
	ELSE IF( @Action = 'CANCEL')
	BEGIN

		UPDATE P
		SET IsCancel = 1,
		CancelTime = GETDATE()
		FROM POS_OutsideOrders P INNER JOIN #TempOrderDetail T ON P.OutsideOrderId = T.OrderId

	END


	



	IF OBJECT_ID(N'tempdb..#TempOrderDetail') IS NOT NULL
	BEGIN
	DROP TABLE #TempOrderDetail
	END
	

COMMIT TRANSACTION
END TRY
BEGIN CATCH
	
	DECLARE @ErrorMessage VARCHAR(MAX)
	DECLARE @ErrorSeverity VARCHAR(MAX)
	DECLARE @ErrorState VARCHAR(MAX)

	SET @ErrorMessage  = ERROR_MESSAGE()
    SET @ErrorSeverity = ERROR_SEVERITY()
    SET @ErrorState    = ERROR_STATE()
	--INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
 --   VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH

GO

