
CREATE  PROCEDURE [dbo].[ItemWastage_M_Save]      
	 @ItmWastageList VARCHAR(MAX), 
	 @PropertyId     INT,
	 @UserId		 INT,
	 @Operation      VARCHAR(1)

AS    
BEGIN  TRY
BEGIN TRANSACTION
  
	SET NOCOUNT ON; 

	DECLARE @AutoCodeId			INT
	SELECT	@AutoCodeId = Id
	FROM	AutoCodes
	WHERE	FileType = 'ITMWASTAGE'

	UPDATE LocationWiseAutoCodes
	SET NextNo = NextNo + 1
	WHERE	AutoCodeId = @AutoCodeId AND CompanyID = @PropertyId

	SELECT * 
	INTO #TempMenuCodes	
	FROM OPENJSON(@ItmWastageList)  
	WITH 
	(		
		DocNo			VARCHAR(10) '$.DocNo',
		Outlet			VARCHAR(5) '$.Outlet',
		BusinessDate    datetime '$.BusinessDate',
		Qty				MONEY '$.Qty',
		ItemCode		VARCHAR(10) '$.ItemCode',
		Remark			VARCHAR(200) '$.Remark',
		Price			MONEY '$.Price',
		WastageTypeId	INT '$.WastageTypeId'
	)
	   
	IF(@Operation = 'I')    
	BEGIN  

	    IF EXISTS( SELECT [DocNo] FROM POS_ItemWastageDetails WHERE [DocNo] IN (SELECT DocNo FROM #TempMenuCodes) AND PropertyId=@PropertyId)  
		BEGIN
			RAISERROR ('Document number already exists.!',16,1)   
		END

		INSERT INTO [dbo].[POS_ItemWastageDetails]
           (
            [DocNo]
           ,[Outlet]
           ,[BusinessDate]
           ,[Qty]
           ,[ItemCode]
           ,[Remark]
           ,[CreatedUserId]
           ,[CreatedDateTime]
		   ,PropertyId
		   ,Price
		   ,WastageTypeId)
			SELECT
            DocNo
           ,Outlet
           ,BusinessDate
           ,Qty
           ,ItemCode
           ,Remark
           ,@UserId
           ,GETDATE()
		   ,@PropertyId
		   ,Price
		   ,WastageTypeId
		   FROM #TempMenuCodes

		   DECLARE @DocNo VARCHAR(50),@OutletCode VARCHAR(5),@BusinessDate DATE
		   SELECT TOP(1) @DocNo = DocNo,@OutletCode = Outlet,@BusinessDate = BusinessDate FROM #TempMenuCodes

		INSERT INTO FinishFoodWastageDetails
				(PropertyID, LocationID, OutletCode, TxnDate, MenuCode, StockItemID, Quantity, TxnUnitID, AveragePrice,DepartmentID,MenuItemQty,MenuItemRate,DocumentNo)
		SELECT	BT.PropertyId, LR.StockLocationID, BT.Outlet, BT.BusinessDate, BT.ItemCode, RD.StockItemCode, SUM(RD.Qty * IB.Qty * BT.Qty) AS IssueQty, RD.Unit, SD.AveragePrice, LR.DepartmentID,SUM(BT.Qty),BT.Price,BT.DocNo
		FROM	RecipeDetails AS RD INNER JOIN RecipeHeader AS RH ON RD.RecipeCode = RH.RecipeCode AND RD.PropertyId = RH.PropertyId 
				INNER JOIN ItemBreakDown AS IB ON RH.RecipeCode = IB.RecipeCode AND IB.PropertyId = RH.PropertyId 
				INNER JOIN POS_ItemWastageDetails AS BT ON IB.MainMenuCode = BT.ItemCode AND BT.PropertyId = IB.PropertyId 
				INNER JOIN Location_Ref AS LR ON BT.Outlet = LR.code AND LR.PropertyId = BT.PropertyId 
				INNER JOIN StockItemDetails AS SD ON RD.StockItemCode = SD.StockItemHeaderID AND SD.PropertyID = BT.PropertyId AND SD.LocationID = LR.StockLocationID
		WHERE	BT.PropertyId =  @PropertyId AND CONVERT(DATE, BT.BusinessDate) =  CONVERT(DATE,@BusinessDate) and LR.Code=@OutletCode AND BT.DocNo = @DocNo
		GROUP BY BT.PropertyId, LR.StockLocationID, BT.Outlet, BT.BusinessDate, BT.ItemCode, RD.StockItemCode, RD.Unit, SD.AveragePrice, LR.DepartmentID,BT.Price,BT.DocNo

		EXEC InsertTempFinishFoodWastage_DocumentWise_OutletWise @PropertyID,@BusinessDate,@OutletCode,@DocNo
		
	END    
	
COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())

	DECLARE  @ERRmsg VARCHAR(MAX) =ERROR_MESSAGE()
	RAISERROR(@ERRmsg,16,1)
END CATCH

GO

