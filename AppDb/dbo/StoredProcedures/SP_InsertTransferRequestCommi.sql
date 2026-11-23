
-- [dbo].[SP_InsertTransferRequestCommi] 60
CREATE PROCEDURE [dbo].[SP_InsertTransferRequestCommi]
      @HeaderID INT
AS
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
			@Flag INT,
			@Remarks VARCHAR(200),
			@TransferLocationId INT,
			@CheckUserId INT,
			@HeaderRemark VARCHAR(200),
			@ErrorMsg2 VARCHAR(300),
			@iDocID INT,@Prefix VARCHAR(MAX) ,
            @Len INT ,
            @Code VARCHAR(MAX)


        SELECT  @RequestType = 'RT' ,
                @LocationID = ProductionLocationID ,
                @PropertyID = 1 ,
                @TxnDate = TxnDate ,
                @txnDateDelivery = TxnDate,
				@Flag = 0,
				@TransferLocationId = RequestedLocationID,
				@HeaderRemark = Remarks,
				@CheckUserId = UserID
        FROM CommiTransferHeader
		WHERE ID = @HeaderID
		
		--OPENXML (@iDocID,'/RequestHeader',2)
		--WITH    ( RequestType VARCHAR(2), LocationID INT , PropertyID INT,DepartmentID INT , RequestDate VARCHAR(10) , DeliveryDate VARCHAR(10), Flag INT,TransferLocation INT,Remarks VARCHAR(200),UserProfileID INT)
		

        SELECT @stockItemId = ItemID ,@unitID = UnitID,@Remarks = ''
        FROM CommiTransferDetail
		WHERE CTHeaderID = @HeaderID
		
		--OPENXML (@iDocID,'/RequestHeader/DetailList/RequestDetail',2)
		--WITH   (StockItemID VARCHAR(MAX),UnitID VARCHAR(MAX), Remarks VARCHAR(200))

	
		IF(@CheckUserId = 0)
		BEGIN
			RAISERROR('User ID Invalid, Please Log In Again',16,1)
			ROLLBACK TRANSACTION
		END

		IF( @RequestType = 'RT')
		BEGIN
			DECLARE @StItemId INT, @Unit INT,@TransferUnitId INT,@ItemName VARCHAR(300),@ErrorMsg VARCHAR(300)
			SELECT ItemID,UnitID INTO #tempItems FROM  CommiTransferDetail WHERE CTHeaderID = @HeaderID 
			--OPENXML (@iDocID,'/RequestHeader/DetailList/RequestDetail',2)
			--WITH   (StockItemID VARCHAR(MAX),UnitID VARCHAR(MAX))

			WHILE (SELECT COUNT(*) FROM #tempItems)>0
			BEGIN
				SELECT TOP(1) @StItemId = ItemID, @Unit = UnitID FROM #tempItems
				SELECT @ItemName = Name FROM StockItemHeaders WHERE Id= @StItemId

				--select @StItemId itemId, @TransferLocationId locId
				--SELECT MasterUnitID FROM StockItemDetails WHERE StockItemHeaderID = @StItemId AND LocationID = @TransferLocationId 

				SELECT @TransferUnitId = MasterUnitID FROM StockItemDetails WHERE StockItemHeaderID = @StItemId AND LocationID = @TransferLocationId 
				IF(SELECT  [dbo].[FN_GetUnitConvertionRate] (@PropertyID,@Unit,@TransferUnitId)) = -1
				BEGIN
					RAISERROR('Please set unit conversion value for %s', 16, 1, @ItemName)

					ROLLBACK TRANSACTION
				END
				DELETE TOP(1) FROM #tempItems
			END
		END

        SELECT  @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @LocationID,@RequestType)

        IF @DocumentNo IS NULL
        BEGIN
            INSERT INTO TransactionTypeWiseNextNumbers
                    ( PropertyID ,
                      LocationID ,
                      TransactionType ,
                      NextNumber ,
                      LengthOfFormatting
                    )
            VALUES  ( @PropertyID , @LocationID ,@RequestType ,1 ,6)
        END

        SELECT  @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @LocationID, @RequestType)

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

   

        SELECT  @Prefix = SUBSTRING(@Prefix, 1, 3)

        SET @DocumentNo = @Prefix + '/' + @Code + '/' + @DocumentNo

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
                  DocumentStatus , -- 'A'
                  UserProfileID ,
                  JobNo ,
                  IsApproved , -- 1
                  Remarks ,
                  DepartmentID ,
                  TransferLocation ,
                  DeliveryDate ,
                  JobID,
				  Urgent,
				  Flag,
				  CommiRequestHeaderID,
                  IsSPOBased,
                  SPOId
                )
                SELECT  1 ,
                        ProductionLocationID,
                        'RT',
						8,
                        @DocumentNo ,
                        TxnDate ,
                        'P' ,
                        UserID ,
                        0 ,
                        1 ,
                       --@Remarks ,
					   Remarks,
                        1 ,
                        RequestedLocationId ,
                        @txnDateDelivery ,
                        0,
						0,
						@Flag,
						@HeaderID,
                        IsSPOBased,
                        SPOId
                FROM CommiTransferHeader
				WHERE Id = @HeaderID
				
				--OPENXML (@iDocID,'/RequestHeader',2)
				--WITH RequestHeaders

		SELECT  @RequestHeaderID = SCOPE_IDENTITY()


        INSERT  INTO RequestDetails
                ( RequestHeaderID ,
                  StockItemID ,
                  UnitID ,
                  RequestedQuantity ,
                  IssuedQuantity ,
                  ApprovedQuantity ,
                  --Remarks ,
                  UnitPrice ,
                  InvAccountID
				  --ItemDeliveryDate
                )
         SELECT  @RequestHeaderID ,
                 ItemID ,
                 UnitID ,
                 TransferredQTY ,
                 0 ,
                 ApprovedQty ,
                 --Remarks ,
                 dbo.FN_GetAveragePrice(@PropertyID, @LocationID,ItemID, @RequestType, 0,UnitID, 0) UnitPrice ,
                 0
				 --ItemDeliveryDate
                FROM CommiTransferDetail
				WHERE CTHeaderID = @HeaderID
		--OPENXML (@iDocID,'/RequestHeader/DetailList/RequestDetail',2)
         --WITH RequestDetails

        COMMIT TRAN
    END TRY
   
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @Message NVARCHAR(MAX)
		SET @Message = N'Error Occured: ' + ERROR_MESSAGE() 
		INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)	
		VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())
		RAISERROR(@Message,16,1)
	END CATCH

GO

