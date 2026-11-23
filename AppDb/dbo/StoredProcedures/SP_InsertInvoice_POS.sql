--EXEC  [SP_InsertInvoice_POS] '<Temp_InvoiceHeader xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><ID>-1</ID><InvoiceNo>SC00000882</InvoiceNo><CustomerID>0</CustomerID><CustomerName /><InvoiceDate>2019-05-23T19:13:38.2657423+05:30</InvoiceDate><DepartmentID>1</DepartmentID><Location>1</Location><GrossTotal>13.47</GrossTotal><NetTotal>13.47</NetTotal><TotalDiscount>0.00</TotalDiscount><ToatlDiscountRate>0.00</ToatlDiscountRate><ItemDiscountTotal>0.00</ItemDiscountTotal><TaxTotal>0.0</TaxTotal><OtherCharges>0.0</OtherCharges><sysDate>2019-05-23T19:13:38.2677443+05:30</sysDate><UserID>1</UserID><PropertyID>1</PropertyID><VATNo>-1</VATNo><IPAddress /><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2019-05-23T19:13:38.2677443+05:30</CreatedDate><LastModDate>2019-05-23T19:13:38.2687441+05:30</LastModDate><IsPercentageForDiscount>false</IsPercentageForDiscount><ItemDiscountType>0</ItemDiscountType><IsSerialUpdated>false</IsSerialUpdated><InvoiceDetail><Temp_InvoiceDetail><ID>-999</ID><TxnType>I</TxnType><InvoiceHeaderID>-999</InvoiceHeaderID><ItemID>70386</ItemID><QTY>1.0</QTY><UnitID>1</UnitID><UnitPrice>13.47</UnitPrice><DelievryQTY>1.0</DelievryQTY><ReturnQty>0.0</ReturnQty><AveragePrice>0.00</AveragePrice><CostPrice>0.00</CostPrice><TaxGroupID>-999</TaxGroupID><TaxValue>0.0</TaxValue><SerialNo /><ItemDiscountValue>0.00</ItemDiscountValue><ItemDiscountPercentage>0.0</ItemDiscountPercentage><ItemDiscountType>0</ItemDiscountType><WarrentyPeriod>0.0</WarrentyPeriod><IsPercentageForDiscount>false</IsPercentageForDiscount><IPAddress /><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2019-05-23T19:13:38.2707454+05:30</CreatedDate><LastModDate>2019-05-23T19:13:38.2707454+05:30</LastModDate><PrintSequence>0.0</PrintSequence><TaxInclusivePrice>13.47</TaxInclusivePrice></Temp_InvoiceDetail></InvoiceDetail><InvoicePaymentsDetails><InvoicePaymentsDetails><ID>0</ID><InvoiceHeaderID>0</InvoiceHeaderID><PaymentTypeID>4</PaymentTypeID><TenderedAmount>100.0</TenderedAmount><ActualAmount>13.00</ActualAmount><BalanceAmount>-86.53</BalanceAmount><Remarks /><ReferanceNumebrs /><CreditNumber /><IPAddress /><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2019-05-23T19:13:38.2167308+05:30</CreatedDate><LastModDate>2019-05-23T19:13:38.2167308+05:30</LastModDate></InvoicePaymentsDetails></InvoicePaymentsDetails><InvoiceTaxBreakdown><Temp_InvoiceTaxBreakdown><Id>0</Id><InvoiceDetailID>0</InvoiceDetailID><InvoiceHeaderID>0</InvoiceHeaderID><ItemID>0</ItemID><TaxID>0</TaxID><TaxRate>0.0</TaxRate><TaxValue>0.0</TaxValue><IPAddress /><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2019-05-23T19:13:38.2657423+05:30</CreatedDate><LastModDate>2019-05-23T19:13:38.2657423+05:30</LastModDate></Temp_InvoiceTaxBreakdown></InvoiceTaxBreakdown><InvoiceOtherCharges><Temp_InvoiceOtherCharges><ID>0</ID><OtherChargID>0</OtherChargID><InvoiceHeaderID>0</InvoiceHeaderID><Amount>0.0</Amount><IPAddress /><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2019-05-23T19:13:38.2657423+05:30</CreatedDate><LastModDate>2019-05-23T19:13:38.2657423+05:30</LastModDate></Temp_InvoiceOtherCharges></InvoiceOtherCharges><AdditionalDetailItem><AdditionalDetailItem /></AdditionalDetailItem></Temp_InvoiceHeader>'
CREATE PROCEDURE [dbo].[SP_InsertInvoice_POS]
(
  @XMLDetails AS XML 
)
AS
BEGIN
    BEGIN TRY
         BEGIN TRANSACTION

		 DECLARE @docID VARCHAR(MAX),
                 @Recipientheaderid INT,
				 @MainRecipientheaderid INT

		 EXEC [SP_InsertInvoice] @XMLDetails,1,0,1,@docID OUTPUT,	@Recipientheaderid OUTPUT
		 SELECT @Recipientheaderid
		 EXEC [SP_InsertInvoicePaymentDetailsAndTempToOriginal_POS] @XMLDetails,0,@Recipientheaderid,@MainRecipientheaderid OUTPUT
		 SELECT @MainRecipientheaderid
		 EXEC [SP_InsertInvoiceAdditionalDetails] @XMLDetails,@MainRecipientheaderid

		 COMMIT TRANSACTION
		  
    END TRY
   BEGIN CATCH
	RETURN CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
	IF @@TRANCOUNT > 0
	ROLLBACK TRANSACTION 
   END CATCH
END

GO

