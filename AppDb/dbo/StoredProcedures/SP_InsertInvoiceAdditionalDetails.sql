-- SP_InsertInvoiceAdditionalDetails '<Temp_InvoiceHeader xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><ID>-1</ID><InvoiceNo>SC00001018</InvoiceNo><CustomerID>0</CustomerID><CustomerName /><InvoiceDate>2019-03-15T10:28:25.8497854+05:30</InvoiceDate><DepartmentID>1</DepartmentID><Location>1</Location><GrossTotal>6050.48</GrossTotal><NetTotal>6050.48</NetTotal><TotalDiscount>0.00</TotalDiscount><ToatlDiscountRate>0.00</ToatlDiscountRate><ItemDiscountTotal>0.00</ItemDiscountTotal><TaxTotal>0.0</TaxTotal><OtherCharges>0.0</OtherCharges><sysDate>2019-03-15T10:28:25.8507856+05:30</sysDate><UserID>1</UserID><PropertyID>1</PropertyID><VATNo>-1</VATNo><IPAddress /><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2019-03-15T10:28:25.8507856+05:30</CreatedDate><LastModDate>2019-03-15T10:28:25.8507856+05:30</LastModDate><IsPercentageForDiscount>false</IsPercentageForDiscount><ItemDiscountType>0</ItemDiscountType><IsSerialUpdated>false</IsSerialUpdated><InvoiceDetail><Temp_InvoiceDetail><ID>-999</ID><TxnType>I</TxnType><InvoiceHeaderID>-999</InvoiceHeaderID><ItemID>281</ItemID><QTY>1.0</QTY><UnitID>3</UnitID><UnitPrice>6050.48</UnitPrice><DelievryQTY>1.0</DelievryQTY><ReturnQty>0.0</ReturnQty><AveragePrice>0.00</AveragePrice><CostPrice>0.00</CostPrice><TaxGroupID>-999</TaxGroupID><TaxValue>0.0</TaxValue><SerialNo /><ItemDiscountValue>0.00</ItemDiscountValue><ItemDiscountPercentage>0.0</ItemDiscountPercentage><ItemDiscountType>0</ItemDiscountType><WarrentyPeriod>0.0</WarrentyPeriod><IsPercentageForDiscount>false</IsPercentageForDiscount><IPAddress /><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2019-03-15T10:28:25.8527869+05:30</CreatedDate><LastModDate>2019-03-15T10:28:25.8527869+05:30</LastModDate><PrintSequence>0.0</PrintSequence><TaxInclusivePrice>6050.48</TaxInclusivePrice></Temp_InvoiceDetail></InvoiceDetail><InvoicePaymentsDetails><InvoicePaymentsDetails><ID>0</ID><InvoiceHeaderID>0</InvoiceHeaderID><PaymentTypeID>4</PaymentTypeID><TenderedAmount>6050.48</TenderedAmount><ActualAmount>6050.48</ActualAmount><BalanceAmount>0.0</BalanceAmount><Remarks /><ReferanceNumebrs /><CreditNumber /><IPAddress /><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2019-03-15T10:28:25.8175798+05:30</CreatedDate><LastModDate>2019-03-15T10:28:25.8175798+05:30</LastModDate></InvoicePaymentsDetails></InvoicePaymentsDetails><InvoiceTaxBreakdown><Temp_InvoiceTaxBreakdown><Id>0</Id><InvoiceDetailID>0</InvoiceDetailID><InvoiceHeaderID>0</InvoiceHeaderID><ItemID>0</ItemID><TaxID>0</TaxID><TaxRate>0.0</TaxRate><TaxValue>0.0</TaxValue><IPAddress /><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2019-03-15T10:28:25.8497854+05:30</CreatedDate><LastModDate>2019-03-15T10:28:25.8497854+05:30</LastModDate></Temp_InvoiceTaxBreakdown></InvoiceTaxBreakdown><InvoiceOtherCharges><Temp_InvoiceOtherCharges><ID>0</ID><OtherChargID>0</OtherChargID><InvoiceHeaderID>0</InvoiceHeaderID><Amount>0.0</Amount><IPAddress /><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2019-03-15T10:28:25.8497854+05:30</CreatedDate><LastModDate>2019-03-15T10:28:25.8497854+05:30</LastModDate></Temp_InvoiceOtherCharges></InvoiceOtherCharges><AdditionalDetailItem><AdditionalDetailItem><FileNo>ER343</FileNo><NIC>123456789V</NIC><ChassisNo>CH4567</ChassisNo><Colour>RED</Colour><Model>CJJ34</Model><BillNo>RC2556</BillNo><Date>14/03/2019</Date><TelNo>0112369874</TelNo><EngineNo>CJ799</EngineNo><TagNo>TG06</TagNo></AdditionalDetailItem></AdditionalDetailItem></Temp_InvoiceHeader>',194
CREATE PROCEDURE [dbo].[SP_InsertInvoiceAdditionalDetails]
    (
      @XMLDetails AS XML,
	  @Recipientheaderid AS INT 
    )
AS
    DECLARE @iDocID INT 


    BEGIN TRY
        BEGIN TRANSACTION

  SET DATEFORMAT DMY

        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;
        SELECT  
		        [FileNo],
		        [NIC],
				[ChassisNo],
				[Colour],
				[Model],
				[BillNo],
				[Date],
				[TelNo],
				[EngineNo],
				[TagNo]
        INTO    #AdditionalDetails
        FROM    OPENXML(@iDocID, 'Temp_InvoiceHeader/AdditionalDetailItem/AdditionalDetailItem', 2)
    WITH
    (   
        [FileNo]VARCHAR(MAX), 
		[NIC]VARCHAR(MAX), 
		[ChassisNo]VARCHAR(MAX), 
		[Colour]VARCHAR(MAX), 
		[Model]VARCHAR(MAX), 
		[BillNo]VARCHAR(MAX), 
		[Date]VARCHAR(MAX), 
		[TelNo]VARCHAR(MAX), 
		[EngineNo]VARCHAR(MAX), 
		[TagNo]VARCHAR(MAX)
    );

		INSERT INTO ItemAdditionalDetail
        SELECT @Recipientheaderid Recipientheaderid,FileNo,NIC,ChassisNo,Colour,Model,BillNo,CONVERT(VARCHAR(10), Date, 103),TelNo,EngineNo,TagNo
		FROM #AdditionalDetails

        EXEC sp_xml_removedocument @iDocID
        IF @@TRANCOUNT > 0
            COMMIT TRAN
 
    END TRY
    BEGIN CATCH
        RETURN CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN 
    END CATCH

GO

