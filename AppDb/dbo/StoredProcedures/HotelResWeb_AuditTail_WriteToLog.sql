-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[HotelResWeb_AuditTail_WriteToLog]	
		@TableName		NVARCHAR(250),
		@Id				INT ,	
		@Module			NVARCHAR(10), 
		@Process		NVARCHAR(10), 
		@Action			NVARCHAR(10), 
		@UserId			INT,
		@Reference01	NVARCHAR(250) = NULL,
		@Reference02	NVARCHAR(250) = NULL,
		@Reference03	NVARCHAR(250) = NULL,
		@Reference04	NVARCHAR(250) = NULL,
		@Reference05	NVARCHAR(250) = NULL,
		@PropertyId		INT
		
		
AS
BEGIN
BEGIN TRY
BEGIN TRANSACTION

	--DECLARE @IPAddress	varchar(16)
	
	--DECLARE @DatabaseName NVARCHAR(250)
	--DECLARE @Username			NVARCHAR(250)

	--SELECT @Username = Username FROM [CentralAccessDB]..[Users] WHERE Id = @UserId
	
	--DECLARE @HistoryTableName NVARCHAR(250)
	--SET @HistoryTableName = @TableName+'_'+@Module+'_History';

	--SELECT TOP (1) 
	--@DatabaseName = DB_NAME()
	--FROM Companies

	----SET @PropertyId = 1

	--SELECT TOP (1)
	--@IPAddress = IPAddress
	--FROM HotelResWeb_AuditTail..UserWiseActiveLogin
	--WHERE UserId = @UserId
	--AND PropertyId = @PropertyId
	--ORDER BY TxnDateTime DESC	
	
	--IF NOT EXISTS(SELECT 1 FROM HotelResWeb_AuditTail.sys.tables WHERE name = @HistoryTableName)
	--BEGIN
	
	--	print 1
	--	SELECT *
	--	INTO #tempNewHistoryTable
	--	FROM INFORMATION_SCHEMA.COLUMNS
	--	WHERE TABLE_NAME = @TableName

	--	DECLARE @TableQry VARCHAR(MAX) = ''
	--	DECLARE @ColomnName NVARCHAR(250)
	--	DECLARE @DataType	NVARCHAR(250)
	--	DECLARE @MaxLength INT
	--	DECLARE @NumericPrecision INT
	--	DECLARE @NumericPrecisionRadix INT
	--	DECLARE @NumericScale	INT

	--	DECLARE @LoopCount	INT = 1
	--	DECLARE @TableColomnCount	INT = 0
	

	--	SELECT @TableColomnCount = COUNT(*) FROM #tempNewHistoryTable

	--	SET @TableQry = 'USE [HotelResWeb_AuditTail] CREATE TABLE '+@TableName+'_'+@Module+'_History (';	
	--	SET @TableQry = @TableQry+' AuditLoggedTxnDateTime DATETIME NOT NULL DEFAULT GETDATE(),';
	--	SET @TableQry = @TableQry+' AuditReferecePropertyId INT NOT NULL ,';

	--	WHILE EXISTS (SELECT * FROM #tempNewHistoryTable)
	--	BEGIN	
	--		SELECT TOP (1) 
	--		@ColomnName = COLUMN_NAME,
	--		@DataType= DATA_TYPE,
	--		@MaxLength = CHARACTER_MAXIMUM_LENGTH,
	--		@NumericPrecision = NUMERIC_PRECISION,
	--		@NumericPrecisionRadix = NUMERIC_PRECISION_RADIX,
	--		@NumericScale = NUMERIC_SCALE
	--		FROM #tempNewHistoryTable

	--		IF (@DataType = 'image')
	--		BEGIN
	--			DELETE TOP (1) FROM #tempNewHistoryTable

	--			CONTINUE;
	--		END

	--		IF @MaxLength IS NOT NULL
	--		BEGiN
	--			SET @DataType = @DataType+ ' ('+CONVERT(NVARCHAR(500),(CASE @MaxLength WHEN -1 THEN 4000 ELSE @MaxLength END) )+')'
	--		END


	--		IF LOWER(@DataType) = 'decimal'
	--		BEGiN
	--			SET @DataType = @DataType+ '('+CONVERT(NVARCHAR(500),@NumericPrecision)+','+CONVERT(NVARCHAR(500),@NumericScale)+')'
	--		END

	--		IF LOWER(@DataType) = 'numeric'
	--		BEGiN
	--			SET @DataType = @DataType+ '('+CONVERT(NVARCHAR(MAX),@NumericPrecision)+','+CONVERT(NVARCHAR(MAX),@NumericScale)+')'
	--		END

	--		IF @LoopCount < @TableColomnCount 
	--		BEGIN
	--			SET @TableQry = @TableQry+' ['+@ColomnName+'] '+@DataType+', '
	--		END
	--		ELSE 
	--		BEGIN
	--			SET @TableQry = @TableQry+' ['+@ColomnName+'] '+@DataType+' '
	--		END

	--		DELETE TOP (1) FROM #tempNewHistoryTable
	--	END

	--	SET @TableQry = @TableQry+' )'

	--	DROP TABLE #tempNewHistoryTable
	--	select @TableQry
	--	exec(@TableQry)
	--END

	
	--IF OBJECT_ID('tempdb..#tempOld') IS NOT NULL
	--	DROP TABLE #tempOld

	--IF OBJECT_ID('tempdb..#tempNew') IS NOT NULL
	--	DROP TABLE #tempNew



	--IF OBJECT_ID('tempdb..#tempOldJson') IS NOT NULL
	--	DROP TABLE #tempOldJson

	--IF OBJECT_ID('tempdb..#tempNewJson') IS NOT NULL
	--	DROP TABLE #tempNewJson

	--CREATE TABLE #tempOldJson
	--(
	--	JsonString VARCHAR(MAX)
	--)

	--CREATE TABLE #tempNewJson
	--(
	--	JsonString VARCHAR(MAX)
	--)

	---- generate colomns --------------
	--DECLARE @ColomnsWithIsNull VARCHAR(MAX)
	--DECLARE @ColomnsWithoutIsNull VARCHAR(MAX)

	--SELECT COLUMN_NAME
	--INTO #tempTableColomns
	--FROM INFORMATION_SCHEMA.COLUMNS
	--WHERE TABLE_NAME = @TableName AND DATA_TYPE <> 'image'


	--SELECT @ColomnsWithIsNull = STUFF((SELECT distinct ', ISNULL(CONVERT(VARCHAR(MAX),[' + t1.COLUMN_NAME+']),'''') AS '''+t1.COLUMN_NAME+''''
	--		 from #tempTableColomns t1       
	--			FOR XML PATH(''), TYPE
	--			).value('.', 'VARCHAR(MAX)') 
	--		,1,2,'')

	--SELECT @ColomnsWithoutIsNull = STUFF((SELECT distinct ', [' + t1.COLUMN_NAME+']'
	--		 from #tempTableColomns t1       
	--			FOR XML PATH(''), TYPE
	--			).value('.', 'VARCHAR(MAX)') 
	--		,1,2,'')


	--DROP TABLE #tempTableColomns
	
	---- end of generate colomns--------

	--DECLARE @NewQry VARCHAR(MAX)--NVARCHAR(4000)
	--DECLARE @OldQry VARCHAR(MAX)--NVARCHAR(4000)

	----print 'select '+@ColomnsWithIsNull+' from '+@TableName+' where Id='+CONVERT(NVARCHAR(300),@Id)
	
	--SET @NewQry = 'insert into #tempNewJson (JsonString) SELECT X.* FROM (select (select '+@ColomnsWithIsNull+' from '+@TableName+' where Id='+CONVERT(VARCHAR(300),@Id)+' for json auto) as JsonVal) AS X';
	--SET @OldQry = 'insert into #tempOldJson (JsonString) SELECT X.* FROM (select (select TOP 1 '+@ColomnsWithIsNull+' from HotelResWeb_AuditTail..'+@TableName+'_'+@Module+'_History  where Id='+CONVERT(VARCHAR(300),@Id)+' and AuditReferecePropertyId = '+CONVERT(VARCHAR(300),@PropertyId)+' order by AuditLoggedTxnDateTime DESC for json auto) as JsonVal) AS X'

	----select @NewQry
	----select @OldQry

	----select LEN(@NewQry)
	----select LEN(@OldQry)

	--exec (@NewQry)
	----RAISERROR(@NewQry,16,1)
	--exec (@OldQry)
	
	--DECLARE @NewJsonObject VARCHAR(MAX)
	--DECLARE @OldJsonObject VARCHAR(MAX)

	--SELECT @NewJsonObject = JsonString FROM #tempOldJson
	--SELECT @OldJsonObject = JsonString FROM #tempNewJson

	----select @OldJsonObject
	----select @NewJsonObject


	--IF OBJECT_ID('tempdb..#tempolddata') IS NOT NULL
	--	DROP TABLE #tempolddata

	--IF OBJECT_ID('tempdb..#tempnewdata') IS NOT NULL
	--	DROP TABLE #tempnewdata

	--SELECT 
	--json.[Key],
	--json.Value
	--into #tempolddata
	--FROM 
	--OPENJSON(REPLACE(REPLACE(@OldJsonObject,'[',''),']','')) AS json;

	--SELECT 
	--json.[Key],
	--json.Value
	--into #tempnewdata
	--FROM 
	--OPENJSON(REPLACE(REPLACE(@NewJsonObject,'[',''),']','')) AS json;

	----select * from #tempolddata
	----select * from #tempnewdata

	--IF OBJECT_ID('tempdb..#tempChanges') IS NOT NULL
	--	DROP TABLE #tempChanges


	--SELECt 
	--A.[Key] AS 'Key',
	--A.[Value] AS 'OldValue',
	--B.[Value] AS 'NewValue'
	--INTO #tempChanges
	--FROM #tempnewdata A
	--INNER JOIN #tempolddata B ON A.[Key] = B.[Key]
	--AND ISNULL(A.[Value],'') <> ISNULL(B.[Value],'')


	--DECLARE @HotelDate DATE
	--DECLARE @TrailId INT

	--SELECT @HotelDate = GETDATE()

	--DECLARE @DocNo NVARCHAR(15)
	--SET @DocNo = dbo.GetNextDocNo('AUD',@PropertyId)
	--EXEC UpdateNextDocNo 'AUD',@PropertyId
	
	--INSERT INTO  HotelResWeb_AuditTail..[AuditTrailMaster]
	--(DocNo, Module, Process, Action, UserID,Username, IPAddress, DatabaseName, TableName, HotelDate, LogDate, Reference01,Reference02,Reference03,Reference04,Reference05)
	--SELECT @DocNo, @Module, @Process, @Action, @UserID,ISNULL(@Username,''), @IPAddress, @DatabaseName, @TableName, @HotelDate, GETDATE(), @Reference01,@Reference02,@Reference03,@Reference04,@Reference05

	--SET @TrailId = SCOPE_IDENTITY()
	
	--INSERT INTO  HotelResWeb_AuditTail..[AuditTrailDetail]
	--(TrailId, FieldName, OldValue, NewValue)
	--SELECT @TrailId,[Key],OldValue, NewValue
	--FROM #tempChanges

	----select @Id

	--DECLARE @InsertToHistoryQry VARCHAR(MAX)
	--SET @InsertToHistoryQry = '	INSERT INTO HotelResWeb_AuditTail..'+@TableName+'_'+@Module+'_History
	--							(AuditLoggedTxnDateTime,AuditReferecePropertyId,'+@ColomnsWithoutIsNull+')
	--							SELECT GETDATE(), '+CONVERT(NVARCHAR(250),@PropertyId)+', '+@ColomnsWithoutIsNull+' FROM '+@DatabaseName+'..'+@TableName +' where id='+CONVERT(NVARCHAR(250),@Id)

	--exec (@InsertToHistoryQry)	

	PRINT 1

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		SELECT ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE()
		ROLLBACK TRANSACTION
		DECLARE @Message VARCHAR(500) 
		SET @Message = ERROR_MESSAGE()

		--INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage,SysDate)
		--VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE(),GETDATE())

		RAISERROR(@Message,16,1)

	END CATCH

	print 1
 
	
END

GO

