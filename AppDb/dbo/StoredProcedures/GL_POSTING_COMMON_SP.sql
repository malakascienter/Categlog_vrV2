


CREATE PROCEDURE [dbo].[GL_POSTING_COMMON_SP] (@CurrDate AS DATE, @DayEndUserID AS UniqueIdentifier, @PropertyID AS INT, @BlockCode AS VARCHAR(4) = '', @DocNo AS VARCHAR(20) ='' )

AS
BEGIN

	SET DATEFORMAT DMY

	--DECLARE @RCount AS INT = 0
	--DECLARE @Count AS INT = 0
	DECLARE @TempTxnNo AS VARCHAR(13)
	DECLARE @ModName AS VARCHAR(1)
	DECLARE @TransType AS VARCHAR(2)
	DECLARE @OutputReq AS VARCHAR(MAX)
	DECLARE @OutputReqD AS VARCHAR(MAX)
	DECLARE @TxnID AS VARCHAR(1)
	DECLARE @GLCompCode AS VARCHAR(3)
	DECLARE @MasterID AS VARCHAR(5)

	DECLARE @GET_ITEM_CATEGORY_REVENUE AS CHAR(1) = 'N' -- Serendib:Y, Jetwing:N

	DECLARE @GET_ROOM_CATEGORY_REVENUE AS CHAR(1) = 'Y' -- Serendib:N, Jetwing:Y

	DECLARE @GL_POST_FROM_SP AS CHAR(1) = 'Y' -- Serendib:N, Jetwing:Y

	
	BEGIN TRY DROP TABLE #Blocks END TRY
	BEGIN CATCH END CATCH

	BEGIN TRY DROP TABLE #PostToGL END TRY
	BEGIN CATCH END CATCH


	--IF NOT EXISTS (
		
	--	SELECT * FROM eFinancials_Accounting.INFORMATION_SCHEMA.COLUMNS	WHERE TABLE_NAME = 'Settings' AND COLUMN_NAME = 'API_Credentials')
	
	--BEGIN
	
	--	ALTER TABLE eFinancials_Accounting.dbo.Settings ADD API_Credentials VARCHAR(100) NOT NULL DEFAULT '192.168.3.123:1001'
	
	--END;


	--SET @DayEndUserID = 'B490B26A-2886-4671-8253-A8644C76660F'
	--SET @MasterID = '00001'

	SELECT @GLCompCode = GLCompCode FROM Properties WHERE Id = @PropertyID
	SELECT @MasterID = MasterID FROM eFinancials_Accounting.dbo.MASTER WHERE MultiCompanyCode = @GLCompCode

	IF @BlockCode = '' AND @DocNo = '' BEGIN
		
		SELECT Blockcode 
		INTO #Blocks 
		FROM eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMappingBlocks 
		WHERE ACTIVE = 1 AND POSTATDAYEND = 1

		SELECT TOP(1) @Blockcode = Blockcode FROM #Blocks

		WHILE @@ROWCOUNT > 0

		BEGIN

			IF @BlockCode = 'ADV' BEGIN -- Reservation Advances

				--EXEC [GL_POSTING_FO_ADVANCE_RECEIVED_RESERVATION] @CurrDate, @DayEndUserID, @PropertyID, @GLCompCode --GL ONLY

				--EXEC [GL_POSTING_FO_ADVANCE_RECEIVED_INHOUSE] @CurrDate, @DayEndUserID, @PropertyID, @GLCompCode --GL ONLY

				EXEC [GL_POSTING_FO_ADVANCE_RECEIVED_RESERVATION_CREDITCARD] @CurrDate, @DayEndUserID, @PropertyID, @GLCompCode

				EXEC [GL_POSTING_FO_ADVANCE_RECEIVED_RESERVATION_GENERAL] @CurrDate, @DayEndUserID, @PropertyID, @GLCompCode
				
				EXEC [GL_POSTING_FO_ADVANCE_RECEIVED_INHOUSE_CREDITCARD] @CurrDate, @DayEndUserID, @PropertyID, @GLCompCode

				EXEC [GL_POSTING_FO_ADVANCE_RECEIVED_INHOUSE_GENERAL] @CurrDate, @DayEndUserID, @PropertyID, @GLCompCode

				EXEC [GL_POSTING_FO_ADVANCE_REFUND_RESERVATION] @CurrDate, @DayEndUserID, @PropertyID, @GLCompCode

				EXEC [GL_POSTING_FO_ADVANCE_REFUND_INHOUSE] @CurrDate, @DayEndUserID, @PropertyID, @GLCompCode

			END
			
			ELSE IF @BlockCode = 'POA' BEGIN -- Accomodation Revenue Posting

				IF @GET_ROOM_CATEGORY_REVENUE = 'Y' BEGIN

					EXEC [GL_POSTING_FO_ROOM_CHARGE_ROOMCATEGORY] @CurrDate, @DayEndUserID, @PropertyID, @GLCompCode

				END

				ELSE BEGIN

					EXEC [GL_POSTING_FO_ROOM_CHARGE] @CurrDate, @DayEndUserID, @PropertyID, @GLCompCode

				END

			END

			ELSE IF @BlockCode = 'POM' BEGIN -- Other Revenue Posting

				EXEC [GL_POSTING_FO_EXTRA_POSTINGS] @CurrDate, @DayEndUserID, @PropertyID, @GLCompCode

				EXEC [GL_POSTING_FO_EXTRA_POSTINGS_REBATE] @CurrDate, @DayEndUserID, @PropertyID, @GLCompCode

				EXEC [GL_POSTING_FO_EXTRA_POSTINGS_DISCOUNT] @CurrDate, @DayEndUserID, @PropertyID, @GLCompCode

				EXEC [GL_POSTING_FO_EXTRA_POSTINGS_DEBITNOTE] @CurrDate, @DayEndUserID, @PropertyID, @GLCompCode

				EXEC [GL_POSTING_FO_EXTRA_POSTINGS_CREDITNOTE] @CurrDate, @DayEndUserID, @PropertyID, @GLCompCode

				--EXEC [GL_POSTING_FO_EXTRA_POSTINGS_LAUNDARY] @CurrDate, @DayEndUserID, @PropertyID, @GLCompCode

			END

			ELSE IF @BlockCode = 'INS' BEGIN -- Main Bill Settlement

				EXEC [GL_POSTING_FO_MAIN_BILL_SETTLEMENT] @CurrDate, @DayEndUserID, @PropertyID, @GLCompCode

			END

			ELSE IF @BlockCode = 'ORS' BEGIN -- Outlet Revenue Posting

			

				IF @GET_ITEM_CATEGORY_REVENUE <> 'Y' BEGIN

					EXEC [GL_POSTING_FE_RESTAURANT_SALE] @CurrDate, @DayEndUserID, @PropertyID, @GLCompCode
				
				END

				ELSE BEGIN

					EXEC [GL_POSTING_FE_RESTAURANT_SALE_ITEMCATEGORY] @CurrDate, @DayEndUserID, @PropertyID, @GLCompCode

				END

				EXEC [GL_POSTING_FE_RESTAURANT_SALE_GENERAL] @CurrDate, @DayEndUserID, @PropertyID, @GLCompCode

				EXEC [GL_POSTING_FE_RESTAURANT_SALE_CREDITCARD] @CurrDate, @DayEndUserID, @PropertyID, @GLCompCode
				
			END

			ELSE IF @BlockCode = 'OCS' BEGIN -- Outlet COS Posting
			
				IF @GET_ITEM_CATEGORY_REVENUE <> 'Y' BEGIN

					EXEC [GL_POSTING_FE_RESTAURANT_COMPLEMENTARY_GENERAL] @CurrDate, @DayEndUserID, @PropertyID, @GLCompCode
				
				END

				ELSE BEGIN

					EXEC [GL_POSTING_FE_RESTAURANT_COMPLEMENTARY_ITEMCATEGORY] @CurrDate, @DayEndUserID, @PropertyID, @GLCompCode
				
				END

			END

			ELSE IF @BlockCode = 'FCE' BEGIN -- Foreign Currency Encashment

				EXEC [GL_POSTING_FO_CURRENCY_ENCASHMENT] @CurrDate, @DayEndUserID, @PropertyID, @GLCompCode

			END

			DELETE FROM #Blocks WHERE Blockcode = @Blockcode
			SELECT TOP(1) @Blockcode = Blockcode FROM #Blocks

		END

		BEGIN TRY DROP TABLE #Blocks END TRY
		BEGIN CATCH END CATCH

	END

	ELSE BEGIN

		SELECT 'REPOSTING'

	--END


		DELETE eFinancials_Accounting.dbo.GL_POSTING 
		WHERE TxnDate = @CurrDate AND TxnNo = '' AND Amount=0 AND CompCode = @GLCompCode

		SELECT distinct TempTxnNo, ModName, TransType, TxnID, CompCode
		INTO #PostToGL
		FROM eFinancials_Accounting.dbo.GL_POSTING 
		WHERE TxnDate = @CurrDate AND TxnNo = '' AND Amount>0 AND CompCode = @GLCompCode --AND ValidationStatus <> 'True' AND PostedStatus <> 'True' 

		--SELECT TOP(1) TempTxnNo, Modname, TransType, TxnID FROM #PostToGL WHERE CompCode = @GLCompCode

		SELECT TOP(1) @TempTxnNo = TempTxnNo, @ModName = Modname, @TransType = TransType, @TxnID = TxnID FROM #PostToGL WHERE CompCode = @GLCompCode

		WHILE @@ROWCOUNT > 0
		BEGIN


			--PRINT @TempTxnNo PRINT @ModName PRINT @TransType PRINT @TxnID PRINT @Count PRINT @RCount

			IF @TransType NOT IN ('CC', 'CR', 'CN', 'DN') BEGIN --<> 'CC' OR @TransType <> 'CR' BEGIN

				EXEC eFinancials_Accounting.dbo.[GL_POSTING_GET_REQUEST_BODY] @TempTxnNo, @CurrDate, @ModName, @DayEndUserID, @MasterID, @TransType, @OutputReq OUTPUT

				select @TempTxnNo TT, @CurrDate CR, @ModName M, @DayEndUserID UIDD, @MasterID MID, @TransType TR

				PRINT @OutputReq

				INSERT INTO [eFinancials_Accounting].dbo.[GL_POST_JSON] ([TempTxnNo], [TxnDate], [ModName], [UserID], [MasterID], [TxnID], [TransType], [GLCompCode], [JSON_OutPut]) VALUES(@TempTxnNo, @CurrDate, @ModName, @DayEndUserID, @MasterID, @TxnID, @TransType, @GLCompCode, @OutputReq)

				IF @GL_POST_FROM_SP = 'Y' BEGIN

					BEGIN TRY

						EXEC [eFinancials_Accounting].dbo.[GL_POSTING_OTHER_MODULE_SP] @TempTxnNo, @CurrDate, @ModName, @DayEndUserID, @MasterID, @TxnID, @TransType, @OutputReq
 			
					END TRY

					BEGIN CATCH  

						SELECT 1

					END CATCH
				
				END
			
				ELSE BEGIN
				
					EXEC [eFinancials_Accounting].dbo.[GL_POSTING_OTHER_MODULE] @TempTxnNo, @CurrDate, @ModName, @DayEndUserID, @MasterID, @TxnID, @TransType, @OutputReq

				END
			END
			------------------------------ INSERT DEBT ------------------------------

			IF @TransType IN ('CC', 'CR', 'CN', 'DN') BEGIN --@TransType = 'CC' OR @TransType = 'CR' BEGIN 
			
				EXEC eFinancials_Accounting.dbo.[GL_POSTING_GET_REQUEST_BODY_DEBT] @TempTxnNo, @CurrDate, @ModName, @DayEndUserID, @MasterID, @TransType, @OutputReqD OUTPUT, @GLCompCode

				--PRINT @OutputReqD

				--select @TempTxnNo, @CurrDate, @ModName, @DayEndUserID, @MasterID, @TransType, @OutputReqD, @GLCompCode

				INSERT INTO [eFinancials_Accounting].dbo.[GL_POST_JSON] ([TempTxnNo], [TxnDate], [ModName], [UserID], [MasterID], [TxnID], [TransType], [GLCompCode], [JSON_OutPut]) VALUES(@TempTxnNo, @CurrDate, @ModName, @DayEndUserID, @MasterID, @TxnID, @TransType, @GLCompCode, @OutputReqD)--@OutputReq
			
				IF @GL_POST_FROM_SP = 'Y' BEGIN
				
					BEGIN TRY

						EXEC [eFinancials_Accounting].dbo.[GL_POSTING_OTHER_MODULE_DEBT_SP] @TempTxnNo, @CurrDate, @ModName, @DayEndUserID, @MasterID, @TxnID, @TransType, @OutputReqD, @GLCompCode
						
					END TRY

					BEGIN CATCH

						SELECT 1

					END CATCH

				END

				ELSE BEGIN

					EXEC [eFinancials_Accounting].dbo.[GL_POSTING_OTHER_MODULE_DEBT] @TempTxnNo, @CurrDate, @ModName, @DayEndUserID, @MasterID, @TxnID, @TransType, @OutputReqD
		
				END

				--select @TempTxnNo, @CurrDate, @ModName, @DayEndUserID, @MasterID, @TxnID, @TransType, @OutputReqD

			END
		
			---------------------------- INSERT DEBT ------------------------------

			DELETE FROM #PostToGL WHERE TempTxnNo = @TempTxnNo AND ModName = @Modname AND TransType = @TransType AND TxnID = @TxnID AND CompCode = @GLCompCode

			SELECT TOP(1) @TempTxnNo = TempTxnNo, @ModName = Modname, @TransType = TransType, @TxnID = TxnID FROM #PostToGL WHERE CompCode = @GLCompCode

		END
		
	END

	BEGIN TRY DROP TABLE #PostToGL END TRY
	BEGIN CATCH END CATCH


END

GO

