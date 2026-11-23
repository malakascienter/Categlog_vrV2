-- =============================================
-- Author		:	Sachith Nuwan
-- Create date	:	02/11/2018
-- Description	:	Insert to history table
-- =============================================
-- AuditTrail_InsertToHistory 'HProducts',3
CREATE PROCEDURE [dbo].[AuditTrail_InsertToHistory]
	@TableName				NVARCHAR(50),
	@UniqueColumnValue		INT
AS
BEGIN
	BEGIN TRY
	
		DECLARE @Id						NVARCHAR(5)
		DECLARE @T1Name					NVARCHAR(MAX)	-- original table
		DECLARE @T2Name					NVARCHAR(MAX)	-- history table
		DECLARE @UniqueColumnName		NVARCHAR(50)	-- table primary key 	
		DECLARE @Columns				NVARCHAR(MAX)	-- will dynamicaly created below

		SELECT @T1Name = TableName, @T2Name = HistoryTableName,@UniqueColumnName = UniqueColumnName FROM AuditTrail_Tables WHERE RTRIM(TableName) = RTRIM(@TableName)
		SET @Id = CONVERT(NVARCHAR(5),@UniqueColumnValue)

		--SELECT * FROM AuditTrail_Tables
		--SELECT @T1Name,@T2Name,@UniqueColumnName
		IF(@T1Name IS NULL OR @T2Name IS NULL OR @UniqueColumnName IS NULL)
		BEGIN
			RAISERROR('Invalid audity trail log table details',16,1)
		END

		SELECT COLUMN_NAME
		INTO #tempT1
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = @T1Name
		AND COLUMN_NAME <> 'SysDate'

		SET @Columns = ''
		WHILE EXISTS (SELECT * FROM #tempT1)
		BEGIN
			IF (LEN(@Columns) = 0)
			BEGIN
				SET @Columns = (SELECT TOP 1 COLUMN_NAME FROM #tempT1) 
			END
			ELSE 
			BEGIN
				SET @Columns = @Columns +','+(SELECT TOP 1 COLUMN_NAME FROM #tempT1)
			END	
			DELETE TOP (1) FROM #tempT1
		END
	
		DECLARE @Qry1 NVARCHAR(MAX)
		SET @Qry1 = 'INSERT INTO '+@T2Name+' ('+@Columns+') SELECT '+@Columns+' FROM '+@T1Name +' WHERE CONVERT(NVARCHAR(5),'+@UniqueColumnName+') = '+@Id
	
		DROP TABLE #tempT1				
		exec sp_executesql @Qry1;

	END TRY
	BEGIN CATCH
		DECLARE @ErrorMsg NVARCHAR(250)
		SET @ErrorMsg = ERROR_MESSAGE()
		RAISERROR (@ErrorMsg,16,1)
	END CATCH
END

GO

