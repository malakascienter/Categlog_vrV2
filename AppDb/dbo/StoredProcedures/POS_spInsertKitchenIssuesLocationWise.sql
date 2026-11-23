--	[dbo].[POS_spInsertKitchenIssuesLocationWise]  1,'069','2026-10-17'

CREATE PROCEDURE [dbo].[POS_spInsertKitchenIssuesLocationWise] 
@PropertyId INT,
@OutletCode varchar(5),
@OrderDate DATE

AS
BEGIN
BEGIN TRY
BEGIN TRANSACTION

SET DATEFORMAT DMY


insert into [dbo].DayEndGL_Posting_SP_Para_OutletWise([PropertyId], [Date],Outlet)
VALUES (@PropertyID, @OrderDate,@OutletCode)

DELETE FROM OutletKitchenIssues WHERE PropertyID = @PropertyId AND CONVERT(DATE, TxnDate) =  CONVERT(DATE,@OrderDate)  AND OutletCode = @OutletCode
	
INSERT INTO OutletKitchenIssues
		(PropertyID, LocationID, OutletCode, TxnDate, MenuCode, StockItemID, Quantity, TxnUnitID, AveragePrice,DepartmentID,MenuItemQty,MenuItemRate)
SELECT	BT.PropertyId, LR.StockLocationID, BT.Outlet, BT.OrderDate, BT.MainMenuCode, RD.StockItemCode, SUM(RD.Qty * IB.Qty * BT.Qty) AS IssueQty, RD.Unit, SD.AveragePrice, LR.DepartmentID,SUM(BT.Qty),BT.Rate
FROM	RecipeDetails AS RD INNER JOIN RecipeHeader AS RH ON RD.RecipeCode = RH.RecipeCode AND RD.PropertyId = RH.PropertyId 
		INNER JOIN ItemBreakDown AS IB ON RH.RecipeCode = IB.RecipeCode AND IB.PropertyId = RH.PropertyId 
		INNER JOIN BillTrans AS BT ON IB.MainMenuCode = BT.MainMenuCode AND BT.PropertyId = IB.PropertyId 
		INNER JOIN Location_Ref AS LR ON BT.Outlet = LR.code AND LR.PropertyId = BT.PropertyId 
		INNER JOIN StockItemDetails AS SD ON RD.StockItemCode = SD.StockItemHeaderID AND SD.PropertyID = BT.PropertyId AND SD.LocationID = LR.StockLocationID
WHERE	BT.PropertyId =  @PropertyId AND CONVERT(DATE, BT.OrderDate) =  CONVERT(DATE,@OrderDate) and LR.Code=@OutletCode
AND BT.OrderType = 'R' AND RD.Ord_Type IN ('B','R')
GROUP BY BT.PropertyId, LR.StockLocationID, BT.Outlet, BT.OrderDate, BT.MainMenuCode, RD.StockItemCode, RD.Unit, SD.AveragePrice, LR.DepartmentID,BT.Rate

INSERT INTO OutletKitchenIssues
		(PropertyID, LocationID, OutletCode, TxnDate, MenuCode, StockItemID, Quantity, TxnUnitID, AveragePrice,DepartmentID,MenuItemQty,MenuItemRate)
SELECT	BT.PropertyId, LR.StockLocationID, BT.Outlet, BT.OrderDate, BT.MainMenuCode, RD.StockItemCode, SUM(RD.Qty * IB.Qty * BT.Qty) AS IssueQty, RD.Unit, SD.AveragePrice, LR.DepartmentID,SUM(BT.Qty),BT.Rate
FROM	RecipeDetails AS RD INNER JOIN RecipeHeader AS RH ON RD.RecipeCode = RH.RecipeCode AND RD.PropertyId = RH.PropertyId 
		INNER JOIN ItemBreakDown AS IB ON RH.RecipeCode = IB.RecipeCode AND IB.PropertyId = RH.PropertyId 
		INNER JOIN BillTrans AS BT ON IB.MainMenuCode = BT.MainMenuCode AND BT.PropertyId = IB.PropertyId 
		INNER JOIN Location_Ref AS LR ON BT.Outlet = LR.code AND LR.PropertyId = BT.PropertyId 
		INNER JOIN StockItemDetails AS SD ON RD.StockItemCode = SD.StockItemHeaderID AND SD.PropertyID = BT.PropertyId AND SD.LocationID = LR.StockLocationID
WHERE	BT.PropertyId =  @PropertyId AND CONVERT(DATE, BT.OrderDate) =  CONVERT(DATE,@OrderDate) and LR.Code=@OutletCode
AND BT.OrderType <> 'R' AND RD.Ord_Type IN ('B','T')
GROUP BY BT.PropertyId, LR.StockLocationID, BT.Outlet, BT.OrderDate, BT.MainMenuCode, RD.StockItemCode, RD.Unit, SD.AveragePrice, LR.DepartmentID,BT.Rate




EXEC [DayEndGL_Posting_OutletWise] @PropertyId,@OrderDate,@OutletCode




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

