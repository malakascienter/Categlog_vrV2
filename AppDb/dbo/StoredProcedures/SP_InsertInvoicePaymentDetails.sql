--SP_InsertInvoicePaymentDetails '<ArrayOfInvoicePaymentsDetails xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><InvoicePaymentsDetails><CreatedUserID>0</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2018-07-17T12:43:09.802Z</CreatedDate><LastModDate>2018-07-17T12:43:09.802Z</LastModDate><ID>0</ID><InvoiceHeaderID>1055</InvoiceHeaderID><PaymentTypeID>2</PaymentTypeID><TenderedAmount>200000</TenderedAmount><ActualAmount>121212</ActualAmount><BalanceAmount>100000</BalanceAmount><Remarks /><CheckNumber>1212</CheckNumber><BankId>1</BankId><BranchId>1</BranchId><RealizedDate>2018-07-17T00:00:00</RealizedDate></InvoicePaymentsDetails></ArrayOfInvoicePaymentsDetails>','',1
--SP_InsertInvoicePaymentDetails '<ArrayOfInvoicePaymentsDetails xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><InvoicePaymentsDetails><CreatedUserID>0</CreatedUserID><LastModUserID>2</LastModUserID><CreatedDate>2018-08-15T04:35:56.621Z</CreatedDate><LastModDate>2018-08-15T04:35:56.621Z</LastModDate><ID>0</ID><InvoiceHeaderID>6218</InvoiceHeaderID><CnId xsi:nil="true" /><PaymentTypeID>4</PaymentTypeID><TenderedAmount>850</TenderedAmount><ActualAmount>850</ActualAmount><BalanceAmount>100000</BalanceAmount><Remarks /><CheckNumber>0</CheckNumber><BankId>0</BankId><BranchId>0</BranchId><RealizedDate>2018-08-15T00:00:00</RealizedDate></InvoicePaymentsDetails></ArrayOfInvoicePaymentsDetails>','',0,0
CREATE PROCEDURE [dbo].[SP_InsertInvoicePaymentDetails]
    (
      @XMLDetails AS XML ,
      @docID VARCHAR(MAX) OUTPUT ,
      @Recipientheaderid INT OUTPUT ,
      @Mode BIT
    )
AS
    DECLARE @iDocID INT 



    BEGIN TRY
        BEGIN TRANSACTION
        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

        DECLARE @InvoiceHeaderID INT ,
            @DocumentNo VARCHAR(6) ,
            @PropertyID INT ,
            @LocationID INT ,
            @DepartmentID INT ,
            @CreatedUserID INT ,
            @TempInvoiceHeaderId INT ,
            @TempInvoiceDetailId INT  = -1 ,
            @StockTransactionHeaderID INT ,
            @TempItemId INT ,
            @TempQty DECIMAL(18, 2) ,
            @TempunitID INT ,
            @TempAveragePrice MONEY = 0   


        SELECT  @InvoiceHeaderID = InvoiceHeaderID
        FROM    OPENXML (@iDocID,'ArrayOfInvoicePaymentsDetails/InvoicePaymentsDetails',2)
WITH  (InvoiceHeaderID INT)

--SELECT  *
-- INTO #TempPayments
--	   FROM     OPENXML (@iDocID,'ArrayOfInvoicePaymentsDetails/InvoicePaymentsDetails',2)	  
--WITH  dbo.Temp_InvoicePaymentsDetails

        SELECT  *
        INTO    #TempPayments
        FROM    OPENXML (@iDocID,'ArrayOfInvoicePaymentsDetails/InvoicePaymentsDetails',2)	  
WITH (
       [InvoiceHeaderID] INT,
       [PaymentTypeID] INT,
	   [CreditRequestID] INT,
       [TenderedAmount] DECIMAL(18,2),
       [ActualAmount] DECIMAL(18,2),
       [BalanceAmount] DECIMAL(18,2),
       [Remarks] VARCHAR(MAX),
       [ReferanceNumebrs] VARCHAR(MAX),
	   [BankId] INT,
	   [BranchId] INT,
	   [RealizedDate] DATETIME,
	   [CreditNumber] VARCHAR(MAX),
       [IPAddress] VARCHAR(MAX),
       [CreatedUserID] INT,
       [LastModUserID] INT,
       [CreatedDate] DATETIME,
       [LastModDate] DATETIME,
	   [CheckNumber] VARCHAR(MAX)
	   

);



--for updating credit approvals-- 

        DECLARE @PayID INT ,
            @CreditID INT ,
            @IsCredit BIT
        WHILE ( SELECT  COUNT(*)
                FROM    #TempPayments
              ) > 0
            BEGIN 

                SELECT TOP ( 1 )
                        @PayID = PaymentTypeID ,
                        @CreditID = CreditRequestID
                FROM    #TempPayments
                ORDER BY PaymentTypeID
                SELECT  @IsCredit = Credit
                FROM    dbo.PaymentTypes
                WHERE   ID = @PayID

                IF ( @IsCredit = 1 )
                    BEGIN

                        UPDATE  dbo.CreditApprovals
                        SET     DocumentStatus = 'C'
                        WHERE   Id = @CreditID

                    END 

                DELETE  FROM #TempPayments
                WHERE   PaymentTypeID = @PayID
            END 


--deleting from Tempinvoiceheaderdetails


        INSERT  INTO dbo.InvoiceHeaders
                ( InvoiceNo ,
                  CustomerID ,
                  InvoiceDate ,
                  DepartmentID ,
                  Location ,
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
                  VATNo ,
                  SalesPersonID ,
                  TotalPrintDiscount ,
                  SubTotal ,
                  IsSerialUpdated ,
                  IsPercentageForDiscount ,
                  GrossTotal ,
                  NetTotal ,
                  ItemDiscountType,
				  Isprint,
				  ReferenceNo
                )
                SELECT  InvoiceNo ,
                        CustomerID ,
                        InvoiceDate ,
                        DepartmentID ,
                        Location ,
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
                        VATNo ,
                        SalesPersonID ,
                        TotalPrintDiscount ,
                        SubTotal ,
                        IsSerialUpdated ,
                        IsPercentageForDiscount ,
                        GrossTotal ,
                        NetTotal ,
                        ItemDiscountType,
						0,
						ReferenceNo
                FROM    dbo.Temp_InvoiceHeader
                WHERE   ID = @InvoiceHeaderID

        SELECT  @Recipientheaderid = SCOPE_IDENTITY()

        INSERT  INTO dbo.InvoiceDetails
                ( InvoiceHeaderID ,
                  ItemID ,
                  QTY ,
                  UnitID ,
                  UnitPrice ,
                  DelievryQTY ,
                  ReturnQty ,
                  AveragePrice ,
                  CostPrice ,
                  TaxGroupID ,
                  TaxValue ,
                  SerialNo ,
                  ItemDiscountValue ,
                  ItemDiscountType ,
                  IPAddress ,
                  CreatedUserID ,
                  LastModUserID ,
                  CreatedDate ,
                  LastModDate ,
                  ItemDiscountPercentage ,
                  WarrentyPeriod ,
                  IsPercentageForDiscount ,
                  TaxCostPrice ,
                  TaxForSellPrice ,
                  PrintSequence
                )
                SELECT  @Recipientheaderid ,
                        ItemID ,
                        QTY ,
                        UnitID ,
                        UnitPrice ,
                        DelievryQTY ,
                        ReturnQty ,
                        AveragePrice ,
                        CostPrice ,
                        TaxGroupID ,
                        TaxValue ,
                        SerialNo ,
                        ItemDiscountValue ,
                        ItemDiscountType ,
                        IPAddress ,
                        CreatedUserID ,
                        LastModUserID ,
                        CreatedDate ,
                        LastModDate ,
                        ItemDiscountPercentage ,
                        WarrentyPeriod ,
                        IsPercentageForDiscount ,
                        TaxCostPrice ,
                        TaxForSellPrice ,
                        PrintSequence
                FROM    dbo.Temp_InvoiceDetail
                WHERE   InvoiceHeaderID = @InvoiceHeaderID


   

        SELECT  @Recipientheaderid

        SELECT  @PropertyID = PropertyID ,
                @LocationID = Location ,
                @DepartmentID = DepartmentID ,
                @CreatedUserID = CreatedUserID
        FROM    Temp_InvoiceHeader
        WHERE   ID = @InvoiceHeaderID

        SELECT  @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID,
                                                           @LocationID, 'II')
        UPDATE  dbo.TransactionTypeWiseNextNumbers
        SET     NextNumber = NextNumber + 1
        WHERE   PropertyID = @PropertyID
                AND LocationID = @LocationID

--INSERT  INTO  dbo.InvoicePaymentsDetails 
--      (InvoiceHeaderID,
--       PaymentTypeID,
--       TenderedAmount,
--       ActualAmount,
--       BalanceAmount,
--       Remarks,
--       ReferanceNumebrs,
--       IPAddress,
--       CreatedUserID,
--       LastModUserID,
--       CreatedDate,
--       LastModDate,
--	   CheckNumber,
--	   BankId,
--	   BranchId,
--	   RealizedDate,
--	   CreditNumber)

--select @Recipientheaderid,
--       PaymentTypeID,
--       TenderedAmount,
--       ActualAmount,
--       BalanceAmount,
--       Remarks,
--       ReferanceNumebrs,
--       IPAddress,
--       CreatedUserID,
--       LastModUserID,
--       CreatedDate,
--       LastModDate,
--	   CheckNumber,
--	   BankId,
--	   BranchId,
--	   RealizedDate,
--	   CreditNumber
--	   FROM     OPENXML (@iDocID,'ArrayOfInvoicePaymentsDetails/InvoicePaymentsDetails',2)
--with Temp_InvoicePaymentsDetails
        SELECT  *
        INTO    #TempPaymentsALL
        FROM    OPENXML (@iDocID,'ArrayOfInvoicePaymentsDetails/InvoicePaymentsDetails',2)	  
WITH (
       [InvoiceHeaderID] INT,
       [PaymentTypeID] INT,
	   [CreditRequestID] INT,
       [TenderedAmount] DECIMAL(18,2),
       [ActualAmount] DECIMAL(18,2),
       [BalanceAmount] DECIMAL(18,2),
       [Remarks] VARCHAR(MAX),
       [ReferanceNumebrs] VARCHAR(MAX),
	   [BankId] INT,
	   [BranchId] INT,
	   [RealizedDate] DATETIME,
	   [CreditNumber] VARCHAR(MAX),
       [IPAddress] VARCHAR(MAX),
       [CreatedUserID] INT,
       [LastModUserID] INT,
       [CreatedDate] DATETIME,
       [LastModDate] DATETIME,
	   [CheckNumber] VARCHAR(MAX)
	   

);

        INSERT  INTO dbo.InvoicePaymentsDetails
                ( InvoiceHeaderID ,
                  PaymentTypeID ,
                  TenderedAmount ,
                  ActualAmount ,
                  BalanceAmount ,
                  Remarks ,
                  ReferanceNumebrs ,
                  IPAddress ,
                  CreatedUserID ,
                  LastModUserID ,
                  CreatedDate ,
                  LastModDate ,
                  CreditNumber ,
                  CreditRequestID
                )
                SELECT  @Recipientheaderid ,
                        PaymentTypeID ,
                        TenderedAmount ,
                        ActualAmount ,
                        BalanceAmount ,
                        Remarks ,
                        ReferanceNumebrs ,
                        IPAddress ,
                        CreatedUserID ,
                        LastModUserID ,
                        CreatedDate ,
                        LastModDate ,
                        CreditNumber ,
                        CreditRequestID
                FROM    #TempPaymentsALL



        INSERT  INTO InvoiceWiseChequeDetails
                ( InvoiceHeaderID ,
                  PaymentTypeID ,
                  ChequeNumber ,
                  BankId ,
                  BranchId ,
                  RealizedDate 
                )
                SELECT  @Recipientheaderid ,
                        TPA.PaymentTypeID ,
                        TPA.CheckNumber ,
                        TPA.BankId ,
                        TPA.BranchId ,
                        TPA.RealizedDate
                FROM    #TempPaymentsALL TPA
                        INNER JOIN dbo.PaymentTypes PT ON PT.ID = TPA.PaymentTypeID
                WHERE   PT.Cheque = 1 


        DROP TABLE #TempPaymentsALL

        IF ( @Mode = 0 )
            BEGIN



                IF NOT EXISTS ( SELECT  *
                                FROM    dbo.StockTransactionHeaders
                                WHERE   CONVERT(VARCHAR, TransactionDate, 101) = CONVERT(VARCHAR, GETDATE(), 101)
                                        AND TransactionType = 'II'
                                        AND PropertyID = @PropertyID )
                    BEGIN

                        IF ( @Mode = 1 )
                            DECLARE @DocNoTransaction VARCHAR(MAX)

                        SELECT  @DocNoTransaction = dbo.FN_GetNextDocumentNumber(@PropertyID,
                                                              @LocationID,
                                                              'IT')
                       
                        IF @DocNoTransaction IS NULL
                            BEGIN
                                INSERT  INTO TransactionTypeWiseNextNumbers
                                        ( PropertyID ,
                                          LocationID ,
                                          TransactionType ,
                                          NextNumber ,
                                          LengthOfFormatting
                                        )
                                VALUES  ( @PropertyID ,
                                          @LocationID ,
                                          'IT' ,
                                          1 ,
                                          6
                                        )
                            END



                        SELECT  @DocNoTransaction = dbo.FN_GetNextDocumentNumber(@PropertyID,
                                                              @LocationID,
                                                              'IT')


 
                        DECLARE @Prefix VARCHAR(MAX) ,
                            @Len INT ,
                            @Code VARCHAR(MAX) 


                        SELECT  @Prefix = Prefix
                        FROM    dbo.Locations
                        WHERE   Id = @LocationID                      


                        SELECT  LEN(@Prefix)

                        SELECT  @Prefix = SUBSTRING(@Prefix, 1, 3)

                        SET @DocNoTransaction = @Prefix + '/'
                            + @DocNoTransaction


				


                        UPDATE  TransactionTypeWiseNextNumbers
                        SET     NextNumber = NextNumber + 1
                        WHERE   LocationID = @LocationID
                                AND TransactionType = 'IT'		




                        INSERT  INTO dbo.StockTransactionHeaders
                                ( DocumentNo ,
                                  TransactionType ,
                                  TransactionDate ,
                                  PropertyID ,
                                  LocationID ,
                                  ReferenceNo ,
                                  SupplierID ,
                                  Remarks ,
                                  ReferenceID ,
                                  DepartmentID ,
                                  UserProfileID ,
                                  TransferLocationID ,
                                  TimeStamp ,
                                  TransactionID ,
                                  Mode ,
                                  SuppCurrencyID ,
                                  ExchangeRate ,
                                  IPAddress ,
                                  CreatedUserID ,
                                  LastModUserID ,
                                  CreatedDate ,
                                  LastModDate ,
                                  IsPrint ,
                                  IsApproved
		                        )
                        VALUES  ( @DocNoTransaction ,       -- DocumentNo - nvarchar(20)
                                  'II' ,       -- TransactionType - nvarchar(2)
                                  GETDATE() , -- TransactionDate - datetime
                                  @PropertyID ,         -- PropertyID - int
                                  @LocationID ,         -- LocationID - int
                                  N'' ,       -- ReferenceNo - nvarchar(20)
                                  0 ,         -- SupplierID - int
                                  N'' ,       -- Remarks - nvarchar(20)
                                  0 ,         -- ReferenceID - int
                                  @DepartmentID ,         -- DepartmentID - int
                                  @CreatedUserID ,         -- UserProfileID - int
                                  0 ,         -- TransferLocationID - int
                                  N'' ,       -- TimeStamp - nvarchar(256)
                                  0 ,         -- TransactionID - int
                                  N'' ,       -- Mode - nvarchar(1)
                                  0 ,         -- SuppCurrencyID - int
                                  0 ,      -- ExchangeRate - decimal(18, 2)
                                  N'' ,       -- IPAddress - nvarchar(max)
                                  @CreatedUserID ,         -- CreatedUserID - int
                                  @CreatedUserID ,         -- LastModUserID - int
                                  GETDATE() , -- CreatedDate - datetime
                                  GETDATE() , -- LastModDate - datetime
                                  0 ,      -- IsPrint - bit
                                  0       -- IsApproved - bit
			                    )
                        SELECT  @StockTransactionHeaderID = SCOPE_IDENTITY()
                    END 
                ELSE
                    BEGIN
                        SELECT  @StockTransactionHeaderID = Id
                        FROM    dbo.StockTransactionHeaders
                        WHERE   CONVERT(VARCHAR, TransactionDate, 101) = CONVERT(VARCHAR, GETDATE(), 101)
                                AND TransactionType = 'II'
                                AND PropertyID = @PropertyID
                    END

                SELECT  *
                INTO    #TEMPInvoiceDetail
                FROM    dbo.Temp_InvoiceDetail
                WHERE   InvoiceHeaderID = @InvoiceHeaderID 

                WHILE ( SELECT  COUNT(*)
                        FROM    #TEMPInvoiceDetail
                      ) > 0
                    BEGIN
                        SELECT TOP 1
                                @TempInvoiceDetailId = ID ,
                                @TempItemId = ItemID ,
                                @TempQty = QTY ,
                                @TempunitID = UnitID ,
                                @TempAveragePrice = AveragePrice
                        FROM    #TEMPInvoiceDetail
                        ORDER BY ID 
	
                        IF NOT EXISTS ( SELECT  *
                                        FROM    dbo.StockTransactionDetails
                                        WHERE   CONVERT(VARCHAR, CreatedDate, 101) = CONVERT(VARCHAR, GETDATE(), 101)
                                                AND StockItemID = @TempItemId AND StockTransactionHeaderID = @StockTransactionHeaderID)
                            BEGIN   
                                INSERT  INTO dbo.StockTransactionDetails
                                        ( StockTransactionHeaderID ,
                                          StockItemID ,
                                          Quantity ,
                                          UnitPrice ,
                                          TxnUnitID ,
                                          MasterUnitID ,
                                          MasterUnitConversion ,
                                          ReportUnitID ,
                                          ReportUnitConversion ,
                                          DiscountValue ,
                                          DiscountPercentage ,
                                          TimeStamp ,
                                          StockMasterQuantity ,
                                          StockMasterAveragePrice ,
                                          NewQuantity ,
                                          NewAveragePrice ,
                                          Remarks ,
                                          UserProfileId ,
                                          CostTransactionAccountID ,
                                          PurchaseTransactionAccountID ,
                                          TxnType ,
                                          BalanceQuantity ,
                                          ReturnQuantity ,
                                          ItemUnitPriceInSuppCurrency ,
                                          IPAddress ,
                                          CreatedUserID ,
                                          LastModUserID ,
                                          CreatedDate ,
                                          LastModDate
				                        )
                                        SELECT  @StockTransactionHeaderID ,
                                                ItemID ,
                                                QTY ,
                                                UnitPrice ,
                                                UnitID ,
                                                ISNULL(dbo.FN_GetMasterUnitID(@PropertyID,
                                                              @LocationID,
                                                              @TempItemId), 0) MasterUnitID ,
                                                ISNULL(dbo.FN_GetUnitConvertionRate(@PropertyID,
                                                              UnitID,
                                                              dbo.FN_GetMasterUnitID(@PropertyID,
                                                              @LocationID,
                                                              @TempItemId)), 0) MasterUnitConversion ,
                                                ISNULL(dbo.FN_GetReportingUnitID(@PropertyID,
                                                              @LocationID,
                                                              @TempItemId), 0) ReportUnitID ,
                                                dbo.FN_GetUnitConvertionRate(@PropertyID,
                                                              UnitID,
                                                              dbo.FN_GetReportingUnitID(@PropertyID,
                                                              @LocationID,
                                                              @TempItemId)) ReportUnitConversion ,
                                                ItemDiscountValue ,
                                                ItemDiscountPercentage ,
                                                '' TimeStamp ,
                                                dbo.FN_GetStockInHand(@PropertyID,
                                                              @LocationID,
                                                              @TempItemId) StockMasterQuantity ,
                                                0 ,
                                                dbo.FN_GetStockInHand(@PropertyID,
                                                              @LocationID,
                                                              @TempItemId)
                                                - QTY ,
                                                0 ,
                                                '' Remarks ,
                                                CreatedUserID ,
                                                dbo.FN_GetPurchaseCostOfSalesAccountID(@TempItemId,
                                                              @LocationID) CostTransactionAccountID ,
                                                dbo.FN_GetPurchaseTransactionAccountID(@TempItemId,
                                                              @LocationID) PurchaseTransactionAccountID ,
                                                'I' ,
                                                0 ,
                                                0 ,
                                                0 ,
                                                IPAddress ,
                                                CreatedUserID ,
                                                CreatedUserID ,
                                                GETDATE() ,
                                                GETDATE()
                                        FROM    dbo.Temp_InvoiceDetail
                                        WHERE   ID = @TempInvoiceDetailId

                            END 
                        ELSE
                            BEGIN
                                UPDATE  StockTransactionDetails
                                SET     Quantity = Quantity + @TempQty,NewQuantity= dbo.FN_GetStockInHand(@PropertyID,
                                                              @LocationID,
                                                              @TempItemID)
                                                - @TempQty
                                WHERE   StockItemID = @TempItemId AND StockTransactionHeaderID=@StockTransactionHeaderID
                                        AND CONVERT(VARCHAR, CreatedDate, 101) = CONVERT(VARCHAR, GETDATE(), 101)
                            END 


                        
    
                        EXEC [SP_UpdateStockItemBalance] @PropertyID,
                            @LocationID, @TempItemId, 'II', @TempQty,
                            @TempunitID, @TempAveragePrice
                        DELETE  FROM #TEMPInvoiceDetail
                        WHERE   ID = @TempInvoiceDetailId
                    END 


            END 
        DELETE  FROM dbo.Temp_InvoiceHeader
        WHERE   ID = @InvoiceHeaderID
        DELETE  FROM dbo.Temp_InvoiceDetail
        WHERE   InvoiceHeaderID = @InvoiceHeaderID


		---for tax breakdown-----
		DECLARE @TempInvoiceDetailsId INT 
		SELECT  ID ,
                ItemID
        INTO    #TEMPInvoiceDetailsId
        FROM    dbo.InvoiceDetails
        WHERE   InvoiceHeaderID = @Recipientheaderid

        WHILE ( SELECT  COUNT(*)
                FROM    #TEMPInvoiceDetailsId
              ) > 0
            BEGIN 
                SELECT TOP 1
                        @TempInvoiceDetailsId = ID ,
                        @TempItemID = ItemID
                FROM    #TEMPInvoiceDetailsId 


				--SELECT * FROM dbo.InvoiceTaxBreakdown

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
				--VALUES  ( 0 , -- InvoiceDetailID - int
				--          0 , -- InvoiceHeaderID - int
				--          0 , -- ItemID - int
				--          0 , -- TaxID - int
				--          NULL , -- TaxRate - decimal
				--          NULL , -- TaxValue - decimal
				--          N'' , -- IPAddress - nvarchar(max)
				--          0 , -- CreatedUserID - int
				--          0 , -- LastModUserID - int
				--          GETDATE() , -- CreatedDate - datetime
				--          GETDATE()  -- LastModDate - datetime
				--        )
                        SELECT  @Recipientheaderid ,
                                ID.ID ,
                                ID.ItemID ,
                                TGD.TaxTypeId ,
                                TGD.ChargeRate ,
                                ID.CostPrice*(TGD.ChargeRate/100) * ID.QTY ,
                                '' ,
                                @CreatedUserID ,
                                @CreatedUserID ,
                                GETDATE() ,
                                GETDATE()
                        FROM    dbo.InvoiceHeaders IH
                                INNER JOIN dbo.InvoiceDetails ID ON ID.InvoiceHeaderID = IH.ID
                                INNER JOIN dbo.StockItemHeaders SH ON SH.Id = ID.ItemID
                                INNER JOIN dbo.TaxGroupDetails TGD ON TGD.TaxGroupId = SH.TaxGroupID
                        WHERE   ID.ID = @TempInvoiceDetailsId

                --INSERT  INTO dbo.Temp_InvoiceTaxBreakdown
                --        SELECT  @TempInvoiceDetailsId ,
                --                @HeaderID ,
                --                @TempItemID ,
                --                TaxID ,
                --                TaxRate ,
                --                TaxValue ,
                --                IPAddress ,
                --                CreatedUserID ,
                --                LastModUserID ,
                --                CreatedDate ,
                --                LastModDate
                --        FROM    #TEMPInvoiceTaxBreakdown
                --        WHERE   ItemID = @TempItemID

                DELETE  FROM #TEMPInvoiceDetailsId
                WHERE   ID = @TempInvoiceDetailsId
            END 


			---end


        EXEC sp_xml_removedocument @iDocID

        COMMIT TRAN 
    END TRY
    BEGIN CATCH
        RETURN CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN 
    END CATCH

GO

