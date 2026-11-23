-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-05-27
-- Description:	Completing Supplier Quotation uploading
-- =============================================
CREATE PROCEDURE [dbo].[SP_UpdateQuotationRequestUpload] 
@QuotationHeaderID INT,
@PropertyID INT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY 
	BEGIN TRANSACTION


	IF NOT EXISTS(SELECT 1
	FROM QuotationRequestHeader QH
	INNER JOIN QuotationRequestDetail QD ON QH.Id = QD.QuotationRequestId
	WHERE QH.ID = @QuotationHeaderID
	AND QH.PropertyID = @PropertyID
	AND QD.IsQuotationUploaded=1)
	BEGIN
		RAISERROR('Uploaded Quotation not found', 16, 1)
		ROLLBACK TRANSACTION

	END
	ELSE
	BEGIN
		UPDATE QuotationRequestHeader
		SET IsDocUpload = 1
		WHERE ID = @QuotationHeaderID
		AND PropertyID = @PropertyID
	END



    
	COMMIT TRANSACTION
	END TRY 
	BEGIN CATCH 
		ROLLBACK TRANSACTION 
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  
		PRINT 'hhhh'
		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);

	END CATCH
    
END

GO

