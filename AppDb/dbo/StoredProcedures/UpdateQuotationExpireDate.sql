CREATE PROCEDURE [dbo].[UpdateQuotationExpireDate](@QuotationID INT, @ExpDate DATE, @remarks VARCHAR(500), @UserId INT = 1)
AS
BEGIN
	BEGIN TRY
	BEGIN TRANSACTION

	DECLARE  @ViewAccess BIT,@QuotationManageAttId INT, @msg VARCHAR(MAX),@ItemId INT, @itemCode CHAR(100), @ItemName VARCHAR(350)
	
	---------check access-------------------------------
	CREATE TABLE #TempAccess(
		FormId INT,
		ViewAccess BIT,
		InsertAccess BIT,
		UpdateAccess BIT,
		DeleteAccess BIT,
		PrintAccess BIT,
		OverrideDefault BIT
	)
	INSERT INTO #TempAccess  EXEC  [dbo].[SP_S_GetFinalSecuritySet] @UserId 

	SELECT @ViewAccess = ViewAccess FROM #TempAccess WHERE FormID = 152


	SELECT @QuotationManageAttId = QuotationManageByHOAttributeId  FROM CommonSettings 

	SELECT QD.ItemId,SH.StockItemCode,SH.Name INTO #TempItemData 
	FROM SupplierQuotationHeader QH
	INNER JOIN SupplierQuotationDetails QD ON QH.Id = QD.QuotationHeaderId AND QH.Id = @QuotationID
	INNER  JOIN StockItemHeaders SH ON SH.Id = QD.ItemId


	IF(@ViewAccess = 0)
	BEGIN
	WHILE (SELECT COUNT(*) FROM #TempItemData) > 0
		BEGIN
			SELECT TOP(1) @ItemId = ItemId, @itemCode = StockItemCode, @ItemName = Name  FROM  #TempItemData
			IF EXISTS(SELECT 1 FROM StockItemWiseAttributes WHERE StockItemHeaderID = @ItemId AND StockItemAttributeID = @QuotationManageAttId 
			AND IsActive = 1)
			BEGIN
				SET @msg='This user has not access for update '+@itemCode +'-'+@ItemName+' item  '
				RAISERROR (@msg,16,1)
				RETURN;
			END
			DELETE TOP(1) FROM  #TempItemData
		END
	END

	---------check access-------------------------------


	UPDATE SupplierQuotationHeader
	SET ValidTo = @ExpDate, ExpdateChangeRemarks = @remarks
	WHERE Id= @QuotationID 

	UPDATE SWD
	SET SWD.ValidTo = @ExpDate
	FROM SupplierWiseItemDetails SWD
	INNER JOIN SupplierQuotationDetails SQD ON SQD.ItemId = SWD.StockItemID AND SQD.QuotationHeaderId = @QuotationID
	INNER JOIN SupplierQuotationHeader SQH ON SQH.Id = @QuotationID AND SQH.SupplierId = SWD.SupplierID

	COMMIT TRAN;
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
		IF @@TRANCOUNT > 0 ROLLBACK   
	END CATCH
END

----update SupplierWiseItemDetails set ValidTo = null

--select * from SupplierWiseItemDetails where StockItemID = 1

GO

