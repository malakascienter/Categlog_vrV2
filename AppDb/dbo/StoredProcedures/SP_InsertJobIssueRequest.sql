--SP_InsertRequest '<RequestHeader xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><Id>-1</Id><Flag>0</Flag><Isprint>false</Isprint><PropertyID>1</PropertyID><LocationID>1</LocationID><DepartmentID>2</DepartmentID><TransferLocation>1</TransferLocation><RequestType>RP</RequestType><DocumentNo>1</DocumentNo><RequestDate>2018-06-25T00:00:00</RequestDate><DocumentStatus>P</DocumentStatus><UserProfileID>1</UserProfileID><JobNo>1</JobNo><IsApproved>false</IsApproved><Remarks>oneday</Remarks><TimeStamp>2018-06-25T05:48:28.814Z</TimeStamp><TransactionTypeCode>PR</TransactionTypeCode><DeliveryDate>2018-06-29T00:00:00</DeliveryDate><DetailList><RequestDetail><Id>0</Id><RequestHeaderID>0</RequestHeaderID><StockItemID>207</StockItemID><UnitID>1</UnitID><RequestedQuantity>12</RequestedQuantity><IssuedQuantity>0</IssuedQuantity><ApprovedQuantity>0</ApprovedQuantity><Remarks>added</Remarks><TimeStamp>2018-06-25T05:48:26.255Z</TimeStamp><UnitPrice>0</UnitPrice><InvAccountID>0</InvAccountID></RequestDetail></DetailList></RequestHeader>','',1
--[dbo].[SP_InsertRequest] '<RequestHeader xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><Id>-1</Id><Flag>0</Flag><Isprint>false</Isprint><PropertyID>1</PropertyID><LocationID>1</LocationID><DepartmentID>1</DepartmentID><TransferLocation>2</TransferLocation><RequestType>RT</RequestType><DocumentNo>1</DocumentNo><RequestDate>2019-02-07T04:34:07.29Z</RequestDate><DocumentStatus>P</DocumentStatus><UserProfileID>1</UserProfileID><JobNo>JR000011</JobNo><IsApproved>false</IsApproved><Remarks>oneday</Remarks><TimeStamp>2019-02-07T04:34:07.290Z</TimeStamp><TransactionTypeCode>TR</TransactionTypeCode><DeliveryDate>2019-02-07T04:34:07.29Z</DeliveryDate><JobID>4</JobID></RequestHeader>','',1
--[dbo].[SP_InsertJobIssueRequest] '<RequestHeader xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><Id>-1</Id><Flag>0</Flag><Isprint>false</Isprint><PropertyID>1</PropertyID><LocationID>1</LocationID><DepartmentID>1</DepartmentID><TransferLocation>1</TransferLocation><RequestType>RI</RequestType><DocumentNo>1</DocumentNo><RequestDate>2019-02-14T11:40:01.103Z</RequestDate><DocumentStatus>P</DocumentStatus><UserProfileID>1</UserProfileID><JobNo>1</JobNo><IsApproved>false</IsApproved><Remarks>oneday</Remarks><TimeStamp>2019-02-14T11:40:01.103Z</TimeStamp><TransactionTypeCode>IR</TransactionTypeCode><DeliveryDate>2019-02-14T11:40:01.103Z</DeliveryDate><JobID>28</JobID><DetailList><RequestDetail><Id>0</Id><RequestHeaderID>70</RequestHeaderID><StockItemID>60</StockItemID><UnitID>3</UnitID><RequestedQuantity>100</RequestedQuantity><IssuedQuantity>0</IssuedQuantity><ApprovedQuantity>0</ApprovedQuantity><Remarks /><TimeStamp>2019-02-14T11:40:01.103Z</TimeStamp><UnitPrice>0</UnitPrice><InvAccountID>2</InvAccountID></RequestDetail></DetailList></RequestHeader>','',1
--[dbo].[SP_InsertJobIssueRequest] '<RequestHeader xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><Id>-1</Id><Flag>0</Flag><Isprint>false</Isprint><PropertyID>1</PropertyID><LocationID>1</LocationID><DepartmentID>1</DepartmentID><TransferLocation>1</TransferLocation><RequestType>IN</RequestType><DocumentNo>1</DocumentNo><RequestDate>2019-02-14T12:20:37.286Z</RequestDate><DocumentStatus>P</DocumentStatus><UserProfileID>1</UserProfileID><JobNo>1</JobNo><IsApproved>false</IsApproved><Remarks>oneday</Remarks><TimeStamp>2019-02-14T12:20:37.286Z</TimeStamp><TransactionTypeCode>IR</TransactionTypeCode><DeliveryDate>2019-02-14T12:20:37.286Z</DeliveryDate><JobID>28</JobID><DetailList><RequestDetail><Id>0</Id><RequestHeaderID>70</RequestHeaderID><StockItemID>60</StockItemID><UnitID>3</UnitID><RequestedQuantity>55</RequestedQuantity><IssuedQuantity>0</IssuedQuantity><ApprovedQuantity>0</ApprovedQuantity><Remarks /><TimeStamp>2019-02-14T12:20:37.286Z</TimeStamp><UnitPrice>0</UnitPrice><InvAccountID>2</InvAccountID></RequestDetail></DetailList></RequestHeader>','',1
CREATE PROCEDURE [dbo].[SP_InsertJobIssueRequest]
    (
      @XMLDetails AS XML ,
      @docID VARCHAR(MAX) OUTPUT ,
      @headerid INT OUTPUT
    )
AS
    DECLARE @iDocID INT


    BEGIN TRY
        BEGIN TRANSACTION


        DECLARE @RequestType VARCHAR(2) ,
            @LocationID INT ,
            @PropertyID INT ,
            @DepartmentID INT ,
            @DocumentNo VARCHAR(MAX) ,
            @RequestHeaderID BIGINT ,
            @TransactionTypeID INT ,
            @TxnDate VARCHAR(10) ,
            @stockItemId VARCHAR(MAX) ,
            @unitID VARCHAR(MAX) ,
            @txnDateDelivery VARCHAR(10),
			@UserProfileID INT 
		

        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails


--

        SELECT  @RequestType = RequestType ,
                @LocationID = LocationID ,
                @PropertyID = PropertyID ,
                @TxnDate = RequestDate ,
                @txnDateDelivery = DeliveryDate,
				@UserProfileID=UserProfileID
        FROM    OPENXML (@iDocID,'/RequestHeader',2)
WITH    ( RequestType VARCHAR(2), LocationID INT , PropertyID INT,DepartmentID INT , RequestDate VARCHAR(10) , DeliveryDate VARCHAR(10),UserProfileID INT)


        SELECT  @stockItemId = StockItemID ,
                @unitID = UnitID
        FROM    OPENXML (@iDocID,'/RequestHeader/DetailList/RequestDetail',2)
WITH   (StockItemID VARCHAR(MAX),UnitID VARCHAR(MAX))


       

--select * from TransactionTypes
--update TransactionTypes set code = 'RP' where id =1

        DECLARE @Prefix VARCHAR(MAX) ,
            @Len INT ,
            @Code VARCHAR(MAX) 


			 SELECT @RequestType

IF(@RequestType='RT')

BEGIN



 SELECT  @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID,
                                                           @LocationID,
                                                           @RequestType)

        IF @DocumentNo IS NULL
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
                          @RequestType ,
                          1 ,
                          6
                        )
            END



        SELECT  @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID,
                                                           @LocationID,
                                                           @RequestType)


 


        SELECT  @Prefix = Prefix
        FROM    dbo.Locations
        WHERE   Id = @LocationID
        SELECT  @Code = Code
        FROM    dbo.TransactionTypes
        WHERE   Code = @RequestType

        SELECT  @Code = CASE WHEN @RequestType = 'RP' THEN 'PR'
                             WHEN @RequestType = 'RD' THEN 'DR'
                             WHEN @RequestType = 'RT' THEN 'TR'
                             WHEN @RequestType = 'RI' THEN 'IR'
                        END 

        SELECT  LEN(@Prefix)

        SELECT  @Prefix = SUBSTRING(@Prefix, 1, 3)

        SET @DocumentNo = @Prefix + '/' + @Code + '/' + @DocumentNo

--SELECT * FROM TransactionTypeWiseNextNumbers
        UPDATE  TransactionTypeWiseNextNumbers
        SET     NextNumber = NextNumber + 1
        WHERE   LocationID = @LocationID
                AND TransactionType = @RequestType

        SELECT  @TransactionTypeID = Id
        FROM    TransactionTypes
        WHERE   Code = @RequestType

        INSERT  INTO RequestHeaders
                ( PropertyID ,
                  LocationID ,
                  RequestType ,
                  TransactionTypeCode ,
                  DocumentNo ,
                  RequestDate ,
                  DocumentStatus ,
                  UserProfileID ,
                  JobNo ,
                  IsApproved ,
                  Remarks ,
                  DepartmentID ,
                  TransferLocation ,
                  DeliveryDate ,
                  JobID
                )
                SELECT  PropertyID ,
                        LocationID ,
                        RequestType ,
                        CAST(@TransactionTypeID AS VARCHAR(20)) ,
                        @DocumentNo ,
                        @TxnDate ,
                        DocumentStatus ,
                        UserProfileID ,
                        JobNo ,
                        IsApproved ,
                        Remarks ,
                        DepartmentID ,
                        TransferLocation ,
                        @txnDateDelivery ,
                        JobID
                FROM    OPENXML (@iDocID,'/RequestHeader',2)
WITH RequestHeaders


        SELECT  @RequestHeaderID = SCOPE_IDENTITY()


        INSERT  INTO RequestDetails
                ( RequestHeaderID ,
                  StockItemID ,
                  UnitID ,
                  RequestedQuantity ,
                  IssuedQuantity ,
                  ApprovedQuantity ,
                  Remarks ,
                  UnitPrice ,
                  InvAccountID
                )
                SELECT  @RequestHeaderID ,
                        StockItemID ,
                        UnitID ,
                        SUM(RequestedQuantity ),
                        SUM(ApprovedQuantity ),
                        SUM(ApprovedQuantity ),
                        Remarks ,
                        dbo.FN_GetAveragePrice(@PropertyID, @LocationID,
                                               StockItemID, @RequestType, 0,
                                               UnitID, 0) UnitPrice ,
                        InvAccountID
                FROM    OPENXML (@iDocID,'/RequestHeader/DetailList/RequestDetail',2)
         WITH RequestDetails GROUP BY StockItemID,UnitID,Remarks,InvAccountID,UnitPrice


		 EXEC dbo.SP_InsertApprovalLevelForRequest @PropertyID, @LocationID,
            @TransactionTypeID, @RequestHeaderID


			SET @docID = @DocumentNo
        SET @headerid = @RequestHeaderID

		 END 



		

		 ELSE IF(@RequestType='IN')
		 
		 BEGIN

                SELECT  PropertyID ,
                        LocationID ,
                        RequestType ,
                        CAST(@TransactionTypeID AS VARCHAR(20)) AS TransactionTypeCode ,
                        @DocumentNo AS DocumentNo ,
                        @TxnDate AS RequestDate ,
                        DocumentStatus ,
                        UserProfileID ,
                        JobNo ,
                        IsApproved ,
                        Remarks ,
                        DepartmentID ,
                        TransferLocation ,
                        @txnDateDelivery AS DeliveryDate ,
                        JobID
						INTO #HEADER
                FROM    OPENXML (@iDocID,'/RequestHeader',2)
WITH RequestHeaders


     


        
                SELECT  @RequestHeaderID AS RequestHeaderID,
                        StockItemID ,
                        UnitID ,
                        SUM(RequestedQuantity ) RequestedQuantity,
                        SUM(ApprovedQuantity ) IssuedQuantity,
                        SUM(ApprovedQuantity ) ApprovedQuantity,
                        Remarks ,
                        dbo.FN_GetAveragePrice(@PropertyID, @LocationID,
                                               StockItemID, @RequestType, 0,
                                               UnitID, 0) UnitPrice ,
                        InvAccountID
						INTO #Detail
                FROM    OPENXML (@iDocID,'/RequestHeader/DetailList/RequestDetail',2)
         WITH RequestDetails GROUP BY StockItemID,UnitID,Remarks,InvAccountID,UnitPrice


		 SELECT * FROM #Detail
		 SELECT * FROM #HEADER
		 ----------------------------------------------start here-------------------------------------------------------------------------
		 ---------------------------------------------------------------------------------------------------------------------------------



		 DECLARE @TransactionType VARCHAR(20)=@RequestType,@TxnType VARCHAR(20),@StockTransactionHeaderID INT,@addtionalCostPre DECIMAL(18,2),@addtionalCostTotal DECIMAL(18,2), @Mode VARCHAR(20)='M',@ExchangeRate DECIMAL(18,2)


		 SET @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID,
                                                           @LocationID,
                                                           @TransactionType)

            IF @DocumentNo IS NULL
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
                              @TransactionType ,
                              1 ,
                              6
                            )

                    SET @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID,
                                                              @LocationID,
                                                              @TransactionType)

                END

      

            SELECT  @Prefix = Prefix
            FROM    dbo.Locations
            WHERE   Id = @LocationID
            SELECT  @Code = Code
            FROM    dbo.TransactionTypes
            WHERE   Code = @TransactionType

            SELECT  LEN(@Prefix)

            SELECT  @Prefix = CASE WHEN @TransactionType='GR' THEN SUBSTRING(@Prefix, 1, 2) ELSE SUBSTRING(@Prefix, 1, 3) END


			--SELECT @Prefix

            SET @DocumentNo = @Prefix + '/' + @Code + '/' + @DocumentNo
			--SELECT @DocumentNo
			
            UPDATE  TransactionTypeWiseNextNumbers
            SET     NextNumber = NextNumber + 1
            WHERE   LocationID = @LocationID
                    AND TransactionType = @TransactionType
            PRINT '1'

            SELECT  @txnDate
            INSERT  INTO StockTransactionHeaders
                    ( Mode ,
                      DocumentNo ,
                      TransactionType ,
                      TransactionDate ,
                      LocationID ,
                      PropertyID ,
                      ReferenceNo ,
                      SupplierID ,
                      Remarks ,
                      ReferenceID ,
                      DepartmentID ,
                      UserProfileID ,
                      TransferLocationID ,
                      TransactionID ,
                      SuppCurrencyID ,
                      ExchangeRate ,
                      CreatedUserID ,
                      LastModUserID ,
                      CreatedDate ,
                      LastModDate
                    )
                    ( SELECT    @TxnType ,
                                @DocumentNo ,
                                RequestType ,
                                RequestDate ,
                                LocationID ,
                                PropertyID ,
                                JobNo,
                                1 ,
                                '' ,
                                JobID ,
                                DepartmentID ,
                                UserProfileID ,
                                TransferLocation ,
                                dbo.FN_getTransactionID(RequestType) ,
                                1 ,
                                1 ,
                                UserProfileID ,
                                UserProfileID ,
                                GETDATE() ,
                                GETDATE()

								FROM #HEADER)


								

     
            DECLARE @StockTransactionwiseChangesID BIGINT

            SELECT  @StockTransactionHeaderID = SCOPE_IDENTITY()
            SELECT  @addtionalCostTotal = SUM(ChargeAmount)
            FROM    StockTransactionwiseCharges
            WHERE   StockTransactionHeaderID = @StockTransactionHeaderID
                    AND AddedToItemCost = 1

 

            SELECT  @addtionalCostPre = ( @addtionalCostTotal / SUM(UnitPrice
                                                              * Quantity
                                                              * 1.0000) )
                    * 100.0000
            FROM    OPENXML (@iDocID,'/StockTransactionHeader/StockDetailList/StockTransactionDetail',2)
WITH  StockTransactionDetails

--print '3'
--------------------------------------------------------------

            SET @addtionalCostPre = ISNULL(@addtionalCostPre, 0)

            SET @addtionalCostTotal = ISNULL(@addtionalCostTotal, 0)



            EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails

            INSERT  INTO StockTransactionDetails
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
                      StockMasterQuantity ,
                      StockMasterAveragePrice ,
                      NewQuantity ,
                      NewAveragePrice ,
                      Remarks ,
                      UserProfileId ,
                      CostTransactionAccountID ,
                      PurchaseTransactionAccountID ,
                      TxnType ,
                      ItemUnitPriceInSuppCurrency ,
                      BalanceQuantity ,
                      ReturnQuantity ,
                      CreatedUserID ,
                      LastModUserID ,
                      CreatedDate ,
                      LastModDate
                    )
                    ( SELECT    @StockTransactionHeaderID ,
                                StockItemID ,
                                CASE WHEN @TransactionType = 'AA' AND @Mode <> 'M'
                                     THEN ABS(RequestedQuantity
                                              - dbo.FN_GetStockInHand(@PropertyID,
                                                              @LocationID,
                                                              StockItemID))
                                     ELSE RequestedQuantity
                                END ,
                                UnitPrice + ( UnitPrice * @addtionalCostPre
                                              / 100.000 ) ,
                                UnitID ,
                                ISNULL(dbo.FN_GetMasterUnitID(@PropertyID,
                                                              @LocationID,
                                                              StockItemID), 0) MasterUnitID ,
                                dbo.FN_GetUnitConvertionRate(@PropertyID,
                                                             UnitID,
                                                             dbo.FN_GetMasterUnitID(@PropertyID,
                                                              @LocationID,
                                                              StockItemID)) ,
                                ISNULL(dbo.FN_GetReportingUnitID(@PropertyID,
                                                              @LocationID,
                                                              StockItemID), 0) ,
                                dbo.FN_GetUnitConvertionRate(@PropertyID,
                                                             UnitID,
                                                             dbo.FN_GetReportingUnitID(@PropertyID,
                                                              @LocationID,
                                                              StockItemID)) ,
                                0 ,
                                0 ,
                                dbo.FN_GetStockInHand(@PropertyID, @LocationID,
                                                      StockItemID) StockMasterQuantity ,
                                dbo.FN_GetAveragePrice(@PropertyID,
                                                       @LocationID,
                                                       StockItemID,
                                                       @TransactionType, 0,
                                                       UnitID, 0) ,
                                dbo.FN_GetStockInHand(@PropertyID, @LocationID,
                                                      StockItemID)
                                + CASE WHEN @TransactionType = 'AA' AND @Mode = 'M'
                                       THEN
									   ABS( CASE WHEN ( CASE
                                                              WHEN RequestedQuantity
                                                              - dbo.FN_GetStockInHand(@PropertyID,
                                                              @LocationID,
                                                              StockItemID) > 0
                                                              THEN 'P'
                                                              ELSE 'M'
                                                          END ) = 'M' THEN -1
                                                   ELSE 1
                                              --END * Quantity ) changed this to below to fix reconcilation 2018-12-07
											 END*  (RequestedQuantity
                                                              - dbo.FN_GetStockInHand(@PropertyID,
                                                              @LocationID,
                                                              StockItemID))) 
                                       ELSE 
									   -1 * RequestedQuantity
									   
									 
									   
									   

                                  END NewQuantity ,
                                dbo.FN_GetAveragePrice(@PropertyID,
                                                       @LocationID,
                                                       StockItemID,
                                                       @TransactionType,
                                                       RequestedQuantity, UnitID,
                                                       UnitPrice + ( UnitPrice
                                                              * @addtionalCostPre
                                                              / 100.000 )) ,
                                '' ,
                                0 ,
                                dbo.FN_GetPurchaseCostOfSalesAccountID(StockItemID,
                                                              @LocationID) CostTransactionAccountID ,
                                dbo.FN_GetPurchaseTransactionAccountID(StockItemID,
                                                              @LocationID) PurchaseTransactionAccountID ,
                              
                                      CASE WHEN RequestedQuantity
                                                    - dbo.FN_GetStockInHand(@PropertyID,
                                                              @LocationID,
                                                              StockItemID) > 0
                                               THEN 'P'
                                               ELSE 'M'
                                          END
                                 ,
             --ADDHERE--
			                   ISNULL( CAST(( CASE WHEN @ExchangeRate <= 0 THEN 0
                                            ELSE ( UnitPrice / @ExchangeRate )
                                       END ) AS DECIMAL(18, 2)),0) ,
									   
                                0 ,
                                0 ,
                                @UserProfileID ,
                                @UserProfileID ,
                                GETDATE() ,
                                GETDATE()
                      FROM  #Detail)
				


					 
           CREATE TABLE #ItemList
                (
                  StockItemID BIGINT ,
                  Quantity MONEY ,
                  TxnUnitID INT ,
                  UnitPrice MONEY ,
                  TxnType CHAR(1)
                )

--commented this to fix reconcilation on 06/12/2018

            INSERT  INTO #ItemList    SELECT  StockItemID,RequestedQuantity,UnitID,UnitPrice,'M' FROM  #Detail  


--INSERT INTO #ItemList
--        ( StockItemID ,
--          Quantity ,
--          TxnUnitID ,
--          UnitPrice ,
--          TxnType
--        )
--SELECT StockItemID,Quantity,TxnUnitID,UnitPrice,TxnType FROM dbo.StockTransactionDetails WHERE StockTransactionHeaderID=@StockTransactionHeaderID



            IF OBJECT_ID('tempdb..#TaxTable') IS NOT NULL
                DROP TABLE #TaxTable

            CREATE TABLE #TaxTable
                (
                  TaxTypeId INT ,
                  TaxValue MONEY
                )

            WHILE ( SELECT  COUNT(*)
                    FROM    #ItemList
                  ) > 0
                BEGIN 	

				DECLARE @Quantity DECIMAL(18,2),@unitPrice DECIMAL(18,2),@AveragePrice DECIMAL(18,2),@ReferenceID INT 
                    SELECT TOP ( 1 )
                            @StockItemID = StockItemID ,
                            @unitID = TxnUnitID ,
                            @Quantity = CASE WHEN @TransactionType = 'AA'
                                     THEN ABS(Quantity
                                              - dbo.FN_GetStockInHand(@PropertyID,
                                                              @LocationID,
                                                              StockItemID))
                                     ELSE Quantity
									 end  ,
                            @unitPrice = UnitPrice ,
                            @TxnType = CASE WHEN @TransactionType <> 'AA'
                                     THEN TxnType
                                     ELSE CASE WHEN Quantity
                                                    - dbo.FN_GetStockInHand(@PropertyID,
                                                              @LocationID,
                                                              StockItemID) > 0
                                               THEN 'P'
                                               ELSE 'M'
                                          END
                                END
                    FROM    #ItemList
                    ORDER BY StockItemID

                    DECLARE @TxnCode CHAR(3)

                    SET @TxnCode = CASE WHEN @TransactionType + @TxnType = 'AAM'
                                        THEN @TransactionType + @TxnType
                                        ELSE @TransactionType
                                   END 

                    SET @AveragePrice = dbo.FN_GetAveragePrice(@PropertyID,
                                                              @LocationID,
                                                              @StockItemID,
                                                              @TxnCode,
                                                              @Quantity,
                                                              @unitID,
                                                              @UnitPrice)
			
			   ---added 
			   IF(NOT((@TransactionType='AAM' OR @TransactionType='AA') AND @Mode='M'))
			   BEGIN
                    EXEC SP_UpdateStockItemBalance @PropertyID, @LocationID,
                        @StockItemID, @TxnCode, @Quantity, @unitID,
                        @AveragePrice

			    END 

				  DELETE  FROM #ItemList
                    WHERE   StockItemID = @StockItemID

				   
			
                    
						
                    

                END 

				


            --SELECT  @docID = DocumentNo
            --FROM    dbo.StockTransactionHeaders
            --WHERE   Id = @StockTransactionHeaderID
            --SET @headerid = @StockTransactionHeaderID 



			SET @docID = @DocumentNo
        SET @headerid = @StockTransactionHeaderID





























		 ---------------------------------------------end here-------------------------------------------------------------------------
		

		 END
         
        DECLARE @jobid INT 

		IF(@RequestType='RT')
		BEGIN
        SELECT  @jobid = jobid
        FROM    dbo.RequestHeaders
        WHERE   Id = @RequestHeaderID

		END 



		ELSE 

		BEGIN
		SELECT @jobid=ReferenceID FROM dbo.StockTransactionHeaders WHERE Id=@StockTransactionHeaderID

		end
		 --added to handle jobrequests in Venora--
		 --@jobid is 0 
        IF ( @jobid <> 0 )
            BEGIN

                DECLARE @ItemID INT ,
                    @RequestedQuantity DECIMAL(18, 2),
					@joboutputID INT 
         
                SELECT RequestHeaderID , 
				       StockItemID ,
                       RequestedQuantity
                INTO    #TEMPProcess
                FROM    OPENXML (@iDocID,'/RequestHeader/DetailList/RequestDetail',2)
         WITH RequestDetails

                WHILE ( SELECT  COUNT(*)
                        FROM    #TEMPProcess
                      ) > 0
                    BEGIN

                        SELECT TOP ( 1 )
                                @ItemID = StockItemID ,
                                @RequestedQuantity = RequestedQuantity,@joboutputID=RequestHeaderID
                        FROM    #TEMPProcess 

		
		                IF( @RequestType='RT')
						BEGIN
                        UPDATE  dbo.JobInputDetails
                        SET     RequestQty = RequestQty + @RequestedQuantity
                        WHERE   JobHeaderID = @jobid
                                AND StockItemHeaderID = @ItemID  AND Id=@joboutputID
                        END
                        
						 IF( @RequestType='IN')
						BEGIN
                        UPDATE  dbo.JobInputDetails
                        SET     IssueQty = IssueQty + @RequestedQuantity
                        WHERE   JobHeaderID = @jobid
                                AND StockItemHeaderID = @ItemID  AND Id=@joboutputID
                        end

                        DELETE  FROM #TEMPProcess
                        WHERE   StockItemID = @ItemID
                                AND RequestedQuantity = @RequestedQuantity AND RequestHeaderID=@joboutputID    

                    END 
            END 
		 --end here-------


        
        --EXEC dbo.SP_InsertApprovalLevelForRequest @PropertyID, @LocationID,
        --    @TransactionTypeID, @RequestHeaderID

        COMMIT TRAN -- Transaction Success!
    END TRY
    BEGIN CATCH

	DECLARE @Message VARCHAR(max)

	SELECT @Message=ERROR_MESSAGE()
	
	    RAISERROR(@Message,
               16,
               1 )

       -- RETURN CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN --RollBack in case of Error
    END CATCH



--select  dbo.FN_GetAveragePrice(@PropertyID,@LocationID,@stockItemId,@requestType,0,@unitID,0) 

GO

