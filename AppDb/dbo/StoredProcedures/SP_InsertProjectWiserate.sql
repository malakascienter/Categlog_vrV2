
--         SP_InsertProjectWiserate '<ArrayOfProjectWiseCurrency xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
--         <ProjectWiseCurrency>
--         <IPAddress>::1</IPAddress>
--         <CreatedUserID>1</CreatedUserID>
--         <LastModUserID>1</LastModUserID>
--         <CreatedDate>2018-11-26T09:03:39.491Z</CreatedDate>
--         <LastModDate>2018-11-26T09:03:39.491Z</LastModDate>
--         <ID>0</ID>
--         <ProjectID>3</ProjectID>
--         <Currency>3</Currency>
--         <BaseCurrency>2</BaseCurrency>
--         <ExchangeRate>96</ExchangeRate>
--         </ProjectWiseCurrency><ProjectWiseCurrency>

--         <IPAddress>::1</IPAddress>
--         <CreatedUserID>1</CreatedUserID>
--         <LastModUserID>1</LastModUserID>
--         <CreatedDate>2018-11-26T09:05:44.818Z</CreatedDate>
--         <LastModDate>2018-11-26T09:05:44.818Z</LastModDate>
--         <ID>0</ID>
--         <ProjectID>3</ProjectID>
--         <Currency>6</Currency>
--         <BaseCurrency>0</BaseCurrency>
--         <ExchangeRate>98</ExchangeRate>
--         </ProjectWiseCurrency></ArrayOfProjectWiseCurrency>','',1
--	SP_InsertProjectWiserate '<ArrayOfProjectWiseCurrency xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><ProjectWiseCurrency><IPAddress>::1</IPAddress><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2018-11-27T05:55:55.456Z</CreatedDate><LastModDate>2018-11-27T05:55:55.456Z</LastModDate><ID>0</ID><ProjectID>3</ProjectID><Currency>3</Currency><BaseCurrency>2</BaseCurrency><ExchangeRate>0.0005</ExchangeRate></ProjectWiseCurrency><ProjectWiseCurrency><IPAddress>::1</IPAddress><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2018-11-27T05:56:10.33Z</CreatedDate><LastModDate>2018-11-27T05:56:10.33Z</LastModDate><ID>0</ID><ProjectID>3</ProjectID><Currency>4</Currency><BaseCurrency>0</BaseCurrency><ExchangeRate>0.00048</ExchangeRate></ProjectWiseCurrency></ArrayOfProjectWiseCurrency>','',1
--	SP_InsertProjectWiserate '<ArrayOfProjectWiseCurrency xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><ProjectWiseCurrency><IPAddress>::1</IPAddress><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2018-11-26T09:03:39.491Z</CreatedDate><LastModDate>2018-11-26T09:03:39.491Z</LastModDate><ID>0</ID><ProjectID>3</ProjectID><Currency>3</Currency><BaseCurrency>2</BaseCurrency><ExchangeRate>0.25</ExchangeRate></ProjectWiseCurrency><ProjectWiseCurrency><IPAddress>::1</IPAddress><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2018-11-26T09:05:44.818Z</CreatedDate><LastModDate>2018-11-26T09:05:44.818Z</LastModDate><ID>0</ID><ProjectID>3</ProjectID><Currency>6</Currency><BaseCurrency>0</BaseCurrency><ExchangeRate>0.00098</ExchangeRate></ProjectWiseCurrency></ArrayOfProjectWiseCurrency>','',1
--SP_InsertInvoicePaymentDetails '<ArrayOfInvoicePaymentsDetails xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><InvoicePaymentsDetails><CreatedUserID>0</CreatedUserID><LastModUserID>2</LastModUserID><CreatedDate>2018-08-15T04:35:56.621Z</CreatedDate><LastModDate>2018-08-15T04:35:56.621Z</LastModDate><ID>0</ID><InvoiceHeaderID>6218</InvoiceHeaderID><CnId xsi:nil="true" /><PaymentTypeID>4</PaymentTypeID><TenderedAmount>850</TenderedAmount><ActualAmount>850</ActualAmount><BalanceAmount>100000</BalanceAmount><Remarks /><CheckNumber>0</CheckNumber><BankId>0</BankId><BranchId>0</BranchId><RealizedDate>2018-08-15T00:00:00</RealizedDate></InvoicePaymentsDetails></ArrayOfInvoicePaymentsDetails>','',0,0
CREATE PROCEDURE [dbo].[SP_InsertProjectWiserate]
(
    @XMLDetails AS XML,
    @docID VARCHAR(MAX) OUTPUT,
    @Recipientheaderid INT OUTPUT
)
AS
BEGIN TRY
    BEGIN TRANSACTION;
    DECLARE @iDocID INT;
    EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;
    SELECT *
    INTO #TempPaymentsALL
    FROM
        OPENXML(@iDocID, 'ArrayOfProjectWiseCurrency/ProjectWiseCurrency', 2)
        WITH
        (
            [ProjectID] INT,
            [Currency] INT,
            [BaseCurrency] INT,
            [ExchangeRate] DECIMAL(18, 6),
            [IPAddress] VARCHAR(MAX),
            [CreatedUserID] INT,
            [LastModUserID] INT,
            [CreatedDate] DATETIME,
            [LastModDate] DATETIME
        );

    DECLARE @Num INT;
    SELECT @Num = COUNT(PW.ProjectID)
    FROM dbo.ProjectWiseCurrencies PW
        INNER JOIN #TempPaymentsALL Temp
            ON PW.ProjectID = Temp.[ProjectID]
               AND PW.Currency = Temp.[Currency];
    IF @Num > 0
    BEGIN
        UPDATE dbo.ProjectWiseCurrencies
        SET ProjectID = Temp.ProjectID,
            Currency = Temp.Currency,
            BaseCurrency = Temp.BaseCurrency,
            ExchangeRate = Temp.ExchangeRate,
            IPAddress = Temp.IPAddress,
            CreatedUserID = Temp.CreatedUserID,
            LastModUserID = Temp.LastModUserID,
            CreatedDate = Temp.CreatedDate,
            LastModDate = Temp.LastModDate
        FROM #TempPaymentsALL Temp
        WHERE ProjectWiseCurrencies.ProjectID = Temp.ProjectID
              AND ProjectWiseCurrencies.Currency = Temp.Currency;
    END;
    ELSE IF @Num = 0
    BEGIN
        SELECT @Recipientheaderid = SCOPE_IDENTITY();

        INSERT INTO dbo.ProjectWiseCurrencies
        (
            ProjectID,
            Currency,
            BaseCurrency,
            ExchangeRate,
            IPAddress,
            CreatedUserID,
            LastModUserID,
            CreatedDate,
            LastModDate
        )
        SELECT ProjectID,
               Currency,
               BaseCurrency,
               ExchangeRate,
               IPAddress,
               CreatedUserID,
               LastModUserID,
               CreatedDate,
               LastModDate
        FROM #TempPaymentsALL;
    END;
    EXEC sp_xml_removedocument @iDocID;
    SELECT @Recipientheaderid;

    COMMIT TRAN;
END TRY
BEGIN CATCH
    RETURN CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line '
           + CAST(ERROR_LINE() AS VARCHAR(10));

END CATCH;

GO

