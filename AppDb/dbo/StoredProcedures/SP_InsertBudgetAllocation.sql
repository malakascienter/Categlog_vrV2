-- =============================================
-- Author:		Nivesh
-- Create date: 2024-08-26
-- Description:	Budget Allocation Insertion
-- =============================================
-- SP_InsertBudgetAllocation '<?xml version="1.0"?><BudgetAllocation xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><ID>3</ID><IsEdit>1</IsEdit><LocationID>2</LocationID><PropertyID>3</PropertyID><Budget>20000.00</Budget><Balance>5000.00</Balance><UtilizeAmount>2000.00</UtilizeAmount><CreatedUserID>4</CreatedUserID><LastModUserID>5</LastModUserID><CreatedDate>2024-08-26T10:00:00</CreatedDate><LastModDate>2024-08-27T12:00:00</LastModDate></BudgetAllocation>'

CREATE PROCEDURE [dbo].[SP_InsertBudgetAllocation]  
(@XMLDetails XML
 )
AS
BEGIN
BEGIN TRANSACTION;

    BEGIN TRY
    SET NOCOUNT ON;

    INSERT tempBudgetAllocation
    (
        xmldata
    )
    SELECT @XMLDetails XMLDetails

    DECLARE @iDocID INT, @IsEdit BIT =0, @UserId INT, @PropertyID INT, @UpdateID INT
          
    EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

    CREATE TABLE #BudgetAllocationTemp
    (
        LocationID INT,
        PropertyID INT,
        Budget decimal(18, 8),
		Balance decimal(18, 8),
		UtilizeAmount decimal(18, 8),
        CreatedUserID INT,
        LastModUserID INT,
		CreatedDate DATETIME,
        LastModDate DATETIME,
		IsEdit BIT,
		ID INT
    );

	    INSERT INTO #BudgetAllocationTemp
    (
        LocationID,
        PropertyID,
        Budget,
        Balance,
        UtilizeAmount,
        CreatedUserID,
		LastModUserID,
		CreatedDate,
		LastModDate,
		IsEdit,
		ID
    )
    SELECT 
		 LocationID,
        PropertyID,
        Budget,
        Balance,
        UtilizeAmount,
        CreatedUserID,
		LastModUserID,
		CreatedDate,
		LastModDate,
		IsEdit,
		ID
    FROM
        OPENXML(@iDocID, '/BudgetAllocation', 2)
        WITH
        (
		LocationID INT,
        PropertyID INT,
        Budget decimal(18, 8),
		Balance decimal(18, 8),
		UtilizeAmount decimal(18, 8),
        CreatedUserID INT,
        LastModUserID INT,
		CreatedDate DATETIME,
        LastModDate DATETIME,
		IsEdit BIT,
		ID INT
        );

		SELECT * FROM #BudgetAllocationTemp

		SELECT @IsEdit=IsEdit FROM #BudgetAllocationTemp

		IF(@IsEdit IS NULL )
		BEGIN
			SET @IsEdit = 0
		END

	------Insert Header data start-------
	
	IF EXISTS (SELECT 1 FROM #BudgetAllocationTemp)
	BEGIN

		IF(@IsEdit = 0) --If transaction IsEdit is 0 then insert the data
		BEGIN

		SELECT
			@PropertyID = PropertyID,
			@UserId = CreatedUserID
			FROM 
			#BudgetAllocationTemp
	
			INSERT INTO BudgetAllocation
			(
			 LocationID,
			PropertyID,
			Budget,
			Balance,
			UtilizeAmount,
			CreatedUserID,
			LastModUserID,
			CreatedDate,
			LastModDate
			) 
			SELECT
			LocationID,
			PropertyID,
			Budget,
			Budget,
			0,
			CreatedUserID,
			LastModUserID,
			GETDATE(),
			GETDATE()
			FROM 
			#BudgetAllocationTemp

			SET @UpdateID = SCOPE_IDENTITY()
		
			EXEC Inventry_AuditTail_WriteToLog 'BudgetAllocation', @UpdateID, 'INV', 'BAI', 'I', @UserId,@PropertyID, '', ''
		END
		ELSE IF (@IsEdit = 1) --If transaction IsEdit is 1 then update the data
		BEGIN
			
			SELECT @UpdateID = B.ID, @UserId = BT.LastModUserID, @PropertyID = BT.PropertyID
			FROM BudgetAllocation B
			INNER JOIN #BudgetAllocationTemp BT ON BT.ID = B.ID
			
			UPDATE B
			SET B.Budget = BT.Budget,
			B.Balance = BT.Budget - B.UtilizeAmount,
			B.LastModDate = GETDATE(),
			B.LastModUserID = BT.LastModUserID
			FROM BudgetAllocation B
			INNER JOIN #BudgetAllocationTemp BT ON BT.ID = B.ID

			IF EXISTS (SELECT 1 FROM BudgetAllocation B
			INNER JOIN #BudgetAllocationTemp BT ON BT.ID = B.ID)
			BEGIN
				EXEC Inventry_AuditTail_WriteToLog 'BudgetAllocation', @UpdateID, 'INV', 'BAU', 'U', @UserId,@PropertyID, '', ''
			END
		END
	END
	------end----------------------------

	DROP TABLE #BudgetAllocationTemp

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

