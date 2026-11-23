-- SP_InsertInvoice '<Temp_InvoiceHeader xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><ID>-1</ID><InvoiceNo>SC00000544</InvoiceNo><CustomerID>-1</CustomerID><CustomerName /><InvoiceDate>2018-10-29T14:45:36.2050368+05:30</InvoiceDate><DepartmentID>1</DepartmentID><Location>1</Location><GrossTotal>3780.00</GrossTotal><NetTotal>3780.00</NetTotal><TotalDiscount>0.00</TotalDiscount><ToatlDiscountRate>0.00</ToatlDiscountRate><ItemDiscountTotal>0.00</ItemDiscountTotal><TaxTotal>0.0</TaxTotal><OtherCharges>0.0</OtherCharges><sysDate>2018-10-29T14:45:36.206038+05:30</sysDate><UserID>1</UserID><PropertyID>1</PropertyID><VATNo>-1</VATNo><IPAddress /><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2018-10-29T14:45:36.2070388+05:30</CreatedDate><LastModDate>2018-10-29T14:45:36.2070388+05:30</LastModDate><IsPercentageForDiscount>false</IsPercentageForDiscount><ItemDiscountType>0</ItemDiscountType><IsSerialUpdated>false</IsSerialUpdated><InvoiceDetail><Temp_InvoiceDetail><ID>-999</ID><TxnType>I</TxnType><InvoiceHeaderID>-999</InvoiceHeaderID><ItemID>21</ItemID><QTY>1.0</QTY><UnitID>3</UnitID><UnitPrice>3780.00</UnitPrice><DelievryQTY>1.0</DelievryQTY><ReturnQty>0.0</ReturnQty><AveragePrice>0.0</AveragePrice><CostPrice>0.0</CostPrice><TaxGroupID>-999</TaxGroupID><TaxValue>0.0</TaxValue><SerialNo /><ItemDiscountValue>0.00</ItemDiscountValue><ItemDiscountPercentage>0.0</ItemDiscountPercentage><ItemDiscountType>0</ItemDiscountType><WarrentyPeriod>0.0</WarrentyPeriod><IsPercentageForDiscount>false</IsPercentageForDiscount><IPAddress /><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2018-10-29T14:45:36.2100413+05:30</CreatedDate><LastModDate>2018-10-29T14:45:36.2100413+05:30</LastModDate><PrintSequence>0.0</PrintSequence><TaxInclusivePrice>3780.00</TaxInclusivePrice></Temp_InvoiceDetail></InvoiceDetail><InvoicePaymentsDetails><InvoicePaymentsDetails><ID>0</ID><InvoiceHeaderID>0</InvoiceHeaderID><PaymentTypeID>4</PaymentTypeID><TenderedAmount>5000.0</TenderedAmount><ActualAmount>3780.00</ActualAmount><BalanceAmount>-1220.00</BalanceAmount><Remarks /><ReferanceNumebrs /><CreditNumber /><IPAddress /><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2018-10-29T14:45:36.1790199+05:30</CreatedDate><LastModDate>2018-10-29T14:45:36.1790199+05:30</LastModDate></InvoicePaymentsDetails></InvoicePaymentsDetails><InvoiceTaxBreakdown><Temp_InvoiceTaxBreakdown><Id>0</Id><InvoiceDetailID>0</InvoiceDetailID><InvoiceHeaderID>0</InvoiceHeaderID><ItemID>0</ItemID><TaxID>0</TaxID><TaxRate>0.0</TaxRate><TaxValue>0.0</TaxValue><IPAddress /><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2018-10-29T14:45:36.204037+05:30</CreatedDate><LastModDate>2018-10-29T14:45:36.204037+05:30</LastModDate></Temp_InvoiceTaxBreakdown></InvoiceTaxBreakdown><InvoiceOtherCharges><Temp_InvoiceOtherCharges><ID>0</ID><OtherChargID>0</OtherChargID><InvoiceHeaderID>0</InvoiceHeaderID><Amount>0.0</Amount><IPAddress /><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2018-10-29T14:45:36.2050368+05:30</CreatedDate><LastModDate>2018-10-29T14:45:36.2050368+05:30</LastModDate></Temp_InvoiceOtherCharges></InvoiceOtherCharges></Temp_InvoiceHeader>',1,0,1,'',0

CREATE PROCEDURE [dbo].[SP_InsertInvoice_test]
    (
      @XMLDetails AS XML ,
      @Mode BIT ,	 --1
      @OrderID INT , --0
	  @IsPOS BIT = 0,
      @docID VARCHAR(MAX) OUTPUT ,
      @Recipientheaderid INT OUTPUT

    )
AS
    DECLARE @iDocID INT 


    BEGIN TRY
        BEGIN TRANSACTION

        DECLARE @LocationID INT ,
            @DepartmentID INT ,
            @DocumentNo VARCHAR(MAX) ,
			@POSDocumentNo VARCHAR(MAX) ,
            @HeaderID INT ,
            @TempInvoiceDetailsId INT ,
            @TempItemID INT ,
            @PropertyID INT ,
            @CreatedUserID INT ,
            @StockTransactionHeaderID INT ,
            @TempInvoiceDetailId INT,
			@PrefixInv VARCHAR(2)='IN'    

        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;
        SELECT  [InvoiceNo],
		        [CustomerID] ,
                [InvoiceDate] ,
                [DepartmentID] ,
                [Location] ,
                [TotalDiscount] ,
                [ToatlDiscountRate] ,
                [ItemDiscountTotal] ,
                [TaxTotal] ,
                [OtherCharges] ,
                GETDATE() AS [sysDate] ,
                [UserID] ,
                [IPAddress] ,
                [CreatedUserID] ,
                [LastModUserID] ,
                [CreatedDate] ,
                [LastModDate] ,
                [CustomerName] ,
                [PropertyID] ,
                [VATNo] ,
                [SalesPersonID] ,
                [TotalPrintDiscount] ,
                [SubTotal] ,
                [IsSerialUpdated] ,
                [IsPercentageForDiscount] ,
                [GrossTotal] ,
                [NetTotal] ,
                [ItemDiscountType]
        INTO    #TEMPInvoiceHeader
        FROM    OPENXML(@iDocID, 'Temp_InvoiceHeader', 2)
    WITH
    (
        [InvoiceNo]VARCHAR(MAX), 
        [CustomerID] INT,
        [InvoiceDate] DATETIME,
        [DepartmentID] INT,
        [Location] INT,       
        [TotalDiscount] DECIMAL(18, 2),       
        [ToatlDiscountRate] DECIMAL(18, 2),
        [ItemDiscountTotal] DECIMAL(18, 2),
        [TaxTotal] DECIMAL(18, 2),
        [OtherCharges] DECIMAL(18, 2),
        [sysDate] DATETIME,
        [UserID] INT,
        [IPAddress] NVARCHAR(MAX),
        [CreatedUserID] INT,
        [LastModUserID] INT,
        [CreatedDate] DATETIME,
        [LastModDate] DATETIME,
		[CustomerName] NVARCHAR(MAX),
		[PropertyID] INT,
	    [VATNo]	INT,
		[SalesPersonID] INT,
		[TotalPrintDiscount] DECIMAL(18,2),
		[SubTotal] DECIMAL(18, 2),
		[IsSerialUpdated] BIT,
		[IsPercentageForDiscount] BIT,
		[GrossTotal] DECIMAL(18, 2),
		[NetTotal] DECIMAL(18, 2),
		[ItemDiscountType] INT 

    );

        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;
        SELECT  [ID]
		        [ItemID] ,
                [QTY] ,
                [UnitID] ,
                [UnitPrice] ,
                [DelievryQTY] ,
                [ReturnQty] ,
                [AveragePrice] ,
                [CostPrice] ,
                [TaxGroupID] ,
                [TaxValue] ,
                [SerialNo] ,
                [ItemDiscountValue] ,
                [ItemDiscountType] ,
                [IPAddress] ,
                [CreatedUserID] ,
                [LastModUserID] ,
                [CreatedDate] ,
                [LastModDate] ,
                [ItemDiscountPercentage] ,
                [WarrentyPeriod] ,
                [IsPercentageForDiscount] ,
                [TaxCostPrice] ,
                [TaxForSellPrice] ,
                [PrintSequence] ,
                [TaxInclusivePrice],
				[TxnType]
        INTO    #TEMPInvoiceDetail
        FROM    OPENXML(@iDocID, 'Temp_InvoiceHeader/InvoiceDetail/Temp_InvoiceDetail', 2)
    WITH
    (	[ID] INT, 
        [ItemID] INT,
        [QTY] DECIMAL(18, 2),
        [UnitID] INT,
        [UnitPrice] DECIMAL(18, 2),
        [DelievryQTY] DECIMAL(18, 2),
        [ReturnQty] DECIMAL(18, 2),
        [AveragePrice] DECIMAL(18, 2),
        [CostPrice] DECIMAL(18, 2),
        [TaxGroupID] INT,
        [TaxValue] DECIMAL(18, 2),
        [SerialNo] NVARCHAR(MAX),
        [ItemDiscountValue] DECIMAL(18, 2),
        [ItemDiscountType] INT,      
        [IPAddress] NVARCHAR(MAX),
        [CreatedUserID] INT,
        [LastModUserID] INT,
        [CreatedDate] DATETIME,
        [LastModDate] DATETIME,
		[ItemDiscountPercentage] DECIMAL(18, 2),
	    [WarrentyPeriod] DECIMAL(18, 2),
	    [IsPercentageForDiscount] BIT ,
		[TaxCostPrice] DECIMAL(18,2),
		[TaxForSellPrice] DECIMAL(18,2),
		[PrintSequence] DECIMAL(18,2),
	    [TaxInclusivePrice] DECIMAL(18,2),
		[TxnType] CHAR(1)
    );

        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;
        SELECT  [ID] [InvoiceHeaderID] ,
                [Amount] ,
                [Remarks] ,
                [IPAddress] ,
                [CreatedUserID] ,
                [LastModUserID] ,
                [CreatedDate] ,
                [LastModDate]
        INTO    #TEMPInvoiceOtherCharges
        FROM    OPENXML(@iDocID, 'Temp_InvoiceHeader/InvoiceOtherCharges/Temp_InvoiceOtherCharges', 2)
    WITH
    (	[ID] INT,
        [InvoiceHeaderID] INT,
        [Amount] DECIMAL(18, 2),
        [Remarks] NVARCHAR(MAX),
        [IPAddress] NVARCHAR(MAX),
        [CreatedUserID] INT,
        [LastModUserID] INT,
        [CreatedDate] DATETIME,
        [LastModDate] DATETIME
    );

        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;
        SELECT  [InvoiceHeaderID] ,
                [PaymentTypeID] ,
                [TenderedAmount] ,
                [ActualAmount] ,
                [BalanceAmount] ,
                [Remarks] ,
                [ReferanceNumebrs] ,
                [IPAddress] ,
                [CreatedUserID] ,
                [LastModUserID] ,
                [CreatedDate] ,
                [LastModDate] ,
                [CheckNumber] ,
                [BankId] ,
                [BranchId] ,
                [RealizedDate] ,
                [CreditNumber] ,
                [CnId]
        INTO    #TEMPInvoicePaymentsDetails
        FROM    OPENXML(@iDocID, 'Temp_InvoiceHeader/InvoicePaymentsDetails/Temp_InvoicePaymentsDetails', 2)
    WITH
    (
        [InvoiceHeaderID] INT,
        [PaymentTypeID] INT,
        [TenderedAmount] DECIMAL(18, 2),
        [ActualAmount] DECIMAL(18, 2),
        [BalanceAmount] DECIMAL(18, 2),
        [Remarks] NVARCHAR(MAX),
        [ReferanceNumebrs] NVARCHAR(MAX),
        [IPAddress] NVARCHAR(MAX),
        [CreatedUserID] INT,
        [LastModUserID] INT,
        [CreatedDate] DATETIME,
        [LastModDate] DATETIME,
		[CheckNumber] INT,
		[BankId] INT,
		[BranchId] INT,
		[RealizedDate] DATETIME,
		[CreditNumber] NVARCHAR(MAX),
		[CnId] INT
    );

        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;
        SELECT  [InvoiceDetailID] ,
                [InvoiceHeaderID] ,
                [ItemID] ,
                [TaxID] ,
                [TaxRate] ,
                [TaxValue] ,
                [IPAddress] ,
                [CreatedUserID] ,
                [LastModUserID] ,
                [CreatedDate] ,
                [LastModDate]
        INTO    #TEMPInvoiceTaxBreakdown
        FROM    OPENXML(@iDocID, 'Temp_InvoiceHeader/InvoiceTaxBreakdown/Temp_InvoiceTaxBreakdown', 2)
    WITH
    (
        [InvoiceDetailID] INT,
        [InvoiceHeaderID] INT,
        [ItemID] INT,
        [TaxID] INT,
        [TaxRate] DECIMAL(18, 2),
        [TaxValue] DECIMAL(18, 2),
        [IPAddress] NVARCHAR(MAX),
        [CreatedUserID] INT,
        [LastModUserID] INT,
        [CreatedDate] DATETIME,
        [LastModDate] DATETIME
    );


        SELECT  @POSDocumentNo = InvoiceNo,
		        @LocationID = Location ,
                @DepartmentID = DepartmentID ,
                @PropertyID = PropertyID ,
                @CreatedUserID = CreatedUserID
        FROM    #TEMPInvoiceHeader

        --SELECT  @DocumentNo = dbo.FN_GetNextDocumentNumberForInvoice(@DepartmentID)
        --UPDATE  InvoiceWiseNextNumbers
        --SET     NextNo = NextNo + 1
        --WHERE   DepartmentId = @DepartmentID 

		SELECT  @DocumentNo = dbo.FN_GetNextDocumentNumberForInvoice(@DepartmentID,@PrefixInv)

IF @DocumentNo IS NULL
BEGIN
	
	INSERT INTO dbo.InvoiceWiseNextNumbers
	        ( DepartmentId ,
	          Prefix ,
	          NextNo ,
	          LengthOfFormatting
	        )
	VALUES  (@DepartmentID , -- DepartmentId - int
	          'IN' , -- Prefix - varchar(2)
	          1 , -- NextNo - int
	          6  -- LengthOfFormatting - int
	        )
END



		SELECT  @DocumentNo = dbo.FN_GetNextDocumentNumberForInvoice(@DepartmentID,@PrefixInv)


		UPDATE  InvoiceWiseNextNumbers
        SET     NextNo = NextNo + 1
        WHERE   DepartmentId = @DepartmentID AND Prefix=@PrefixInv


        INSERT  INTO dbo.Temp_InvoiceHeader
                SELECT  CASE WHEN @IsPOS = 1 THEN @POSDocumentNo ELSE @DocumentNo END,
                        [CustomerID] ,
						[InvoiceDate] ,
						[DepartmentID] ,
						[Location] ,
						[TotalDiscount] ,
						[ToatlDiscountRate] ,
						[ItemDiscountTotal] ,
						[TaxTotal] ,
						[OtherCharges] ,
						[sysDate] ,
						[UserID] ,
						[IPAddress] ,
						[CreatedUserID] ,
						[LastModUserID] ,
						[CreatedDate] ,
						[LastModDate] ,
						[CustomerName] ,
						[PropertyID] ,
						[VATNo] ,
						[SalesPersonID] ,
						[TotalPrintDiscount] ,
						[SubTotal] ,
						[IsSerialUpdated] ,
						[IsPercentageForDiscount] ,
						[GrossTotal] ,
						[NetTotal] ,
						[ItemDiscountType]
                FROM    #TEMPInvoiceHeader;
        SELECT  @HeaderID = SCOPE_IDENTITY()


 --SELECT * FROM #TEMPInvoiceDetail
 
        INSERT  INTO dbo.Temp_InvoiceDetail
                SELECT  @HeaderID ,
                        TD.ItemID ,
                        TD.QTY ,
                        TD.UnitID ,
                        CASE WHEN TD.UnitPrice = TD.TaxInclusivePrice
                             THEN dbo.FN_GetActualPriceWithoutTax(TD.TaxInclusivePrice,
                                                              SD.TaxGroupID)
                             ELSE TD.UnitPrice
                        END ,
                        TD.DelievryQTY ,
                        TD.ReturnQty ,
                        TD.AveragePrice ,
                        TD.CostPrice ,
                        SD.TaxGroupID ,
                        CASE WHEN TD.UnitPrice = TD.TaxInclusivePrice
                             THEN CASE WHEN ( TD.TaxInclusivePrice = TD.UnitPrice
                                              + dbo.FN_GetStockItemWiseTotalTax(TD.ItemID,
                                                              ( dbo.FN_GetActualPriceWithoutTax(TD.TaxInclusivePrice,
                                                              SD.TaxGroupID) )) )
                                       THEN dbo.FN_GetStockItemWiseTotalTax(TD.ItemID,
                                                              ( dbo.FN_GetActualPriceWithoutTax(TD.TaxInclusivePrice,
                                                              SD.TaxGroupID) ))
                                       ELSE dbo.FN_GetStockItemWiseTotalTax(TD.ItemID,
                                                              ( dbo.FN_GetActualPriceWithoutTax(TD.TaxInclusivePrice,
                                                              SD.TaxGroupID) ))
                                            + ( TD.TaxInclusivePrice
                                                - ( ( dbo.FN_GetActualPriceWithoutTax(TD.TaxInclusivePrice,
                                                              SD.TaxGroupID) )
                                                    + dbo.FN_GetStockItemWiseTotalTax(TD.ItemID,
                                                              ( dbo.FN_GetActualPriceWithoutTax(TD.TaxInclusivePrice,
                                                              SD.TaxGroupID) )) ) )
                                  END
                             ELSE CASE WHEN ( TD.TaxInclusivePrice = TD.UnitPrice
                                              + dbo.FN_GetStockItemWiseTotalTax(TD.ItemID,
                                                              TD.UnitPrice) )
                                       THEN TD.TaxValue
                                       ELSE TD.TaxValue
                                            + ( TD.TaxInclusivePrice
                                                - ( TD.UnitPrice
                                                    + dbo.FN_GetStockItemWiseTotalTax(TD.ItemID,
                                                              TD.UnitPrice) ) )
                                  END
                        END ,
                        TD.SerialNo ,
                        TD.ItemDiscountValue ,
                        TD.ItemDiscountType ,
                        TD.IPAddress ,
                        TD.CreatedUserID ,
                        TD.LastModUserID ,
                        TD.CreatedDate ,
                        TD.LastModDate ,
                        TD.ItemDiscountPercentage ,
                        TD.WarrentyPeriod ,
                        TD.IsPercentageForDiscount ,
						--TD.TaxCostPrice
                        CASE WHEN ( SELECT  dbo.FN_GetActualPriceWithoutTax(TD.TaxInclusivePrice,
                                                              SD.TaxGroupID)
                                  ) <> TD.UnitPrice
                                  AND TD.TaxCostPrice <> 0
                             THEN ( CASE WHEN TD.IsPercentageForDiscount = 0
                                         THEN TD.ItemDiscountValue
                                         ELSE TD.UnitPrice
                                              * ( TD.ItemDiscountPercentage
                                                  / 100 )
                                    END )
                             ELSE TD.TaxCostPrice
                        END ,
                        CASE WHEN ( TD.UnitPrice
                                    + dbo.FN_GetStockItemWiseTotalTax(TD.ItemID,
                                                              TD.UnitPrice) <> TD.TaxInclusivePrice
                                    AND TD.UnitPrice <> TD.TaxInclusivePrice
                                  )
                             THEN dbo.FN_GetStockItemWiseTotalTax(TD.ItemID,
                                                              TD.UnitPrice)
                                  + ( TD.TaxInclusivePrice - ( TD.UnitPrice
                                                              + dbo.FN_GetStockItemWiseTotalTax(TD.ItemID,
                                                              TD.UnitPrice) ) )
                             WHEN ( TD.UnitPrice = TD.TaxInclusivePrice )
                             THEN 
							 --dbo.FN_GetStockItemWiseTotalTax(TD.ItemID,
        --                                                      ( dbo.FN_GetActualPriceWithoutTax(TD.TaxInclusivePrice,
        --                                                      SD.TaxGroupID) ))
                                  dbo.FN_GetStockItemWiseTotalTax(TD.ItemID,
                                                              ( dbo.FN_GetActualPriceWithoutTax(TD.TaxInclusivePrice,
                                                              SD.TaxGroupID) ))
                                  + TD.TaxInclusivePrice
                                  - ( dbo.FN_GetActualPriceWithoutTax(TD.TaxInclusivePrice,
                                                              SD.TaxGroupID)
                                      + dbo.FN_GetStockItemWiseTotalTax(TD.ItemID,
                                                              ( dbo.FN_GetActualPriceWithoutTax(TD.TaxInclusivePrice,
                                                              SD.TaxGroupID) )) )
                             ELSE dbo.FN_GetStockItemWiseTotalTax(TD.ItemID,
                                                              TD.UnitPrice)
                        END ,
                        PrintSequence,
						TD.TxnType
                FROM    #TEMPInvoiceDetail TD
                        INNER JOIN dbo.StockItemHeaders SD ON TD.ItemID = SD.Id
                        INNER JOIN dbo.StockItemDetails SH ON SH.StockItemHeaderID = SD.Id
                WHERE   SH.LocationID = @LocationID;


				
			IF EXISTS(SELECT TxnType FROM #TEMPInvoiceDetail WHERE TxnType = 'R')
			BEGIN
				DECLARE @ReturnQty DECIMAL,
				        @InvoDetailId INT
				SELECT @InvoDetailId=ItemID,@ReturnQty=QTY FROM #TEMPInvoiceDetail WHERE TxnType = 'R'

				 UPDATE dbo.InvoiceDetails SET ReturnQty = ReturnQty+@ReturnQty WHERE ID = @InvoDetailId
			END

				
			--UPDATE TH SET TH.TaxTotal=(SELECT SUM(TaxValue*qty) 
			--FROM dbo.Temp_InvoiceDetail WHERE InvoiceHeaderID=@HeaderID) FROM dbo.Temp_InvoiceHeader TH WHERE TH.ID = @HeaderID

 ------



        IF NOT EXISTS ( SELECT  InvoiceHeaderID
                        FROM    #TEMPInvoiceOtherCharges
                        WHERE   InvoiceHeaderID = -999 )
            BEGIN
                INSERT  INTO dbo.Temp_InvoiceOtherCharges
                        SELECT  1 ,
                                @HeaderID ,
                                Amount ,
                                Remarks ,
                                IPAddress ,
                                CreatedUserID ,
                                LastModUserID ,
                                CreatedDate ,
                                LastModDate
                        FROM    #TEMPInvoiceOtherCharges
            END

        IF NOT EXISTS ( SELECT  InvoiceHeaderID
                        FROM    #TEMPInvoicePaymentsDetails
                        WHERE   InvoiceHeaderID = -999 )
            BEGIN

                INSERT  INTO Temp_InvoicePaymentsDetails
                        SELECT  @HeaderID ,
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
                                CheckNumber ,
                                BankId ,
                                BranchId ,
                                RealizedDate ,
                                CreditNumber ,
                                CnId
                        FROM    #TEMPInvoicePaymentsDetails;
            END

    --    SELECT  ID ,
    --            ItemID
    --    INTO    #TEMPInvoiceDetailsId
    --    FROM    dbo.Temp_InvoiceDetail
    --    WHERE   InvoiceHeaderID = @HeaderID

    --    WHILE ( SELECT  COUNT(*)
    --            FROM    #TEMPInvoiceDetailsId
    --          ) > 0
    --        BEGIN 
    --            SELECT TOP 1
    --                    @TempInvoiceDetailsId = ID ,
    --                    @TempItemID = ItemID
    --            FROM    #TEMPInvoiceDetailsId 


				----SELECT * FROM dbo.InvoiceTaxBreakdown

    --            INSERT  INTO dbo.InvoiceTaxBreakdowns
    --                    ( InvoiceDetailID ,
    --                      InvoiceHeaderID ,
    --                      ItemID ,
    --                      TaxID ,
    --                      TaxRate ,
    --                      TaxValue ,
    --                      IPAddress ,
    --                      CreatedUserID ,
    --                      LastModUserID ,
    --                      CreatedDate ,
    --                      LastModDate
				--        )
				----VALUES  ( 0 , -- InvoiceDetailID - int
				----          0 , -- InvoiceHeaderID - int
				----          0 , -- ItemID - int
				----          0 , -- TaxID - int
				----          NULL , -- TaxRate - decimal
				----          NULL , -- TaxValue - decimal
				----          N'' , -- IPAddress - nvarchar(max)
				----          0 , -- CreatedUserID - int
				----          0 , -- LastModUserID - int
				----          GETDATE() , -- CreatedDate - datetime
				----          GETDATE()  -- LastModDate - datetime
				----        )
    --                    SELECT  @HeaderID ,
    --                            ID.ID ,
    --                            ID.ItemID ,
    --                            TGD.TaxTypeId ,
    --                            TGD.ChargeRate ,
    --                            ID.CostPrice*(TGD.ChargeRate/100) * ID.QTY ,
    --                            '' ,
    --                            @CreatedUserID ,
    --                            @CreatedUserID ,
    --                            GETDATE() ,
    --                            GETDATE()
    --                    FROM    dbo.Temp_InvoiceHeader IH
    --                            INNER JOIN dbo.Temp_InvoiceDetail ID ON ID.InvoiceHeaderID = IH.ID
    --                            INNER JOIN dbo.StockItemHeaders SH ON SH.Id = ID.ItemID
    --                            INNER JOIN dbo.TaxGroupDetails TGD ON TGD.TaxGroupId = SH.TaxGroupID
    --                    WHERE   ID.ID = @TempInvoiceDetailsId

    --            --INSERT  INTO dbo.Temp_InvoiceTaxBreakdown
    --            --        SELECT  @TempInvoiceDetailsId ,
    --            --                @HeaderID ,
    --            --                @TempItemID ,
    --            --                TaxID ,
    --            --                TaxRate ,
    --            --                TaxValue ,
    --            --                IPAddress ,
    --            --                CreatedUserID ,
    --            --                LastModUserID ,
    --            --                CreatedDate ,
    --            --                LastModDate
    --            --        FROM    #TEMPInvoiceTaxBreakdown
    --            --        WHERE   ItemID = @TempItemID

    --            DELETE  FROM #TEMPInvoiceDetailsId
    --            WHERE   ID = @TempInvoiceDetailsId
    --        END 



    -------- for separate settlement------------------------------------------------



        IF ( @Mode = 1 )
            BEGIN
                IF NOT EXISTS ( SELECT  *
                                FROM    dbo.StockTransactionHeaders
                                WHERE   CONVERT(VARCHAR, TransactionDate, 101) = CONVERT(VARCHAR, GETDATE(), 101)
                                        AND TransactionType = 'II'
                                        AND PropertyID = @PropertyID )
                    BEGIN

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



--SELECT * FROM TransactionTypeWiseNextNumbers
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

                DECLARE @TempQty INT ,
                    @TempunitID INT ,
                    @TempAveragePrice DECIMAL 

                SELECT  *
                INTO    #TEMPInvoiceDetail1
                FROM    dbo.Temp_InvoiceDetail
                WHERE   InvoiceHeaderID = @HeaderID
				
                SELECT  *
                FROM    #TEMPInvoiceDetail1 

                WHILE ( SELECT  COUNT(*)
                        FROM    #TEMPInvoiceDetail1
                      ) > 0
                    BEGIN
                        SELECT TOP 1
                                @TempInvoiceDetailId = ID ,
                                @TempItemID = ItemID ,
                                @TempQty = QTY ,
                                @TempunitID = UnitID ,
                                @TempAveragePrice = AveragePrice
                        FROM    #TEMPInvoiceDetail1
                        ORDER BY ID 
	
                        IF NOT EXISTS ( SELECT  *
                                        FROM    dbo.StockTransactionDetails
                                        WHERE   CONVERT(VARCHAR, CreatedDate, 101) = CONVERT(VARCHAR, GETDATE(), 101)
                                                AND StockItemID = @TempItemID AND StockTransactionHeaderID=@StockTransactionHeaderID)
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
                                                              @TempItemID), 0) MasterUnitID ,
                                                ISNULL(dbo.FN_GetUnitConvertionRate(@PropertyID,
                                                              UnitID,
                                                              dbo.FN_GetMasterUnitID(@PropertyID,
                                                              @LocationID,
                                                              @TempItemID)), 0) MasterUnitConversion ,
                                                ISNULL(dbo.FN_GetReportingUnitID(@PropertyID,
                                                              @LocationID,
                                                              @TempItemID), 0) ReportUnitID ,
                                                dbo.FN_GetUnitConvertionRate(@PropertyID,
                                                              UnitID,
                                                              dbo.FN_GetReportingUnitID(@PropertyID,
                                                              @LocationID,
                                                              @TempItemID)) ReportUnitConversion ,
                                                ItemDiscountValue ,
                                                ItemDiscountPercentage ,
                                                '' TimeStamp ,
                                                dbo.FN_GetStockInHand(@PropertyID,
                                                              @LocationID,
                                                              @TempItemID) StockMasterQuantity ,
                                                0 ,
                                                dbo.FN_GetStockInHand(@PropertyID,
                                                              @LocationID,
                                                              @TempItemID)
                                                - QTY ,
                                                0 ,
                                                '' Remarks ,
                                                CreatedUserID ,
                                                dbo.FN_GetPurchaseCostOfSalesAccountID(@TempItemID,
                                                              @LocationID) CostTransactionAccountID ,
                                                dbo.FN_GetPurchaseTransactionAccountID(@TempItemID,
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
                                SET     Quantity = Quantity + @TempQty
                                WHERE   StockItemID = @TempItemID AND StockTransactionHeaderID=@StockTransactionHeaderID
                                        AND CONVERT(VARCHAR, CreatedDate, 101) = CONVERT(VARCHAR, GETDATE(), 101)
                            END 
    
                        EXEC [SP_UpdateStockItemBalance] @PropertyID,
                            @LocationID, @TempItemID, 'II', @TempQty,
                            @TempunitID, @TempAveragePrice
                        DELETE  FROM #TEMPInvoiceDetail1
                        WHERE   ID = @TempInvoiceDetailId 
                    END 
            END


			--------------------end here-----------------------
			 --------------------For OrderPreparation-----------
			-----@OrderID is equal to 0 when there is no sales order
        IF ( @OrderID <> 0 )
            BEGIN	 			

                INSERT  INTO dbo.SalesOrderWiseInvoices
                        ( OrderID ,
                          InvoiceID ,
                          TransactionDate
			            )
                VALUES  ( @OrderID ,
                          @HeaderID , -- InvoiceID - int
                          GETDATE()  -- TransactionDate - datetime
			            )

                UPDATE  dbo.OrderHeaders
                SET     IsInvoiceCreated = 1
                WHERE   Id = @OrderID

                SELECT  *
                INTO    #TEMPInvoiceDetail2
                FROM    dbo.Temp_InvoiceDetail
                WHERE   InvoiceHeaderID = @HeaderID 


                DECLARE @ItemID INT ,
                    @Quantity DECIMAL ,
                    @DetailID INT 

                WHILE ( SELECT  COUNT(1)
                        FROM    #TEMPInvoiceDetail2
                      ) > 0
                    BEGIN
                       

                        SELECT TOP ( 1 )
                                @ItemID = ItemID ,
                                @Quantity = QTY ,
                                @DetailID = ID
                        FROM    #TEMPInvoiceDetail2
                        ORDER BY ID

                        UPDATE  dbo.OrderDetails
                        SET     BalanceQty = BalanceQty + @Quantity
                        WHERE   ProductID = @ItemID
                                AND OrderHeaderID = @OrderID

                        DELETE  FROM #TEMPInvoiceDetail2
                        WHERE   ID = @DetailID  
                 

                    END 


               --IF EXISTS (SELECT   COUNT(*)
               --        FROM     dbo.OrderDetails
               --        WHERE    OrderHeaderID = @HeaderID
               --        HAVING   SUM(BalanceQty) >= SUM(OrderQty))
                       
               --     BEGIN

               --         UPDATE  dbo.OrderHeaders
               --         SET     DocumentStatus = 'C'
               --         WHERE   Id = @HeaderID

               --     END


                IF ( SELECT COUNT(*)
                     FROM   dbo.OrderDetails
                     WHERE  BalanceQty < OrderQty
                            AND OrderHeaderID = @OrderID
                   ) = 0
                    BEGIN

                        UPDATE  dbo.OrderHeaders
                        SET     DocumentStatus = 'C'
                        WHERE   Id = @OrderID

                    END
                          
                
            END
            

			--------------------end here-----------------------


        SET @Recipientheaderid = @HeaderID
        SET @docID = @DocumentNo
	

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

