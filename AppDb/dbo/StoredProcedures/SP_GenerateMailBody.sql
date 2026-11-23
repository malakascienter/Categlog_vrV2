-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-05-27
-- Modified by: Nivesh
-- Modified date: 2025-08-18
-- Description:	Getting Supplier Quotation mail body
-- [dbo].[SP_GenerateMailBody] 8,159
-- =============================================
CREATE PROCEDURE [dbo].[SP_GenerateMailBody] 
@QuotationRequestId INT,
@SupplierId INT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN
    BEGIN TRY 
	BEGIN TRANSACTION
	DECLARE @EmailBody VARCHAR(MAX),@MailSubject VARCHAR(MAX),@SupName VARCHAR(MAX),@SupplierEmail VARCHAR(200)

	SELECT @SupName = Name,@SupplierEmail =Email,@MailSubject='Test Quotation Request'
	FROM Suppliers
	WHERE ID = @SupplierId

	--IF(@SupplierEmail IS NULL OR @SupplierEmail = '')
	--BEGIN
	--	RAISERROR('%s supplier Email Address Missing', 16, 1, @SupName)
	--	ROLLBACK TRANSACTION
	--END

    DECLARE @Rows NVARCHAR(MAX), @TaxDetailBody NVARCHAR(MAX);

    SELECT @Rows = (
        SELECT 
            '<tr>
                <td style="width: 20%">' + TD.Name + '</td>
                <td style="width: 20%">' + CAST(TG.ChargeRate AS NVARCHAR) + '</td>
             </tr>'
        FROM TaxGroupDetails TG
        INNER JOIN TaxDetails TD 
            ON TD.TaxTypeId = TG.TaxTypeId
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)');

    SET @TaxDetailBody = 
    '<html><body>
      <table border="1">
        <thead>
          <tr>
            <th style="width: 20%">Tax</th>
            <th style="width: 20%">Rate %</th>
          </tr>
        </thead>
        <tbody>'
    + @Rows +
    '   </tbody>
      </table>
    </body></html>';


	SET @EmailBody = 
    '<html><body>' +
    '<p>Dear ' + @SupName + ',</p>' +

    '<p>We are currently in the process of sourcing the following items and would appreciate it if you could provide us with a quotation at your earliest convenience.</p>' +
    
    '<p>Please find the detailed requirements in the attached document.</p>' +

    '<p><strong>Details:</strong><br>' +
    '- Unit Price<br>' +
	'- Tax Amount<br>' +
	'- Discount Value<br>' +
	'- Discount Percentage<br>' +
    '</p> <br>' +
    '<p><strong>Unit Price Required:</strong> Please enter the unit price instead of the net price.</p>' +
    '<p><strong>Discount Validation:</strong> Please enter either a discount value or a discount percentage, not both.</p>' +
    '<p><strong>Tax Information:</strong> Please enter taxes using the Tax Detail section.</p>'+
    @TaxDetailBody+
    '<br>'+
    '<p><em>(Please do not change any details other than the ones specified)</em></p>' +

    '<p>Should you need any further information or clarification, feel free to reach out to me directly.</p>' +

    '<br><p>Best regards,<br>' +
    'Test User<br>' +
    'Purchase Department<br>' +
    'ABC Company<br>' +
    'test@example.com<br>' +
    '+91-XXXXXXXXXX</p>' +

    '</body></html>';

		

		SELECT @SupplierEmail SupplierEmail,@MailSubject MailSubject,@EmailBody EmailBody

    
	COMMIT TRANSACTION
 END TRY

BEGIN CATCH

	IF @@TRANCOUNT>0
	BEGIN
		ROLLBACK TRANSACTION
	END 
	
	DECLARE @ErrorMessage NVARCHAR(4000);  
	DECLARE @ErrorSeverity INT;  
	DECLARE @ErrorState INT;
	DECLARE @ErrorProcedure NVARCHAR(4000);  

	SELECT   
    @ErrorMessage = ERROR_MESSAGE(),  
    @ErrorSeverity = ERROR_SEVERITY(),  
    @ErrorState = ERROR_STATE(),
	@ErrorProcedure = ERROR_PROCEDURE(); 
	RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
    END CATCH;
END
END

GO

