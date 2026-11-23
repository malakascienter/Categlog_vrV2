-- =============================================
-- Author:		Nivesh
-- Create date: 2024-12-13
-- Description:	Insert Batch Transaction
-- =============================================
-- InsertBatchTransactions '<ArrayOfBatchTransactionGrid xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><BatchTransactionGrid><Id>14677</Id></BatchTransactionGrid><BatchTransactionGrid><Id>10556</Id></BatchTransactionGrid><BatchTransactionGrid><Id>10510</Id></BatchTransactionGrid><BatchTransactionGrid><Id>10528</Id></BatchTransactionGrid><BatchTransactionGrid><Id>10530</Id></BatchTransactionGrid></ArrayOfBatchTransactionGrid>',4168,1

CREATE PROCEDURE [dbo].[InsertBatchTransactions] 
	@XMLDetails xml,
	@UserId INT,
	@PropertyID INT,
	@LocationID INT,
	@SupplierID INT,
	@DocNo VARCHAR(MAX) OUTPUT,
    @BatchTransactionHeaderID INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY 
	BEGIN TRANSACTION
	DECLARE @iDocID INT, @ApprovalPrefix VARCHAR(MAX), @ApprovalCode VARCHAR(MAX)
	CREATE TABLE #BatchTransactionGrid  (
		Id INT
	)
	
	EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

	INSERT INTO #BatchTransactionGrid
	SELECT *
	FROM OPENXML(@iDocID, 'ArrayOfBatchTransactionGridDetail/BatchTransactionGridDetail', 2)
	WITH (
	Id INT
	)

	IF NOT EXISTS(SELECT 1 FROM #BatchTransactionGrid)
	BEGIN
		RAISERROR('Select GRN',16,1)
		ROLLBACK TRANSACTION
	END

    SET @DocNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @LocationID, 'BT');
	IF @DocNo IS NULL
    BEGIN
        INSERT INTO TransactionTypeWiseNextNumbers
        (
                PropertyID,
                LocationID,
                TransactionType,
                NextNumber,
                LengthOfFormatting
        )
        VALUES
        (@PropertyID, @LocationID, 'BT', 1, 6);
        SET @DocNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @LocationID, 'BT');
    END;
    
	SET @ApprovalPrefix = NULL;
    SELECT @ApprovalPrefix = Prefix
    FROM dbo.Locations
    WHERE Id = @LocationID;

	IF (@ApprovalPrefix IS NULL)
	BEGIN
		SET @ApprovalPrefix = 'ALL'
	END
    SELECT @ApprovalCode = Code
    FROM dbo.TransactionTypes
    WHERE Code =  'BT';
    SELECT @ApprovalPrefix =  SUBSTRING(@ApprovalPrefix, 1,3)
        
    SET @DocNo = @ApprovalPrefix + '/' + @ApprovalCode + '/' + @DocNo;
    UPDATE TransactionTypeWiseNextNumbers
    SET NextNumber = NextNumber + 1
    WHERE LocationID = @LocationID
    AND TransactionType =  'BT';                
	
	INSERT INTO [dbo].[BatchTransactionHeader]
           ([DocNo]
           ,[PropertyID]
           ,[CreatedUserID]
           ,[CreatedDate],
		   LocationID,
		   SupplierID)
     VALUES
           (@DocNo
           ,@PropertyID
           ,@UserId
           ,GETDATE(),
		   @LocationID,
		   @SupplierID)
	SET @BatchTransactionHeaderID = SCOPE_IDENTITY()

	INSERT INTO [dbo].[BatchTransactionDetail]
           ([BatchTransactionHeaderID]
           ,[TransactionID]
           ,[CreatedUserID]
           ,[CreatedDate])
     SELECT 
	 @BatchTransactionHeaderID,
	 Id,
	 @UserId,
	 GETDATE()
	 FROM #BatchTransactionGrid
           
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT>0
		ROLLBACK TRANSACTION
			DECLARE @ErrorMessage NVARCHAR(4000);  
			DECLARE @ErrorSeverity INT;  
			DECLARE @ErrorState INT;  

			SELECT   
			@ErrorMessage = ERROR_MESSAGE(),  
			@ErrorSeverity = ERROR_SEVERITY(),  
			@ErrorState = ERROR_STATE(); 
			RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
	END CATCH;
END

GO

