--SP_InsertInvoicePaymentDetailsAndTempToOriginal_POS '<Temp_InvoiceHeader xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><ID>-1</ID><InvoiceNo>SC00001031</InvoiceNo><CustomerID>0</CustomerID><CustomerName /><InvoiceDate>2019-03-26T14:47:43.0826111+05:30</InvoiceDate><DepartmentID>1</DepartmentID><Location>1</Location><GrossTotal>6050.48</GrossTotal><NetTotal>6050.48</NetTotal><TotalDiscount>0.00</TotalDiscount><ToatlDiscountRate>0.00</ToatlDiscountRate><ItemDiscountTotal>0.00</ItemDiscountTotal><TaxTotal>0.0</TaxTotal><OtherCharges>0.0</OtherCharges><sysDate>2019-03-26T14:47:43.0826111+05:30</sysDate><UserID>1</UserID><PropertyID>1</PropertyID><VATNo>-1</VATNo><IPAddress /><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2019-03-26T14:47:43.0826111+05:30</CreatedDate><LastModDate>2019-03-26T14:47:43.0826111+05:30</LastModDate><IsPercentageForDiscount>false</IsPercentageForDiscount><ItemDiscountType>0</ItemDiscountType><IsSerialUpdated>false</IsSerialUpdated><InvoiceDetail><Temp_InvoiceDetail><ID>-999</ID><TxnType>I</TxnType><InvoiceHeaderID>-999</InvoiceHeaderID><ItemID>281</ItemID><QTY>1.0</QTY><UnitID>3</UnitID><UnitPrice>6050.48</UnitPrice><DelievryQTY>1.0</DelievryQTY><ReturnQty>0.0</ReturnQty><AveragePrice>0.00</AveragePrice><CostPrice>0.00</CostPrice><TaxGroupID>-999</TaxGroupID><TaxValue>0.0</TaxValue><SerialNo /><ItemDiscountValue>0.00</ItemDiscountValue><ItemDiscountPercentage>0.0</ItemDiscountPercentage><ItemDiscountType>0</ItemDiscountType><WarrentyPeriod>0.0</WarrentyPeriod><IsPercentageForDiscount>false</IsPercentageForDiscount><IPAddress /><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2019-03-26T14:47:43.0826111+05:30</CreatedDate><LastModDate>2019-03-26T14:47:43.0826111+05:30</LastModDate><PrintSequence>0.0</PrintSequence><TaxInclusivePrice>6050.48</TaxInclusivePrice></Temp_InvoiceDetail></InvoiceDetail><InvoicePaymentsDetails><InvoicePaymentsDetails><ID>0</ID><InvoiceHeaderID>0</InvoiceHeaderID><PaymentTypeID>4</PaymentTypeID><TenderedAmount>6050.48</TenderedAmount><ActualAmount>6050.48</ActualAmount><BalanceAmount>0.0</BalanceAmount><Remarks /><ReferanceNumebrs /><CreditNumber /><IPAddress /><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2019-03-26T14:47:43.0544715+05:30</CreatedDate><LastModDate>2019-03-26T14:47:43.0544715+05:30</LastModDate></InvoicePaymentsDetails></InvoicePaymentsDetails><InvoiceTaxBreakdown><Temp_InvoiceTaxBreakdown><Id>0</Id><InvoiceDetailID>0</InvoiceDetailID><InvoiceHeaderID>0</InvoiceHeaderID><ItemID>0</ItemID><TaxID>0</TaxID><TaxRate>0.0</TaxRate><TaxValue>0.0</TaxValue><IPAddress /><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2019-03-26T14:47:43.0826111+05:30</CreatedDate><LastModDate>2019-03-26T14:47:43.0826111+05:30</LastModDate></Temp_InvoiceTaxBreakdown></InvoiceTaxBreakdown><InvoiceOtherCharges><Temp_InvoiceOtherCharges><ID>0</ID><OtherChargID>0</OtherChargID><InvoiceHeaderID>0</InvoiceHeaderID><Amount>0.0</Amount><IPAddress /><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2019-03-26T14:47:43.0826111+05:30</CreatedDate><LastModDate>2019-03-26T14:47:43.0826111+05:30</LastModDate></Temp_InvoiceOtherCharges></InvoiceOtherCharges><AdditionalDetailItem><AdditionalDetailItem><FileNo>TC2347V</FileNo><NIC>123456789V</NIC><ChassisNo>CH468</ChassisNo><Colour>BLUE</Colour><Model>EJ20R</Model><BillNo>IN00001</BillNo><Date>28/03/2019</Date><TelNo>0112154896</TelNo><EngineNo>EJ20</EngineNo><TagNo>TG343</TagNo></AdditionalDetailItem></AdditionalDetailItem></Temp_InvoiceHeader>',0,233,0

CREATE Procedure [dbo].[SP_InsertInvoicePaymentDetailsAndTempToOriginal_POS] 
(@XMLDetails as XML , @Mode BIT,@HeaderId INT,@Recipientheaderid INT OUTPUT)
AS 
DECLARE @iDocID INT 

BEGIN TRY
BEGIN TRANSACTION
EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

DECLARE --@InvoiceHeaderID INT,
        @DocumentNo VARCHAR(6),
        @PropertyID INT,
		@LocationID INT,
		@DepartmentID INT,
		@CreatedUserID INT,
		@TempInvoiceHeaderId INT,
		@TempInvoiceDetailId INT  = -1,
		@StockTransactionHeaderID INT,
		@TempItemId INT,
		@TempQty DECIMAL(18, 2),
		@TempunitID INT,
		@TempAveragePrice money = 0   

SELECT  *
 INTO #TempPayments
	   FROM     OPENXML (@iDocID,'Temp_InvoiceHeader/InvoicePaymentsDetails/InvoicePaymentsDetails',2)	  
WITH  dbo.Temp_InvoicePaymentsDetails



DECLARE @PayID INT,@CreditNO VARCHAR(MAX)
WHILE(SELECT COUNT(*) FROM #TempPayments)>0
BEGIN 

SELECT TOP(1) @PayID=PaymentTypeID,@CreditNO=CreditNumber FROM #TempPayments ORDER BY PaymentTypeID

IF(@PayID=1)
BEGIN

UPDATE dbo.CreditApprovals SET DocumentStatus='C' WHERE CRNumber=@CreditNO
EXEC  [PostInvoiceToDebtors] @HeaderId

END 

DELETE FROM #TempPayments WHERE PaymentTypeID=@PayID
END 

SELECT  @PropertyID=PropertyID,@LocationID=Location,@DepartmentID=DepartmentID,@CreatedUserID=CreatedUserID FROM Temp_InvoiceHeader	WHERE ID = @HeaderId
SELECT @DocumentNo = dbo.FN_GetNextDocumentNumber (@PropertyID,@LocationID,'II')
UPDATE  dbo.TransactionTypeWiseNextNumbers SET NextNumber = NextNumber+1 
WHERE PropertyID = @PropertyID AND LocationID = @LocationID


IF(@Mode=0)
BEGIN



IF NOT EXISTS (SELECT  * FROM dbo.StockTransactionHeaders WHERE CONVERT(VARCHAR,TransactionDate, 101) = CONVERT(VARCHAR,GETDATE(), 101) AND TransactionType = 'II' AND PropertyID = @PropertyID)
	BEGIN
		INSERT INTO dbo.StockTransactionHeaders
		(
			DocumentNo,
			TransactionType,
			TransactionDate,
			PropertyID,
			LocationID,
			ReferenceNo,
			SupplierID,
			Remarks,
			ReferenceID,
			DepartmentID,
			UserProfileID,
			TransferLocationID,
			TimeStamp,
			TransactionID,
			Mode,
			SuppCurrencyID,
			ExchangeRate,
			IPAddress,
			CreatedUserID,
			LastModUserID,
			CreatedDate,
			LastModDate,
			IsPrint,
			IsApproved
		)
		VALUES
		(   @DocumentNo,       -- DocumentNo - nvarchar(20)
			'II',       -- TransactionType - nvarchar(2)
			GETDATE(), -- TransactionDate - datetime
			@PropertyID,         -- PropertyID - int
			@LocationID,         -- LocationID - int
			N'',       -- ReferenceNo - nvarchar(20)
			0,         -- SupplierID - int
			N'',       -- Remarks - nvarchar(20)
			0,         -- ReferenceID - int
			@DepartmentID,         -- DepartmentID - int
			@CreatedUserID,         -- UserProfileID - int
			0,         -- TransferLocationID - int
			N'',       -- TimeStamp - nvarchar(256)
			0,         -- TransactionID - int
			N'',       -- Mode - nvarchar(1)
			0,         -- SuppCurrencyID - int
			0,      -- ExchangeRate - decimal(18, 2)
			N'',       -- IPAddress - nvarchar(max)
			@CreatedUserID,         -- CreatedUserID - int
			@CreatedUserID,         -- LastModUserID - int
			GETDATE(), -- CreatedDate - datetime
			GETDATE(), -- LastModDate - datetime
			0,      -- IsPrint - bit
			0       -- IsApproved - bit
			)
		SELECT  @StockTransactionHeaderID= SCOPE_IDENTITY()
	
	
	END 
ELSE
	BEGIN
		SELECT  @StockTransactionHeaderID =  ID  FROM dbo.StockTransactionHeaders WHERE CONVERT(VARCHAR,TransactionDate, 101) = CONVERT(VARCHAR,GETDATE(), 101) AND TransactionType = 'II' AND PropertyID = @PropertyID
	END

SELECT * INTO #TEMPInvoiceDetail FROM dbo.Temp_InvoiceDetail WHERE InvoiceHeaderID = @HeaderId 

WHILE (SELECT COUNT(*) FROM #TEMPInvoiceDetail)	> 0
BEGIN
	SELECT TOP 1 @TempInvoiceDetailId = ID,@TempItemId=ItemID,@TempQty=QTY,@TempunitID=UnitID,@TempAveragePrice=AveragePrice FROM #TEMPInvoiceDetail ORDER  BY ID 
	
	IF NOT EXISTS (SELECT  * FROM dbo.StockTransactionDetails WHERE CONVERT(VARCHAR,CreatedDate, 101) = CONVERT(VARCHAR,GETDATE(), 101) AND StockItemID = @TempItemId)
		BEGIN   
				INSERT INTO dbo.StockTransactionDetails
				(      
				        StockTransactionHeaderID,
						StockItemID,
						Quantity,
						UnitPrice,
						TxnUnitID,
						MasterUnitID,
						MasterUnitConversion,
						ReportUnitID,
						ReportUnitConversion,
						DiscountValue,
						DiscountPercentage,
						TimeStamp,
						StockMasterQuantity,
						StockMasterAveragePrice,
						NewQuantity,
						NewAveragePrice,
						Remarks,
						UserProfileId,
						CostTransactionAccountID,
						PurchaseTransactionAccountID,
						TxnType,
						BalanceQuantity,
						ReturnQuantity,
						ItemUnitPriceInSuppCurrency,
						IPAddress,
						CreatedUserID,
						LastModUserID,
						CreatedDate,
						LastModDate	
						
				) 
				    SELECT   
					   @StockTransactionHeaderID,
					   ItemID,
					   qty,
					   UnitPrice,
					   UnitID,
					   ISNULL(dbo.FN_GetMasterUnitID(@PropertyID,@LocationID, @TempItemId),0) MasterUnitID,
					   ISNULL(dbo.FN_GetUnitConvertionRate(@PropertyID,UnitID,dbo.FN_GetMasterUnitID(@PropertyID,@LocationID, @TempItemId)),0)	MasterUnitConversion,
					   ISNULL(dbo.FN_GetReportingUnitID(@PropertyID,@LocationID, @TempItemId),0) ReportUnitID,
					   dbo.FN_GetUnitConvertionRate( @PropertyID,UnitID,dbo.FN_GetReportingUnitID(@PropertyID,@LocationID, @TempItemId)) ReportUnitConversion,
					   ItemDiscountValue,
					   ItemDiscountPercentage,
					   '' TimeStamp,
					   dbo.FN_GetStockInHand(@PropertyID,@LocationID,@TempItemId) StockMasterQuantity,
					   0,
					   0,
					   0,
					   '' Remarks,
					   CreatedUserID,
					   dbo.FN_GetPurchaseCostOfSalesAccountID(@TempItemId, @LocationID) CostTransactionAccountID,
					   dbo.FN_GetPurchaseTransactionAccountID (@TempItemId, @LocationID) PurchaseTransactionAccountID,
					   'I',
					   0,
					   0,
					   0,
					   IPAddress,
					   CreatedUserID,
					   CreatedUserID,
					   GETDATE(),
					   GETDATE()  
				  FROM dbo.Temp_InvoiceDetail  WHERE ID = @TempInvoiceDetailId

		END 
	ELSE
	    BEGIN
		     UPDATE StockTransactionDetails SET Quantity = Quantity + @TempQty WHERE StockItemID = @TempItemId AND  CONVERT(VARCHAR,CreatedDate, 101) = CONVERT(VARCHAR,GETDATE(), 101)
		END 
    
	EXEC [SP_UpdateStockItemBalance] @PropertyID,@LocationID,@TempItemId,'II',@TempQty,@TempunitID,@TempAveragePrice
	DELETE FROM #TEMPInvoiceDetail WHERE ID = @TempInvoiceDetailId
END 


END 

INSERT INTO dbo.InvoiceHeaders
        ( InvoiceNo ,
          CustomerID ,
          InvoiceDate ,
          DepartmentID ,
          Location ,
          GrossTotal,
		  NetTotal,
          TotalDiscount ,
          ToatlDiscountRate ,
          ItemDiscountTotal ,
          TaxTotal ,
          OtherCharges ,
          sysDate ,
          UserID ,
          IPAddress ,
          CreatedUserID ,
          LastModUserID ,
          CreatedDate ,
          LastModDate ,
          CustomerName ,
          PropertyID ,
          VATNo,
		  SalesPersonID	,
		  IsPercentageForDiscount
        )
SELECT  InvoiceNo ,
          CustomerID ,
          InvoiceDate ,
          DepartmentID ,
          Location ,
          GrossTotal,
		  NetTotal,
          TotalDiscount ,
          ToatlDiscountRate ,
          ItemDiscountTotal ,
          TaxTotal ,
          OtherCharges ,
          sysDate ,
          UserID ,
          IPAddress ,
          CreatedUserID ,
          LastModUserID ,
          CreatedDate ,
          LastModDate ,
          CustomerName ,
          PropertyID ,
          VATNo,
		  SalesPersonID,
		  IsPercentageForDiscount
		  FROM dbo.Temp_InvoiceHeader WHERE ID=@HeaderId

DECLARE @InvoiceHeaderId INT = SCOPE_IDENTITY()



INSERT INTO dbo.InvoiceDetails
        ( 
		InvoiceHeaderID,
        ItemID,
        QTY,
        UnitID,
        UnitPrice,
        DelievryQTY,
        ReturnQty,
        AveragePrice,
        CostPrice,
        TaxGroupID,
        TaxValue,
        SerialNo,
        ItemDiscountValue,
        ItemDiscountPercentage,
        ItemDiscountType, 
        WarrentyPeriod,  
        IsPercentageForDiscount,
        IPAddress,
        CreatedUserID,  
        LastModUserID,  
        CreatedDate,
        LastModDate,
        PrintSequence,
		TxnType
        )
SELECT    @InvoiceHeaderId	,
          ItemID,
		QTY,
		UnitID,
		UnitPrice,
		DelievryQTY,
		ReturnQty,
		AveragePrice,
		CostPrice,
		TaxGroupID,
		TaxValue,
		SerialNo,
		ItemDiscountValue,
		ItemDiscountPercentage,
		ItemDiscountType, 
		WarrentyPeriod,  
		IsPercentageForDiscount,
		IPAddress,
		CreatedUserID,  
		LastModUserID,  
		CreatedDate,
		LastModDate,
		PrintSequence,
		TxnType 
		  FROM dbo.Temp_InvoiceDetail WHERE InvoiceHeaderID=@HeaderId

INSERT  INTO  dbo.InvoicePaymentsDetails 
      (

			InvoiceHeaderID,
			PaymentTypeID,
			TenderedAmount,
			ActualAmount,
			BalanceAmount,
			Remarks,
			ReferanceNumebrs,
			CreditNumber,
			IPAddress,  
			CreatedUserID, 
			LastModUserID, 
			CreatedDate, 
			LastModDate
	   )

select @InvoiceHeaderId,
		PaymentTypeID,
		TenderedAmount,
		ActualAmount,
		BalanceAmount,
		Remarks,
		ReferanceNumebrs,
		CreditNumber,
		IPAddress,  
		CreatedUserID, 
		LastModUserID, 
		CreatedDate, 
		LastModDate
	   FROM     OPENXML (@iDocID,'Temp_InvoiceHeader/InvoicePaymentsDetails/InvoicePaymentsDetails',2)
with Temp_InvoicePaymentsDetails

INSERT  INTO dbo.InvoiceTaxBreakdowns
        ( InvoiceDetailID ,
            InvoiceHeaderID ,
            ItemID ,
            TaxID ,
            TaxRate ,
            TaxValue ,
            IPAddress ,
            CreatedUserID ,
            LastModUserID ,
            CreatedDate ,
            LastModDate
		)
SELECT  ID.ID ,
		IH.ID,
        ID.ItemID ,
        TGD.TaxTypeId ,
        TGD.ChargeRate ,
        ID.TaxValue * ID.QTY ,
        '' ,
        @CreatedUserID ,
        @CreatedUserID ,
        GETDATE() ,
        GETDATE()
FROM    dbo.InvoiceHeaders IH
        INNER JOIN dbo.InvoiceDetails ID ON ID.InvoiceHeaderID = IH.ID
        INNER JOIN dbo.StockItemHeaders SH ON SH.Id = ID.ItemID
        INNER JOIN dbo.TaxGroupDetails TGD ON TGD.TaxGroupId = SH.TaxGroupID
WHERE   IH.ID = @InvoiceHeaderId

 
	SET @Recipientheaderid = @InvoiceHeaderId

DELETE FROM dbo.Temp_InvoiceHeader WHERE ID=@HeaderId
DELETE FROM dbo.Temp_InvoiceDetail WHERE InvoiceHeaderID=@HeaderId

EXEC  sp_xml_removedocument @iDocID

COMMIT TRAN 
END TRY
BEGIN CATCH
	return CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN 
END CATCH

GO

