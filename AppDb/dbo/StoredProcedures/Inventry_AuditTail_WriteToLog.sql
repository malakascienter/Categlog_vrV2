-- =============================================
-- Author:			Stehani
-- Create date:		26/11/2020
-- Modified by:		Nivesh
-- Modified date:	2024-02-15
-- Description:	Hotel transaction log Details

-- EXEC Inventry_AuditTail_WriteToLog 'Location', 2064, 'MEM', 'MU', 'U', 4168, '', ''

-- =============================================
CREATE PROCEDURE [dbo].[Inventry_AuditTail_WriteToLog]
		@TableName		NVARCHAR(250),
		@Id				INT ,	
		@Module			NVARCHAR(10), 
		@Process		NVARCHAR(10), 
		@Action			NVARCHAR(10), 
		@UserId			INT,
		@PropertyId		INT,
		@Reference01	NVARCHAR(250) = NULL,
		@Reference02	NVARCHAR(250) = NULL,
		@Reference03	NVARCHAR(250) = NULL,
		@Reference04	NVARCHAR(250) = NULL,
		@Reference05	NVARCHAR(250) = NULL
		
AS
BEGIN
	DECLARE @IPAddress		NVARCHAR(16)
	--DECLARE @PropertyId		INT
	DECLARE @DatabaseName	NVARCHAR(250)
	DECLARE @Username		NVARCHAR(250)

	SELECT @Username = [Username] FROM [dbo].[Users] WHERE Id = @UserId
	
	DECLARE @HistoryTableName NVARCHAR(250)
	SET @HistoryTableName = @TableName+'_History';

	--SELECT TOP (1) @PropertyId = Id, @DatabaseName = DB_NAME()
	--FROM Property
	SELECT @DatabaseName = DB_NAME()

	SET @DatabaseName = '['+@DatabaseName+']'


	SELECT TOP (1)
	@IPAddress = IPAddress
	FROM HotelResWeb_AuditTail..UserWiseActiveLogin
	WHERE UserId = @UserId
	AND PropertyId = @PropertyId
	ORDER BY TxnDateTime DESC

	--REMOVE when deploying / these are here for test
	--EXEC('SELECT * FROM ' + @TableName)	
		
	IF NOT EXISTS(SELECT 1 FROM HotelResWeb_AuditTail.sys.tables WHERE name = @HistoryTableName)
	BEGIN
	
		SELECT *
		INTO #tempNewHistoryTable
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = @TableName

		DECLARE @TableQry NVARCHAR(MAX) = ''
		DECLARE @ColomnName NVARCHAR(250)
		DECLARE @DataType	NVARCHAR(250)
		DECLARE @MaxLength INT
		DECLARE @NumericPrecision INT
		DECLARE @NumericPrecisionRadix INT
		DECLARE @NumericScale	INT

		DECLARE @LoopCount	INT = 1
		DECLARE @TableColomnCount	INT = 0

		SELECT @TableColomnCount = COUNT(*) FROM #tempNewHistoryTable

		SET @TableQry = 'USE [HotelResWeb_AuditTail] CREATE TABLE '+@TableName+'_History (';	
		SET @TableQry = @TableQry+' AuditLoggedTxnDateTime DATETIME NOT NULL DEFAULT GETDATE(),';
		SET @TableQry = @TableQry+' AuditReferecePropertyId INT NOT NULL ,';
		SET @TableQry = @TableQry+' AuditTrailID INT NULL ,';

		WHILE EXISTS (SELECT * FROM #tempNewHistoryTable)
		BEGIN
			SELECT TOP (1) 
			@ColomnName = COLUMN_NAME,
			@DataType= DATA_TYPE,
			@MaxLength = CHARACTER_MAXIMUM_LENGTH,
			@NumericPrecision = NUMERIC_PRECISION,
			@NumericPrecisionRadix = NUMERIC_PRECISION_RADIX,
			@NumericScale = NUMERIC_SCALE
			FROM #tempNewHistoryTable

			IF @MaxLength IS NOT NULL
			BEGIN
				SET @DataType = @DataType+ ' ('+CONVERT(NVARCHAR(500),(CASE @MaxLength WHEN -1 THEN 4000 ELSE @MaxLength END) )+')'
				SET @DataType = REPLACE(@DataType, '4000','MAX')
			END

			IF LOWER(@DataType) = 'decimal'
			BEGiN
				SET @DataType = @DataType+ '('+CONVERT(NVARCHAR(500),@NumericPrecision)+','+CONVERT(NVARCHAR(500),@NumericScale)+')'
			END

			IF @LoopCount < @TableColomnCount 
			BEGIN
				SET @TableQry = @TableQry+' ['+@ColomnName+'] '+@DataType+', '
			END
			ELSE 
			BEGIN
				SET @TableQry = @TableQry+' ['+@ColomnName+'] '+@DataType+' '
			END

			DELETE TOP (1) FROM #tempNewHistoryTable
		END
		SET @TableQry = @TableQry+' )'

		DROP TABLE #tempNewHistoryTable
		
		exec(@TableQry)
	END
	ELSE 
	BEGIN
	---------------------------Add updated columns to History table -----------------------------------------
	DECLARE @SQLUpdate NVARCHAR(MAX) = ''
	DECLARE @ColumnList NVARCHAR(MAX) = ''
	DECLARE @ColumnName NVARCHAR(255)
	DECLARE @DataTypeUpdate NVARCHAR(255)
	DECLARE @MaxLengthUpdate NVARCHAR(10)
		DECLARE col_cursor CURSOR FOR 
		SELECT COLUMN_NAME, DATA_TYPE, 
			   CASE 
				   WHEN CHARACTER_MAXIMUM_LENGTH IS NOT NULL 
				   THEN CAST(CHARACTER_MAXIMUM_LENGTH AS NVARCHAR) 
				   ELSE NULL 
			   END AS MaxLength
		FROM Categlog_vrV2.INFORMATION_SCHEMA.COLUMNS 
		WHERE TABLE_NAME = @TableName
		AND COLUMN_NAME NOT IN 
			  (SELECT COLUMN_NAME FROM HotelResWeb_AuditTail.INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @HistoryTableName)

		OPEN col_cursor

		FETCH NEXT FROM col_cursor INTO @ColumnName, @DataTypeUpdate, @MaxLengthUpdate

		WHILE @@FETCH_STATUS = 0
		BEGIN
			-- Generate ALTER TABLE statement
			SET @SQLUpdate = 'ALTER TABLE HotelResWeb_AuditTail.dbo.' + QUOTENAME(@HistoryTableName) + ' ADD ' + QUOTENAME(@ColumnName) + ' ' + @DataTypeUpdate + 
					   CASE WHEN @MaxLengthUpdate IS NOT NULL THEN '(' + @MaxLengthUpdate + ')' ELSE '' END

			-- Execute ALTER TABLE
			EXEC sp_executesql @SQLUpdate

			FETCH NEXT FROM col_cursor INTO @ColumnName, @DataTypeUpdate, @MaxLengthUpdate
		END

		CLOSE col_cursor
		DEALLOCATE col_cursor
	---------------------------------------------------------------------------------------------------------	
	END



	IF NOT EXISTS(SELECT  1 FROM HotelResWeb_AuditTail.sys.columns c 
	INNER JOIN HotelResWeb_AuditTail.sys.tables t ON c.object_id = t.object_id
	WHERE t.name = @HistoryTableName and c.name ='AuditTrailID')
	BEGIN

	DECLARE @sql NVARCHAR(MAX);
	SET @sql = '
    USE [HotelResWeb_AuditTail];
    ALTER TABLE ' + QUOTENAME(@HistoryTableName) + ' ADD AuditTrailID INT NULL;';

	EXEC sp_executesql @sql;

	END




	
	IF OBJECT_ID('tempdb..#tempOld') IS NOT NULL
		DROP TABLE #tempOld

	IF OBJECT_ID('tempdb..#tempNew') IS NOT NULL
		DROP TABLE #tempNew

	IF OBJECT_ID('tempdb..#tempOldJson') IS NOT NULL
		DROP TABLE #tempOldJson

	IF OBJECT_ID('tempdb..#tempNewJson') IS NOT NULL
		DROP TABLE #tempNewJson

	CREATE TABLE #tempOldJson
	(
		JsonString NVARCHAR(MAX)
	)

	CREATE TABLE #tempNewJson
	(
		JsonString NVARCHAR(MAX)
	)
	
	-- generate colomns --------------
	DECLARE @ColomnsWithIsNull NVARCHAR(MAX)
	DECLARE @ColomnsWithoutIsNull NVARCHAR(MAX)

	SELECT COLUMN_NAME
	INTO #tempTableColomns
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = @TableName

	SELECT @ColomnsWithIsNull = STUFF((SELECT distinct ', ISNULL(CONVERT(NVARCHAR(MAX),[' + t1.COLUMN_NAME+']),'''') AS '''+t1.COLUMN_NAME+''''
			 from #tempTableColomns t1       
				FOR XML PATH(''), TYPE
				).value('.', 'NVARCHAR(MAX)') 
			,1,2,'')

	SELECT @ColomnsWithoutIsNull = STUFF((SELECT distinct ', [' + t1.COLUMN_NAME+']'
			 from #tempTableColomns t1       
				FOR XML PATH(''), TYPE
				).value('.', 'NVARCHAR(MAX)') 
			,1,2,'')


	DROP TABLE #tempTableColomns

	-- end of generate colomns--------

	DECLARE @NewQry NVARCHAR(MAX)--NVARCHAR(4000)
	DECLARE @OldQry NVARCHAR(MAX)--NVARCHAR(4000)
	
	--REMOVE when deploying / these are here for test
	--declare @tempq1 varchar(max),
	--		@tempq2 varchar(max)

	--select CONVERT(NVARCHAR(300),@Id)

	--set @tempq1 = 'select '+@ColomnsWithIsNull+' from '+@TableName+' where Id='+CONVERT(NVARCHAR(300),@Id)
	--set @tempq2 = 'select '+@ColomnsWithIsNull+' from HotelResWeb_AuditTail..'+@TableName+'_History  where Id='+CONVERT(NVARCHAR(300),@Id)

	--exec (@tempq1)
	--exec (@tempq2)
	---------------------------------------
	
	SET @NewQry = 'insert into #tempNewJson (JsonString) SELECT X.* FROM (select (select '+@ColomnsWithIsNull+' from '+@TableName+' where Id='+CONVERT(NVARCHAR(300),@Id)+' for json auto) as JsonVal) AS X';
	SET @OldQry = 'insert into #tempOldJson (JsonString) SELECT X.* FROM (select (select TOP 1 '+@ColomnsWithIsNull+' from HotelResWeb_AuditTail..'+@TableName+'_History  where Id='+CONVERT(NVARCHAR(300),@Id)+' and AuditReferecePropertyId = '+CONVERT(NVARCHAR(300),@PropertyId)+' order by AuditLoggedTxnDateTime DESC for json auto) as JsonVal) AS X'

	exec (@NewQry)
	exec (@OldQry)
	

	DECLARE @NewJsonObject NVARCHAR(MAX)
	DECLARE @OldJsonObject NVARCHAR(MAX)

	SELECT @NewJsonObject = JsonString FROM #tempOldJson
	SELECT @OldJsonObject = JsonString FROM #tempNewJson

	--REMOVE when deploying / these are here for test
	--select @NewJsonObject as new, @OldJsonObject as old
	-------------------------------------------------

	IF OBJECT_ID('tempdb..#tempolddata') IS NOT NULL
		DROP TABLE #tempolddata

	IF OBJECT_ID('tempdb..#tempnewdata') IS NOT NULL
		DROP TABLE #tempnewdata

	SELECT 
	json.[Key],
	json.Value
	into #tempolddata
	FROM 
	OPENJSON(REPLACE(REPLACE(@OldJsonObject,'[',''),']','')) AS json;

	SELECT	
	json.[Key],
	json.Value
	into #tempnewdata
	FROM 
	OPENJSON(REPLACE(REPLACE(@NewJsonObject,'[',''),']','')) AS json;

	IF OBJECT_ID('tempdb..#tempChanges') IS NOT NULL
		DROP TABLE #tempChanges

	SELECT 
	A.[Key] AS 'Key',
	A.[Value] AS 'OldValue',
	B.[Value] AS 'NewValue'
	INTO #tempChanges
	FROM #tempnewdata A
	INNER JOIN #tempolddata B ON A.[Key] = B.[Key]
	AND ISNULL(A.[Value],'') <> ISNULL(B.[Value],'')

	--DECLARE @HotelDate DATE
	DECLARE @TrailId INT

	--Added by Nivesh 2026-02-09 to fix doc no overflow issue
	DECLARE @NextNo BIGINT

	SELECT @NextNo = NextNo
	FROM [DocumentNumbers]
	WHERE CODE ='INV'
	select @NextNo NextNo
	IF(@NextNo = 1000000)
	BEGIN
		UPDATE [DocumentNumbers]
		SET NextNo = 1
		WHERE CODE ='INV'
	END
	--End

	--SELECT @HotelDate = CurrentDate FROM FOSettings
	DECLARE @DocNo NVARCHAR(15)
	SET @DocNo = dbo.InvGetNextDocNo('INV')
	EXEC InvUpdateNextDocNo 'INV'

	INSERT INTO  HotelResWeb_AuditTail..[AuditTrailMaster]
	(DocNo, Module, Process, Action, UserID,PropertyId, Username, IPAddress, DatabaseName, TableName, HotelDate, LogDate, Reference01,Reference02,Reference03,Reference04,Reference05)
	SELECT @DocNo, @Module, @Process, @Action, @UserID,@PropertyId,@Username, @IPAddress, @DatabaseName, @TableName, GETDATE(), GETDATE(), @Reference01,@Reference02,@Reference03,@Reference04,@Reference05

	SET @TrailId = SCOPE_IDENTITY()

	INSERT INTO  HotelResWeb_AuditTail..[AuditTrailDetail]
	(TrailID, FieldName, OldValue, NewValue)
	SELECT @TrailId,[Key],OldValue, NewValue
	FROM #tempChanges

	--REMOVE when deploying / these are here for test
	--declare @qry3 VARCHAR(MAX)
	--SET @qry3 = 'SELECT GETDATE(), '+CONVERT(NVARCHAR(250),@PropertyId)+', '+@ColomnsWithoutIsNull+' FROM '+@DatabaseName+'..'+@TableName +' where id='+CONVERT(NVARCHAR(250),@Id)
	--select @qry3

	DECLARE @InsertToHistoryQry NVARCHAR(MAX)
	SET @InsertToHistoryQry = '	INSERT INTO HotelResWeb_AuditTail..'+@TableName+'_History
								(AuditLoggedTxnDateTime,AuditReferecePropertyId,AuditTrailID,'+@ColomnsWithoutIsNull+')
								SELECT GETDATE(), '+CONVERT(NVARCHAR(250),@PropertyId)+','+CONVERT(NVARCHAR(250),@TrailId)+', '+@ColomnsWithoutIsNull+' FROM '+@DatabaseName+'..'+@TableName +' where id='+CONVERT(NVARCHAR(250),@Id)

	exec (@InsertToHistoryQry)

END

GO

