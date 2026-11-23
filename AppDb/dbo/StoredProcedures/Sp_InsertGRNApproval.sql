
CREATE PROCEDURE [dbo].[Sp_InsertGRNApproval] (
@XMLDetails XML,
@HeaderOutID INT OUTPUT,
@DocNo VARCHAR(50) OUTPUT,
@BulkDocNoJson NVARCHAR(MAX) = '' OUTPUT  ----------Added by Nivesh 2025-11-07--------------
)
AS
SET XACT_ABORT ON; --added by isuru 2026-10-02 Reason: roll back at once on timeout/error, no open transaction left holding locks
BEGIN

	insert into tempGrnTxn (XmlDATA)
	select convert(varchar(max),  @XMLDetails) 
BEGIN TRY
BEGIN TRANSACTION
    DECLARE @iDocID INT,@iDocIDORG INT, @HeaderId INT, @ApprovedUser INT, @Remarks VARCHAR(250), @Status CHAR(2), 
	@GRNXML VARCHAR(MAX), @NEWGRNXML XML,@NEWGRNXML2 XML, @NEWGRNXML3 XML,@NEWGRNXML4 XML, @ItemId INT,@ItemId2 INT,@UnitPrice DECIMAL(18,6), @TxnType CHAR(2), @Quantity DECIMAL(18,6),@Quantity2 DECIMAL(18,6),
	@TempRowCount INT, @TempRowCount2 INT, @TempDocNo nvarchar(30), @TempPropertyID INT,
        @ReferenceId INT,@ApprovalLevelID INT , @PropertyID INT, @LocationID INT, @UnitPriceSH decimal(18,6) , @UnitPriceGRN decimal(18,6),@IsMailNotification BIT, @headerOut INT, @documentNumber VARCHAR(MAX)
		,@QuantityGRN DECIMAL(18,6),@QuantitySH DECIMAL(18,6),@TxnUnitIdSH INT
		,@TxnUnitIdGRN INT,@IsGRNApprovalModification BIT, @SuppInv VARCHAR(50), @SuppInvDate NVARCHAR(50)

    EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;


        SELECT * INTO #TempGRNHeader FROM
        OPENXML(@iDocID, 'GRNApproval', 2)
        WITH
        (
            HeaderId INT,
            ApprovedUser INT,
            Remarks VARCHAR(250),
            Status CHAR(2),
			ApprovalLevelID INT,
			SuppInv VARCHAR(50),
			SuppInvDate  NVARCHAR(50)
        );


		SELECT * INTO #TempGRNDetails FROM
		OPENXML(@iDocID, '/GRNApproval/ItemWiseUnitPrice/GRNApprovalDetailsModel', 2)
		WITH
		(
			ItemName VARCHAR(250),
			StockItemID INT,
			Unit VARCHAR(250),
			QuantityInHand DECIMAL(18,6),
			GRNQty DECIMAL(18,6),
			UnitPrice DECIMAL(18,6),
			TxnUnitId INT
		);

			SELECT @HeaderId = HeaderId, @ApprovedUser = ApprovedUser, @Remarks = Remarks, @Status = Status, @ApprovalLevelID = ApprovalLevelID, @SuppInv = SuppInv, @SuppInvDate = SuppInvDate    
			FROM #TempGRNHeader

			SELECT @ReferenceId  = ReferenceID,@PropertyID = CompanyId,  @TempDocNo = ApprovalDocNo FROM GRNApprovalLog  WHERE Id = @HeaderId

			SELECT @GRNXML = XMLDetails, @TxnType = TransactionType FROM  [dbo].[GRNApprovalLog] WHERE Id = @HeaderId

			SELECT @IsGRNApprovalModification = ISNULL(IsGRNApprovalModification,0)
			FROM Companies
			WHERE CompanyID = @PropertyID

			SET @NEWGRNXML = CONVERT(XML,@GRNXML)

			EXEC sp_xml_preparedocument @iDocIDORG OUTPUT, @NEWGRNXML;

			SELECT * INTO #TempDetails FROM
			OPENXML(@iDocIDORG, '/StockTransactionHeader/StockDetailList/StockTransactionDetail', 2)
			WITH StockTransactionDetails
			
			
			--added by Isuru 2023-07-13
			SELECT Id as GRNApprovalID
			INTO #TempGRNApproval
			FROM GRNApprovalLog  
			WHERE Id = @HeaderId
			--end
			
			IF EXISTS (
				SELECT 1 
				FROM GRNApprovalLog 
				WHERE Id = @HeaderId 
				AND ApprovalDocNo = @TempDocNo
				AND CompanyId = @PropertyID
				AND Status <> 'P'
				AND TransactionType <> 'IR'
            )
			BEGIN
				RAISERROR('This document has already been updated.', 16, 1)
				RETURN
			END

			--added 2026-10-07
			--Reason: the approval screen could post the item list of a previously viewed document
			--        (slow/overlapping details requests), which then overwrote this document's prices
			--        and quantities for every item both documents share. Reject any item that is not
			--        a line of this document.
			IF EXISTS (
				SELECT 1
				FROM #TempGRNDetails G
				WHERE NOT EXISTS (SELECT 1 FROM #TempDetails D WHERE D.StockItemID = G.StockItemID)
			)
			BEGIN
				RAISERROR('The item details sent do not belong to this document. Please reopen the document and try again.', 16, 1)
				RETURN
			END

			SELECT @IsMailNotification =  ISNULL(IsMailNotification,0)
			FROM TransactionTypes
			WHERE CODE = @TxnType
			            --------------------
            IF(@TxnType ='AA')
            BEGIN
                    SELECT * INTO #TempGRNDetails2 FROM #TempGRNDetails
                    SELECT * INTO #TempDetails2 FROM #TempDetails
                    SET @NEWGRNXML2 = @NEWGRNXML
                    DECLARE @TempDocNoForRec NVARCHAR(50), @TempPropertyIDForRec INT, @tempQTY int
                    SELECT @TempDocNoForRec = ApprovalDocNo, @TempPropertyIDForRec = CompanyId, @LocationID = LocationId FROM  [dbo].[GRNApprovalLog] WHERE Id = @HeaderId
                    WHILE(SELECT COUNT(*) FROM #TempGRNDetails2 ) > 0
                    BEGIN
                            SELECT TOP(1) @ItemId2 = StockItemID, @Quantity2 = GRNQty FROM #TempGRNDetails2;
                            (select TOP(1)  @tempQTY= Quantity from #TempDetails2 WHERE StockItemID= @ItemId2);
                            UPDATE #TempDetails2
                            SET Quantity = @Quantity2,
                            NewQuantity = @Quantity2
                            WHERE StockItemID = @ItemId2;
    -------------------------------------------Insert StockReconciliationLog table-------------------------------------------------------------        
                            INSERT INTO [dbo].[StockReconciliationLog]
                            (ApprovalLogID,ApprovalDocNo,ReceivedQuantity,ApprovedQuantity,UserID,ApprovalLevelID,SeqID,CreatedDate,StockTransactionHeaderID)
                            (select        @HeaderId, @TempDocNoForRec,@tempQTY , @Quantity2,UserProfileId,ApprovalLevelID,SeqID,GETDATE(),StockTransactionHeaderID
                            from [dbo].[GRNApprovalLog] WHERE Id = @HeaderId);
    --------------------------------------------------------------------------------------------------------
                            DELETE TOP(1) FROM  #TempGRNDetails2
                    END
                    DECLARE @newFeatures3 xml;  
                    set  @newFeatures3  =(select * from #TempDetails2 FOR XML PATH('StockTransactionDetail'))
                    SET @NEWGRNXML2.modify('delete /StockTransactionHeader/StockDetailList/StockTransactionDetail')
                    SET @NEWGRNXML2.modify('            
                    insert sql:variable("@newFeatures3")            
                    into (/StockTransactionHeader/StockDetailList)[1] ')      
                                
                    IF EXISTS (SELECT 1 FROM [dbo].[GRNApprovalLog] WHERE Id = @HeaderId)
                    BEGIN
                            UPDATE [dbo].[GRNApprovalLog]
                            SET XMLDetails = (select convert(varchar(max),  @NEWGRNXML2))
                            WHERE ApprovalDocNo=@TempDocNoForRec AND CompanyId=@TempPropertyIDForRec
                    END
                    -----------------
                    TRUNCATE TABLE #TempDetails
                    INSERT INTO #TempDetails SELECT * FROM #TempDetails2
                    ------------------
            END

			            ------------------

			--IF(@TxnType = 'GR')
			--BEGIN
			--	DECLARE @TempDocNoForGR1 NVARCHAR(50), @TempPropertyIDForGR1 INT
			--	DECLARE @SuppInvFromXML VARCHAR(50)

			--	-- Read SuppInv from the incoming approval XML
			--	SELECT @SuppInvFromXML = SuppInv
			--	FROM #TempGRNHeader

			--	print @SuppInvFromXML

			--	SELECT @TempDocNoForGR1 = ApprovalDocNo, 
			--		   @TempPropertyIDForGR1 = CompanyId, 
			--		   @LocationID = LocationId 
			--	FROM [dbo].[GRNApprovalLog] 
			--	WHERE Id = @HeaderId

			--	-- Update ReferenceNo inside the XML (already rebuilt as @NEWGRNXML3)
			--	SET @NEWGRNXML3.modify('replace value of (/StockTransactionHeader/ReferenceNo/text())[1]
			--							with sql:variable("@SuppInvFromXML")')

			--	IF EXISTS (SELECT * FROM [dbo].[GRNApprovalLog] 
			--			   WHERE ApprovalDocNo = @TempDocNoForGR1 AND CompanyId = @TempPropertyIDForGR1)
			--	BEGIN
			--		UPDATE [dbo].[GRNApprovalLog]
			--		SET XMLDetails  = CONVERT(VARCHAR(MAX), @NEWGRNXML3),
			--			ReferenceNo = @SuppInvFromXML        -- also update the column directly
			--		WHERE ApprovalDocNo = @TempDocNoForGR1 
			--		AND CompanyId = @TempPropertyIDForGR1
			--	END
			--END


			IF(@TxnType ='GR')
			
            BEGIN
			--@UnitPriceSH decimal(18,6) , @UnitPriceGRN decimal(18,6)
                    SELECT * INTO #TempGRNDetails3 FROM #TempGRNDetails
                    SELECT * INTO #TempDetails3 FROM #TempDetails
                    SET @NEWGRNXML3 = @NEWGRNXML
                    DECLARE @TempDocNoForGR NVARCHAR(50), @TempPropertyIDForGR INT
                    SELECT @TempDocNoForGR = ApprovalDocNo, @TempPropertyIDForGR = CompanyId, @LocationID = LocationId FROM  [dbo].[GRNApprovalLog] WHERE Id = @HeaderId
                    WHILE(SELECT COUNT(*) FROM #TempGRNDetails3 ) > 0
                    BEGIN
                            SELECT TOP(1) @ItemId2 = StockItemID, @UnitPriceGRN = UnitPrice ,@QuantityGRN = GRNQty,@TxnUnitIdGRN = TxnUnitId
							FROM #TempGRNDetails3;
                            
							(select TOP(1)  @UnitPriceSH = UnitPrice ,@QuantitySH = Quantity,@TxnUnitIdSH = TxnUnitId
							from #TempDetails3 
							WHERE StockItemID= @ItemId2);


                            UPDATE #TempDetails3
                            SET UnitPrice = @UnitPriceGRN
                            WHERE StockItemID = @ItemId2;

							IF(@IsGRNApprovalModification = 1)
							BEGIN
								UPDATE #TempDetails3
								SET Quantity = @QuantityGRN,TxnUnitId = @TxnUnitIdGRN
								WHERE StockItemID = @ItemId2;

							END

							
						
                            DELETE TOP(1) FROM  #TempGRNDetails3

		

                    END
					select * from  #TempDetails3
                    DECLARE @newFeatures4 xml;  
                    set  @newFeatures4  =(select * from #TempDetails3 FOR XML PATH('StockTransactionDetail'))
					select @newFeatures4 newFeatures4
                    SET @NEWGRNXML3.modify('delete /StockTransactionHeader/StockDetailList/StockTransactionDetail')
                    SET @NEWGRNXML3.modify('            
                    insert sql:variable("@newFeatures4")            
                    into (/StockTransactionHeader/StockDetailList)[1] ')					
					SET @NEWGRNXML3.modify('replace value of (/StockTransactionHeader/ReferenceNo/text())[1]
                        with sql:variable("@SuppInv")')
					SET @NEWGRNXML3.modify('replace value of (/StockTransactionHeader/InvoiceDate/text())[1]
                        with sql:variable("@SuppInvDate")')
                       
					
                    IF EXISTS (SELECT * FROM [dbo].[GRNApprovalLog] WHERE ApprovalDocNo = @TempDocNoForGR AND CompanyId=@TempPropertyIDForGR)
                    BEGIN
					select @NEWGRNXML3 NEWGRNXML3
					select @NEWGRNXML NEWGRNXML
                            UPDATE [dbo].[GRNApprovalLog]
                            SET XMLDetails = (select convert(varchar(max),  @NEWGRNXML3)),
							ReferenceNo = @SuppInv
                            WHERE ApprovalDocNo=@TempDocNoForGR AND CompanyId=@TempPropertyIDForGR

							select 1111111,XMLDetails from [GRNApprovalLog] WHERE ApprovalDocNo=@TempDocNoForGR AND CompanyId=@TempPropertyIDForGR
							
                    END

					    -------------------------------------------Insert GRNApprovalDetailsLog table-------------------------------------------------------------        
                           
						   INSERT INTO [dbo].GRNApprovalDetailsLog
                            (GRNApprovalLogID,ApprovalDocNo,GRNPrice,ApprovedPrice,UserID,UserName,SeqID,ApprovalLevelID,ApprovalDate,StockTransactionHeaderID
							,GRNQuantity,ApprovedQuantity,GRNTxnUnitId,ApprovedTxnUnitId)
                            (select   @HeaderId, @TempDocNoForGR ,@UnitPriceSH,@UnitPriceGRN, UserProfileId,'',SeqID,ApprovalLevelID,GETDATE(),StockTransactionHeaderID
							,@QuantitySH,@QuantityGRN,@TxnUnitIdSH,@TxnUnitIdGRN
                            from [dbo].[GRNApprovalLog] WHERE Id = @HeaderId);
    --------------------------------------------------------------------------------------------------------

					--IF EXISTS (SELECT * FROM [dbo].[GRNApprovalLog] WHERE id = @HeaderId)
     --               BEGIN
					--select @NEWGRNXML3 NEWGRNXML3
					--select @NEWGRNXML NEWGRNXML
     --                       UPDATE [dbo].[GRNApprovalLog]
     --                       SET XMLDetails = (select convert(varchar(max),  @NEWGRNXML3))
     --                       WHERE ApprovalDocNo=@TempDocNoForGR AND CompanyId=@TempPropertyIDForRec

					--		select 1111111,XMLDetails from [GRNApprovalLog] WHERE ApprovalDocNo=@TempDocNoForGR AND CompanyId=@TempPropertyIDForRec
							
     --               END
                    -----------------
                    TRUNCATE TABLE #TempDetails
                    INSERT INTO #TempDetails SELECT * FROM #TempDetails3
                    ------------------
            END
			--------------------------------------------------------------------------------------------------------------------------

			WHILE(SELECT COUNT(*) FROM #TempGRNDetails ) > 0
			BEGIN

				SELECT TOP(1) @ItemId = StockItemID , @UnitPrice = UnitPrice, @Quantity = GRNQty FROM #TempGRNDetails

			
				---------------------
				IF(@Status  = 'X')
					BEGIN
						------------------------------------------------------------------------------------------------------------------------
						IF @TxnType='GR'
						BEGIN

							UPDATE PoDetails
							SET ReceivedQuantity = ReceivedQuantity - @Quantity 
							WHERE PoHeaderID = @ReferenceId AND StockItemID = @ItemId;

							-- Commented by Isuru 2024-10-16 for allowing re-use PO if grn cancelled
							--UPDATE PoHeaders
							--SET DocumentStatus = 'X'
							--WHERE Id = @ReferenceId;

							-- added by Isuru 2024-10-16 for allowing re-use PO if grn cancelled
							UPDATE PoHeaders
							SET DocumentStatus = 'P'
							WHERE Id = @ReferenceId;
							
							----------------------- 14.06.2024 vinuki -----------------------------------------------------
							UPDATE GRNApprovalLog
							SET Status = 'X' , ApprovedUserId = @ApprovedUser , Remarks = @Remarks , ApprovedDateTime = GETDATE()
							WHERE Id =  @HeaderId AND ApprovalDocNo = @TempDocNo
							AND CompanyId = @PropertyID

							SELECT @TempDocNo = ApprovalDocNo
							FROM GRNApprovalLog
							WHERE id = @HeaderId

							if exists ( select * from GRNApprovalLog where ApprovalDocNo = @TempDocNo and SeqID = 1 and Status = 'P' AND CompanyId = @PropertyID)
							begin
									update GRNApprovalLog
									set Status = 'X', Remarks = @Remarks , ApprovedDateTime = GETDATE()
									where ApprovalDocNo = @TempDocNo
									AND CompanyId = @PropertyID

							end 
							-----------------------------------------------------------------------------------------------
				------------------------------------------------------------------------------------------------------------------------

						END
						IF @TxnType='SR'
						BEGIN
							SELECT 'UPDATED --- 1'
							UPDATE StockTransactionDetails
							SET ReturnQuantity = ReturnQuantity- @Quantity
							WHERE StockTransactionHeaderID = @ReferenceID
							AND StockItemID = @ItemId;

						END
						IF(@TxnType = 'IR')
						BEGIN
							UPDATE StockTransactionDetails
							SET ReturnQuantity = ReturnQuantity- @Quantity
							WHERE StockTransactionHeaderID = @ReferenceID
							AND StockItemID = @ItemId;


							UPDATE ApprovalLogs
							SET DocStatus = 'X', IsComplete = 1,ApprovalUserID =  @ApprovedUser
							WHERE TransactionID = 7 AND TransactionHeaderID = @HeaderId
						END
					END

				------------------------
				
				UPDATE #TempDetails 
				SET UnitPrice = @UnitPrice WHERE StockItemID = @ItemId

				DELETE TOP(1) FROM  #TempGRNDetails
			END


			DECLARE @newFeatures xml;  

			DECLARE @newFeatures2 xml;

			set  @newFeatures  =(select * from #TempDetails FOR XML PATH('StockTransactionDetail'))


			set  @newFeatures2  =(select * from #TempGRNApproval FOR XML PATH('GRNApprovalDetails'))

			SET @NEWGRNXML.modify('delete /StockTransactionHeader/StockDetailList/StockTransactionDetail') 

			SET @NEWGRNXML.modify('delete /StockTransactionHeader/GRNApprovalDetails') 

			SET @NEWGRNXML.modify('             
			insert sql:variable("@newFeatures")             
			into (/StockTransactionHeader/StockDetailList)[1] ')       
			
			SET @NEWGRNXML.modify('             
			insert sql:variable("@newFeatures2")             
			into (/StockTransactionHeader)[1] ')    
		 
			IF(@TxnType <>'AA')
			BEGIN
				UPDATE GRNApprovalLog SET Remarks = @Remarks , Status = @Status , ApprovedUserId = @ApprovedUser,ApprovedDateTime = GETDATE()
				WHERE Id = @HeaderId
			END --Modified by Nivesh 2024-07-16
			
		    -------------------------------------Added by Nivesh 2024-03-01----------------------------------------------
            DECLARE @TempDocNoForRecon VARCHAR(50), @TempPropertyIDForRecon INT, @TempSeqNum INT, @TempLevelNo INT, @TempLocationID INT
            SELECT @TempDocNoForRecon = ApprovalDocNo ,@TempPropertyIDForRecon = CompanyId, @TempSeqNum = SeqID,@TempLevelNo = ApprovalLevelID,
			@TempLocationID = LocationId	 FROM GRNApprovalLog WHERE Id = @HeaderId
            IF(@TxnType ='AA' AND @Status='X')
            BEGIN
                    UPDATE GRNApprovalLog SET Remarks = @Remarks , Status = @Status , ApprovedUserId = @ApprovedUser,ApprovedDateTime = GETDATE(),IsComplete =1
                    WHERE ApprovalDocNo = @TempDocNoForRecon AND CompanyId =@TempPropertyIDForRecon
            END
            ELSE
            BEGIN
                    --UPDATE GRNApprovalLog SET Remarks = @Remarks , Status = @Status , ApprovedUserId = @ApprovedUser,ApprovedDateTime = GETDATE()
                    --WHERE Id = @HeaderId
					UPDATE GRNApprovalLog SET Remarks = @Remarks , Status = @Status , ApprovedUserId = @ApprovedUser,ApprovedDateTime = GETDATE()
                    WHERE ApprovalDocNo = @TempDocNoForRecon AND CompanyId =@TempPropertyIDForRecon AND  LocationId =@TempLocationID AND
					SeqID =@TempSeqNum AND  ApprovalLevelID=@TempLevelNo --Modified by Nivesh 2024-07-16
            END
            -----------------------------------------------------------------------------------
			IF(@Status = 'C')
		
			BEGIN
				IF(@TxnType = 'IR')
				BEGIN
					Update ApprovalLogs
					SET DocStatus = 'C', IsComplete = 1, ApprovalUserID = @ApprovedUser
					WHERE TransactionID = 7 AND TransactionHeaderID = @HeaderId AND ApprovalLevelID = @ApprovalLevelID

					IF (SELECT COUNT(*) FROM ApprovalLogs 
					WHERE TransactionID = 7 AND TransactionHeaderID = @HeaderId 
					AND DocStatus <> 'C' ) = 0

					-- Insert stock transactions and return HeaderId and DocNo ( 2025/11/04 - Ravindu ) --

						EXEC SP_InsertStockTransactions @NEWGRNXML,@documentNumber OUTPUT,0,'',@headerOut OUTPUT,1

						SET @HeaderOutID = @headerOut;
                        SET @DocNo = @documentNumber;
						--Added by Isuru 2026-05-14 to Update IR doc id

						UPDATE GRNApprovalLog
						SET StockTransactionHeaderID = @headerOut
						WHERE ApprovalDocNo = @TempDocNo
						AND CompanyId = @PropertyID
						AND TransactionType = 'IR'
						--End
				END
				ELSE
			------------------------------------------------

			--======================================================================================================================================================
				------------------------------------ 13.06.2024 VINUKI -----------------------------------------------------
				 IF (@TxnType = 'GR')
				BEGIN
				
			
				SELECT @TempDocNo = ApprovalDocNo
				FROM GRNApprovalLog
				WHERE id = @HeaderId
				
				
				IF(@Status  = 'C')
				BEGIN




				UPDATE GRNApprovalLog
				SET Status = 'C' , ApprovedUserId = @ApprovedUser , Remarks = @Remarks , ApprovedDateTime = GETDATE()
				WHERE Id =  @HeaderId AND ApprovalDocNo = @TempDocNo
				AND CompanyId = @PropertyID
				

				declare @TempGRNSeqNo int

				SELECT @TempGRNSeqNo = SeqID
				FROM GRNApprovalLog
				WHERE id = @HeaderId

			
				------------------------------------14.06.2024 Vinuki ------------------------------------------------------------------------------------------------------
				-- this code piece checks if the approved grnapproval log data has another data with the same sequence id and if its pending and if so it becomes completed -	
				if exists ( select * from GRNApprovalLog where ApprovalDocNo = @TempDocNo and SeqID = @TempGRNSeqNo and Status = 'P' AND CompanyId = @PropertyID)
				begin
				
					update GRNApprovalLog
					set Status = 'C' ,ApprovedUserId = @ApprovedUser,ApprovedDateTime = GETDATE()
					where ApprovalDocNo = @TempDocNo and SeqID = @TempGRNSeqNo
					AND CompanyId = @PropertyID and Status = 'P' -- CompanyId Added by Isuru 2025-02-03 to prevent updating other properties Documents

				end 
				-------------------------------------------------------------------------------------------------------------------------------------------------------------
				end
					SELECT @TempDocNo = ApprovalDocNo,@TempPropertyID = CompanyId FROM GRNApprovalLog WHERE ID= @HeaderId
					SELECT @TempRowCount = COUNT(ID) FROM GRNApprovalLog WHERE ApprovalDocNo = @TempDocNo AND CompanyId = @TempPropertyID
						SELECT @TempRowCount TempRowCount
					SELECT @TempRowCount2= COUNT(ID) FROM GRNApprovalLog WHERE ApprovalDocNo = @TempDocNo AND Status ='C' AND CompanyId = @TempPropertyID
					SELECT @TempRowCount2 TempRowCount2
					IF(@TempRowCount=@TempRowCount2)
					BEGIN
					
					

					------------------- 2026-04-22 Added by Tharuka for Upadte Approve GRN refernce number ---------------------

					SET @NEWGRNXML.modify('replace value of (/StockTransactionHeader/ReferenceNo/text())[1]
                        with sql:variable("@SuppInv")')
					SET @NEWGRNXML.modify('replace value of (/StockTransactionHeader/InvoiceDate/text())[1]
                        with sql:variable("@SuppInvDate")')

					-------------------------------------------------------------------------------------------------------------

					
						EXEC SP_InsertStockTransactions @NEWGRNXML,@documentNumber OUTPUT,0,'',@headerOut OUTPUT,1, 0,@BulkDocNoJson OUTPUT

						 SET @HeaderOutID = @headerOut;
                         SET @DocNo = @documentNumber;

					END
				END
				-------------------------------------------------------------------------------------------------------------
				--======================================================================================================================================================
				ELSE IF(@TxnType = 'AA')
				BEGIN
					SELECT @TempDocNo = ApprovalDocNo,@TempPropertyID = CompanyId FROM GRNApprovalLog WHERE ID= @HeaderId
					SELECT @TempRowCount = COUNT(ID) FROM GRNApprovalLog WHERE ApprovalDocNo = @TempDocNo AND CompanyId = @TempPropertyID
						
					SELECT @TempRowCount2= COUNT(ID) FROM GRNApprovalLog WHERE ApprovalDocNo = @TempDocNo AND Status ='C' AND CompanyId = @TempPropertyID

					IF(@TempRowCount=@TempRowCount2)
					BEGIN

					-- Insert stock transactions and return HeaderId and DocNo ( 2025/11/03 - Ravindu ) --
					
						EXEC SP_InsertStockTransactions @NEWGRNXML,@documentNumber OUTPUT,0,'',@headerOut OUTPUT,1

						SET @HeaderOutID = @headerOut;
                        SET @DocNo = @documentNumber;
					END

				END
			------------------------------------------------
				--========================================================================================================================================================
			----------------------------------------------------- ADDED BY VINUKI 18.06.2024 ----------------------------------------------------------------------------
				ELSE IF (@TxnType = 'SR')
				BEGIN
				
				SELECT @TempDocNo = ApprovalDocNo
				FROM GRNApprovalLog
				WHERE id = @HeaderId
				
				
				IF(@Status  = 'C')
				begin
				UPDATE GRNApprovalLog
				SET Status = 'C' , ApprovedUserId = @ApprovedUser , Remarks = @Remarks , ApprovedDateTime = GETDATE()
				WHERE Id =  @HeaderId AND ApprovalDocNo = @TempDocNo
				AND CompanyId = @PropertyID
				

				declare @TempSRNSeqNo int
		

				SELECT @TempSRNSeqNo = SeqID
				FROM GRNApprovalLog
				WHERE id = @HeaderId

				SELECT @TempSRNSeqNo TempSRNSeqNo
				select @TempDocNo TempDocNo
			
				------------------------------------18.06.2024 Vinuki ------------------------------------------------------------------------------------------------------
				-- this code piece checks if the approved grnapproval log data has another data with the same sequence id and if its pending and if so it becomes completed -	
				if exists ( select * from GRNApprovalLog where ApprovalDocNo = @TempDocNo and SeqID = @TempSRNSeqNo and Status = 'P' AND CompanyId = @PropertyID)
				begin
					update GRNApprovalLog
					set Status = 'C' ,ApprovedUserId = @ApprovedUser ,ApprovedDateTime = GETDATE()
					where ApprovalDocNo = @TempDocNo and SeqID = @TempSRNSeqNo
					and Status = 'P' AND CompanyId = @PropertyID -- CompanyId Added by Isuru 2025-02-03 to prevent updating other properties Documents

				end 
				-------------------------------------------------------------------------------------------------------------------------------------------------------------
				end
					SELECT @TempDocNo = ApprovalDocNo,@TempPropertyID = CompanyId FROM GRNApprovalLog WHERE ID= @HeaderId
					SELECT @TempRowCount = COUNT(ID) FROM GRNApprovalLog WHERE ApprovalDocNo = @TempDocNo AND CompanyId = @TempPropertyID
						SELECT @TempRowCount TempRowCount
					SELECT @TempRowCount2= COUNT(ID) FROM GRNApprovalLog WHERE ApprovalDocNo = @TempDocNo AND Status ='C' AND CompanyId = @TempPropertyID
					SELECT @TempRowCount2 TempRowCount2
					IF(@TempRowCount=@TempRowCount2)
					BEGIN
					
					-- Insert stock transactions and return HeaderId and DocNo ( 2025/11/04 - Ravindu ) --
						EXEC SP_InsertStockTransactions @NEWGRNXML,@documentNumber OUTPUT,0,'',@headerOut OUTPUT,1

						SET @HeaderOutID = @headerOut;
						SET @DocNo = @documentNumber;
					END
				END

				-------------------------------------------------------------------------------------------------------------------------------------------------------------
				--========================================================================================================================================================
				else IF(@TxnType <> 'AA')
				
				BEGIN

				    -- Insert stock transactions and return HeaderId and DocNo ( 2025/11/04 - Ravindu ) --
				
					EXEC SP_InsertStockTransactions @NEWGRNXML,@documentNumber OUTPUT,0,'',@headerOut OUTPUT,1

					SET @HeaderOutID = @headerOut;
					SET @DocNo = @documentNumber;
				END
			END

			--Added by Isuru 2024-09-10 for sending approval mail
			IF(@IsMailNotification=1)
			BEGIN
				DECLARE @Email VARCHAR(MAX),@EmailBody VARCHAR(MAX), @CompanyName VARCHAR(200), @LocationName VARCHAR(200), @RequestedUser VARCHAR(200),@DocumentNo VARCHAR(20),@TransactionName VARCHAR(MAX)

				SELECT @TransactionName = Name
				FROM TransactionTypes
				WHERE CODE = @TxnType
				
				SELEct @RequestedUser=CU.UserName, @LocationName=LO.Name,@CompanyName=CO.Name,@DocumentNo = GR.ApprovalDocNo
				FROM GRNApprovalLog GR
				INNER JOIN Locations LO ON LO.ID = GR.LocationId
				INNER JOIN Companies CO ON CO.CompanyID = GR.CompanyId
				INNER JOIN CentralUsers CU ON CU.Id = GR.CreatedUserId
				WHERE GR.ApprovalDocNo = @TempDocNo AND TransactionType = @TxnType
				AND GR.CompanyId = @PropertyID

				SELECT TOP(1)@Email =  US.Email
				FROM GRNApprovalLog AS GR
				INNER JOIN TransactionTypes TR ON GR.TransactionType = TR.Code
				 INNER JOIN dbo.UserWiseApproveLevels AS UAL ON TR.Id = UAL.TransactionTypeID AND GR.LocationID = UAL.LocationId
				           AND GR.CompanyId = UAL.PropertyId AND GR.ApprovalLevelID = UAL.ApproveLevelID
				    INNER JOIN CentralUsers AS US ON US.Id = GR.UserProfileId
				WHERE GR.TransactionType = @TxnType AND GR.SendMail = 0  
				AND GR.ApprovalDocNo = @TempDocNo
					AND GR.CompanyId = @PropertyID
				ORDER BY GR.SeqID ASC;

				--Added by Isuru 2024-05-22 for sending multiplle users with approval mail
				DECLARE @SeqID INT

			

				SELECT TOP(1)@SeqID= AL.SeqID
				FROM GRNApprovalLog AL
				INNER JOIN TransactionTypes TR ON AL.TransactionType = TR.Code
				WHERE TR.Code= @TxnType AND AL.ApprovalDocNo = @TempDocNo AND AL.SendMail = 0 AND AL.Status = 'P'
				AND AL.CompanyId = @PropertyID
				ORDER BY AL.SeqID ASC;
		
				SELECT DISTINCT US.Email,GR.UserProfileId
				into #TempEmail
				FROM GRNApprovalLog AS GR
				INNER JOIN TransactionTypes TR ON GR.TransactionType = TR.Code
				 INNER JOIN dbo.UserWiseApproveLevels AS UAL ON TR.Id = UAL.TransactionTypeID AND GR.LocationID = UAL.LocationId
				           AND GR.CompanyId = UAL.PropertyId AND GR.ApprovalLevelID = UAL.ApproveLevelID
				    INNER JOIN CentralUsers AS US ON US.Id = GR.UserProfileId
				WHERE GR.TransactionType = @TxnType AND GR.SendMail = 0  
				AND GR.ApprovalDocNo= @DocumentNo AND GR.SeqID=@SeqID
					AND GR.CompanyId = @PropertyID
				---END

				SET @EmailBody = '<html><body><p>You have to respond a pending approval</p>
						  <table border = 1>
						  <thead>
							  <th  style="width: 20%" >Approval type</th>
							  <th  style="width: 20%" >Document Number</th>
							  <th  style="width: 20%" >Company Name</th>
							  <th  style="width: 20%" >Location Name</th>
							  <th  style="width: 20%" >Requested User</th>
						  </thead>
						  <tbody >
							<tr>
							 <td  style="width: 20%" >'+@TransactionName+'</td>
							 <td  style="width: 20%" >'+@DocumentNo+'</td>
							 <td  style="width: 20%" >'+@CompanyName+'</td>
							 <td  style="width: 20%" >'+@LocationName+'</td>
							 <td  style="width: 20%" >'+@RequestedUser+'</td>
				            </tr>
						  </tbody>
						  </table></html></body>'

				IF @Email IS NOT NULL OR @Email  <> ''
				BEGIN

					DECLARE @NewEmail VARCHAR(MAX),@NewApprovalUserID INT,@MailSubject VARCHAR(MAX)
					SELECT @MailSubject = CONCAT(@TransactionName, ' Approval') 

					WHILE EXISTS(SELECT 1  FROM #TempEmail)
					BEGIN
						SELECT TOP(1) @NewEmail= EMAIL,@NewApprovalUserID =UserProfileId  FROM #TempEmail

						EXEC [dbo].[SendReuestMail] @NewEmail, @MailSubject, @EmailBody, 2

						;WITH CTE AS (
					SELECT TOP 1 GR.SeqID
					FROM GRNApprovalLog AS GR
					INNER JOIN TransactionTypes TR ON GR.TransactionType = TR.Code
					INNER JOIN dbo.UserWiseApproveLevels AS UAL ON TR.Id = UAL.TransactionTypeID AND GR.LocationID = UAL.LocationId
					AND GR.CompanyId = UAL.PropertyId AND GR.ApprovalLevelID = UAL.ApproveLevelID
					AND GR.ApprovalDocNo = @DocumentNo
					 INNER JOIN CentralUsers AS US ON US.Id = GR.UserProfileId
					WHERE GR.TransactionType = @TxnType
						AND GR.Status = 'P'
						AND GR.SeqID=@SeqID
						AND GR.UserProfileId=@NewApprovalUserID
						AND GR.CompanyId = @PropertyID
					ORDER BY GR.SeqID ASC
					)
					UPDATE AL
					SET AL.SendMail = 1
					FROM GRNApprovalLog AS AL
					INNER JOIN CTE ON AL.SeqID = CTE.SeqID
					WHERE AL.ApprovalDocNo =@DocumentNo
					AND AL.CompanyId = @PropertyID;

						DELETE TOP(1) FROM #TempEmail
					END
					DROP TABLE #TempEmail
				END

			END

			--end
COMMIT TRANSACTION
END TRY
BEGIN CATCH



	-- 2026-08-05 Tharuka
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	DECLARE @ErrorMessage NVARCHAR(4000);
	DECLARE @ErrorSeverity INT;  
	DECLARE @ErrorState INT;  

	SELECT
    @ErrorMessage = ERROR_MESSAGE(),
    @ErrorSeverity = ERROR_SEVERITY(),
    @ErrorState = ERROR_STATE();

	-- 2026-08-05: replaced by the THROW below.
	-- RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);

	THROW;
END CATCH

END

GO

