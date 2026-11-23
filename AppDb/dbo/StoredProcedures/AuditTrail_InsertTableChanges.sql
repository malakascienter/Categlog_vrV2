-- =============================================
-- Author		:	Sachith Nuwan
-- Create date	:	02/11/2018
-- Description	:	Insert to history table
-- =============================================
-- AuditTrail_InsertTableChanges 'HProducts',3,'1','U','HProduct table updated'
CREATE PROCEDURE [dbo].[AuditTrail_InsertTableChanges]
	@TableName				NVARCHAR(50),
	@UniqueColumnValue		INT,
	@UserId					INT,	
	@ActionType				CHAR(1),
	@Remark					NVARCHAR(250)
AS
BEGIN
	BEGIN TRY
	
		DECLARE @Id						NVARCHAR(5)
		DECLARE @TableId				INT
		DECLARE @T1Name					NVARCHAR(MAX)	-- original table
		DECLARE @T2Name					NVARCHAR(MAX)	-- history table
		DECLARE @UniqueColumnName		NVARCHAR(50)	-- table primary key 	
		DECLARE @Columns				NVARCHAR(MAX)	-- will dynamicaly created below
		

		SELECT @TableId =Id, @T1Name = TableName, @T2Name = HistoryTableName,@UniqueColumnName = UniqueColumnName FROM AuditTrail_Tables WHERE RTRIM(TableName) = RTRIM(@TableName)
		SET @Id = CONVERT(NVARCHAR(5),@UniqueColumnValue)
				
		IF(@T1Name IS NULL OR @T2Name IS NULL OR @UniqueColumnName IS NULL)
		BEGIN
			RAISERROR('Invalid audit trail log table details',16,1)
		END
		
		SELECT COLUMN_NAME
		INTO #tempT1
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = @T1Name
		AND COLUMN_NAME <> 'SysDate' AND COLUMN_NAME <> 'Photo'

		DECLARE @TempChanges TABLE
		(		
			ColumnName			NVARCHAR(256),
			PreviousValue		NVARCHAR(MAX),
			NewValue			NVARCHAR(MAX)
		)

		DECLARE @T1 TABLE
		(
			Val NVARCHAR(MAX)
		)

		DECLARE @T2 TABLE
		(
			Val NVARCHAR(MAX)
		)


		DECLARE @ColomnName NVARCHAR(100)
		DECLARE @Qry1 NVARCHAR(MAX)
		DECLARE @Qry2 NVARCHAR(MAX)

		DECLARE @T1Val NVARCHAR(MAX)
		DECLARE @T2Val NVARCHAR(MAX)

		--SELECT * FROM #tempT1

		WHILE EXISTS(SELECT * FROM #tempT1) 
		BEGIN
			SELECT TOP 1 @ColomnName = COLUMN_NAME FROM #tempT1	
			SET @Qry1 = 'SELECT '+@ColomnName+' FROM '+@T1Name +' WHERE CONVERT(NVARCHAR(10),'+@UniqueColumnName+') = '+@Id
			SET @Qry2 = 'SELECT TOP 1 '+@ColomnName+' FROM '+@T2Name+ +' WHERE CONVERT(NVARCHAR(10),'+@UniqueColumnName+') = '+@Id+' ORDER BY SysDate DESC' -- selecting last hisory record

			--SELECT @Qry1, @Qry2
			INSERT INTO @T1
			exec sp_executesql @Qry1;

			INSERT INTO @T2
			exec sp_executesql @Qry2;	

			--SELECT  @ColomnName
			SELECT TOP 1 @T1Val = ISNULL(Val,'') FROM @T1
			SELECT TOP 1 @T2Val = ISNULL(Val,'') FROM @T2

			IF(@T1Val <> @T2Val)
			BEGIN
				INSERT INTO @TempChanges
				SELECT @ColomnName, @T2Val, @T1Val
			END

			DELETE FROM @T1
			DELETE FROM @T2
	
			DELETE TOP (1) FROM #tempT1
		END

		DROP TABLE #tempT1
				
		DECLARE @Changes  NVARCHAR(MAX)
		SELECT @Changes = (SELECT * FROM @TempChanges FOR JSON AUTO)
		

		DECLARE @Code NVARCHAR(50)
		SELECT @Code = dbo.AuditTrail_GetNextDocNo('LSEQ')

		INSERT INTO [dbo].[AuditTrail_Log]
		([Code], [UserId], [TableId],UniqueColumnName,UniqueColumnValue, [ActionType], [Remark], [Changes])
		VALUES (@Code, @UserId,@TableId,@UniqueColumnName, @Id, @ActionType,@Remark,@Changes)
		
		EXEC [dbo].[AuditTrail_UpdateDocNo] 'LSEQ'

	END TRY
	BEGIN CATCH
		DECLARE @ErrorMsg NVARCHAR(250)
		SET @ErrorMsg = ERROR_MESSAGE()
		RAISERROR (@ErrorMsg,16,1)
	END CATCH
END

GO

