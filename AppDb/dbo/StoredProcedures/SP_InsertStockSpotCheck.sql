-- =============================================
-- Author:		Nivesh
-- Create date: 2024-08-08
-- Description:	StockSpotCheck Insertion
-- =============================================
-- SP_InsertStockSpotCheck '<StockSpotCheckHeader xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><ID>0</ID><PropertyID>1</PropertyID><LocationID>4</LocationID><DocNo /><SpotCheckDate>2024-08-09T00:00:00</SpotCheckDate><UserID>4168</UserID><CreatedDate>2024-08-09T03:54:42.339Z</CreatedDate><StockSpotCheckDetail><StockSpotCheckDetail><ID>0</ID><StockSpotHeaderID>0</StockSpotHeaderID><StockItemID>1014</StockItemID><QuantityInHand>874</QuantityInHand><PhysicalQty>10</PhysicalQty><UserID>4168</UserID><CreatedDate>2024-08-09T03:54:42.34Z</CreatedDate><Remark>test1</Remark></StockSpotCheckDetail><StockSpotCheckDetail><ID>0</ID><StockSpotHeaderID>0</StockSpotHeaderID><StockItemID>152</StockItemID><QuantityInHand>1234</QuantityInHand><PhysicalQty>5</PhysicalQty><UserID>4168</UserID><CreatedDate>2024-08-09T03:54:42.34Z</CreatedDate><Remark>test2</Remark></StockSpotCheckDetail></StockSpotCheckDetail></StockSpotCheckHeader>'

CREATE PROCEDURE [dbo].[SP_InsertStockSpotCheck]  
(@XMLDetails XML,
 @docno VARCHAR(MAX) OUTPUT,
 @headerid INT OUTPUT
 )
AS
BEGIN
BEGIN TRANSACTION;

    BEGIN TRY
    SET NOCOUNT ON;

	DECLARE @DocumentNo VARCHAR(MAX), @PropertyID INT, @LocationID INT, @ApprovalPrefix VARCHAR(10), @ApprovalCode VARCHAR(10), @UserID INT
	, @tempStocIID INT,@IsSpotCheckApproval BIT,@SpotCheckDate DATETIME
    DECLARE @InsertedIDs_StockSpotCheckDetail TABLE (ID INT);
	
	INSERT tempStockItems
    (
        xmldata
    )
    SELECT @XMLDetails XMLDetails

    DECLARE @iDocID INT
          
    EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

    CREATE TABLE #StockSpotCheckHeaderTemp
    (
        PropertyID INT,
        LocationID INT,
        DocNo VARCHAR(20),
        SpotCheckDate DATETIME,
        UserID INT,
		Remark VARCHAR(MAX),
        CreatedDate DATETIME
    );

	    CREATE TABLE #StockSpotCheckDetailTemp
    (
        StockSpotHeaderID INT,
        StockItemID INT,
        QuantityInHand DECIMAL(18,8),
        PhysicalQty DECIMAL(18,8),
        UserID INT,
        CreatedDate DATETIME,
        Remark VARCHAR(MAX)
    );

	    INSERT INTO #StockSpotCheckHeaderTemp
    (
        PropertyID,
        LocationID,
        DocNo,
        SpotCheckDate,
        UserID,
        CreatedDate,
		Remark
    )
    SELECT 
		PropertyID,
        LocationID,
        DocNo,
        SpotCheckDate,
        UserID,
        CreatedDate = GETDATE(),
		Remark
    FROM
        OPENXML(@iDocID, '/StockSpotCheckHeader', 2)
        WITH
        (
			PropertyID INT,
			LocationID INT,
			DocNo VARCHAR(20),
			SpotCheckDate DATETIME,
			UserID INT,
			CreatedDate DATETIME,
			Remark VARCHAR(MAX)
        );

    INSERT INTO #StockSpotCheckDetailTemp
    (
        StockSpotHeaderID,
        StockItemID,
        QuantityInHand,
        PhysicalQty,
        UserID,
        CreatedDate,
        Remark 
    )
    SELECT 
        StockSpotHeaderID,
        StockItemID,
        QuantityInHand,
        PhysicalQty,
        UserID,
        CreatedDate = GETDATE(),
        Remark 
    FROM
        OPENXML(@iDocID, '/StockSpotCheckHeader/StockSpotCheckDetail/StockSpotCheckDetail', 2)
        WITH
        (
			StockSpotHeaderID INT,
			StockItemID INT,
			QuantityInHand DECIMAL(18,8),
			PhysicalQty DECIMAL(18,8),
			UserID INT,
			CreatedDate DATETIME,
			Remark VARCHAR(MAX)
        );

	------Insert Header data start-------
	DECLARE @stockSpotCheckHeaderID int
	IF EXISTS (SELECT 1 FROM #StockSpotCheckHeaderTemp)
	BEGIN
		 
		SELECT
			@PropertyID =PropertyID,
			@LocationID =LocationID,
			@UserID = UserID,
			@SpotCheckDate = SpotCheckDate
		FROM #StockSpotCheckHeaderTemp


		IF EXISTS(SELECT 1 FROM StockSpotCheckHeader WHERE SpotCheckDate = @SpotCheckDate AND LocationID = @LocationID)
		BEGIN
			RAISERROR ( 'Stock Spot Check already found for this location', 16, 1 );  
			ROLLBACK TRANSACTION
		END

		SELECT @IsSpotCheckApproval = ISNULL(IsSpotCheckApproval,0)
		FROM Companies
		WHERE CompanyID = @PropertyID

		SET @DocumentNo =  dbo.FN_GetNextDocumentNumber(@PropertyID, @LocationID, 'SS');
		SELECT @ApprovalPrefix = Prefix
        FROM dbo.Locations
        WHERE Id = @LocationID;
        SELECT @ApprovalCode = Code
        FROM dbo.TransactionTypes
        WHERE Code =  'SS';
        SELECT @ApprovalPrefix =  SUBSTRING(@ApprovalPrefix, 1,3)
        
		SET @DocumentNo = @ApprovalPrefix + '/' + @ApprovalCode + '/' + @DocumentNo;
		UPDATE TransactionTypeWiseNextNumbers
		SET NextNumber = NextNumber + 1
		WHERE LocationID = @LocationID
		AND TransactionType =  'SS';

		INSERT INTO StockSpotCheckHeader
		(
			PropertyID,
			LocationID,
			DocNo,
			SpotCheckDate,
			UserID,
			CreatedDate,
			Remark,
			IsApprove,
			FirstLevel,
			SecondLevel
		) 
		SELECT
			PropertyID,
			LocationID,
			@DocumentNo,
			SpotCheckDate,
			UserID,
			CreatedDate,
			Remark,
			CASE WHEN @IsSpotCheckApproval = 1 THEN 0 ELSE 1 END,
			CASE WHEN @IsSpotCheckApproval = 1 THEN 0 ELSE 1 END,
			CASE WHEN @IsSpotCheckApproval = 1 THEN 0 ELSE 1 END
		FROM 
		#StockSpotCheckHeaderTemp

		SET @stockSpotCheckHeaderID = SCOPE_IDENTITY();

		---------------Insert Approval Log----------------------
		IF(@IsSpotCheckApproval = 1)
		BEGIN
			DECLARE @I INT =1;
			WHILE (@I <=2)
			BEGIN
				INSERT INTO StockSpotApprovalLog(StockSpotHeaderID,PropertyID,LocationID, DocNo,SpotCheckDate,ApprovedDate,CreatedDate,RequestUserID,ApprovedUserID,Status,IsApproved,LevelNo)
				SELECT
					@stockSpotCheckHeaderID,
					PropertyID,
					LocationID,
					@DocumentNo,
					SpotCheckDate,
					NULL,
					CreatedDate,
					UserID,
					NULL,
					'P',
					0,
					@I
				FROM 
				#StockSpotCheckHeaderTemp;
				SET @I = @I +1;
			END
		END
		-------------------------------------
		EXEC Inventry_AuditTail_WriteToLog 'StockSpotCheckHeader', @stockSpotCheckHeaderID, 'INV', 'SSCHI', 'I', @UserID,@PropertyID, '', ''
	END
	------end----------------------------

	-------Insert Detail items start-----------
	IF EXISTS (SELECT 1 FROM #StockSpotCheckDetailTemp)
	BEGIN

	IF EXISTS (SELECT 1 FROM @InsertedIDs_StockSpotCheckDetail)
	BEGIN
		TRUNCATE TABLE InsertedIDs_StockSpotCheckDetail
	END

		INSERT INTO StockSpotCheckDetail
		(
			StockSpotHeaderID,
			StockItemID,
			QuantityInHand,
			PhysicalQty,
			UserID,
			CreatedDate,
			Remark,
			AveragePrice
		)
		OUTPUT INSERTED.Id INTO @InsertedIDs_StockSpotCheckDetail
		SELECT
			@stockSpotCheckHeaderID,
			StockItemID,
		--	QuantityInHand, commented by isuru 2024-09-09
			[dbo].[FN_GetStockInHand_StockSpotCheck](@PropertyID, @LocationID , StockItemID) as QuantityInHand,-- Added by isuru 2024-09-09
			PhysicalQty,
			UserID,
			CreatedDate,
			Remark,
			[dbo].[FN_GetLastAveragePrice](@LocationID , StockItemID) AveragePrice
		FROM #StockSpotCheckDetailTemp

		IF(@stockSpotCheckHeaderID IS NOT NULL)
		BEGIN

		IF(@IsSpotCheckApproval = 1)
		BEGIN
			EXEC [dbo].[SendTransactionWiseEmailS] 'S1',@stockSpotCheckHeaderID,@LocationID,@PropertyID,'P'
		END
		--DECLARE @HTMLTable VARCHAR(MAX);

			--SET @HTMLTable = 
			--'<table border="1" style="border-collapse: collapse; width: 100%;">' +
			--'<thead>' +
			--'<tr><th>Code</th><th>Name</th><th>System Qty In Hand</th><th>Quantity</th></tr>' +
			--'</thead>' +
			--'<tbody>' +
			--(
			--	SELECT STRING_AGG(
			--		'<tr><td>' + CAST(SH.StockItemCode AS NVARCHAR(10)) + 
			--		'</td><td>' + CAST(SH.Name AS VARCHAR(10)) + 
			--		'</td><td>' + CAST(ROUND(SD.QuantityInHand,2) AS VARCHAR(20)) + 
			--		 '</td><td>' + CAST(ROUND(SD.PhysicalQty,2) AS VARCHAR(20)) + 
			--		'</td></tr>', 
			--		''
			--	) AS [text()]
			--	FROM StockSpotCheckDetail SD
			--	INNER JOIN StockItemHeaders SH ON SH.Id = SD.StockItemID
			--	WHERE SD.StockSpotHeaderID = @stockSpotCheckHeaderID
			--) +
			--'</tbody>' +
			--'</table>';
			--EXEC [dbo].[SendReuestMail] 'niveshw@scienter.lk', 'Test', @HTMLTable, 2

		END
		WHILE EXISTS (SELECT 1 FROM @InsertedIDs_StockSpotCheckDetail)
		BEGIN
			SELECT TOP(1) @tempStocIID = Id FROM @InsertedIDs_StockSpotCheckDetail
			EXEC Inventry_AuditTail_WriteToLog 'StockSpotCheckDetail', @tempStocIID, 'INV', 'SSCDI', 'I', @UserID,@PropertyID, '', ''
			DELETE TOP(1) FROM @InsertedIDs_StockSpotCheckDetail
		END
	END
	-------End---------------------------------
	SELECT @docno = @DocumentNo;
	SELECT @headerid = @stockSpotCheckHeaderID;
	DROP TABLE #StockSpotCheckHeaderTemp
	DROP TABLE #StockSpotCheckDetailTemp

    COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
        ROLLBACK TRANSACTION;
        
    END CATCH
END

GO

