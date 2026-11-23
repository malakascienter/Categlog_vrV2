
--[dbo].[SP_CheckQuantityForInv] '<Temp_InvoiceHeader xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><IPAddress>192.168.1.1</IPAddress><CreatedUserID>2</CreatedUserID><LastModUserID>2</LastModUserID><CreatedDate>2018-08-09T08:08:42.117Z</CreatedDate><LastModDate>2018-08-09T08:08:42.117Z</LastModDate><ID>0</ID><CustomerID>548</CustomerID><CustomerName>ACCESS CIVIMECH (PVT) LTD</CustomerName><InvoiceDate>2018-08-09T08:08:42.117Z</InvoiceDate><DepartmentID>1</DepartmentID><Location>1</Location><TotalValue>850</TotalValue><TotalDiscount>0</TotalDiscount><ToatlDiscountType>0</ToatlDiscountType><ToatlDiscountRate>10</ToatlDiscountRate><ItemDiscountTotal>0</ItemDiscountTotal><TaxTotal>125.64</TaxTotal><OtherCharges>1000</OtherCharges><sysDate>2018-08-09T08:08:42.117Z</sysDate><UserID>2</UserID><PropertyID>1</PropertyID><VATNo>121221</VATNo><SalesPersonID>3</SalesPersonID><TotalPrintDiscount>0</TotalPrintDiscount><SubTotal>724.36</SubTotal><InvoiceDetail><Temp_InvoiceDetail><IPAddress>232</IPAddress><CreatedUserID>0</CreatedUserID><LastModUserID>2</LastModUserID><CreatedDate>2018-08-09T08:08:37.471Z</CreatedDate><LastModDate>2018-08-09T08:08:37.471Z</LastModDate><ID>0</ID><InvoiceHeaderID>0</InvoiceHeaderID><ItemID>59</ItemID><QTY>2</QTY><UnitID>1</UnitID><UnitPrice>362.18</UnitPrice><DelievryQTY>0</DelievryQTY><ReturnQty>0</ReturnQty><AveragePrice>0</AveragePrice><CostPrice>362.18</CostPrice><TaxGroupID>0</TaxGroupID><TaxValue>62.82</TaxValue><ItemDiscountValue>0</ItemDiscountValue><ItemDiscountPercentage>0</ItemDiscountPercentage><ItemDiscountType>0</ItemDiscountType><ItemDiscountRate>0</ItemDiscountRate><WarrentyPeriod>0</WarrentyPeriod><IsPercentageForDiscount>false</IsPercentageForDiscount><TaxCostPrice>0</TaxCostPrice><TaxForSellPrice>0</TaxForSellPrice></Temp_InvoiceDetail></InvoiceDetail></Temp_InvoiceHeader>',0
CREATE PROCEDURE [dbo].[SP_CheckQuantityForInv]
    (
      @XMLDetails AS XML ,
      @Count INT OUTPUT

    )
AS
    DECLARE @iDocID INT 
    BEGIN


        DECLARE @LocationID INT ,
            @PropertyID INT 


        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;
        SELECT  [CustomerID] ,
                [InvoiceDate] ,
                [DepartmentID] ,
                [Location] ,
                [TotalValue] ,
                [TotalDiscount] ,
                [ToatlDiscountType] ,
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
                [SubTotal]
        INTO    #TEMPInvoiceHeader
        FROM    OPENXML(@iDocID, 'Temp_InvoiceHeader', 2)
    WITH
    (
        
        [CustomerID] INT,
        [InvoiceDate] DATETIME,
        [DepartmentID] INT,
        [Location] INT,
        [TotalValue] DECIMAL(18, 2),
        [TotalDiscount] DECIMAL(18, 2),
        [ToatlDiscountType] INT,
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
		[TotalPrintDiscount] DECIMAL,
		[SubTotal] DECIMAL
    );


        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;
        SELECT  [ItemID] ,
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
                [ItemDiscountRate] ,
                [IPAddress] ,
                [CreatedUserID] ,
                [LastModUserID] ,
                [CreatedDate] ,
                [LastModDate] ,
                [ItemDiscountPercentage] ,
                [WarrentyPeriod] ,
                [IsPercentageForDiscount] ,
                [TaxCostPrice] ,
                [TaxForSellPrice]
        INTO    #TEMPInvoiceDetail
        FROM    OPENXML(@iDocID, 'Temp_InvoiceHeader/InvoiceDetail/Temp_InvoiceDetail', 2)
    WITH
    (
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
        [ItemDiscountRate] INT,
        [IPAddress] NVARCHAR(MAX),
        [CreatedUserID] INT,
        [LastModUserID] INT,
        [CreatedDate] DATETIME,
        [LastModDate] DATETIME,
		[ItemDiscountPercentage] DECIMAL(18, 2),
	    [WarrentyPeriod] DECIMAL(18, 2),
	    [IsPercentageForDiscount] BIT ,
		[TaxCostPrice] DECIMAL(18,2),
		[TaxForSellPrice] DECIMAL(18,2)
    );

        SELECT  @LocationID = Location ,
                @PropertyID = PropertyID
        FROM    #TEMPInvoiceHeader


		SELECT  *  FROM #TEMPInvoiceHeader
		SELECT  *  FROM #TEMPInvoiceDetail

        SELECT  @Count = COUNT(OD.ItemID)
        FROM    dbo.StockItemDetails SD
                INNER JOIN #TEMPInvoiceDetail OD ON OD.ItemID = SD.StockItemHeaderID
        WHERE   SD.LocationID = @LocationID
                AND SD.PropertyID = @PropertyID
                AND SD.QuantityInHand < OD.QTY


	    SELECT @Count

        EXEC sp_xml_removedocument @iDocID

    END

GO

