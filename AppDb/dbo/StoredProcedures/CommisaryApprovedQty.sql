-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-05-17
-- Description:	Updating Approved Commisary Request details

-- EXEC [dbo].[CommisaryApprovedQty] @List=N'[{"RequestedDate":"2025-05-22T00:00:00","StockItemCode":"003","StockItemID":3914,"StockItemName":"EGG BUN (PRO)","RequestedQTY":2109.0,"TotalQty":2109.0,"ProductionLocationID":8,"userId":4168,"PropertyID":1},{"RequestedDate":"2025-05-20T00:00:00","StockItemCode":"10005","StockItemID":3921,"StockItemName":"SFG  - CREPE BATTER","RequestedQTY":4.0,"TotalQty":4.0,"ProductionLocationID":8,"userId":4168,"PropertyID":1}]'


-- =============================================
CREATE PROCEDURE [dbo].[CommisaryApprovedQty]
	 @List VARCHAR(MAX),
	 @ManualAddDatalist VARCHAR(MAX)
AS
INSERT INTO CommisaryApprovedQtyLog( List, SysDateTime)
VALUES (@List,getdate())
INSERT INTO CommisaryApprovedQtyLog( List, SysDateTime)
VALUES (@ManualAddDatalist,getdate())

BEGIN
	BEGIN TRANSACTION;
    BEGIN TRY
    SET NOCOUNT ON;

	create table #temp(RequestedDate DATE,StockItemCode VARCHAR(500),StockItemID INT,StockItemName VARCHAR(MAX)
	,RequestedQTY DECIMAL(18,6),TotalQty DECIMAL(18,6),ProductionLocationID INT,userId INT,PropertyID INT,Type VARCHAR(50));

	create table #tempReqBase(RequestedDate DATE,StockItemCode VARCHAR(500),StockItemID INT,StockItemName VARCHAR(MAX)
	,RequestedQTY DECIMAL(18,6),TotalQty DECIMAL(18,6),ProductionLocationID INT,userId INT,PropertyID INT,Remarks VARCHAR(255));

	create table #tempManual(RequestedDate DATE,StockItemCode VARCHAR(500),StockItemID INT,StockItemName VARCHAR(MAX)
	,RequestedQTY DECIMAL(18,6),TotalQty DECIMAL(18,6),ProductionLocationID INT,userId INT,PropertyID INT,Remarks VARCHAR(255));

	CREATE TABLE #TempRecipe (RecipeIttem INT,RecipeQty DECIMAL(18,6),RecipeUnit INT)
	
	DECLARE @RequestedDate DATE,@StockItemID INT,@ProductionLocationID INT,@TotalQty DECIMAL(18,6)
	,@DocumentNo  VARCHAR(MAX),@PropertyID INT,@userId INT,@RequestedQTY DECIMAL(18,6),@StockItemIDLW INT

	 DECLARE @ApprovalPrefix VARCHAR(MAX), @ApprovalCode VARCHAR(MAX)

	 DECLARE @ProductionConsolidateHeaderID INT,@RecipeIttem INT,@RecipeQty DECIMAL(18,6),@RecipeUnit INT,@ProductionRemark NVARCHAR(MAX)

	
IF( @List <> '[]' )
BEGIN

    Insert INTO #tempReqBase(RequestedDate,StockItemCode,StockItemID,StockItemName,RequestedQTY,TotalQty,ProductionLocationID,userId,PropertyID,Remarks) 
	SELECT RequestedDate,StockItemCode,StockItemID,StockItemName,RequestedQTY,TotalQty,ProductionLocationID,userId,PropertyID,Remarks
	  FROM OPENJSON(@List)
		WITH (
			RequestedDate DATE,
			StockItemCode VARCHAR(500),
			StockItemID INT,
			StockItemName VARCHAR(MAX),
			RequestedQTY DECIMAL(18,6),
			TotalQty DECIMAL(18,6),
			ProductionLocationID INT,
			userId INT,
			PropertyID INT,
            Remarks VARCHAR(255)

		); 

		SELECT TOP (1)@ProductionRemark = ISNULL(Remarks,'')
		FROM #tempReqBase
		WHERE Remarks IS NOT NULL OR Remarks <> ''

END


IF( @ManualAddDatalist <> '[]' )
BEGIN

    Insert INTO #tempManual(RequestedDate,StockItemCode,StockItemID,StockItemName,RequestedQTY,TotalQty,ProductionLocationID,userId,PropertyID,Remarks) 
	SELECT RequestedDate,StockItemCode,itemId,itemText,quantity,quantity,locationId,userId,PropertyID,Remarks
	  FROM OPENJSON(@ManualAddDatalist)
		WITH (
		    RequestedDate DATE,
			StockItemCode VARCHAR(500),
			itemId INT,
			itemText VARCHAR(MAX),
			quantity DECIMAL(18,6),
			locationId INT,
			userId INT,
			PropertyID INT,
            Remarks VARCHAR(255)

		); 

END


 Insert INTO #temp(RequestedDate,StockItemCode,StockItemID,StockItemName,RequestedQTY,TotalQty,ProductionLocationID,userId,PropertyID,Type) 
 select RequestedDate,StockItemCode,StockItemID,StockItemName,SUM(RequestedQTY) AS RequestedQTY,SUM(TotalQty) AS TotalQty,ProductionLocationID,userId,PropertyID  ,Type
 from 
 (
	 select RequestedDate,StockItemCode,StockItemID,StockItemName,RequestedQTY,TotalQty,ProductionLocationID,userId,PropertyID ,'' AS Type
	 from #tempReqBase
	 union all
	 select RequestedDate,StockItemCode,StockItemID,StockItemName,RequestedQTY,TotalQty,ProductionLocationID,userId,PropertyID ,'' AS Type
	 from #tempManual
 ) A
 GROUP BY RequestedDate,StockItemCode,StockItemID,StockItemName,ProductionLocationID,userId,PropertyID ,Type

	

		SELECT TOP 1 @RequestedDate = RequestedDate
		,@ProductionLocationID = ProductionLocationID,@PropertyID = PropertyID,@userId = userId
		FROM #temp


		--Setting Document No
		SET @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @ProductionLocationID, 'PL');
		IF @DocumentNo IS NULL
		BEGIN
		INSERT INTO TransactionTypeWiseNextNumbers
		(
			PropertyID,
			LocationID,
			TransactionType,
			NextNumber,
			LengthOfFormatting
		)
		VALUES
		(@PropertyID, @ProductionLocationID, 'PL', 1, 6);

		SET @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @ProductionLocationID, 'PL');
		END;
		SELECT @ApprovalPrefix = Prefix
		FROM dbo.Locations
		WHERE Id = @ProductionLocationID;

		SELECT @ApprovalCode = Code
		FROM dbo.TransactionTypes
		WHERE Code = 'PL';

		SELECT @ApprovalPrefix = SUBSTRING(@ApprovalPrefix, 1, 3)
	
		SET @DocumentNo = @ApprovalPrefix + '/' + @ApprovalCode + '/' + @DocumentNo;
		
		UPDATE TransactionTypeWiseNextNumbers
		SET NextNumber = NextNumber + 1
		WHERE LocationID = @ProductionLocationID
		AND TransactionType =  'PL';

		--Document no ENd

		--Inserting into Header and detail tables
		INSERT INTO ProductionConsolidateHeader(PropertyID, LocationID, DocumentNo, TxnDate, 
		RequestedDate, Status, SysDateTime, UserID,Remarks)
		SELECT @PropertyID,@ProductionLocationID ,@DocumentNo ,CONVERT(DATE,GETDATE()),
		@RequestedDate ,'P',GETDATE(),@userId,@ProductionRemark

		SET @ProductionConsolidateHeaderID = SCOPE_IDENTITY();

		INSERT INTO ProductionConsolidateDetails(HeaderID, StockItemID,RequestedQTY, ProductionQuantity, QuantityInHand, SysDateTime,MasterUnitID)
		SELECT @ProductionConsolidateHeaderID,StockItemID,RequestedQTY,TotalQty
		,[dbo].[FN_GetStockInHand](@propertyId , @ProductionLocationID  ,StockItemID),GETDATE(),dbo.FN_GetMasterUnitID(@propertyId,@ProductionLocationID,StockItemID) MasterUnitID
		FROM #temp
		--End


		--Inserting into ProductionConsolidateLocationWise table
		SELECT *
		INTO #TempLocationWise
		FROM #temp


		SELECT *
		INTO #TempLocationWise2
		FROM #tempReqBase

		WHILE EXISTS(SELECT 1 FROM #TempLocationWise2)
		BEGIN

			SELECT TOP 1 @StockItemIDLW = StockItemID
			FROM #TempLocationWise2


				INSERT INTO ProductionConsolidateLocationWise(PropertyID, ProductionConsolidateHeaderID, 
				CommiRequestHeaderID, ProductionLocationID, RequestedLocationID, StockItemID, RequestedQTY, UnitID, sysDateTime, UserID,MasterUnitID,ConvertedQuantity)
				SELECT @propertyId,@ProductionConsolidateHeaderID, CH.ID ,@ProductionLocationID,CH.RequestedLocationID,CD.StockItemID,CD.RequestedQTY,CD.UnitID,GETDATE(),@userId
				,dbo.FN_GetMasterUnitID(CH.PropertyID,@ProductionLocationID,CD.StockItemID) MasterUnitID,
				dbo.FN_GetUnitConvertionRate(CH.PropertyID,CD.UnitID,dbo.FN_GetMasterUnitID(CH.PropertyID,@ProductionLocationID,CD.StockItemID)) * CD.RequestedQTY AS ConvertedQuantity
				FROM CommiRequestHeader CH
				INNER JOIN CommiRequestDetails CD ON CH.ID = CD.HeaderID
				WHERE CD.StockItemID = @StockItemIDLW AND CONVERT(DATE,CH.RequestedDate) = @RequestedDate
				AND CH.ProductionLocationID = @ProductionLocationID
				AND CH.Status = 'A' 

			DELETE TOP (1) FROM #TempLocationWise2

		END

		WHILE EXISTS(SELECT 1 FROM #TempLocationWise)
		BEGIN

		SELECT TOP 1 @StockItemID = StockItemID,@TotalQty = TotalQty,@RequestedQTY = RequestedQTY
		FROM #TempLocationWise

		--Production Item/Recipe Item Summary Tabel insert

		INSERT INTO #TempRecipe(RecipeIttem,RecipeQty,RecipeUnit)
		SELECT RD.StockItemId RecipeIttem
		--,RD.Quantity RecipeQty

		,SUM((dbo.FN_GetUnitConvertionRate(@PropertyID,RD.UnitId,dbo.FN_GetMasterUnitID(@PropertyID,@ProductionLocationID, RD.StockItemId)) 
		 * RD.Quantity)* @TotalQty)
	   *(dbo.FN_GetUnitConvertionRate(@PropertyID,RH.UnitId,IT.UnitId) / IT.Quantity) RecipeQty
		
		,RD.UnitId RecipeUnit
		FROM Inv_ItemWiseRecipes IT
		INNER JOIN Inv_RecipeHeader RH ON RH.ID = IT.RecipeId
		INNER JOIN Inv_RecipeDetails RD ON RD.RecipeHeaderId = RH.Id
		WHERE IT.StockItemId = @StockItemID
		AND IT.LocationId = @ProductionLocationID
		GROUP BY RD.StockItemId ,RD.Quantity,RD.UnitId,RH.UnitId,IT.UnitId,IT.Quantity

		WHILE EXISTS(SELECT 1 FROM #TempRecipe)
		BEGIN
			SELECT TOP 1 @RecipeIttem = RecipeIttem, @RecipeQty = RecipeQty *@TotalQty,@RecipeUnit = RecipeUnit
			FROM #TempRecipe

			IF NOT EXISTS(SELECT 1 FROM ProductionConsolidateRecipeSummary WHERE ProductionConsolidateHeaderID = @ProductionConsolidateHeaderID
			AND RecipeItemID = @RecipeIttem)
			BEGIN

			INSERT INTO ProductionConsolidateRecipeSummary(PropertyID, LocationID, ProductionConsolidateHeaderID
			, RecipeItemID, UnitId, Quantity, SysDateTime, UserID,RecievedQuantity,MasterUnitID,ConvertedQuanity)
			SELECT @PropertyID,@ProductionLocationID,@ProductionConsolidateHeaderID 
			,@RecipeIttem RecipeItem,@RecipeUnit,@RecipeQty,GETDATE(),@userId,0
			,dbo.FN_GetMasterUnitID(@PropertyID,@ProductionLocationID,@RecipeIttem) MasterUnitID,
			dbo.FN_GetUnitConvertionRate(@PropertyID,@RecipeUnit,dbo.FN_GetMasterUnitID(@PropertyID,@ProductionLocationID,@RecipeIttem)) * @RecipeQty AS ConvertedQuantity

			END
			ELSE
			BEGIN
			UPDATE ProductionConsolidateRecipeSummary
			SET Quantity = Quantity + @RecipeQty ,
			ConvertedQuanity = ConvertedQuanity + dbo.FN_GetUnitConvertionRate(@PropertyID,@RecipeUnit,dbo.FN_GetMasterUnitID(@PropertyID,@ProductionLocationID,@RecipeIttem)) * @RecipeQty
			WHERE ProductionConsolidateHeaderID = @ProductionConsolidateHeaderID
			AND RecipeItemID = @RecipeIttem

			END

			DELETE TOP (1) FROM #TempRecipe
		END

		INSERT INTO ProductionConsolidateRecipeDetails(PropertyID, LocationID, ProductionConsolidateHeaderID, RecipeCode, RecipeHeaderId, ProductionItemID, RecipeItemID, UnitId, Quantity, 
                  SysDateTime, UserID,MasterUnitID,ConvertedQuanity)

		SELECT  @PropertyID,@ProductionLocationID,@ProductionConsolidateHeaderID ,RH.RecipeCode,RH.Id RecipeHeaderId,@StockItemID ProductionItem,RD.StockItemId RecipeItem,RD.UnitId,
		(RD.Quantity *PD.ProductionQuantity),GETDATE(),@userId
		,dbo.FN_GetMasterUnitID(@PropertyID,@ProductionLocationID,RD.StockItemId) MasterUnitID,
			dbo.FN_GetUnitConvertionRate(@PropertyID,RD.UnitId,dbo.FN_GetMasterUnitID(@PropertyID,@ProductionLocationID,RD.StockItemId)) * (RD.Quantity * 	@TotalQty) AS ConvertedQuantity
			
		--(dbo.FN_GetUnitConvertionRate(@PropertyID,PD.MasterUnitID,dbo.FN_GetMasterUnitID(@PropertyID,@ProductionLocationID,RD.StockItemId))*
		FROM ProductionConsolidateHeader PH
		INNER JOIN ProductionConsolidateDetails PD ON PD.HeaderID = PH.ID
		INNER JOIN Inv_ItemWiseRecipes IT ON IT.StockItemId = PD.StockItemID AND IT.LocationId = @ProductionLocationID
		INNER JOIN Inv_RecipeHeader RH ON RH.Id = IT.RecipeId
		INNER JOIN Inv_RecipeDetails RD ON RD.RecipeHeaderId = RH.Id
		--WHERE PD.StockItemID = @StockItemID AND CONVERT(DATE,PH.RequestedDate) = @RequestedDate
		--AND PH.LocationID = @ProductionLocationID
		--AND PH.Status = 'P'
		WHERE PH.Id = @ProductionConsolidateHeaderID AND PD.StockItemID = @StockItemID




	




		--ENd


		DELETE TOP (1) FROM #TempLocationWise

		END

		--End


	

		WHILE EXISTS(SELECT 1 FROM #tempReqBase )
		BEGIN
				SELECT TOP 1 @RequestedDate = RequestedDate,@StockItemID = StockItemID,
				@TotalQty = TotalQty,@ProductionLocationID = ProductionLocationID 
				FROM #tempReqBase
				--WHERE Type = 'R'

				UPDATE CD 
				SET CD.Status = 'C'
				FROM CommiRequestHeader CH
				INNER JOIN CommiRequestDetails CD ON CH.ID = CD.HeaderID
				WHERE CD.StockItemID = @StockItemID AND CONVERT(DATE,CH.RequestedDate) = @RequestedDate
				AND CH.ProductionLocationID = @ProductionLocationID
				AND CH.Status = 'A' AND CD.Status='A'

				UPDATE CH
				SET CH.Status = 'C'
				FROM CommiRequestHeader CH
				WHERE CH.Status = 'A'
				  AND EXISTS (
					SELECT 1
					FROM CommiRequestDetails CD
					WHERE CD.HeaderID = CH.ID
					  AND CD.StockItemID = @StockItemID
					  AND CONVERT(DATE, CH.RequestedDate) = @RequestedDate
					  AND CH.ProductionLocationID = @ProductionLocationID
				  )
				  AND NOT EXISTS (
					SELECT 1
					FROM CommiRequestDetails CD
					WHERE CD.HeaderID = CH.ID AND CD.Status != 'C'
				  );

				--IF NOT EXISTS(SELECT 1 FROM CommiRequestHeader CH INNER JOIN CommiRequestDetails CD ON CH.ID = CD.HeaderID
				--WHERE CD.StockItemID = @StockItemID AND CONVERT(DATE,CH.RequestedDate) = @RequestedDate
				--AND CH.ProductionLocationID = @ProductionLocationID
				--AND CD.Status='P')
				--BEGIN
				--	UPDATE CH
				--	SET CH.Status = 'C'
				--	FROM CommiRequestHeader CH
				--	INNER JOIN CommiRequestDetails CD ON CH.ID = CD.HeaderID
				--	WHERE CD.StockItemID = @StockItemID AND CONVERT(DATE,CH.RequestedDate) = @RequestedDate
				--	AND CH.ProductionLocationID = @ProductionLocationID
				--	AND CH.Status = 'P'

				--END
				--ELSE
				--BEGIN
				--	UPDATE CH
				--	SET CH.Status = 'P'
				--	FROM CommiRequestHeader CH
				--	INNER JOIN CommiRequestDetails CD ON CH.ID = CD.HeaderID
				--	WHERE CD.StockItemID = @StockItemID AND CONVERT(DATE,CH.RequestedDate) = @RequestedDate
				--	AND CH.ProductionLocationID = @ProductionLocationID
				--END
	

	
				DELETE TOP (1) FROM #tempReqBase 
		END



		IF OBJECT_ID(N'tempdb..#TempLocationWise2') IS NOT NULL
		BEGIN
		DROP TABLE #TempLocationWise2
		END

		IF OBJECT_ID(N'tempdb..#TempLocationWise') IS NOT NULL
		BEGIN
		DROP TABLE #TempLocationWise
		END

		IF OBJECT_ID(N'tempdb..#tempReqBase') IS NOT NULL
		BEGIN
		DROP TABLE #tempReqBase
		END

		IF OBJECT_ID(N'tempdb..#temp') IS NOT NULL
		BEGIN
		DROP TABLE #temp
		END

		IF OBJECT_ID(N'tempdb..#tempManual') IS NOT NULL
		BEGIN
		DROP TABLE #tempManual
		END

		IF OBJECT_ID(N'tempdb..#TempRecipe') IS NOT NULL
		BEGIN
		DROP TABLE #TempRecipe
		END

		SELECT @ProductionConsolidateHeaderID Headerid,@DocumentNo Docno

    COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
        ROLLBACK TRANSACTION;
        
    END CATCH
END

GO

