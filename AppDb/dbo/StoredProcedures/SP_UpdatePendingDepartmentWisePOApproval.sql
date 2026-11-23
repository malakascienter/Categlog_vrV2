-- =============================================
-- Author:		Nivesh
-- Create date: 2025-11-18
-- Description:	Update Department-wise PO Approvals
-- =============================================
CREATE   PROCEDURE [dbo].[SP_UpdatePendingDepartmentWisePOApproval]
    @XMLDetails XML,
    @IsApprove BIT = 1
AS
BEGIN

	DROP TABLE CHANXXX
	SELECT @XMLDetails XX, @IsApprove IsApprove  
    INTO CHANXXX 
	--select * from CHANXXX

BEGIN TRY

    DECLARE @iDocID INT;

    DECLARE @RequestTransactionTypeID INT,
            @ApprovedDate DATETIME,
            @UserProfileID BIGINT,
            @RequestHeaderID BIGINT,
            @ApprovalLevelID INT,
            @StockItemID BIGINT,
            @ApprovedQuantity DECIMAL(18,6),
            @RequestDetailID BIGINT,
			@Remarks VARCHAR(500),
            @CUNT INT,
            @RejectedCount INT


    EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

    SELECT @RequestTransactionTypeID = RequestTransactionTypeID,
           @ApprovedDate = ApprovedDate,
           @UserProfileID = UserProfileID,
           @RequestHeaderID = RequestHeaderID,
           @ApprovalLevelID = ApprovalLevelID,
		   @Remarks = Remarks
    FROM
        OPENXML(@iDocID, '/POApproved', 2)
        WITH
        (
            RequestTransactionTypeID INT,
            ApprovedDate DATETIME,
            UserProfileID BIGINT,
            RequestHeaderID BIGINT,
            ApprovalLevelID INT,
			Remarks VARCHAR(500)
        ) ;

    IF OBJECT_ID('tempdb..#ItemList') IS NOT NULL
        DROP TABLE #ItemList;

    CREATE TABLE #ItemList
    (
        StockItemID BIGINT,
        ApprovedQuantity DECIMAL(18,6),
        RequestDetailID BIGINT
    );

    INSERT INTO #ItemList
    SELECT StockItemID,
           ApprovedQuantity,
           RequestDetailID
    FROM
        OPENXML(@iDocID, '/POApproved/RequestionApprovalDetailCollection/PORequestionApprovalDetail', 2)
        WITH #ItemList;

    CREATE TABLE #TaxTable
    (
        TaxValue MONEY
    );

	DECLARE  
        @DiscountValue MONEY,
        @DiscoutRate MONEY,
        @supplierID INT,
        @UnitPrice MONEY,
        @taxVal MONEY,
        @MailPropertyID INT,
        @IsMailNotification BIT,
        @IsWhatsAppNotification VARCHAR(MAX),
        @PropertyID INT,
        @LocationID INT,
        @TransactionID INT,
        @TransactionHeaderID BIGINT,
        @ActiveSeq INT,
        @newSeq INT;

	SELECT @MailPropertyID = PropertyID 
	FROM PoHeaders
	WHERE ID = @RequestHeaderID 

	SELECT 
        @IsMailNotification =  ISNULL(IsMailNotification,0),
        @IsWhatsAppNotification = ISNULL(IsWhatsAppNotification,0)
	FROM TransactionTypes
	WHERE CODE = 'PO'

    SELECT @PropertyID = PropertyID,
            @LocationID = LocationID,
            @TransactionID = TransactionID,
            @TransactionHeaderID = TransactionHeaderID,
            @ActiveSeq = SeqID
    FROM dbo.ApprovalLogs WITH(NOLOCK)
    WHERE TransactionID = @RequestTransactionTypeID
            AND TransactionHeaderID = @RequestHeaderID
            AND ApprovalLevelID = @ApprovalLevelID;


    IF (@IsApprove = 1) --Approve PO
    BEGIN

        WHILE ((SELECT COUNT(*) FROM #ItemList ) > 0)
        BEGIN


            SELECT TOP (1)
                   @StockItemID = StockItemID,
                   @ApprovedQuantity = ApprovedQuantity,
                   @RequestDetailID = RequestDetailID
				   		    
            FROM #ItemList 
            ORDER BY StockItemID;
            PRINT @StockItemID;


			SELECT	
                @DiscountValue= DiscountValue,
                @DiscoutRate= DiscountPercentage,
                @UnitPrice=
                    ( 
                        (
                            UnitPrice - 
                            ( DiscountValue + 
                                ( UnitPrice * DiscountPercentage /100.00 )
                            )
                        ) 
                    )
                    * @ApprovedQuantity
			FROM	PoDetails WITH(NOLOCK)
			WHERE	PoHeaderID = @RequestHeaderID 
			AND StockItemID = @StockItemID

			--Added by Isuru
			DECLARE @SupLocationId INT
			--END

			SELECT	
                @supplierID = supplierID,
                @SupLocationId = LocationID  -- Added by Isuru
			FROM	PoHeaders WITH(NOLOCK)
			WHERE	ID = @RequestHeaderID  
			

            UPDATE dbo.PoDetails
            SET ApprovedQuantity = @ApprovedQuantity,
            TaxValue =  
            ISNULL(
                    (UnitPrice- 
                        (
                            (DiscountValue * ApprovedQuantity) 
                            + (UnitPrice * (DiscountPercentage / 100)
                        )
                         * ApprovedQuantity
                         )
                        )    * dbo.GetSupplierWiseTaxRateSum(@StockItemID, @supplierID) /100
                  ,0)
            WHERE Id = @RequestDetailID; --Modified by Nivesh 2024-10-07
			 

			DELETE 
            FROM POwiseTaxes
			WHERE StockItemID = @StockItemID 
            AND PODetailID = @RequestDetailID
			
			INSERT INTO POwiseTaxes
            (
                PODetailID,
                StockItemID,
                TaxTypeID,
                TaxAmount
            )
			SELECT  
                @RequestDetailID,
                StockItemID,
                TaxTypeID,
                @UnitPrice * ChargeRate /100.00 
			FROM SupplierWiseItemDetails S WITH(NOLOCK)
			INNER JOIN TaxGroupDetails G WITH(NOLOCK) ON G.TaxGroupId =S.TaxGroupID
			WHERE S.SupplierID = @supplierID 
            AND S.StockItemID = @StockItemID 
            AND S.LocationId = @SupLocationId
			

			---------------------------------- 17.06.2024 added by vinuki to log the PO approval Changes -------------------------------------------------------
			-------------------------------- added by vinuki 17.06.2024 to get the quantity before approval -------------------------------------------
			DECLARE @TempPoQuantityBeforeApproval DECIMAL(18,6)

			SELECT 
                @TempPoQuantityBeforeApproval = RequestedQuantity 
            FROM PoDetails 
            WHERE PoHeaderID = @RequestHeaderID 
            AND id = @RequestDetailID
			
			---------------------------------------------------------------------------------------------------------------------------------------


			INSERT INTO [dbo].PoApprovalLog
			(
                PoHeaderID,
                PoDetailID,
                StockItemID ,
                ApprovalLevelID,
                PoQuantity,
                ApprovedQuantity,
                ApprovalDate,
                UserID,
                UserName
            )
			VALUES
			(
                @RequestHeaderID,
                @RequestDetailID,
                @StockItemID,
                @ApprovalLevelID,
                @TempPoQuantityBeforeApproval,
                @ApprovedQuantity,
                GETDATE(),
                @UserProfileID,
                ''
            );
    -----------------------------------------------------------------------------------------------------------------------------------------------------
            DELETE FROM #ItemList
            WHERE StockItemID = @StockItemID;

        END;

        SELECT @RequestHeaderID POHeaderID,
               SUM(PD.TaxValue * PD.ApprovedQuantity) TaxTotal,
               SUM(PD.UnitPrice * PD.ApprovedQuantity) GrossTotal,
               SUM(PD.UnitPrice * PD.ApprovedQuantity 
                    + ((PD.TaxValue * PD.ApprovedQuantity))
                   - ((PD.DiscountValue * PD.ApprovedQuantity) + (PD.UnitPrice * (PD.DiscountPercentage / 100))
                      * PD.ApprovedQuantity
                     )
                  ) NetTotal,
               SUM((PD.DiscountValue * PD.ApprovedQuantity) + (PD.UnitPrice * (PD.DiscountPercentage / 100))
                   * PD.ApprovedQuantity
                  ) DiscountTotal
        INTO #UpdateHeaders
        FROM dbo.PoHeaders PH WITH(NOLOCK)
        INNER JOIN dbo.PoDetails  PD WITH(NOLOCK) ON PH.Id = PD.PoHeaderID
        WHERE PD.PoHeaderID = @RequestHeaderID;

        UPDATE SD
        SET SD.TaxTotal = SH.TaxTotal,
            SD.GrossTotal = SH.GrossTotal,
            SD.NetTotal = SH.NetTotal,
            SD.TotalDiscount = SH.DiscountTotal
        FROM dbo.PoHeaders SD
        INNER JOIN #UpdateHeaders SH ON SD.Id = SH.POHeaderID
        WHERE SD.Id = @RequestHeaderID;

        DROP TABLE #UpdateHeaders;
			---------------------------------------------------------------------------------------------------------------------------------------

        UPDATE dbo.ApprovalLogs
        SET IsComplete = 1,
            ApprovalUserID = @UserProfileID,
            DocStatus = 'C',
			Remarks = @Remarks,
			ApprovalDate = GETDATE()
        WHERE TransactionID = @RequestTransactionTypeID
              AND TransactionHeaderID = @RequestHeaderID
              AND ApprovalLevelID = @ApprovalLevelID;

------------SEND MAIL-------------------

	IF(@IsMailNotification=1)
	BEGIN

	DECLARE @Email VARCHAR(MAX),@EmailBody VARCHAR(MAX), @CompanyName VARCHAR(200), @LocationName VARCHAR(200), @RequestedUser VARCHAR(200),@DocumentNo VARCHAR(20)

	SELECT @RequestedUser = U.UserName ,@LocationName = L.Name,@CompanyName = C.Name, @DocumentNo = PO.PoNo
	FROM PoHeaders PO WITH(NOLOCK)
	INNER JOIN CentralUsers U WITH(NOLOCK) ON PO.CreatedUserID = U.Id
	INNER JOIN Locations L WITH(NOLOCK) On L.Id = PO.LocationID
	INNER JOIN Companies C WITH(NOLOCK) ON C.CompanyID =PO.PropertyID
	WHERE PO.Id = @RequestHeaderID



 
	SELECT TOP(1) @Email=us.Email
	FROM ApprovalLogs AS AL WITH(NOLOCK)
    INNER JOIN dbo.UserWiseApproveLevels AS UAL WITH(NOLOCK)
        ON AL.TransactionID = UAL.TransactionTypeID
            AND AL.LocationID = UAL.LocationId
            AND AL.PropertyID = UAL.PropertyId
            AND AL.ApprovalLevelID = UAL.ApproveLevelID
			AND AL.TransactionHeaderID = @RequestHeaderID
    INNER JOIN dbo.CentralUsers AS US WITH(NOLOCK) ON US.Id = UAL.UserProfileId
		WHERE AL.TransactionID = 2 AND AL.SendMail = 0 AND AL.DocStatus = 'P' 
		ORDER BY AL.SeqID ASC;

		--Added by Isuru 2024-05-22 for sending multiplle users with approval mail
		DECLARE @SeqID INT

		SELECT TOP(1)@SeqID= AL.SeqID
		FROM ApprovalLogs AL
		WHERE AL.TransactionID=2 AND AL.TransactionHeaderID= @RequestHeaderID AND AL.SendMail = 0 AND AL.DocStatus = 'P' 
		ORDER BY AL.SeqID ASC;


		SELECT DISTINCT US.Email,AL.ApprovalUserID
		INTO #TempEmail
		FROM ApprovalLogs AS AL
			INNER JOIN dbo.UserWiseApproveLevels AS UAL
				   ON AL.TransactionID = UAL.TransactionTypeID
				   AND AL.LocationID = UAL.LocationId
				   AND AL.PropertyID = UAL.PropertyId
				   AND AL.ApprovalLevelID = UAL.ApproveLevelID
			INNER JOIN CentralUsers AS US ON US.Id = AL.ApprovalUserID
		WHERE AL.TransactionID = 2 
        AND AL.SendMail = 0  
		AND AL.TransactionHeaderID=@RequestHeaderID 
        AND AL.SeqID=@SeqID 
        AND AL.DocStatus = 'P' 
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
						 <td  style="width: 20%" >Purchase Order Request</td>
						 <td  style="width: 20%" >'+@DocumentNo+'</td>
						 <td  style="width: 20%" >'+@CompanyName+'</td>
						 <td  style="width: 20%" >'+@LocationName+'</td>
						 <td  style="width: 20%" >'+@RequestedUser+'</td>
                        </tr>
					  </tbody>
					  </table></html></body>'

	IF @Email IS NOT NULL
	BEGIN

	DECLARE @NewEmail VARCHAR(MAX),@NewApprovalUserID INT
		WHILE EXISTS(SELECT 1  FROM #TempEmail)
		BEGIN

			SELECT TOP(1) @NewEmail= EMAIL,@NewApprovalUserID =ApprovalUserID  FROM #TempEmail
			
			EXEC [dbo].[SendReuestMail] @NewEmail, 'PO Approval', @EmailBody, 2

			;WITH CTE AS (
			SELECT TOP 1 AL.SeqID
			FROM ApprovalLogs AS AL
			INNER JOIN dbo.UserWiseApproveLevels AS UAL ON AL.TransactionID = UAL.TransactionTypeID AND AL.LocationID = UAL.LocationId 
			AND AL.PropertyID = UAL.PropertyId AND AL.ApprovalLevelID = UAL.ApproveLevelID AND AL.TransactionHeaderID = @RequestHeaderID
			INNER JOIN CentralUsers AS US ON US.Id = AL.ApprovalUserID
			WHERE AL.TransactionID = 2 
				AND AL.DocStatus = 'P'
				AND AL.SeqID=@SeqID
				AND AL.ApprovalUserID=@NewApprovalUserID
			ORDER BY AL.SeqID ASC
			)
			UPDATE AL
			SET AL.SendMail = 1
			FROM ApprovalLogs AS AL
			--INNER JOIN CTE ON AL.SeqID = CTE.SeqID;
            INNER JOIN CTE ON AL.SeqID = CTE.SeqID
            WHERE AL.TransactionID = 2
            AND AL.TransactionHeaderID = @RequestHeaderID
            AND AL.ApprovalUserID = @NewApprovalUserID
            AND AL.DocStatus = 'P';

		DELETE TOP(1) FROM #TempEmail
		END
		DROP TABLE #TempEmail
	END

	END

------------SEND MAIL-------------------

        SELECT @newSeq = MIN(SeqID)
        FROM dbo.ApprovalLogs WITH(NOLOCK)
        WHERE TransactionID = @RequestTransactionTypeID
              AND TransactionHeaderID = @RequestHeaderID
              AND DocStatus <> 'C';


        IF EXISTS
        (
            SELECT *
            FROM dbo.ApprovalLogs WITH(NOLOCK)
            WHERE TransactionID = @RequestTransactionTypeID
                  AND TransactionHeaderID = @RequestHeaderID
                  AND SeqID = @newSeq
        )
        BEGIN

            DECLARE @uesrId INT,
                    @ApprovalLevel INT,
                    @UserEmail VARCHAR(MAX);

            SELECT @PropertyID = PropertyID,
                   @LocationID = LocationID,
                   @TransactionID = TransactionID,
                   @TransactionHeaderID = TransactionHeaderID,
                   @ApprovalLevel = ApprovalLevelID
            FROM dbo.ApprovalLogs WITH(NOLOCK)
            WHERE TransactionID = @RequestTransactionTypeID
                  AND TransactionHeaderID = @RequestHeaderID
                  AND SeqID = @newSeq;



            SELECT @uesrId = UWL.UserProfileId
            FROM dbo.TransactionWiseApprovalTypes AS TWA WITH(NOLOCK)
                INNER JOIN dbo.UserWiseApproveLevels AS UWL WITH(NOLOCK)
                    ON TWA.TransactionID = UWL.TransactionTypeID
                       AND TWA.PropertyID = UWL.PropertyId
                       AND TWA.LocationID = UWL.LocationId
                       AND TWA.ApprovalTypeID = UWL.ApproveLevelID
            WHERE TWA.TransactionID = @TransactionID
                  AND TWA.PropertyID = @PropertyID
                  AND TWA.LocationID = @LocationID
                  AND UWL.ApproveLevelID = @ApprovalLevel;


            SELECT @UserEmail = Email
            FROM dbo.UserMasters WITH(NOLOCK)
            WHERE Id = @uesrId;

        END;

        SET @CUNT = (SELECT COUNT(*) 
			FROM dbo.ApprovalLogs 
			WHERE PropertyID= @PropertyID 
			AND LocationID=@LocationID
			AND TransactionHeaderID= @TransactionHeaderID 
            AND TransactionID = @TransactionID 
			AND DocStatus <> 'C')
    
        SET @RejectedCount = (  SELECT COUNT(*) 
            FROM ApprovalLogs
	        WHERE PropertyID=@PropertyID 
            AND LocationID=@LocationID 
	        AND TransactionHeaderID= @TransactionHeaderID 
            AND TransactionID = @TransactionID 
	        AND DocStatus ='X')

        IF(@CUNT =0)
        BEGIN
            UPDATE  dbo.PoHeaders
		    SET   isApproved     = 1 
			    , DocumentStatus ='P'
		    WHERE Id = @TransactionHeaderID 
        END
        ELSE IF (@RejectedCount>0)
        BEGIN
            Update  dbo.POHeaders
		    SET isApproved=0 ,
            DocumentStatus ='X'
		    WHERE POHeaderID = @TransactionHeaderID 
        END
	IF(@IsMailNotification = 1)
	BEGIN
		--sending Tranasctionwise emails 2024-09-27
		EXEC [dbo].[SendTransactionWiseEmailS] 'PO',@TransactionHeaderID,@LocationID,@PropertyID,'C'
	END

    --ADDED BY ISURU 2025-08-15 TO SEND WHTSAPP MSG
    DECLARE @SMSText NVARCHAR(MAX)
    IF(@IsWhatsAppNotification = 1)
    BEGIN
        SELECT @SMSText = PoNo
        FROM PoHeaders
        WHERE ID = @TransactionHeaderID

        EXEC [dbo].[SP_GetTransactionWiseWhatsAppSMS] @LocationID ,'PO',@PropertyID ,'C',@TransactionHeaderID ,@SMSText 
    END

    --END

    END;
    ELSE -- Reject PO
    BEGIN

        UPDATE dbo.PoHeaders
        SET isApproved = 0,
            DocumentStatus = 'X',
			LastModUserID = @UserProfileID,
			LastModDate = GETDATE()
        WHERE Id = @RequestHeaderID;

        UPDATE dbo.ApprovalLogs
        SET IsComplete = 1,
            ApprovalUserID = @UserProfileID,
            DocStatus = 'X',
			Remarks = @Remarks,
			ApprovalDate =  GETDATE()
        WHERE TransactionID = @RequestTransactionTypeID
              AND TransactionHeaderID = @RequestHeaderID
              AND ApprovalLevelID = @ApprovalLevelID;

		--Added by Isuru 2025-02-05 for inserting into log table cancelled POs
		INSERT INTO  POStatusUpdate_Log(PropertyID, PoHeaderID, Status, Module, SysDate, UserID)
		SELECT @PropertyID,@RequestHeaderID,'Cancel','Approval View',GETDATE(),@UserProfileID
		--End

		--Added by Isuru 2025-02-05
		DECLARE @PRHeaderID INT
		DECLARE @IsDirectPO2 BIT =0;
		DECLARE @TEmpPR AS TABLE
        (
            RequestHeaderID INT
        );

        INSERT INTO @TEmpPR
        (
            RequestHeaderID
           
        )
        SELECT RequestHeaderID
        FROM dbo.PoWisePRs WITH(NOLOCK)
        WHERE PoHeaderID = @RequestHeaderID;

		 WHILE
        (SELECT COUNT(*) FROM @TEmpPR) > 0
        BEGIN
		SELECT TOP (1) @PRHeaderID =RequestHeaderID
		FROM @TEmpPR

		
			SELECT @IsDirectPO2 = IsDirectPo FROM PoHeaders WHERE ID = @RequestHeaderID;

			IF(ISNULL(@IsDirectPO2,0)= 0)
			BEGIN
                UPDATE dbo.RequestHeaders
                SET DocumentStatus = 'P'
                WHERE Id = @PRHeaderID;				
			END
		DELETE TOP (1) FROM @TEmpPR
		END
		--End

	-----------------Added by Nivesh 2024-10-24 Send user mail PO rejection--------------------------
	IF(@IsMailNotification = 1)
	BEGIN
		EXEC [dbo].[SendTransactionWiseEmailS] 'PO',@TransactionHeaderID,@LocationID,@PropertyID,'X'
	END
	--------------------------------------------

------------SEND MAIL TO REQUEST USER WHEN REJECT-------------------

	DECLARE @RejectUser VARCHAR(200), @RejectReason VARCHAR(MAX)

	SELECT @RequestedUser = U.UserName ,@LocationName = L.Name,@CompanyName = C.Name, @DocumentNo = PO.PoNo
	FROM PoHeaders PO WITH(NOLOCK)
	INNER JOIN UserMasters U WITH(NOLOCK) ON PO.CreatedUserID = U.Id
	INNER JOIN Locations L WITH(NOLOCK) On L.Id = PO.LocationID
	INNER JOIN Companies C WITH(NOLOCK) ON C.CompanyID =PO.PropertyID
	WHERE PO.Id = @RequestHeaderID

	SELECT @Email=E.Email
	FROM PoHeaders PO WITH(NOLOCK)
	INNER JOIN UserMasters UM  WITH(NOLOCK) ON UM.Id = PO.UserProfileID
	INNER JOIN Employees E WITH(NOLOCK) ON E.Id = UM.EmployeeId
	WHERE PO.Id = @RequestHeaderID

	SELECT @RejectUser =  U.UserName, @RejectReason = A.Remarks
	FROM PoHeaders PO WITH(NOLOCK)
	INNER JOIN ApprovalLogs A WITH(NOLOCK) ON A.TransactionHeaderID = @RequestHeaderID AND A.TransactionID = 2 AND A.DocStatus = 'X'
	INNER JOIN UserWiseApproveLevels UL WITH(NOLOCK) ON UL.ApproveLevelID = A.ApprovalLevelID 
	INNER JOIN UserMasters U WITH(NOLOCK) ON U.Id = UL.UserProfileId


		SET @EmailBody = '<html><body><p>Your Request is Rejected</p>
					  <table border = 1>
					  <thead>
						  <th  style="width: 20%" >Approval type</th>
						  <th  style="width: 20%" >Document Number</th>
						  <th  style="width: 20%" >Company Name</th>
						  <th  style="width: 20%" >Location Name</th>
						  <th  style="width: 20%" >Rejected User</th>
						  <th  style="width: 20%" >Reject Reason</th>
					  </thead>
					  <tbody >
						<tr>
						 <td  style="width: 20%" >Purchase Order Request</td>
						 <td  style="width: 20%" >'+@DocumentNo+'</td>
						 <td  style="width: 20%" >'+@CompanyName+'</td>
						 <td  style="width: 20%" >'+@LocationName+'</td>
						 <td  style="width: 20%" >'+@RejectUser+'</td>
						 <td  style="width: 20%" >'+@RejectReason+'</td>
                        </tr>
					  </tbody>
					  </table></html></body>'

	IF @Email IS NOT NULL
	BEGIN
		EXEC [dbo].[SendReuestMail] @Email, 'Reject Request',@EmailBody,2;

	END


------------SEND MAIL TO REQUEST USER WHEN REJECT-------------------


        DECLARE @TEmp AS TABLE
        (
            RequestHeaderID INT,
            RequestedQty DECIMAL,
            StockItemID INT,
            ApprovedQty DECIMAL
        );

        INSERT INTO @TEmp
        (
            RequestHeaderID,
            RequestedQty,
            StockItemID,
            ApprovedQty
        )
        SELECT RequestHeaderID,
               RequestionQty,
               StockItemID,
               ApprovedQty
        FROM dbo.PoWisePRs WITH(NOLOCK)
        WHERE PoHeaderID = @RequestHeaderID;
        --SELECT *
        --FROM dbo.PoWisePRs; --commented by Nivesh 2024-05-03

        --SELECT *
        --FROM @TEmp; --commented by Nivesh 2024-05-03

        WHILE
        (SELECT COUNT(*) FROM @TEmp) > 0
        BEGIN

            DECLARE @RequestHeadID INT,
                    @RequestionQty DECIMAL,
                    @ApprovedQty DECIMAL,
                    @ItemId INT;

            SELECT TOP (1)
                   @RequestHeadID = RequestHeaderID,
                   @RequestionQty = RequestedQty,
                   @ItemId = StockItemID,
                   @ApprovedQty = ApprovedQty
            FROM @TEmp;

            UPDATE dbo.PoWisePRs
            SET ApprovedQty = @RequestionQty
            WHERE PoHeaderID = @RequestHeaderID
                  AND StockItemID = @ItemId
                  AND RequestHeaderID = @RequestHeadID;

            IF (@ApprovedQty > 0)
            BEGIN
                UPDATE dbo.RequestDetails
                SET IssuedQuantity = (IssuedQuantity + (@RequestionQty - @ApprovedQty)) - @RequestionQty
                WHERE RequestHeaderID = @RequestHeadID
                      AND StockItemID = @ItemId;

            END;

            ELSE
            BEGIN
                UPDATE dbo.RequestDetails
                SET IssuedQuantity = IssuedQuantity - @RequestionQty
                WHERE RequestHeaderID = @RequestHeadID AND StockItemID = @ItemId;
            END;

            --for update requestheaders if request mrn based 
			------------------------Added by Nivesh 2024-10-02-------------------When rejecting the PR base PO update the document status 'C' to 'P'
			DECLARE @IsDirectPO BIT =0;
			SELECT @IsDirectPO = IsDirectPo FROM PoHeaders WHERE ID = @RequestHeaderID;

			IF(ISNULL(@IsDirectPO,0)= 0)
			BEGIN
                UPDATE dbo.RequestHeaders
                SET DocumentStatus = 'P'
                WHERE Id = @RequestHeadID;				
			END
			------------------------------------------------------

            IF EXISTS
            (
                SELECT *
                FROM dbo.MRNRegistries WITH(NOLOCK)
                WHERE RequestionID = @RequestHeadID
            )
            BEGIN

                UPDATE dbo.RequestHeaders
                SET DocumentStatus = 'P'
                WHERE Id = @RequestHeadID;

            END;



            SELECT @RequestHeadID,
                   @RequestionQty,
                   @ItemId;

            DELETE FROM @TEmp
            WHERE StockItemID = @ItemId
                  AND RequestHeaderID = @RequestHeadID;

        END;



    END;
END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000);  
    DECLARE @ErrorSeverity INT;  
    DECLARE @ErrorState INT;  
  
    SELECT   
        @ErrorMessage = ERROR_MESSAGE(),  
        @ErrorSeverity = ERROR_SEVERITY(),  
        @ErrorState = ERROR_STATE();  
  
    -- Use RAISERROR inside the CATCH block to return error  
    -- information about the original error that caused  
    -- execution to jump to the CATCH block.  
    RAISERROR (@ErrorMessage, -- Message text.  
               @ErrorSeverity, -- Severity.  
               @ErrorState -- State.  
               );  
END CATCH
END

GO

