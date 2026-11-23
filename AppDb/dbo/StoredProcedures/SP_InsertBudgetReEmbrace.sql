-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2024-08-27
-- Description:	Inserting Budget ReEmrace

-- [dbo].[SP_InsertBudgetReEmbrace]  '<ArrayOfBudgetReEmbrace xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><BudgetReEmbrace><ID>2027</ID><DocumentNo>MS/GR/000332</DocumentNo><SupName>ACCENTURE DISTRIBUTORS</SupName><ReferenceNo>656jhjh</ReferenceNo><TransactionDate>2024-08-27</TransactionDate><LocationName>MAIN STOREfs</LocationName><Budget>0</Budget><PaidAmount>0</PaidAmount><GRNTotal>948.75</GRNTotal><Balance>948.75</Balance><IsSelected>true</IsSelected><CreatedUserID>4168</CreatedUserID></BudgetReEmbrace><BudgetReEmbrace><ID>2015</ID><DocumentNo>MS/GR/000328</DocumentNo><SupName>ACCENTURE DISTRIBUTORS</SupName><ReferenceNo>ghgh5656gf</ReferenceNo><TransactionDate>2024-08-27</TransactionDate><LocationName>MAIN STOREfs</LocationName><Budget>0</Budget><PaidAmount>0</PaidAmount><GRNTotal>9397.5</GRNTotal><Balance>9397.5</Balance><IsSelected>true</IsSelected><CreatedUserID>4168</CreatedUserID></BudgetReEmbrace><BudgetReEmbrace><ID>2014</ID><DocumentNo>MS/GR/000327</DocumentNo><SupName>ACCENTURE DISTRIBUTORS</SupName><ReferenceNo>gg7666</ReferenceNo><TransactionDate>2024-08-27</TransactionDate><LocationName>MAIN STOREfs</LocationName><Budget>0</Budget><PaidAmount>0</PaidAmount><GRNTotal>1339.75</GRNTotal><Balance>1339.75</Balance><IsSelected>true</IsSelected><CreatedUserID>4168</CreatedUserID></BudgetReEmbrace><BudgetReEmbrace><ID>2027</ID><DocumentNo>MS/GR/000332</DocumentNo><SupName>ACCENTURE DISTRIBUTORS</SupName><ReferenceNo>656jhjh</ReferenceNo><TransactionDate>2024-08-27</TransactionDate><LocationName>MAIN STOREfs</LocationName><Budget>0</Budget><PaidAmount>0</PaidAmount><GRNTotal>948.75</GRNTotal><Balance>948.75</Balance><IsSelected>true</IsSelected><CreatedUserID>4168</CreatedUserID></BudgetReEmbrace><BudgetReEmbrace><ID>2015</ID><DocumentNo>MS/GR/000328</DocumentNo><SupName>ACCENTURE DISTRIBUTORS</SupName><ReferenceNo>ghgh5656gf</ReferenceNo><TransactionDate>2024-08-27</TransactionDate><LocationName>MAIN STOREfs</LocationName><Budget>0</Budget><PaidAmount>0</PaidAmount><GRNTotal>9397.5</GRNTotal><Balance>9397.5</Balance><IsSelected>true</IsSelected><CreatedUserID>4168</CreatedUserID></BudgetReEmbrace><BudgetReEmbrace><ID>2014</ID><DocumentNo>MS/GR/000327</DocumentNo><SupName>ACCENTURE DISTRIBUTORS</SupName><ReferenceNo>gg7666</ReferenceNo><TransactionDate>2024-08-27</TransactionDate><LocationName>MAIN STOREfs</LocationName><Budget>0</Budget><PaidAmount>0</PaidAmount><GRNTotal>1339.75</GRNTotal><Balance>1339.75</Balance><IsSelected>true</IsSelected><CreatedUserID>4168</CreatedUserID></BudgetReEmbrace></ArrayOfBudgetReEmbrace>'


-- =============================================
CREATE PROCEDURE [dbo].[SP_InsertBudgetReEmbrace]  
(@XMLDetails XML)
AS
BEGIN
BEGIN TRANSACTION

 BEGIN TRY
	SET NOCOUNT ON;

	DECLARE @ReleasedBudget decimal(18,8),@BudgetID INT, @tempStocIID int, @LastModUserID INT, @PropertyID INT =0
		IF OBJECT_ID('tempdb..#BudgetReEmberceTemp') IS NOT NULL
		DROP TABLE #BudgetReEmberceTemp
		IF OBJECT_ID('tempdb..#BudgetReEmberceTemp2') IS NOT NULL
		DROP TABLE #BudgetReEmberceTemp2
		IF OBJECT_ID('tempdb..#TempBudgets') IS NOT NULL
		DROP TABLE #TempBudgets

	INSERT tempBudgetReEmbrece
    (
        xmldata
    )
	SELECT @XMLDetails XMLDetails

	 DECLARE @iDocID INT, @IsEdit BIT =0
          
    EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;
	
	DECLARE @InsertedIDs_StockTransactionWiseBudgetPayment TABLE (ID INT,UserID INT);
	
	CREATE TABLE #BudgetReEmberceTemp
    (
         ID INT,
		 DocumentNo VARCHAR(200),
		 SupName VARCHAR(200),
		 ReferenceNo VARCHAR(100),
		 TransactionDate DATE,
		 LocationName VARCHAR(100),
		 Budget DECIMAL(18, 8),
		 PaidAmount DECIMAL(18, 8),
		 GRNTotal DECIMAL(18, 8),
		 Balance DECIMAL(18, 8),
		 IsSelected BIT,
		 CreatedUserID INT,
		 Payment DECIMAL(18, 8)
    );

	    INSERT INTO #BudgetReEmberceTemp
    (
          ID,
		 DocumentNo,
		 SupName,
		 ReferenceNo,
		 TransactionDate ,
		 LocationName,
		 Budget ,
		 PaidAmount ,
		 GRNTotal ,
		 Balance,
		 IsSelected,
		 CreatedUserID,
		 Payment
    )
    SELECT 
		  ID,
		 DocumentNo,
		 SupName,
		 ReferenceNo,
		 TransactionDate ,
		 LocationName,
		 Budget ,
		 PaidAmount ,
		 GRNTotal ,
		 Balance,
		 IsSelected,
		 CreatedUserID,
		 Payment
    FROM
        OPENXML(@iDocID, 'ArrayOfBudgetReEmbrace/BudgetReEmbrace', 2)
        WITH
        (
		 ID INT,
		 DocumentNo VARCHAR(200),
		 SupName VARCHAR(200),
		 ReferenceNo VARCHAR(100),
		 TransactionDate DATE,
		 LocationName VARCHAR(100),
		 Budget DECIMAL(18, 8),
		 PaidAmount DECIMAL(18, 8),
		 GRNTotal DECIMAL(18, 8),
		 Balance DECIMAL(18, 8),
		 IsSelected BIT,
		 CreatedUserID INT,
		 Payment DECIMAL(18, 8)
        );
		
		IF EXISTS (SELECT 1 FROM @InsertedIDs_StockTransactionWiseBudgetPayment)
		BEGIN
			TRUNCATE TABLE #InsertedIDs_StockTransactionWiseBudgetPayment
		END


		INSERT INTO StockTransactionWiseBudgetPayment(StockTransactionHeaderID, PaidAmount, BudgetID, UserID, SysDateTime)
		OUTPUT INSERTED.Id, INSERTED.UserID INTO @InsertedIDs_StockTransactionWiseBudgetPayment
		SELECT SH.Id,BT.Payment,SH.BudgetID,BT.CreatedUserID,GETDATE()
		FROM #BudgetReEmberceTemp BT
		INNER JOIN StockTransactionHeaders SH ON BT.ID = SH.Id

		WHILE EXISTS (SELECT 1 FROM @InsertedIDs_StockTransactionWiseBudgetPayment)
		BEGIN
			SELECT TOP(1) @tempStocIID = Id, @LastModUserID = UserID FROM @InsertedIDs_StockTransactionWiseBudgetPayment
			EXEC Inventry_AuditTail_WriteToLog 'StockTransactionWiseBudgetPayment', @tempStocIID, 'INV', 'STWBPI', 'I', @LastModUserID,@PropertyID, '', ''
			DELETE TOP(1) FROM @InsertedIDs_StockTransactionWiseBudgetPayment
		END

		SELECT SUM(BT.Payment) Payment,SH.BudgetID
		INTO #TempBudgets
		FROM #BudgetReEmberceTemp BT
		INNER JOIN StockTransactionHeaders SH ON BT.ID = SH.Id
		GROUP BY SH.BudgetID

		

		UPDATE SH
		SET SH.PaidAmount = SH.PaidAmount + BT.Payment
		from #BudgetReEmberceTemp BT
		INNER JOIN StockTransactionHeaders SH ON BT.ID = SH.Id

		SELECT * INTO #BudgetReEmberceTemp2 FROM #BudgetReEmberceTemp

		IF EXISTS (SELECT 1 from #BudgetReEmberceTemp2 BT
		INNER JOIN StockTransactionHeaders SH ON BT.ID = SH.Id)
		BEGIN
			SELECT TOP 1 @tempStocIID = BT.ID, @LastModUserID = BT.CreatedUserID from #BudgetReEmberceTemp2 BT
			INNER JOIN StockTransactionHeaders SH ON BT.ID = SH.Id
			
			EXEC Inventry_AuditTail_WriteToLog 'StockTransactionHeaders', @BudgetID, 'INV', 'STU', 'U', @LastModUserID,@PropertyID, '', ''
			
			DELETE TOP (1) FROM #BudgetReEmberceTemp2 WHERE ID = @tempStocIID
		END
	

		WHILE EXISTS(SELECT 1 FROM #TempBudgets)
		BEGIN
			SELECT TOP (1)@ReleasedBudget = Payment,@BudgetID = BudgetID FROM #TempBudgets

			UPDATE BudgetAllocation
			SET Balance = Balance + @ReleasedBudget , UtilizeAmount = UtilizeAmount - @ReleasedBudget
			WHERE ID = @BudgetID

			SELECT @LastModUserID = BT.CreatedUserID FROM #BudgetReEmberceTemp BT
			INNER JOIN StockTransactionHeaders SH ON BT.ID = SH.Id
			WHERE SH.BudgetID = @BudgetID

			EXEC Inventry_AuditTail_WriteToLog 'BudgetAllocation', @BudgetID, 'INV', 'BAU', 'U', @LastModUserID,@PropertyID, '', ''

			DELETE TOP(1) FROM #TempBudgets
		END
		
	
		
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

