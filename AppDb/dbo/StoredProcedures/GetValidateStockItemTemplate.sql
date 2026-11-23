
/*------------------------------------------------------------------------------
  2. ALTER (original text; only the AA SELECT block replaced).
------------------------------------------------------------------------------*/
-- =============================================
-- Author:		Nivesh
-- Create date: 2024-09-10
-- Description:	Get Validate Excel Data
-- =============================================
CREATE PROCEDURE [dbo].[GetValidateStockItemTemplate] (
	@XMLDetails XML,
	@PropertyId INT,
	@LocationID INT,
	@TxnDate date=null ,
	@TransactionType VARCHAR(3) = 'AA',
	@CurrentLocationID INT = 0
	)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO ExcelUploadXML( XMLDetails,SysDateTime)
	SELECT convert(nvarchar(max),  @XMLDetails) ,GETDATE()

	BEGIN TRY 
		declare  @iDocID INT, @RowCount INT, @I INT = 1, @ErrorMessage NVARCHAR(4000),  @ISGross BIT, @DecimalPlace INT; 

	IF NOT EXISTS (SELECT 1 FROM Locations  WHERE Id = @CurrentLocationID) AND @TransactionType = 'TR'
	BEGIN
		RAISERROR('Invalid Current Location',16,1)
		RETURN
	END

	IF NOT EXISTS (SELECT 1 FROM Locations  WHERE Id = @LocationID)
	BEGIN
		RAISERROR('Invalid To Location',16,1)
		RETURN
	END

	IF NOT EXISTS (SELECT 1 FROM Companies  WHERE CompanyID = @Propertyid)
	BEGIN
		RAISERROR('Invalid Property',16,1)
		RETURN
	END

	IF (@LocationID = @CurrentLocationID) AND @TransactionType = 'TR'
	BEGIN
		RAISERROR('There cannot be similar loations',16,1)
		RETURN
	END	

	IF(@TxnDate is NUll)
	BEGIN
		RAISERROR('Invalid Transaction date',16,1)
		RETURN
	END	

	EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

	SELECT * 
	INTO #TempAllDetails
	FROM
	OPENXML(@iDocID, '/ArrayOfExcelUpload/ExcelUpload', 2)
	WITH (	
	Quantity decimal(18,8),
	StockItemCode nVARCHAR(50),
	StockName nVARCHAR(50),
	UnitName nVARCHAR(50),
	UnitPrice decimal(18,8),
	Remark nVARCHAR(100),
	RowNum int);

	IF(@TransactionType = 'AA')
	BEGIN
		INSERT INTO StockReconcilationExcelTemp(Quantity, StockItemCode, StockName, UnitName, UnitPrice, Remark, RowNum)
		SELECT * 
		FROM
		OPENXML(@iDocID, '/ArrayOfExcelUpload/ExcelUpload', 2)
		WITH (	
		Quantity FLOAT,
		StockItemCode nVARCHAR(50),
		StockName nVARCHAR(50),
		UnitName nVARCHAR(50),
		UnitPrice decimal(18,8),
		Remark nVARCHAR(100),
		RowNum int);
	END

	IF(@TransactionType = 'TR')
	BEGIN
		INSERT INTO TransferRequestExcelTemp(Quantity, StockItemCode, StockName, UnitName, UnitPrice, Remark, RowNum)
		SELECT * 
		FROM
		OPENXML(@iDocID, '/ArrayOfExcelUpload/ExcelUpload', 2)
		WITH (	
		Quantity FLOAT,
		StockItemCode nVARCHAR(50),
		StockName nVARCHAR(50),
		UnitName nVARCHAR(50),
		UnitPrice decimal(18,8),
		Remark nVARCHAR(100),
		RowNum int);
	END
	

	--SELECT @RowCount = COUNT(*) FROM #TempAllDetails;

	--WHILE  (@I <= @RowCount)
	--BEGIN
	--IF ((SELECT S.StockItemCode FROM #TempAllDetails TD LEFT JOIN StockItemHeaders S on S.StockItemCode = TD.StockItemCode WHERE TD.RowNum = @I)is null)
	--	BEGIN
	--	SET @ErrorMessage = 'Invalid StockItemCode In Row num '+ cast( @I as varchar(20))
	--		RAISERROR(@ErrorMessage,16,1)
	--	END
	--	SET @I = @I+1;
	--END
	--D.TemplateHeaderID Id,
	--TH.Name TemplateName,
	--d.StockItemHeaderID StockItemID,
	--H.Name StockName,
	--C.id CategoryID,
	--C.Name CategoryName,
	--d.UnitID,
	--U.Name UnitName,
	--1 MasterUnitID,
	--D.Qty Quantity,
	--TH.IsActive IsActive,
	--[dbo].[GetBalance](@TxnDate ,h.Id,@location,0,0) QuantityInHand,
	--sd.AveragePrice AS UnitPrice,
	--H.StockItemCode
	IF(@TransactionType = 'AA')
	BEGIN
		-- 2026-10-02: set-based rewrite (isuru). The old SELECT called GetBalance twice and
		-- FN_GetLastAveragePrice once per Excel row (each a scan of the item's history);
		-- 681 rows at Main Store took ~300 s and the API (30 s timeout) failed with
		-- "A severe error occurred ... Operation cancelled by user".
		-- One pass over the location's lines now finds, per item:
		--   Kind 'D' = last line on/before @TxnDate -> NewQuantity      (= GetBalance(@TxnDate, item, @LocationID, 0, 0))
		--   Kind 'A' = last line ever               -> NewAveragePrice  (= FN_GetLastAveragePrice(@LocationID, item))
		-- Same order as both functions: TransactionDate DESC, StockTransactionDetails.Id DESC.
		CREATE TABLE #LastLine (StockItemID INT NOT NULL, Kind CHAR(1) NOT NULL, NewQuantity DECIMAL(18,6) NOT NULL,
		                        NewAveragePrice DECIMAL(18,6) NOT NULL, PRIMARY KEY (StockItemID, Kind));

		INSERT INTO #LastLine (StockItemID, Kind, NewQuantity, NewAveragePrice)
		SELECT X.StockItemID, K.Kind, X.NewQuantity, X.NewAveragePrice
		FROM (
			SELECT D.StockItemID, D.NewQuantity, D.NewAveragePrice,
			       InDate = CASE WHEN H.TransactionDate <= @TxnDate THEN 1 ELSE 0 END,
			       rnAll  = ROW_NUMBER() OVER (PARTITION BY D.StockItemID ORDER BY H.TransactionDate DESC, D.Id DESC),
			       rnDate = ROW_NUMBER() OVER (PARTITION BY D.StockItemID, CASE WHEN H.TransactionDate <= @TxnDate THEN 1 ELSE 0 END
			                                   ORDER BY H.TransactionDate DESC, D.Id DESC)
			FROM dbo.StockTransactionHeaders AS H
			INNER JOIN dbo.StockTransactionDetails AS D ON D.StockTransactionHeaderID = H.Id
			WHERE H.LocationID = @LocationID
		) AS X
		CROSS APPLY (SELECT 'A' WHERE X.rnAll = 1
		             UNION ALL
		             SELECT 'D' WHERE X.InDate = 1 AND X.rnDate = 1) AS K(Kind)
		OPTION (RECOMPILE);

		SELECT
			H.id StockItemID,
			H.Name StockName,
			C.id CategoryID,
			C.Name CategoryName,
			U.id UnitID,
			U.Name UnitName,
			sd.MasterUnitID MasterUnitID,
			CAST(ISNULL(LD.NewQuantity, 0) AS DECIMAL(18,6)) QuantityInHand,
			td.Quantity Quantity,
			CASE WHEN CAST(ISNULL(LD.NewQuantity, 0) AS DECIMAL(18,6)) <= 0 THEN TD.UnitPrice
			     ELSE CAST(ISNULL(LA.NewAveragePrice, 0) AS DECIMAL(18,6)) END AS UnitPrice,
			H.StockItemCode,
			H.IsExpiryDateApplicable
		FROM			StockItemHeaders H
		INNER JOIN  dbo.StockItemDetails SD ON sd.StockItemHeaderID = h.Id
		INNER JOIN	Units U on u.Id = sd.MasterUnitID
		INNER JOIN	Categories C on C.Id = H.CategoryId
		INNER JOIN Locations L on l.Id = sd.LocationID
		INNER JOIN #TempAllDetails TD on td.StockItemCode = H.StockItemCode
		LEFT JOIN  #LastLine LD ON LD.StockItemID = H.Id AND LD.Kind = 'D'
		LEFT JOIN  #LastLine LA ON LA.StockItemID = H.Id AND LA.Kind = 'A'
		WHERE SD.LocationID =@LocationID AND H.CompanyId = @PropertyId
		ORDER BY H.Name

		DROP TABLE #LastLine
	END
	ELSE IF(@TransactionType ='TR')
	BEGIN
	    SELECT  @ISGross = IsTaxOrSellPrice,@DecimalPlace = DecimalPlaces
		FROM    dbo.Companies
		WHERE   CompanyID = @Propertyid

		--Check not existing items
		IF EXISTS(SELECT 1 
				FROM    dbo.StockItemDetails SID
                INNER JOIN dbo.StockItemHeaders SIH ON SID.StockItemHeaderID = SIH.Id
				INNER JOIN #TempAllDetails TD on td.StockItemCode = SIH.StockItemCode	
				LEFT JOIN Categories CA ON CA.Id = SIH.CategoryID
				LEFT JOIN Units U ON U.Id = SID.MasterUnitID
				 WHERE    SID.LocationID = @LocationID 
                AND SID.PropertyID = @PropertyId 
				AND SID.IsActive = 1
				AND ISNULL(SIH.IsProductionItem,0) = 0 
				AND SIH.Id NOT IN (	(SELECT SID2.StockItemHeaderID FROM StockItemDetails SID2 WHERE SID2.LocationID = @CurrentLocationID AND SID2.CompanyID = @Propertyid))
				)
		BEGIN
			SELECT 	SIH.id StockItemID,
			SIH.Name StockName,
			CA.id CategoryID,
			CA.Name CategoryName,
			U.id UnitID,
			U.Name UnitName,
			SID.MasterUnitID MasterUnitID,
			ROUND(dbo.[FN_GetStockInHand_Reatils](@propertyId,@LocationID,SIH.Id),@DecimalPlace) QuantityInHand,
			td.Quantity Quantity,
			TD.UnitPrice AS UnitPrice,
			SIH.StockItemCode,
			SIH.IsExpiryDateApplicable,
			'E' Status
			FROM    dbo.StockItemDetails SID
					INNER JOIN dbo.StockItemHeaders SIH ON SID.StockItemHeaderID = SIH.Id
					INNER JOIN #TempAllDetails TD on td.StockItemCode = SIH.StockItemCode	
					LEFT JOIN Categories CA ON CA.Id = SIH.CategoryID
					LEFT JOIN Units U ON U.Id = SID.MasterUnitID
			WHERE    SID.LocationID = @LocationID 
					AND SID.PropertyID = @PropertyId 
					AND SID.IsActive = 1
					AND ISNULL(SIH.IsProductionItem,0) = 0 
					AND SIH.Id NOT IN (	SELECT SID2.StockItemHeaderID FROM StockItemDetails SID2 WHERE SID2.LocationID = @CurrentLocationID AND SID2.CompanyID = @Propertyid)
		END
		ELSE IF EXISTS(  SELECT 
			1
        FROM    dbo.StockItemDetails SID
                INNER JOIN dbo.StockItemHeaders SIH ON SID.StockItemHeaderID = SIH.Id
				INNER JOIN #TempAllDetails TD on td.StockItemCode = SIH.StockItemCode	
				INNER JOIN 
				(SELECT SID2.StockItemHeaderID FROM StockItemDetails SID2 WHERE SID2.LocationID = @CurrentLocationID AND SID2.CompanyID = @Propertyid) TempTable ON TempTable.StockItemHeaderID = SIH.Id
				LEFT JOIN Categories CA ON CA.Id = SIH.CategoryID
				LEFT JOIN Units U ON U.Id = SID.MasterUnitID
        WHERE    SID.LocationID = @LocationID 
                AND SID.PropertyID = @PropertyId 
				AND SID.IsActive = 1
				AND ISNULL(SIH.IsProductionItem,0) = 1	)
		BEGIN
		  SELECT 
			SIH.id StockItemID,
			SIH.Name StockName,
			CA.id CategoryID,
			CA.Name CategoryName,
			U.id UnitID,
			U.Name UnitName,
			SID.MasterUnitID MasterUnitID,
			ROUND(dbo.[FN_GetStockInHand_Reatils](@propertyId,@LocationID,SIH.Id),@DecimalPlace) QuantityInHand,
			td.Quantity Quantity,
			TD.UnitPrice AS UnitPrice,
			SIH.StockItemCode,
			SIH.IsExpiryDateApplicable,
				'EP' Status
        FROM    dbo.StockItemDetails SID
                INNER JOIN dbo.StockItemHeaders SIH ON SID.StockItemHeaderID = SIH.Id
				INNER JOIN #TempAllDetails TD on td.StockItemCode = SIH.StockItemCode	
				INNER JOIN 
				(SELECT SID2.StockItemHeaderID FROM StockItemDetails SID2 WHERE SID2.LocationID = @CurrentLocationID AND SID2.CompanyID = @Propertyid) TempTable ON TempTable.StockItemHeaderID = SIH.Id
				LEFT JOIN Categories CA ON CA.Id = SIH.CategoryID
				LEFT JOIN Units U ON U.Id = SID.MasterUnitID
        WHERE    SID.LocationID = @LocationID 
                AND SID.PropertyID = @PropertyId 
				AND SID.IsActive = 1
				AND ISNULL(SIH.IsProductionItem,0) = 1
		END
		ELSE
		BEGIN
	       SELECT 
			SIH.id StockItemID,
			SIH.Name StockName,
			CA.id CategoryID,
			CA.Name CategoryName,
			U.id UnitID,
			U.Name UnitName,
			SID.MasterUnitID MasterUnitID,
			ROUND(dbo.[FN_GetStockInHand_Reatils](@propertyId,@LocationID,SIH.Id),@DecimalPlace) QuantityInHand,
			td.Quantity Quantity,
			TD.UnitPrice AS UnitPrice,
			SIH.StockItemCode,
			SIH.IsExpiryDateApplicable,
				'C' Status
        FROM    dbo.StockItemDetails SID
                INNER JOIN dbo.StockItemHeaders SIH ON SID.StockItemHeaderID = SIH.Id
				INNER JOIN #TempAllDetails TD on td.StockItemCode = SIH.StockItemCode	
				INNER JOIN 
				(SELECT SID2.StockItemHeaderID FROM StockItemDetails SID2 WHERE SID2.LocationID = @CurrentLocationID AND SID2.CompanyID = @Propertyid) TempTable ON TempTable.StockItemHeaderID = SIH.Id
				LEFT JOIN Categories CA ON CA.Id = SIH.CategoryID
				LEFT JOIN Units U ON U.Id = SID.MasterUnitID
        WHERE    SID.LocationID = @LocationID 
                AND SID.PropertyID = @PropertyId 
				AND SID.IsActive = 1
				AND ISNULL(SIH.IsProductionItem,0) = 0	
		END

 
			
	END

	DROP TABLE #TempAllDetails


	END TRY
	BEGIN CATCH
		 
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
	END CATCH;
END

GO

