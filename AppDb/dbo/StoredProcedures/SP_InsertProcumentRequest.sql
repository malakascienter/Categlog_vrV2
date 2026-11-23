
-- =============================================
-- Author:        Nivesh
-- Create date:   2025-04-24
-- Description:   Insert Procurement Request
-- =============================================
-- EXEC SP_InsertProcumentRequest '<ProcurementRequest xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ID>0</ID><CompanyID>1</CompanyID><LocationID>1</LocationID><DocumentNo /><InitiatedDate /><StatusID>0</StatusID><EvaluationCriteriaID>2</EvaluationCriteriaID><NewItem /><ItemID>0</ItemID><ItemName>test yyy</ItemName><UnitID>38</UnitID><Quantity>45</Quantity><isNewItem>true</isNewItem><isSendEmail>false</isSendEmail><UserID>4168</UserID><AutoStockItemCode>true</AutoStockItemCode><CategoryID>2</CategoryID><SubCategoryID>59</SubCategoryID><SubCategoryID2>1</SubCategoryID2><stockItemRequest><Id>-1</Id><PropertyId>1</PropertyId><ItemDescription>test yyy</ItemDescription><ItemUnit>38</ItemUnit><CategoryId>2</CategoryId><SubCategoryId>59</SubCategoryId><SubCategory2Id>1</SubCategory2Id><Remarks>Request Item through procument</Remarks><ItemWiseLocation><ItemWiseLocation><text>MAIN STORES</text><id>1</id></ItemWiseLocation></ItemWiseLocation></stockItemRequest></ProcurementRequest>', '<StockItemRequestModel xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><Id>-1</Id><PropertyId>1</PropertyId><ItemDescription>test yyy</ItemDescription><ItemUnit>38</ItemUnit><CategoryId>2</CategoryId><SubCategoryId>59</SubCategoryId><SubCategory2Id>1</SubCategory2Id><Remarks>Request Item through procument</Remarks><ItemWiseLocation><ItemWiseLocation><text>MAIN STORES</text><id>1</id></ItemWiseLocation></ItemWiseLocation></StockItemRequestModel>', @docno OUTPUT, @headerid OUTPUT

CREATE PROCEDURE [dbo].[SP_InsertProcumentRequest] 
    @XMLData XML,
    @XMLRequestItemString XML,
    @docno VARCHAR(MAX) OUTPUT,
    @headerid INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE 
            @iDocID INT,
            @CompanyID INT,
            @LocationID INT,
            @DocumentNo NVARCHAR(50),
            @InitiatedDate DATETIME = GETDATE(),
            @GeneralDescription VARCHAR(MAX),
            @EvaluationCriteriaID INT,
            @ItemID INT,
            @UnitID INT,
            @Quantity DECIMAL(18,8),
            @isNewItem BIT,
            @isSendEmail BIT,
            @ItemName VARCHAR(500),
            @ApprovalPrefix VARCHAR(50),
            @ApprovalCode VARCHAR(50),
            @UserID INT,
            @IsProcurementApproval BIT = 0,
            @AutoStockItemCode BIT,
            @StockItemCode VARCHAR(100),
            @CategoryID INT,
            @SubCategoryID INT,
            @SubCategoryID2 INT;

        CREATE TABLE #TempProcurementRequest (
            ID INT NULL,
            CompanyID INT NULL,
            LocationID INT NULL,
            DocumentNo VARCHAR(MAX) NULL,
            InitiatedDate DATETIME NULL,
            StatusID INT NULL,
            GeneralDescription VARCHAR(MAX) NULL,
            EvaluationCriteriaID INT NULL,
            NewItem BIT NULL,
            ItemID INT NULL,
            ItemName VARCHAR(MAX) NULL,
            UnitID INT NULL,
            Quantity DECIMAL(18,8) NULL,
            IsApprove BIT NULL,
            isNewItem BIT NULL,
            isSendEmail BIT NULL,
            UserID INT NULL,
            AutoStockItemCode BIT NULL,
            StockItemCode VARCHAR(100) NULL,
            CategoryID INT NULL,
            SubCategoryID INT NULL,
            SubCategoryID2 INT NULL
        );

        CREATE TABLE #TempUserApproval (
            UserProfileId INT,
            ApproveLevelID INT,
            TransactionTypeID INT,
            SeqID INT
        );
		DECLARE @InsertedIDs_TempProcurement TABLE (ID INT);
        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLData;

        INSERT INTO #TempProcurementRequest
        SELECT *
        FROM OPENXML(@iDocID, '/ProcurementRequest', 2)
        WITH (
            ID INT,
            CompanyID INT,
            LocationID INT,
            DocumentNo VARCHAR(MAX),
            InitiatedDate DATETIME,
            StatusID INT,
            GeneralDescription VARCHAR(MAX),
            EvaluationCriteriaID INT,
            NewItem BIT,
            ItemID INT,
            ItemName VARCHAR(MAX),
            UnitID INT,
            Quantity DECIMAL(18,8),
            IsApprove BIT,
            isNewItem BIT,
            isSendEmail BIT,
            UserID INT,
            AutoStockItemCode BIT,
            StockItemCode VARCHAR(100),
            CategoryID INT,
            SubCategoryID INT,
            SubCategoryID2 INT
        );

        SELECT
            @CompanyID = CompanyID,
            @LocationID = LocationID,
            @GeneralDescription = GeneralDescription,
            @EvaluationCriteriaID = EvaluationCriteriaID,
            @ItemID = ItemID,
            @UnitID = UnitID,
            @Quantity = Quantity,
            @isNewItem = isNewItem,
            @isSendEmail = isSendEmail,
            @ItemName = ItemName,
            @UserID = UserID,
            @AutoStockItemCode = AutoStockItemCode,
            @StockItemCode = StockItemCode,
            @CategoryID = CategoryID,
            @SubCategoryID = SubCategoryID,
            @SubCategoryID2 = SubCategoryID2
        FROM #TempProcurementRequest;

        SET @isNewItem = ISNULL(@isNewItem, 0);
        SET @isSendEmail = ISNULL(@isSendEmail, 0);

        -- Validation Section
        IF (@CompanyID IS NULL OR @CompanyID = 0)
            THROW 50001, 'Invalid Company', 1;

        IF (@LocationID IS NULL OR @LocationID = 0)
            THROW 50002, 'Invalid Location', 1;

        IF ((@ItemID IS NULL OR @ItemID = 0) AND @isNewItem = 0)
            THROW 50003, 'Invalid Item', 1;

        IF ((@ItemName IS NULL OR @ItemName = '') AND @isNewItem = 1)
            THROW 50004, 'Provide Item Name', 1;

        IF (@UnitID IS NULL OR @UnitID = 0)
            THROW 50005, 'Invalid Unit', 1;

        IF (@EvaluationCriteriaID IS NULL OR @EvaluationCriteriaID = 0)
            THROW 50006, 'Invalid Evaluation Template', 1;

        IF (@Quantity IS NULL OR @Quantity <= 0)
            THROW 50007, 'Quantity cannot be less than or equal to zero', 1;

        IF ((@UserID IS NULL OR @UserID = 0) AND @IsProcurementApproval = 1)
            THROW 50008, 'Invalid User', 1;

        -- Item Existence Check
        IF (@isNewItem = 0 
            AND NOT EXISTS (
                SELECT 1
                FROM StockItemHeaders SIH
                INNER JOIN StockItemDetails SID ON SID.StockItemHeaderID = SIH.Id
                WHERE SIH.Id = @ItemID
                AND SID.LocationID = @LocationID
            ))
            THROW 50009, 'Item does not exist', 1;

        -- New Item Validation
        IF (@isNewItem = 1)
        BEGIN
            IF EXISTS (
                SELECT 1 FROM StockItemHeaders WHERE Name = TRIM(@ItemName)
                UNION ALL
                SELECT 1 FROM ProcurementRequest WHERE ItemName = TRIM(@ItemName)
            )
                THROW 50010, 'Item already exists or requested', 1;

            IF (@AutoStockItemCode = 0 AND (ISNULL(@StockItemCode, '') = ''))
                THROW 50011, 'Provide stock item code', 1;

            IF @AutoStockItemCode = 0 AND (
                EXISTS (SELECT 1 FROM TempStockItemRequest WHERE UPPER(ItemCode) = UPPER(@StockItemCode))
                OR EXISTS (SELECT 1 FROM StockItemHeaders WHERE UPPER(StockItemCode) = UPPER(@StockItemCode))
            )
                THROW 50012, 'Item code already exists', 1;

            IF @AutoStockItemCode = 0 AND EXISTS (SELECT 1 FROM TempStockItemRequest WHERE UPPER(ItemDescription) = UPPER(@ItemName))
                THROW 50013, 'Item description already exists', 1;

            IF (@CategoryID IS NULL OR @CategoryID = 0)
                THROW 50014, 'Provide Category', 1;

            IF (@SubCategoryID IS NULL OR @SubCategoryID = 0)
                THROW 50015, 'Provide SubCategory', 1;

            IF (@SubCategoryID2 IS NULL OR @SubCategoryID2 = 0)
                THROW 50016, 'Provide SubCategory2', 1;
        END

        -- Record Existence Validation
        IF NOT EXISTS (
            SELECT 1
            FROM #TempProcurementRequest TPR
            INNER JOIN Locations L ON L.Id = TPR.LocationID
            INNER JOIN Units U ON U.Id = TPR.UnitID
            INNER JOIN EvaluationTemplate ET ON ET.ID = TPR.EvaluationCriteriaID
        )
            THROW 50017, 'Record not saved', 1;

     
       

        SET @DocumentNo = dbo.FN_GetNextDocumentNumber(@CompanyID, @LocationID, 'PC');

        IF (@DocumentNo IS NULL)
        BEGIN
            INSERT INTO TransactionTypeWiseNextNumbers (
                PropertyID, LocationID, TransactionType, NextNumber, LengthOfFormatting
            )
            VALUES (
                @CompanyID, @LocationID, 'PC', 1, 6
            );

            SET @DocumentNo = dbo.FN_GetNextDocumentNumber(@CompanyID, @LocationID, 'PC');
        END;

        SELECT @ApprovalPrefix = SUBSTRING(Prefix, 1, 3)
        FROM dbo.Locations
        WHERE Id = @LocationID;

        SELECT @ApprovalCode = Code
        FROM dbo.TransactionTypes
        WHERE Code = 'PC';

        SET @DocumentNo = @ApprovalPrefix + '/' + @ApprovalCode + '/' + @DocumentNo;

        UPDATE TransactionTypeWiseNextNumbers
        SET NextNumber = NextNumber + 1
        WHERE LocationID = @LocationID
          AND TransactionType = 'PC';

        IF NOT EXISTS(  SELECT 1
            FROM UserWiseApproveLevels UWAL
            INNER JOIN TransactionWiseApprovalTypes TWAT ON UWAL.TransactionTypeID = TWAT.TransactionID
            AND UWAL.ApproveLevelID = TWAT.ApprovalTypeID
			INNER JOIN TransactionTypes TT ON TT.Id = UWAL.TransactionTypeID
            WHERE TWAT.LocationID = @LocationID
              AND TT.Code = 'PC')
        BEGIN
            INSERT INTO ProcurementRequest (
                CompanyID, LocationID, DocumentNo, InitiatedDate, StatusID, GeneralDescription, EvaluationCriteriaID,
                NewItem, ItemID, ItemName, UnitID, Quantity, IsApprove, UserID, XMLRequestItem
            )
            SELECT 
                CompanyID, LocationID, @DocumentNo, @InitiatedDate, 1, GeneralDescription, EvaluationCriteriaID,
                @isNewItem, ItemID, @ItemName, UnitID, Quantity, 1, UserID, @XMLRequestItemString
            FROM #TempProcurementRequest
            WHERE 1=1;

            SET @headerid = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            INSERT INTO #TempUserApproval
            SELECT UWAL.UserProfileId, UWAL.ApproveLevelID, UWAL.TransactionTypeID, TWAT.SeqID
            FROM UserWiseApproveLevels UWAL
            INNER JOIN TransactionWiseApprovalTypes TWAT ON UWAL.TransactionTypeID = TWAT.TransactionID
            AND UWAL.ApproveLevelID = TWAT.ApprovalTypeID
			INNER JOIN TransactionTypes TT ON TT.Id = UWAL.TransactionTypeID
            WHERE TWAT.LocationID = @LocationID
               AND TT.Code = 'PC';

            IF NOT EXISTS (SELECT 1 FROM #TempUserApproval)
                THROW 50018, 'Please set Approval', 1;

            INSERT INTO ProcurementRequest (
                CompanyID, LocationID, DocumentNo, InitiatedDate, StatusID, GeneralDescription, EvaluationCriteriaID,
                NewItem, ItemID, ItemName, UnitID, Quantity, IsApprove, UserProfileId, ApproveLevelID, SeqID, UserID, XMLRequestItem
            )
			OUTPUT INSERTED.Id INTO @InsertedIDs_TempProcurement
            SELECT 
                @CompanyID, @LocationID, @DocumentNo, @InitiatedDate, 1, @GeneralDescription, @EvaluationCriteriaID,
                @isNewItem, @ItemID, @ItemName, @UnitID, @Quantity, 0, UserProfileId, ApproveLevelID, SeqID, @UserID, @XMLRequestItemString
            FROM #TempUserApproval;

            SET @headerid = SCOPE_IDENTITY();
        END

		--Updating StockItemHeaderID when existing item
		IF (@isNewItem = 0)
        BEGIN
			UPDATE ProcurementRequest
				SET StockItemHeaderID = @ItemID
				WHERE Id = @headerid

		END
		--ENd

        -- Insert Stock Item Request if new item
   --     IF (@isNewItem = 1)
   --     BEGIN
			--DECLARE @OutputInsertedID INT
   --         EXEC [dbo].[SP_InsertStockItemRequest] @XMLRequestItemString, 1, @OutputInsertedID OUTPUT;

			--select @OutputInsertedID OutputInsertedID
			--IF EXISTS(SELECT 1 FROM @InsertedIDs_TempProcurement) AND @OutputInsertedID IS NOT NULL
			--BEGIN
			--	UPDATE PCR
			--	SET StockItemRequestID = @OutputInsertedID
			--	FROM ProcurementRequest PCR
			--	INNER JOIN @InsertedIDs_TempProcurement ITPC ON ITPC.ID = PCR.ID
			--END
			--ELSE IF(@OutputInsertedID IS NOT NULL)
			--BEGIN
			--	UPDATE ProcurementRequest
			--	SET StockItemRequestID = @OutputInsertedID
			--	WHERE Id = @headerid
			--END

   --     END

        -- Set Output
        SET @docno = @DocumentNo;

        EXEC sp_xml_removedocument @iDocID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END

GO

