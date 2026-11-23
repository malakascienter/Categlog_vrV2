-- =============================================
-- Author:		Nivesh
-- Create date: 2025-02-12
-- Description:	Issue Request checking multiple item GL Mapping
-- =============================================
-- CheckGLMappingsForMultipleItems ''

CREATE PROCEDURE [dbo].[CheckGLMappingsForMultipleItems]
	@json NVARCHAR(MAX),
	@TransactionType CHAR(2),
	@LocationID INT,
	@propertyID INT,
	@DepartmentID INT
	--WITH RECOMPILE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @StockItemID1 INT, @LocationID1 INT = @LocationID, @PropertyID1 INT = @propertyID, @DepartmentID1 INT = @DepartmentID, @HaveMapping BIT;

	SELECT id StockItemID,@LocationID1 LocationID,@PropertyID1 PropertyID, @DepartmentID1 DepartmentID,0 HaveMapping into #tempTable
	FROM OPENJSON(@json)
	WITH (
		 id INT
	) --Extract Json Stock Item Id into table

	DECLARE cur CURSOR FORWARD_ONLY FAST_FORWARD 
	FOR 
	SELECT StockItemID, LocationID, PropertyID, DepartmentID 
	FROM #tempTable;

	-- Step 2: Open Cursor
	OPEN cur;

	-- Step 3: Fetch First Row
	FETCH NEXT FROM cur INTO @StockItemID1, @LocationID1, @PropertyID1, @DepartmentID1;

	-- Step 4: Loop Through Each Row
	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- Call Stored Procedure for Each Row
		EXEC [dbo].[CheckGLMappings] 
			@StockItemID1, 
			'RI', 
			@LocationID1, 
			@PropertyID1, 
			@DepartmentID1, 
			@HaveMapping OUTPUT;

		-- Update the temporary table with the result
		UPDATE #tempTable
		SET HaveMapping = @HaveMapping
		WHERE StockItemID = @StockItemID1;

		-- Fetch Next Row
		FETCH NEXT FROM cur INTO @StockItemID1, @LocationID1, @PropertyID1, @DepartmentID1;
	END

	-- Step 5: Close and Deallocate Cursor
	CLOSE cur;
	DEALLOCATE cur;

	SELECT StockItemID FROM #tempTable WHERE HaveMapping=0 --Get GL mapping error items list

END

GO

