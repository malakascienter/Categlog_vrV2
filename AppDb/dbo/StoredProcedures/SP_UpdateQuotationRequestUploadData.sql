-- =============================================
-- Author:		Nivesh
-- Create date: 2025-08-14
-- Description:	Update Quatation Upload data
-- =============================================
create PROCEDURE [dbo].[SP_UpdateQuotationRequestUploadData] 
	@XMLDetails NVARCHAR(MAX)
AS
DECLARE @iDocID INT
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY 
	BEGIN TRANSACTION

	DECLARE @QuotationRequestId INT, @RequestHeaderID INT, @SupplierId INT, @UserID INT

	EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

	CREATE TABLE #QuotationExcelItemDetails( 
		Price DECIMAL(18,6),
		NetPrice DECIMAL(18,6),
		ItemID INT,
		TaxAmount DECIMAL(18,6),
		DiscountValue DECIMAL(18,6),
		DiscountPercentage DECIMAL(18,6),
		ChangeRemark NVARCHAR(500)
	);

	SELECT @QuotationRequestId = QuotationRequestId,
			@RequestHeaderID = RequestHeaderID,
			@SupplierId = SupplierId,
			@UserID = UserID
		FROM 
		OPENXML(@iDocID, '/SupplierWiseQuotationHeaderView', 2)
		WITH(
		QuotationRequestId INT,
		RequestHeaderID INT,
		SupplierId INT,
		UserID INT
		);

		INSERT INTO #QuotationExcelItemDetails
		SELECT Price,NetPrice, ItemID, TaxAmount, DiscountValue, DiscountPercentage, ChangeRemark
		FROM 
		OPENXML(@iDocID, '/SupplierWiseQuotationHeaderView/DetailList/SupplierWiseQuotationDetailView', 2)
		WITH(
			Price DECIMAL(18,6),
			NetPrice DECIMAL(18,6),
			ItemID INT,
			TaxAmount DECIMAL(18,6),
			DiscountValue DECIMAL(18,6),
			DiscountPercentage DECIMAL(18,6),
			ChangeRemark NVARCHAR(500)
		);

		UPDATE SQ
		SET SQ.Price = QT.price,
		SQ.TaxAmount = QT.TaxAmount,
		SQ.DiscountValue = QT.DiscountValue,
		SQ.DiscountPercentage = QT.DiscountPercentage,
		SQ.NetPrice = QT.NetPrice,
		SQ.ChangeRemark = QT.ChangeRemark
		FROM QuotationRequestHeader QH
		INNER JOIN QuotationRequestDetail QD ON QH.Id = QD.QuotationRequestId
		INNER JOIN SupplierQuotationUploadDetail SQ ON SQ.QuotationHeaderId = QH.Id AND QD.Id = SQ.QuotationDetailID
		INNER JOIN #QuotationExcelItemDetails QT ON QT.ItemID = SQ.ItemID AND SQ.SupplierID = @SupplierId
		WHERE SQ.SupplierID = @SupplierId
		AND SQ.QuotationHeaderID = @QuotationRequestId

		UPDATE QuotationRequestHeader
		SET LastModifiedUserID = @UserID,
		LastModifiedDate = GETDATE()
		WHERE Id = @QuotationRequestId
	
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

