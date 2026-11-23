-- =============================================
-- Author				: Isuru Pramodya
-- Create date			: 2025-05-23
-- Last Modified User	: Nivesh
-- Last Modified Date	: 2025-08-15
-- Description			: Inserting Supplier quotation details using excel

-- [dbo].[SP_InsertSupplierExcelQuotation]  '<ArrayOfSupplierQuotationUpload xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><SupplierQuotationUpload><DocumentNo>MST/PR/000001</DocumentNo><UserID>4168</UserID><RequestHeaderID>1</RequestHeaderID><QuotationRequestId>1</QuotationRequestId><LocationID>-999</LocationID><PropertyID>1</PropertyID><Itemdetails><QuotationExcelItemDetails><StockItemCode>003</StockItemCode><ItemName>EGG BUN (PRO)</ItemName><UnitName>NUMBERS</UnitName><Quantity>10</Quantity><Price>20</Price><ItemID>3914</ItemID><UnitID>1</UnitID></QuotationExcelItemDetails><QuotationExcelItemDetails><StockItemCode>10006</StockItemCode><ItemName>FG CHICKEN CREPE</ItemName><UnitName>NUMBERS</UnitName><Quantity>30</Quantity><Price>44</Price><ItemID>3922</ItemID><UnitID>1</UnitID></QuotationExcelItemDetails><QuotationExcelItemDetails><StockItemCode>10005</StockItemCode><ItemName>SFG  - CREPE BATTER</ItemName><UnitName>GRAM</UnitName><Quantity>20</Quantity><Price>45</Price><ItemID>39251</ItemID><UnitID>20</UnitID></QuotationExcelItemDetails></Itemdetails><QuotationFileName>QR_MST_PR_000001_120250526165811.xlsx</QuotationFileName><SupplierId>159</SupplierId></SupplierQuotationUpload></ArrayOfSupplierQuotationUpload>'


-- =============================================
CREATE PROCEDURE [dbo].[SP_InsertSupplierExcelQuotation] 
 @XMLDetails XML
AS

DECLARE @iDocID INT
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY 
	BEGIN TRANSACTION
	EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

		SELECT DocumentNo,UserID,RequestHeaderID,QuotationRequestId,PropertyID,QuotationFilePath,SupplierId
		INTO #SupplierQuotationUpload
		FROM 
		OPENXML(@iDocID, '/ArrayOfSupplierQuotationUpload/SupplierQuotationUpload', 2)
		WITH(
		DocumentNo  VARCHAR(200),
		UserID INT,
		RequestHeaderID INT,
		QuotationRequestId INT,
		PropertyID INT,
		QuotationFilePath VARCHAR(MAX),
		SupplierId INT
		);

		SELECT StockItemCode,ItemName,UnitName,Quantity,Price,ItemID,UnitID,TaxAmount,DiscountValue,DiscountPercentage
		INTO #QuotationExcelItemDetails
		FROM 
		OPENXML(@iDocID, '/ArrayOfSupplierQuotationUpload/SupplierQuotationUpload/Itemdetails/QuotationExcelItemDetails', 2)
		WITH(
		StockItemCode  VARCHAR(max),
		ItemName varchar(MAX),
		UnitName VARCHAR(200),
		Quantity DECIMAL(18,6),
		Price DECIMAL(18,6),
		ItemID INT,
		UnitID INT,
		TaxAmount DECIMAL(18,6),
		DiscountValue DECIMAL(18,6),
		DiscountPercentage DECIMAL(18,6));



		

		DECLARE @RequestHeaderID INT,@UserID INT,@QuotationRequestId INT,@LocationID INT,@PropertyID INT,@QuotationFilePath VARCHAR(MAX),@SupplierId INT

		SELECT TOP (1) @RequestHeaderID =RequestHeaderID,@UserID = UserID,@QuotationRequestId = QuotationRequestId,@PropertyID =PropertyID,
		@QuotationFilePath = QuotationFilePath,@SupplierId = SupplierId
		from #SupplierQuotationUpload

		SELECT @LocationID =LocationID
		FROM RequestHeaders
		WHERE ID = @RequestHeaderID
		AND RequestType='RP'


		
		SELECT *
		INTO #ItemCheck
		FROM RequestDetails
		WHERE RequestHeaderID = @RequestHeaderID

		DECLARE @CheckItemID INT,@CheckItemName VARCHAR(MAX)
		WHILE EXISTS(SELECT 1 FROM #ItemCheck)
		BEGIN
			SELECT TOP 1 @CheckItemID = StockItemID FROM #ItemCheck

			IF NOT EXISTS(SELECT 1 FROM  #QuotationExcelItemDetails WHERE ItemID = @CheckItemID)
			BEGIN

			SELECT @CheckItemName = Name
			FROM StockItemHeaders
			WHERE ID = @CheckItemID

					RAISERROR('%s Item is missing from Excel', 16, 1, @CheckItemName)
				ROLLBACK TRANSACTION
			END

			DELETE TOP (1) FROM #ItemCheck

		END

		UPDATE SQ -- With Supplier entered data
		SET SQ.Price = QT.price,
		SQ.IsQuotationUpload =1,
		SQ.TaxAmount =QT.TaxAmount ,
		SQ.DiscountValue = QT.DiscountValue,
		SQ.DiscountPercentage = QT.DiscountPercentage,
		SQ.NetPrice = QT.price + (QT.price * QT.TaxAmount 
		/100) - (QT.DiscountValue - (QT.DiscountPercentage/100) )
		FROM QuotationRequestHeader QH
		INNER JOIN QuotationRequestDetail QD ON QH.Id = QD.QuotationRequestId
		INNER JOIN SupplierQuotationUploadDetail SQ ON SQ.QuotationHeaderId = QH.Id AND QD.Id = SQ.QuotationDetailID
		INNER JOIN #SupplierQuotationUpload SU ON SU.QuotationRequestId =SQ.QuotationHeaderId
		INNER JOIN #QuotationExcelItemDetails QT ON QT.ItemID = SQ.ItemID AND SQ.SupplierID = SU.SupplierID
		WHERE SQ.SupplierID = @SupplierId
		AND SQ.QuotationHeaderID = @QuotationRequestId

		--UPDATE SQ -- with Tax inclusive suppliers
		--SET 
		--	SQ.Price = QT.Price,
		--	SQ.IsQuotationUpload = 1,
		--	SQ.TaxAmount = COALESCE(TG.ChargeRate, QT.TaxAmount),
		--	SQ.DiscountValue = QT.DiscountValue,
		--	SQ.DiscountPercentage = QT.DiscountPercentage,
		--	SQ.NetPrice = QT.Price 
		--				 + (QT.Price * COALESCE(TG.ChargeRate, QT.TaxAmount) / 100) 
		--				 - (QT.DiscountValue - (QT.DiscountPercentage / 100))
		--FROM QuotationRequestHeader QH
		--INNER JOIN QuotationRequestDetail QD 
		--	ON QH.Id = QD.QuotationRequestId
		--INNER JOIN SupplierQuotationUploadDetail SQ 
		--	ON SQ.QuotationHeaderId = QH.Id 
		--   AND QD.Id = SQ.QuotationDetailID
		--INNER JOIN #SupplierQuotationUpload SU 
		--	ON SU.QuotationRequestId = SQ.QuotationHeaderId
		--INNER JOIN #QuotationExcelItemDetails QT 
		--	ON QT.ItemID = SQ.ItemID 
		--   AND SQ.SupplierID = SU.SupplierID
		--LEFT JOIN SupplierWiseItemDetails SSW 
		--	ON SSW.StockItemID = SQ.ItemID
		--   AND SSW.LocationId = @LocationID
		--   AND SSW.SupplierID = @SupplierId
		--LEFT JOIN TaxGroupDetails TG 
		--	ON TG.TaxGroupId = SSW.TaxGroupID
		--WHERE SQ.SupplierID = @SupplierId
		--  AND SQ.QuotationHeaderID = @QuotationRequestId;


		UPDATE QD
		SET QD.IsQuotationUploaded=1,QD.QuotationFilePath = @QuotationFilePath
		FROM QuotationRequestHeader QH
		INNER JOIN QuotationRequestDetail QD ON QH.Id = QD.QuotationRequestId
		INNER JOIN SupplierQuotationUploadDetail SQ ON SQ.QuotationHeaderId = QH.Id AND QD.Id = SQ.QuotationDetailID
		INNER JOIN #SupplierQuotationUpload SU ON SU.QuotationRequestId =SQ.QuotationHeaderId
		INNER JOIN #QuotationExcelItemDetails QT ON QT.ItemID = SQ.ItemID AND SQ.SupplierID = SU.SupplierID
		WHERE SQ.SupplierID = @SupplierId
		AND SQ.QuotationHeaderID = @QuotationRequestId

	

		
		 
    
	COMMIT TRANSACTION
	END TRY 
	BEGIN CATCH 
		ROLLBACK TRANSACTION 
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  
		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);

	END CATCH
    
END

GO

