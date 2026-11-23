-- [dbo].[POS_spInsertKitchenIssues] 2,'2020-08-27'
CREATE PROCEDURE [dbo].[POS_spInsertKitchenIssues] 
@PropertyId INT,
@OrderDate DATE

AS
BEGIN
BEGIN TRY

	insert into [dbo].[DayEndGL_Posting_SP_Para]
	([PropertyId], [Date])
	VALUES (@PropertyID, @OrderDate)

BEGIN TRANSACTION

	SET DATEFORMAT DMY

	DELETE FROM OutletKitchenIssues WHERE PropertyID = @PropertyId AND TxnDate = @OrderDate
	--delete from POS_spInsertKitchenIssues_SP_Para_Temp
	insert into POS_spInsertKitchenIssues_SP_Para_Temp
	select @PropertyId, @OrderDate


	
	INSERT INTO OutletKitchenIssues
			(PropertyID, LocationID, OutletCode, TxnDate, MenuCode, StockItemID, Quantity, TxnUnitID, AveragePrice,DepartmentID)
	SELECT	BT.PropertyId, LR.StockLocationID, BT.Outlet, BT.OrderDate, BT.MainMenuCode, RD.StockItemCode, SUM(RD.Qty * IB.Qty * BT.Qty) AS IssueQty, RD.Unit, SD.AveragePrice, LR.DepartmentID
	FROM	RecipeDetails AS RD INNER JOIN RecipeHeader AS RH ON RD.RecipeCode = RH.RecipeCode AND RD.PropertyId = RH.PropertyId 
			INNER JOIN ItemBreakDown AS IB ON RH.RecipeCode = IB.RecipeCode AND IB.PropertyId = RH.PropertyId 
			INNER JOIN BillTrans AS BT ON IB.MainMenuCode = BT.MainMenuCode AND BT.PropertyId = IB.PropertyId 
			INNER JOIN Location_Ref AS LR ON BT.Outlet = LR.code AND LR.PropertyId = BT.PropertyId 
			INNER JOIN StockItemDetails AS SD ON RD.StockItemCode = SD.StockItemHeaderID AND SD.PropertyID = BT.PropertyId AND SD.LocationID = LR.StockLocationID
	WHERE	BT.PropertyId =  @PropertyId AND CONVERT(DATE, BT.OrderDate) =  CONVERT(DATE,@OrderDate) --and SD.IsActive = 1
	GROUP BY BT.PropertyId, LR.StockLocationID, BT.Outlet, BT.OrderDate, BT.MainMenuCode, RD.StockItemCode, RD.Unit, SD.AveragePrice, LR.DepartmentID

	insert into POS_spInsertKitchenIssues_SP_Para_Temp
	select 10, @OrderDate

	EXEC DayEndGL_Posting  @PropertyId, @OrderDate

COMMIT TRANSACTION 
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	
	DECLARE @ErrorMessage NVARCHAR(4000);  
	DECLARE @ErrorSeverity INT;  
	DECLARE @ErrorState INT;  

	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage,SysDate)
	VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE(),GETDATE())

	SELECT 1 
	--SELECT   
 --   @ErrorMessage = ERROR_MESSAGE(),  
 --   @ErrorSeverity = ERROR_SEVERITY(),  
 --   @ErrorState = ERROR_STATE(); 
	--RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);

END CATCH

END

GO

