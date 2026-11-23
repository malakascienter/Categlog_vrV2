 --[dbo].[SP_Save_DepartmentWiseItems] '<ArrayOfDepartmentWiseItems xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><DepartmentWiseItems><DepartmentId>6</DepartmentId><StockItemId>1007</StockItemId></DepartmentWiseItems><DepartmentWiseItems><DepartmentId>6</DepartmentId><StockItemId>1061</StockItemId></DepartmentWiseItems><DepartmentWiseItems><DepartmentId>2</DepartmentId><StockItemId>1007</StockItemId></DepartmentWiseItems><DepartmentWiseItems><DepartmentId>2</DepartmentId><StockItemId>1061</StockItemId></DepartmentWiseItems></ArrayOfDepartmentWiseItems>'

 --go
CREATE PROCEDURE [dbo].[SP_Save_DepartmentWiseItems](@XMLDetails XML)

	
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
		
DECLARE @iDocID INT, @DeptId INT, @StopckItemId INT

	EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails
	SELECT * INTO #TempDeptWiseItems FROM OPENXML (@iDocID,'/ArrayOfDepartmentWiseItems/DepartmentWiseItems',2) WITH(DepartmentId INT ,StockItemId  INT ) 

	EXEC InsertMasterFileChangeLog 'Department Wise Items',1,'I','Department Wise Items'

	--print('point 0') --Commented by Nivesh 2024-02-26
	IF EXISTS (SELECT * FROM departmentwiseitems DI INNER JOIN #TempDeptWiseItems TI ON DI.DepartmentId = TI.DepartmentId 
				AND DI.StockItemId = TI.StockItemId)
	BEGIN
	--print ('point 1') --Commented by Nivesh 2024-02-26
		DELETE TI FROM #TempDeptWiseItems TI INNER JOIN departmentwiseitems DI ON DI.DepartmentId = TI.DepartmentId 
				AND DI.StockItemId = TI.StockItemId
	END
	--print('point 2') --Commented by Nivesh 2024-02-26
	DECLARE @InsertedIDs_departmentwiseitems TABLE (ID INT);
	DECLARE @tempDeWiIt int = null 

	INSERT INTO departmentwiseitems
	OUTPUT INSERTED.Id INTO @InsertedIDs_departmentwiseitems --Added by Nivesh 2024-02-26
	SELECT * FROM #TempDeptWiseItems
		---------------------------------------Log departmentwiseitems Insert 2024-02-26---------------------------------------
	WHILE EXISTS (SELECT 1 FROM @InsertedIDs_departmentwiseitems)
	BEGIN
		SELECT TOP(1) @tempDeWiIt = Id FROM @InsertedIDs_departmentwiseitems
		EXEC Inventry_AuditTail_WriteToLog 'DepartmentWiseItems', @tempDeWiIt, 'INV', 'DWII', 'I', 0,0, '', ''
		DELETE TOP(1) FROM @InsertedIDs_departmentwiseitems
	END
		------------------------------------------------------------------------------

        COMMIT TRANSACTION;
    END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION
	
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);

	END CATCH

END

GO

