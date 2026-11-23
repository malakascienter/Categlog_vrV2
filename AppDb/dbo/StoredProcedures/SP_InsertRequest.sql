
CREATE PROCEDURE [dbo].[SP_InsertRequest]
    (
      @XMLDetails AS XML ,
      @docID VARCHAR(MAX) OUTPUT ,
      @headerid INT OUTPUT
    )
AS
    DECLARE @iDocID INT

		insert into TempRequestHeader
		SELECT @XMLDetails ,getdate()
		--SELECT * FROM TempRequestHeader WHERE Convert(varchar(max),xx) like'%ExpireDatesList%'


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
			@IsMailNotification BIT
		   ,@IsBatchTransactionEnable BIT
		   ,@IsFranchise BIT,
		    @UrgentRemark VARCHAR(200),
			@PaxCount DECIMAL(8,2)
			,@IsSPOBased BIT

        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails

--
		--added by isuru 2023-08-09
		DECLARE @HeaderRemark VARCHAR(200)

		--end

        SELECT  @RequestType = RequestType ,
                @LocationID = LocationID ,
                @PropertyID = PropertyID ,
                @TxnDate = RequestDate ,
                @txnDateDelivery = DeliveryDate,
				@Flag = Flag,
				@TransferLocationId = TransferLocation,
				@HeaderRemark = Remarks,
				@CheckUserId = UserProfileID,
				@UrgentRemark = UrgentRemark,
				@PaxCount = PaxCount
				,@IsSPOBased = IsSPOBased
        FROM    OPENXML (@iDocID,'/RequestHeader',2)
		WITH    ( RequestType VARCHAR(2), LocationID INT , PropertyID INT,DepartmentID INT , RequestDate VARCHAR(10) , DeliveryDate VARCHAR(10), Flag INT,TransferLocation INT
		,Remarks VARCHAR(200),UserProfileID INT,UrgentRemark VARCHAR(200),
		PaxCount DECIMAL(8,2),IsSPOBased BIT)



		--Added by Isuru 2025-03-27
		SELECT @IsFranchise = IsFranchise
		FROM Locations
		WHERE ID = @TransferLocationId
		--End

--Added by Tharuka 2026-09-04
--Read the detail lines into a temp table and delete the blank ones
--(StockItemID = 0) before they are inserted into RequestDetails.
--Damage Request only. Every other RequestType still rejects the document.
        SELECT  *
        INTO    #RequestDetailLines
        FROM    OPENXML (@iDocID,'/RequestHeader/DetailList/RequestDetail',2)
        WITH RequestDetails

        IF @RequestType = 'RD'
        BEGIN
            DELETE  FROM #RequestDetailLines
            WHERE   ISNULL(StockItemID, 0) = 0
        END
        ELSE
        BEGIN
            DECLARE @BlankLines INT

            SELECT  @BlankLines = COUNT(*)
            FROM    #RequestDetailLines
            WHERE   ISNULL(StockItemID, 0) = 0

            IF @BlankLines > 0
                RAISERROR('This request contains %d line(s) with no item. Please remove the blank line(s), re-select the item, then submit again.', 16, 1, @BlankLines)
        END
--End Tharuka 2026-09-04

        SELECT  @stockItemId = StockItemID ,
                @unitID = UnitID,
				@Remarks = Remarks
        FROM    OPENXML (@iDocID,'/RequestHeader/DetailList/RequestDetail',2)
WITH   (StockItemID VARCHAR(MAX),UnitID VARCHAR(MAX), Remarks VARCHAR(200))


--Added by Isuru 2023-09-07 for prevent 0 userId inserting
DECLARE @ErrorMsg2 VARCHAR(300)
	select @CheckUserId '@CheckUserId'
	IF(@CheckUserId = 0)
		BEGIN
			--SET @ErrorMsg2  =  'User ID Invalid, Please Log Again'
			--RAISERROR ( @ErrorMsg2, 16, 1 );
			RAISERROR('User ID Invalid, Please Log In Again',16,1)
			ROLLBACK TRANSACTION
		END
--End

--Added by Isuru 2024-09-10
	SELECT @IsMailNotification =  ISNULL(IsMailNotification,0)
	FROM TransactionTypes
	WHERE CODE = @RequestType
--End


SELECT @IsBatchTransactionEnable  = ISNULL(IsBatchTransactionEnable,0)
FROM Companies
WHERE CompanyID = @PropertyID


IF( @RequestType = 'RT')
	BEGIN


		--Added by Tharuka 2026-08-18
		DECLARE @BadUnitItems  VARCHAR(MAX),
				@NoMasterUnitItems VARCHAR(MAX),
				@UnparsedLines INT,
				@UnitErrorMsg  VARCHAR(MAX)


		--Edited by Tharuka 2026-08-18
		SELECT	StockItemID = TRY_CONVERT(INT, StockItemID),
				UnitID      = TRY_CONVERT(INT, UnitID)
		INTO	#tempItems
		FROM	OPENXML (@iDocID,'/RequestHeader/DetailList/RequestDetail',2)
		WITH	(StockItemID VARCHAR(MAX), UnitID VARCHAR(MAX))


		--Added by Tharuka 2026-08-18

		SELECT @UnparsedLines = COUNT(*)
		FROM   #tempItems
		WHERE  StockItemID IS NULL OR UnitID IS NULL


		DECLARE @IsDisableTRUnit    BIT ,
				@TRUnitMismatchItems VARCHAR(MAX)

		SELECT @IsDisableTRUnit = ISNULL(IsDisableTRUnit, 0)
		FROM   Companies
		WHERE  CompanyID = @PropertyID


		--Added by Tharuka 2026-08-21
		IF (@IsDisableTRUnit = 1)
		BEGIN
			SELECT @TRUnitMismatchItems = STUFF((
						SELECT DISTINCT ', ' + SH.Name
									  + ' (' + ISNULL(RU.Name, 'not set') + ' / ' + ISNULL(TU.Name, 'not set') + ')'
						FROM   #tempItems t
						INNER JOIN StockItemHeaders SH ON SH.Id = t.StockItemID
						INNER JOIN StockItemDetails RD ON RD.StockItemHeaderID = t.StockItemID
													  AND RD.LocationID        = @LocationID
						LEFT  JOIN Units RU ON RU.ID = RD.MasterUnitID
						LEFT  JOIN Units TU ON TU.ID = t.UnitID
						WHERE  RD.MasterUnitID <> t.UnitID
						FOR XML PATH(''), TYPE).value('.', 'VARCHAR(MAX)'), 1, 2, '')

			IF @TRUnitMismatchItems IS NOT NULL
			BEGIN
				SET @UnitErrorMsg = 'Unit mismatch for: ' + @TRUnitMismatchItems  + 'Please update the unit configuration and try again.';
				RAISERROR (@UnitErrorMsg, 16, 1)
			END
		END

		-- END 2026-08-21 --

		IF @UnparsedLines > 0
		BEGIN
			RAISERROR('Transfer Request contains %d line(s) with a missing item or unit. Please re-select the item and unit and try again.', 16, 1, @UnparsedLines)
		END
		--End Tharuka 2026-08-18

		--Added by Tharuka 2026-08-18 - this case used to be absorbed by the stale @TransferUnitId and passed silently
		SELECT @NoMasterUnitItems = STUFF((
					SELECT DISTINCT ', ' + SH.Name
					FROM   #tempItems t
					INNER JOIN StockItemHeaders SH ON SH.Id = t.StockItemID
					WHERE  NOT EXISTS (SELECT 1
									   FROM   StockItemDetails D
									   WHERE  D.StockItemHeaderID = t.StockItemID
										 AND  D.LocationID        = @TransferLocationId
										 AND  D.MasterUnitID IS NOT NULL)
					FOR XML PATH(''), TYPE).value('.', 'VARCHAR(MAX)'), 1, 2, '')

		IF @NoMasterUnitItems IS NOT NULL
		BEGIN
			SET @UnitErrorMsg = 'No unit is set up at the transfer location for: ' + @NoMasterUnitItems
			RAISERROR (@UnitErrorMsg, 16, 1)
		END
		-- Tharuka 2026-08-18
		SELECT @BadUnitItems = STUFF((
					SELECT DISTINCT ', ' + SH.Name
					FROM   #tempItems t
					INNER JOIN StockItemDetails D  ON D.StockItemHeaderID = t.StockItemID
												  AND D.LocationID        = @TransferLocationId
					INNER JOIN StockItemHeaders SH ON SH.Id = t.StockItemID
					WHERE  dbo.FN_GetUnitConvertionRate(@PropertyID, t.UnitID, D.MasterUnitID) = -1
					FOR XML PATH(''), TYPE).value('.', 'VARCHAR(MAX)'), 1, 2, '')

		IF @BadUnitItems IS NOT NULL
		BEGIN
			SET @UnitErrorMsg = 'Please set unit conversion value for: ' + @BadUnitItems
			RAISERROR (@UnitErrorMsg, 16, 1)
		END


		DROP TABLE #tempItems
	END


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



        DECLARE @Prefix VARCHAR(MAX) ,
            @Len INT ,
            @Code VARCHAR(MAX)


        SELECT  @Prefix = Prefix
        FROM    dbo.Locations
        WHERE   Id = @LocationID
        SELECT  @Code = Code
        FROM    dbo.TransactionTypes
        WHERE   Code = @RequestType

        --SELECT  @Code = CASE WHEN @RequestType = 'RP' THEN 'PR'
        --                     WHEN @RequestType = 'RD' THEN 'DR'
        --                     WHEN @RequestType = 'RT' THEN 'TR'
        --                     WHEN @RequestType = 'RI' THEN 'IR'
        --                END

        --Edited 2026-09-11 - Franchise Request (TransactionTypes Id 86, Code 'FR').
        --Without a branch for 'FR', @Code stays NULL and the document number
        --below (@Prefix + '/' + @Code + '/' + @DocumentNo) becomes NULL.
        SELECT  @Code = CASE WHEN @RequestType = 'RP' THEN 'PR'
                             WHEN @RequestType = 'RD' THEN 'DR'
                             WHEN @RequestType = 'RT' THEN 'TR'
                             WHEN @RequestType = 'RI' THEN 'IR'
                             WHEN @RequestType = 'FR' THEN 'FR'
                        END
        --End 2026-09-11

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

--select * from TransactionTypes
--update TransactionTypes set code = 'RP' where id =1

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
                  JobID,
				  Urgent,
				  Flag,
				  UrgentRemark,
				  PaxCount,
				  DamageCategoryID
				  ,IsSPOBased
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
                       --@Remarks ,
					   @HeaderRemark,
                        DepartmentID ,
                        TransferLocation ,
                        @txnDateDelivery ,
                        JobID,
						isnull(Urgent,0),
						@Flag,
						ISNULL(@UrgentRemark,''),
						PaxCount,
						DamageCategoryID
						,CASE WHEN @IsSPOBased IS NULL THEN 0 ELSE @IsSPOBased END
                FROM    OPENXML (@iDocID,'/RequestHeader',2)
WITH RequestHeaders


        SELECT  @RequestHeaderID = SCOPE_IDENTITY()

			--Inserting into Audit Log Table 2025-05-14
			EXEC Inventry_AuditTail_WriteToLog 'RequestHeaders', @RequestHeaderID, 'INV', 'RHI', 'I', @CheckUserId,@PropertyID, '', ''

			--End


        INSERT  INTO RequestDetails
                ( RequestHeaderID ,
                  StockItemID ,
                  UnitID ,
                  RequestedQuantity ,
                  IssuedQuantity ,
                  ApprovedQuantity ,
                  Remarks ,
                  UnitPrice ,
                  InvAccountID,
				  ItemDeliveryDate,
				  StockMasterQuantity
                )
                SELECT  @RequestHeaderID ,
                        StockItemID ,
                        UnitID ,
                        RequestedQuantity ,
                        ApprovedQuantity ,
                        ApprovedQuantity ,
                        Remarks ,
                        CASE WHEN @IsFranchise = 1
						THEN dbo.FN_GetSellingPrice(StockItemID,@LocationID,@PropertyID) ELSE
						dbo.[FN_GetLastAveragePrice](@LocationID,StockItemID)
					--	dbo.[FN_GetLastAveragePrice](@LocationID,StockItemID) * dbo.FN_GetUnitConvertionRate(@PropertyID,UnitID,dbo.FN_GetMasterUnitID(@PropertyID,@LocationID,StockItemID))
						END UnitPrice ,
						 --dbo.FN_GetAveragePrice(@PropertyID, @LocationID,
       --                                        StockItemID, @RequestType, 0,
       --                                        UnitID, 0)  END UnitPrice, --Commented by Isuru 2025-04-25 to get last avg price
                        InvAccountID,
						ItemDeliveryDate,
						[dbo].[FN_GetStockInHand](@propertyId,@LocationID,StockItemID)
                --Added by Tharuka 2026-09-04 - read from the cleaned temp table
                --instead of the raw XML, so blank lines are already gone.
                FROM    #RequestDetailLines

        DECLARE @jobid INT
        SELECT  @jobid = jobid
        FROM    dbo.RequestHeaders
        WHERE   Id = @RequestHeaderID
		 --added to handle jobrequests in Venora--
		 --@jobid is 0
        IF ( @jobid <> 0 )
            BEGIN

                DECLARE @ItemID INT ,
                    @RequestedQuantity DECIMAL(18, 2)

                SELECT  StockItemID ,
                        RequestedQuantity
                INTO    #TEMPProcess
                --Added by Tharuka 2026-09-04 - same cleaned temp table.
                FROM    #RequestDetailLines

                WHILE ( SELECT  COUNT(*)
                        FROM    #TEMPProcess
                      ) > 0
                    BEGIN

                        SELECT TOP ( 1 )
                                @ItemID = StockItemID ,
                                @RequestedQuantity = RequestedQuantity
                        FROM    #TEMPProcess


		                IF( @RequestType='RT')
						BEGIN
                        UPDATE  dbo.JobInputDetails
                        SET     RequestQty = RequestQty + @RequestedQuantity
                        WHERE   JobHeaderID = @jobid
                                AND StockItemHeaderID = @ItemID
                        END

						 IF( @RequestType='RI')
						BEGIN
                        UPDATE  dbo.JobInputDetails
                        SET     IssueQty = IssueQty + @RequestedQuantity
                        WHERE   JobHeaderID = @jobid
                                AND StockItemHeaderID = @ItemID
                        end

                        DELETE  FROM #TEMPProcess
                        WHERE   StockItemID = @ItemID
                                AND RequestedQuantity = @RequestedQuantity

                    END
            END
		 --end here-------

----------------------------- For Expire Dates -------------------------------------------------------------------------------
			IF (@TransactionTypeID =14 AND @IsBatchTransactionEnable =1)

			DECLARE @BatchStockItemID INT,
			@BatchQuantity DECIMAL(18,8),
			@BatchNO VARCHAR(MAX)
			,@BatchEXPDate DATE
			,@BatchID INT
			,@SellingPrice DECIMAL(18,8)

			DECLARE @TransactionIDBatch INT = dbo.FN_getTransactionID('RD')

			BEGIN
			SELECT *
			INTO #StockItemWiseEXPDateIns
			FROM    OPENXML (@iDocID,'/RequestHeader/ExpireDatesList/ExpireDatesList',2)
			WITH   (StockItemID INT,Quantity DECIMAL,EXPDate DATETIME,BatchNo VARCHAR(200),SellingPrice DECIMAL(18,8) );

			select '#StockItemWiseEXPDateIns',*
			from #StockItemWiseEXPDateIns

			WHILE EXISTS(SELECT 1 FROM  #StockItemWiseEXPDateIns)
			BEGIN
				SELECT TOP (1) @BatchStockItemID = StockItemID,@BatchQuantity = Quantity,@BatchEXPDate = CONVERT(DATE,EXPDate), @BatchNO = BatchNo,@BatchID = 0,@SellingPrice = SellingPrice
				FROM #StockItemWiseEXPDateIns

				--SELECT @BatchStockItemID BatchStockItemID,@BatchQuantity BatchQuantity,@BatchEXPDate BatchEXPDate
				--,@PropertyID PropertyID,@LocationID  LocationID,@RequestHeaderID StockTransactionHeaderID,@BatchNO '@BatchNO', @BatchID BatchID
				--,@TransactionIDBatch TransactionIDBatch

				EXEC [UpdateExpDateFIFO_WithBatchNo] @PropertyID,@LocationID,  @BatchStockItemID, @BatchQuantity , @RequestHeaderID ,  @TransactionIDBatch,@BatchNO,@BatchEXPDate,@BatchID,@SellingPrice



				DELETE TOP (1) FROM #StockItemWiseEXPDateIns

			END

			END

			IF (@TransactionTypeID =14 AND @IsBatchTransactionEnable =0)
			BEGIN

				SELECT  *
				INTO #ExpireDatesList
				FROM    OPENXML (@iDocID,'/RequestHeader/ExpireDatesList/ExpireDatesList',2)
				WITH   (StockItemID INT,Quantity DECIMAL,EXPDate DATETIME)

				DECLARE @CurID INT, @ExpDate DATE, @ExpItemID INT, @Qty MONEY, @TxnQty INT, @Error BIT= 0

				WHILE EXISTS (SELECT TOP 1 1 FROM #ExpireDatesList)

				BEGIN

					SELECT	TOP (1) @ExpDate = EXPDate , @ExpItemID=StockItemID, @Qty=Quantity
					FROM	#ExpireDatesList

						INSERT INTO StockItemWiseEXPDateIns (PropertyID	,LocationID	,TransactionID	,TransactionType	,StockItemID	,Quantity	,BalanceQuantity	,EXPDate, logdate)
						Values (@PropertyID, @LocationID, @TransactionTypeID, 'RD',@ExpItemID,@Qty,0,@ExpDate, getdate())

					WHILE @Qty >0 and @Error =0
					BEGIN

						SELECT top 1 @CurID=ID, @TxnQty=BalanceQuantity
						FROM  StockItemWiseEXPDateIns
						WHERE	PropertyID = @PropertyID and LocationID= @LocationID AND StockItemID =@ExpItemID
								AND EXPDate = @ExpDate and BalanceQuantity > 0
						ORDER BY EXPDate

						IF @CurID is null
							set @Error =1

						UPDATE StockItemWiseEXPDateIns
						SET BalanceQuantity =BalanceQuantity - CASE WHEN @TxnQty > @Qty THEN @Qty ELSE @TxnQty END
						WHERE ID= @CurID


						SET @Qty -= CASE WHEN @TxnQty > @Qty THEN @Qty ELSE @TxnQty END

					END



					DELETE FROM #ExpireDatesList
					WHERE EXPDate= @ExpDate  and StockItemID= @ExpItemID

				END
			END

------------------------------------------------------------------------------------------------------------------------------
		SELECT @PropertyID, @LocationID,@TransactionTypeID, @RequestHeaderID '55555'

        SET @docID = @DocumentNo
        SET @headerid = @RequestHeaderID


		DECLARE @TotalRequestedQuantity DECIMAL(18,6)
		SELECT @TotalRequestedQuantity = sum(RequestedQuantity)
		FROM            RequestDetails D INNER JOIN RequestHeaders H ON D.RequestHeaderID = H.ID
		WHERE H.Id = @RequestHeaderID



		--Added by Tharuka 2026-09-04 - also acts as the backstop for the delete
		--above: if every line was blank and got deleted, the sum is NULL and the
		--whole document is rolled back instead of saving an empty header.
		IF( ISNULL(@TotalRequestedQuantity,0) = 0 )
		BEGIN

			RAISERROR('The Total Requested Quantity must be greater than zero.',16,1)
			ROLLBACK TRANSACTION

		END

		select top(1)'1',*
		from RequestHeaders
		order by Id desc

			select @LocationID '--@LocationID'



		select @DepartmentID = DepartmentID from RequestHeaders where Id = @RequestHeaderID

		DECLARE @IsRangeWiseApproval BIT;

		SELECT @IsRangeWiseApproval = IsRangeWiseApproval
		FROM dbo.Companies
		WHERE CompanyID = @PropertyID;



		IF(@IsRangeWiseApproval = 1)
		BEGIN
			select @LocationID,
														@TransactionTypeID,
														@RequestHeaderID ,
														@DepartmentID,
														@CheckUserId;
			EXEC dbo.SP_InsertApprovalLevelForRange @PropertyID,
														@LocationID,
														@TransactionTypeID,
														@RequestHeaderID ,
														@DepartmentID,
														@CheckUserId;


		END
		ELSE
		BEGIN

			EXEC dbo.SP_InsertApprovalLevelForRequest @PropertyID, @LocationID,@TransactionTypeID, @RequestHeaderID
		END
			select top(1)'2',*
from RequestHeaders
order by Id desc
----------SEND MAIL------------------------------------------------------------------------------------------------------------
--DECLARE @IsMailNotification BIT
--SELECT  @IsMailNotification = IsMailNotification FROM Companies WHERE CompanyID = @PropertyID

IF(@IsMailNotification = 1)
BEGIN

	--sending Tranasctionwise emails 2024-09-27
	 EXEC [dbo].[SendTransactionWiseEmailS] @RequestType,@RequestHeaderID,@LocationID,@PropertyID,'C'

	--END
	DECLARE @Email VARCHAR(MAX),@EmailBody VARCHAR(MAX), @CompanyName VARCHAR(200), @LocationName VARCHAR(200), @RequestedUser VARCHAR(200),@TransactionName VARCHAR(MAX)

	SELECT @TransactionName = Name
	FROM TransactionTypes
	WHERE CODE = @RequestType

	SELECT @RequestedUser = U.UserName ,@LocationName = L.Name,@CompanyName = C.Name
	FROM RequestHeaders RH
	INNER JOIN CentralUsers U ON RH.UserProfileID = U.Id
	INNER JOIN Locations L On L.Id = RH.LocationID
	INNER JOIN Companies C ON C.CompanyID =RH.PropertyID
	WHERE RH.Id = @RequestHeaderID

	SELECT TOP(1) @Email=US.Email
    FROM ApprovalLogs AS AL
        INNER JOIN dbo.UserWiseApproveLevels AS UAL
            ON AL.TransactionID = UAL.TransactionTypeID
               AND AL.LocationID = UAL.LocationId
               AND AL.PropertyID = UAL.PropertyId
               AND AL.ApprovalLevelID = UAL.ApproveLevelID
			   AND AL.ApprovalUserID = UAL.UserProfileId
                AND UAL.SendEmail = 1
        INNER JOIN dbo.CentralUsers AS US ON US.Id = UAL.UserProfileId
		INNER JOIN TransactionTypes TR ON AL.TransactionID = TR.Id
    WHERE TR.Code = @RequestType AND AL.TransactionHeaderID= @RequestHeaderID
	ORDER BY AL.SeqID ASC;

		--Added by Isuru 2024-05-22 for sending multiplle users with approval mail
	SELECT DISTINCT US.Email,AL.ApprovalUserID
	into #TempEmail
    FROM ApprovalLogs AS AL
        INNER JOIN dbo.UserWiseApproveLevels AS UAL
			   ON AL.TransactionID = UAL.TransactionTypeID
               AND AL.LocationID = UAL.LocationId
               AND AL.PropertyID = UAL.PropertyId
               AND AL.ApprovalLevelID = UAL.ApproveLevelID
			   AND AL.ApprovalUserID = UAL.UserProfileId
               AND UAL.SendEmail = 1
        INNER JOIN CentralUsers AS US ON US.Id = AL.ApprovalUserID
		INNER JOIN TransactionTypes TR ON AL.TransactionID = TR.Id
    WHERE TR.Code = @RequestType AND AL.SendMail = 0
	AND AL.TransactionHeaderID=@RequestHeaderID AND AL.SeqID=1
	--ORDER BY AL.SeqID ASC;





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

		SELECT TOP(1) @NewEmail= EMAIL,@NewApprovalUserID =ApprovalUserID  FROM #TempEmail

		EXEC [dbo].[SendReuestMail] @NewEmail, @MailSubject, @EmailBody, 2


			--UPDATE TOP(1) AL
			--SET AL.SendMail = 1
			--FROM ApprovalLogs AS AL
			--	INNER JOIN dbo.UserWiseApproveLevels AS UAL
			--		ON AL.TransactionID = UAL.TransactionTypeID
			--		   AND AL.LocationID = UAL.LocationId
			--		   AND AL.PropertyID = UAL.PropertyId
			--		   AND AL.ApprovalLevelID = UAL.ApproveLevelID
			--		   AND AL.TransactionHeaderID = @PoHeaderID
			--	INNER JOIN @UserData AS US
			--		ON US.Id = UAL.UserProfileId
			--WHERE AL.TransactionID = 2 AND AL.DocStatus = 'P'


			;WITH CTE AS (
			SELECT TOP 1 AL.SeqID
			FROM ApprovalLogs AS AL
			INNER JOIN dbo.UserWiseApproveLevels AS UAL ON AL.TransactionID = UAL.TransactionTypeID AND AL.LocationID = UAL.LocationId
			AND AL.PropertyID = UAL.PropertyId AND AL.ApprovalLevelID = UAL.ApproveLevelID AND AL.TransactionHeaderID = @RequestHeaderID
			INNER JOIN CentralUsers AS US ON US.Id = AL.ApprovalUserID
			INNER JOIN TransactionTypes TR ON TR.Id = AL.TransactionID
			WHERE TR.Code = @RequestType
				AND AL.DocStatus = 'P'
				AND AL.SeqID=1
				AND AL.ApprovalUserID=@NewApprovalUserID
			ORDER BY AL.SeqID ASC
			)
			UPDATE AL
			SET AL.SendMail = 1
			FROM ApprovalLogs AS AL
			INNER JOIN CTE ON AL.SeqID = CTE.SeqID
			WHERE AL.TransactionHeaderID = @RequestHeaderID;




		DELETE TOP(1) FROM #TempEmail
		END
		DROP TABLE #TempEmail

		--EXEC [dbo].[SendReuestMail] @Email, 'PR Approval',@EmailBody,@TransactionTypeID;

		--UPDATE TOP(1) AL
		--SET AL.SendMail = 1
		--FROM ApprovalLogs AS AL
		--	INNER JOIN dbo.UserWiseApproveLevels AS UAL
		--		ON AL.TransactionID = UAL.TransactionTypeID
		--		   AND AL.LocationID = UAL.LocationId
		--		   AND AL.PropertyID = UAL.PropertyId
		--		   AND AL.ApprovalLevelID = UAL.ApproveLevelID
		--		   AND AL.TransactionHeaderID = @RequestHeaderID
		--	INNER JOIN dbo.UserMasters AS US
		--		ON US.Id = UAL.UserProfileId
		--WHERE AL.TransactionID = @TransactionTypeID AND AL.DocStatus = 'P'
	END

END

----------SEND MAIL------------------------------------------------------------------------------------------------------------

        COMMIT TRAN  --Transaction Success!
    END TRY
   BEGIN CATCH
	ROLLBACK TRANSACTION
	DECLARE @Message NVARCHAR(2044)
	SET @Message = N'Error Occured: ' + ERROR_MESSAGE()
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())
	RAISERROR(@Message,16,1)
END CATCH

GO

