-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--'[dbo].[SP_UpdateJobStatus] 23,'<ArrayOfJobOutputDetailsView xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><JobOutputDetailsView><JobHeaderID>21</JobHeaderID><StockItemHeaderID>56</StockItemHeaderID><Qty>40</Qty><name>A1 PAPER</name><OutputQty>23</OutputQty></JobOutputDetailsView></ArrayOfJobOutputDetailsView>'


-- [dbo].[SP_UpdateJobStatus] 9,'<ArrayOfJobOutputDetailsView ><JobOutputDetailsView><Id>11</Id><JobHeaderID>9</JobHeaderID><StockItemHeaderID>1</StockItemHeaderID><Qty>5</Qty><name>1 sq.mm, 1C,  Cu/PVC/PVC Brown KELANI</name><OutputQty>5</OutputQty><UnitID>1</UnitID></JobOutputDetailsView></ArrayOfJobOutputDetailsView>','<StockTransactionHeader><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2019-10-03T07:01:41.154Z</CreatedDate><LastModDate>2019-10-03T07:01:41.154Z</LastModDate><Id>0</Id><IsPrint>false</IsPrint><IsApproved>false</IsApproved><DocumentNo /><TransactionType>PI</TransactionType><TransactionDate>2019-10-03T07:01:41.154Z</TransactionDate><PropertyID>1</PropertyID><LocationID>1</LocationID><ReferenceNo>J000006</ReferenceNo><SupplierID>-1</SupplierID><ReferenceID>9</ReferenceID><DepartmentID>0</DepartmentID><UserProfileID>1</UserProfileID><TransferLocationID>0</TransferLocationID><TransactionID>3</TransactionID><Mode>R</Mode><SuppCurrencyID>1</SuppCurrencyID><ExchangeRate>0</ExchangeRate><IsTrasferIn>false</IsTrasferIn><StockDetailList><StockTransactionDetail><IPAddress /><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2019-10-03T07:01:41.154Z</CreatedDate><LastModDate>2019-10-03T07:01:41.154Z</LastModDate><Id>0</Id><StockTransactionHeaderID>-1</StockTransactionHeaderID><StockItemID>1</StockItemID><Quantity>5</Quantity><UnitPrice>0</UnitPrice><TxnUnitID>1</TxnUnitID><MasterUnitID>0</MasterUnitID><MasterUnitConversion>0</MasterUnitConversion><ReportUnitID>0</ReportUnitID><ReportUnitConversion>0</ReportUnitConversion><DiscountValue>0</DiscountValue><DiscountPercentage>0</DiscountPercentage><TimeStamp>0</TimeStamp><StockMasterQuantity>0</StockMasterQuantity><StockMasterAveragePrice>0</StockMasterAveragePrice><NewQuantity>0</NewQuantity><NewAveragePrice>0</NewAveragePrice><Remarks /><UserProfileId>1</UserProfileId><CostTransactionAccountID>0</CostTransactionAccountID><PurchaseTransactionAccountID>0</PurchaseTransactionAccountID><TxnType>P</TxnType><BalanceQuantity>0</BalanceQuantity><ReturnQuantity>0</ReturnQuantity><ItemUnitPriceInSuppCurrency>0</ItemUnitPriceInSuppCurrency><TBPHeaderId>0</TBPHeaderId></StockTransactionDetail></StockDetailList></StockTransactionHeader>'

CREATE PROCEDURE [dbo].[SP_UpdateJobStatus]
    @JobheaderID INT,
    @XMLdata XML,
    @XMLdataTran XML
AS
BEGIN

    DECLARE @iDocID INT,
            @iDocID1 INT;

    EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLdata;
    EXEC sp_xml_preparedocument @iDocID1 OUTPUT, @XMLdataTran;

    BEGIN TRY

        BEGIN TRAN;



        SELECT JobHeaderID,
               StockItemHeaderID,
               Qty,
               OutputQty
        INTO #JobOutputDetails
        FROM
            OPENXML(@iDocID, 'ArrayOfJobOutputDetailsView/JobOutputDetailsView', 2)
            WITH dbo.JobOutputDetails;


        SELECT *
        FROM #JobOutputDetails;

        WHILE
        (SELECT COUNT(*) FROM #JobOutputDetails) > 0
        BEGIN



            DECLARE @Stockitemid INT,
                    @outqty DECIMAL(18, 2);

            SELECT TOP (1)
                   @Stockitemid = StockItemHeaderID,
                   @outqty = OutputQty
            FROM #JobOutputDetails;



            UPDATE dbo.JobOutputDetails
            SET OutputQty = OutputQty+@outqty
            WHERE JobHeaderID = @JobheaderID
                  AND StockItemHeaderID = @Stockitemid;


            DELETE FROM #JobOutputDetails
            WHERE StockItemHeaderID = @Stockitemid;


        END;

        EXEC [dbo].[SP_InsertStockTransactions] @XMLdataTran, '', 1, '', 1;



        --select * from JobOutputDetails
        IF ((SELECT COUNT(*) FROM JobOutputDetails WHERE Qty <= OutputQty and JobHeaderID=@JobheaderID) > 0)
        BEGIN
            UPDATE dbo.JobHeaders
            SET Complete = 1
            WHERE ID = @JobheaderID;
        END;


		

        EXEC sp_xml_removedocument @iDocID;
        EXEC sp_xml_removedocument @iDocID1;
        IF @@TRANCOUNT > 0
            COMMIT TRAN;



    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;

    END CATCH;



END;

GO

