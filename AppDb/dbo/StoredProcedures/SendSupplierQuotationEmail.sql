-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-05-15
-- Description:	Sending Supplier Quotation Email

-- [dbo].[SendSupplierQuotationEmail] 1,1,1,1

-- =============================================
CREATE PROCEDURE [dbo].[SendSupplierQuotationEmail]
	@ProcurementID INT,
	@SupplierID INT,
	@StockItemHeaderID INT,
	@PropertyID INT
AS
BEGIN
 BEGIN TRY
         BEGIN TRANSACTION
	SET NOCOUNT ON;
	DECLARE @Email VARCHAR(MAX),@EmailBody VARCHAR(MAX), @CompanyName VARCHAR(200), @LocationName VARCHAR(200), @RequestedUser VARCHAR(200)
	,@TransactionTypeName VARCHAR(MAX), @DocumentNo VARCHAR(MAX)
	DECLARE @NewEmail VARCHAR(MAX),@NewApprovalUserID INT,@NewMailSubject VARCHAR(MAX)
	DECLARE @SupplierName VARCHAR(MAX),@Quantity MONEY,@Unit VARCHAR(200),@StockItemCode VARCHAR(MAX),@ItemName VARCHAR(MAX),@ProcurementDocumentNo varchar(200)

	SELECT @Quantity = PR.Quantity,@Unit = UN.Name ,@ProcurementDocumentNo  = DocumentNo
	FROM ProcurementRequest PR
	INNER JOIN Units UN ON UN.ID = PR.UnitID
	WHERE PR.ID = @ProcurementID

	SELECT @Email= Email,@SupplierName = Name
	FROM SUPPLIERS
	WHERE ID = @SupplierID

	SELECT @StockItemCode = StockItemCode,@ItemName =Name
	FROM StockItemHeaders
	WHERE ID = @StockItemHeaderID

	SELECT @CompanyName = Name
	FROM Companies
	WHERE CompanyID = @PropertyID


	--SELECT @Quantity Quantity,@Unit Unit,@Email Email,@SupplierName SupplierName,@StockItemCode StockItemCode,@ItemName ItemName, @CompanyName CompanyName

			SET @EmailBody = 
			'<html><body>' +
			'<p>Dear ' + @SupplierName + ',</p>' +
			'<p>The following supplier quotation has been approved.</p>' +
			'<p><strong>Procurement Request No:</strong> ' + @ProcurementDocumentNo + '</p>' +
			'<table border="1" cellpadding="5" cellspacing="0">' +
			'<thead>' +
			'<tr>' +
			'<th style="width: 20%;">Company Name</th>' +
			'<th style="width: 20%;">Item Code</th>' +
			'<th style="width: 20%;">Item Name</th>' +
			'<th style="width: 20%;">Unit</th>' +
			'<th style="width: 20%;">Quantity</th>' +
			'</tr>' +
			'</thead>' +
			'<tbody>' +
			'<tr>' +
			'<td>' + @CompanyName + '</td>' +
			'<td>' + @StockItemCode + '</td>' +
			'<td>' + @ItemName + '</td>' +
			'<td>' + @Unit + '</td>' +
			'<td>' + CAST(@Quantity AS VARCHAR(20)) + '</td>' +
			'</tr>' +
			'</tbody>' +
			'</table>' +
			'<br><br>' +
			'<p style="font-size:12px; color:gray;"><small>This email is auto-generated, please do not respond.</small></p>' +
			'</body></html>';

	
	SET @NewMailSubject = 'Supplier Quotation Approved – ' + @ItemName + ' for ' + @CompanyName;

		select @EmailBody EmailBody,@Email NewEmail,@NewMailSubject NewMailSubject

		EXEC [dbo].[SendReuestMail] @Email, @NewMailSubject, @EmailBody, 2

		  COMMIT TRANSACTION
 END TRY
 BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN --RollBack in case of Error
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

