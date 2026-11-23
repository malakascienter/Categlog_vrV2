
-- [dbo].[POS_spInsertKitchenIssuesLocationWise] 1,'T01','2024-10-7'

CREATE PROCEDURE [dbo].[POS_spInsertOrderReturnLocationWise] 
@PropertyId INT,
@OutletCode varchar(5),
@OrderDate DATE

AS
BEGIN
BEGIN TRY
BEGIN TRANSACTION

SET DATEFORMAT DMY


DELETE FROM OutletOrderReturn WHERE PropertyID = @PropertyId AND CONVERT(DATE, TxnDate) =  CONVERT(DATE,@OrderDate)  AND OutletCode = @OutletCode



IF( @OutletCode = 'T01' )
BEGIN

		INSERT INTO OutletOrderReturn
		(PropertyID, LocationID, OutletCode, TxnDate, MenuCode, StockItemID, Quantity, TxnUnitID, AveragePrice,DepartmentID)
		SELECT	BT.PropertyId, 1 AS LocationID, BT.Outlet, BT.BusinessDate, BT.MainMenuCode, RD.StockItemCode, SUM(RD.Qty * IB.Qty * BT.Quantity) AS IssueQty, RD.Unit, SD.AveragePrice, LR.DepartmentID
		FROM	RecipeDetails AS RD INNER JOIN RecipeHeader AS RH ON RD.RecipeCode = RH.RecipeCode AND RD.PropertyId = RH.PropertyId 
				INNER JOIN ItemBreakDown AS IB ON RH.RecipeCode = IB.RecipeCode AND IB.PropertyId = RH.PropertyId 
				INNER JOIN POS_OrderReturnDetail AS BT ON IB.MainMenuCode = BT.MainMenuCode AND BT.PropertyId = IB.PropertyId 
				INNER JOIN MainMenu MM ON MM.ItemCode = BT.MainMenuCode AND MM.PropertyId = BT.PropertyId
				INNER JOIN Category C ON C.Code = MM.Category AND C.PropertyId = MM.PropertyId
				INNER JOIN pos_Classification01 C01 ON C01.Id = C.Classification01Id
				INNER JOIN Location_Ref AS LR ON BT.Outlet = LR.code AND LR.PropertyId = BT.PropertyId 
				INNER JOIN StockItemDetails AS SD ON RD.StockItemCode = SD.StockItemHeaderID AND SD.PropertyID = BT.PropertyId AND SD.LocationID = 1
		WHERE	BT.PropertyId =  @PropertyId AND CONVERT(DATE, BT.BusinessDate) =  CONVERT(DATE,@OrderDate) and LR.Code=@OutletCode AND C01.Id <> 1 -- NOT FINISH FOOD ITEM DEDICATE IN T-LOUNGE HORTON PLACE 
		GROUP BY BT.PropertyId, BT.Outlet, BT.BusinessDate, BT.MainMenuCode, RD.StockItemCode, RD.Unit, SD.AveragePrice, LR.DepartmentID


		UNION ALL

		SELECT	BT.PropertyId, 1 AS LocationID, BT.Outlet, BT.BusinessDate, BT.MainMenuCode, sd.StockItemHeaderID, SUM(BT.Quantity) AS IssueQty, SD.MasterUnitID, SD.AveragePrice, LR.DepartmentID
		FROM	POS_OrderReturnDetail AS BT 
				INNER JOIN MainMenu MM ON BT.MainMenuCode = MM.ItemCode AND BT.PropertyId = MM.PropertyId
				INNER JOIN Location_Ref AS LR ON BT.Outlet = LR.code AND LR.PropertyId = BT.PropertyId 
				INNER JOIN StockItemDetails AS SD ON MM.StockItemId = SD.StockItemHeaderID AND MM.PropertyID = SD.PropertyId AND SD.LocationID = 1 -- RETAIL ITEM DEDICATE IN T-LOUNGE HORTON PLACE 
		WHERE	BT.PropertyId =  @PropertyId AND CONVERT(DATE, BT.BusinessDate) =  CONVERT(DATE,@OrderDate) and LR.Code=@OutletCode
		GROUP BY BT.PropertyId, BT.Outlet, BT.BusinessDate, BT.MainMenuCode, sd.StockItemHeaderID, SD.MasterUnitID, SD.AveragePrice, LR.DepartmentID

		UNION ALL

		SELECT	BT.PropertyId, 16 AS LocationID, BT.Outlet, BT.BusinessDate, BT.MainMenuCode, RD.StockItemCode, SUM(RD.Qty * IB.Qty * BT.Quantity) AS IssueQty, RD.Unit, SD.AveragePrice, LR.DepartmentID
		FROM	RecipeDetails AS RD INNER JOIN RecipeHeader AS RH ON RD.RecipeCode = RH.RecipeCode AND RD.PropertyId = RH.PropertyId 
				INNER JOIN ItemBreakDown AS IB ON RH.RecipeCode = IB.RecipeCode AND IB.PropertyId = RH.PropertyId 
				INNER JOIN POS_OrderReturnDetail AS BT ON IB.MainMenuCode = BT.MainMenuCode AND BT.PropertyId = IB.PropertyId
				INNER JOIN MainMenu MM ON MM.ItemCode = BT.MainMenuCode AND MM.PropertyId = BT.PropertyId
				INNER JOIN Category C ON C.Code = MM.Category AND C.PropertyId = MM.PropertyId
				INNER JOIN pos_Classification01 C01 ON C01.Id = C.Classification01Id
				INNER JOIN Location_Ref AS LR ON BT.Outlet = LR.code AND LR.PropertyId = BT.PropertyId 
				INNER JOIN StockItemDetails AS SD ON RD.StockItemCode = SD.StockItemHeaderID AND SD.PropertyID = BT.PropertyId AND SD.LocationID = 16 -- FINISH FOOD ITEM DEDICATE IN HORTON PLACE KITCHEN 
		WHERE	BT.PropertyId =  @PropertyId AND CONVERT(DATE, BT.BusinessDate) =  CONVERT(DATE,@OrderDate) and LR.Code=@OutletCode AND C01.Id = 1
		GROUP BY BT.PropertyId, BT.Outlet, BT.BusinessDate, BT.MainMenuCode, RD.StockItemCode, RD.Unit, SD.AveragePrice, LR.DepartmentID

END
ELSE
BEGIN

		INSERT INTO OutletOrderReturn
				(PropertyID, LocationID, OutletCode, TxnDate, MenuCode, StockItemID, Quantity, TxnUnitID, AveragePrice,DepartmentID)
		SELECT	BT.PropertyId, LR.StockLocationID, BT.Outlet, BT.BusinessDate, BT.MainMenuCode, RD.StockItemCode, SUM(RD.Qty * IB.Qty * BT.Quantity) AS IssueQty, RD.Unit, SD.AveragePrice, LR.DepartmentID
		FROM	RecipeDetails AS RD INNER JOIN RecipeHeader AS RH ON RD.RecipeCode = RH.RecipeCode AND RD.PropertyId = RH.PropertyId 
				INNER JOIN ItemBreakDown AS IB ON RH.RecipeCode = IB.RecipeCode AND IB.PropertyId = RH.PropertyId 
				INNER JOIN POS_OrderReturnDetail AS BT ON IB.MainMenuCode = BT.MainMenuCode AND BT.PropertyId = IB.PropertyId 
				INNER JOIN Location_Ref AS LR ON BT.Outlet = LR.code AND LR.PropertyId = BT.PropertyId 
				INNER JOIN StockItemDetails AS SD ON RD.StockItemCode = SD.StockItemHeaderID AND SD.PropertyID = BT.PropertyId AND SD.LocationID = LR.StockLocationID
		WHERE	BT.PropertyId =  @PropertyId AND CONVERT(DATE, BT.BusinessDate) =  CONVERT(DATE,@OrderDate) and LR.Code=@OutletCode
		GROUP BY BT.PropertyId, LR.StockLocationID, BT.Outlet, BT.BusinessDate, BT.MainMenuCode, RD.StockItemCode, RD.Unit, SD.AveragePrice, LR.DepartmentID

		UNION ALL

		SELECT	BT.PropertyId, LR.StockLocationID, BT.Outlet, BT.BusinessDate, BT.MainMenuCode, sd.StockItemHeaderID, SUM(BT.Quantity) AS IssueQty, SD.MasterUnitID, SD.AveragePrice, LR.DepartmentID
		FROM	POS_OrderReturnDetail AS BT 
				INNER JOIN MainMenu MM ON BT.MainMenuCode = MM.ItemCode AND BT.PropertyId = MM.PropertyId
				INNER JOIN Location_Ref AS LR ON BT.Outlet = LR.code AND LR.PropertyId = BT.PropertyId 
				INNER JOIN StockItemDetails AS SD ON MM.StockItemId = SD.StockItemHeaderID AND MM.PropertyID = SD.PropertyId AND SD.LocationID = LR.StockLocationID
		WHERE	BT.PropertyId =  @PropertyId AND CONVERT(DATE, BT.BusinessDate) =  CONVERT(DATE,@OrderDate) and LR.Code=@OutletCode
		GROUP BY BT.PropertyId, LR.StockLocationID, BT.Outlet, BT.BusinessDate, BT.MainMenuCode, sd.StockItemHeaderID, SD.MasterUnitID, SD.AveragePrice, LR.DepartmentID

END


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

