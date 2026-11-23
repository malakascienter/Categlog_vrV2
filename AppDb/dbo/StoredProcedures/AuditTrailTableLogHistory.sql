-- =============================================
-- Author:		Nivesh
-- Create date: 2024-03-07
-- Description:	Get history of table
-- =============================================
-- AuditTrailTableLogHistory 'Departments',22,1

CREATE PROCEDURE [dbo].[AuditTrailTableLogHistory] 
 @HistoryTableName NVARCHAR(MAX),
 @ID INT,
 @PropertyID INT
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY 

	
		
		DECLARE @sql NVARCHAR(MAX);
		
		IF(@HistoryTableName IS NOT NULL AND @ID IS NOT NULL )
		BEGIN
			SET @HistoryTableName = @HistoryTableName + '_History';
			
			IF NOT EXISTS(SELECT 1 FROM HotelResWeb_AuditTail.sys.tables WHERE name = @HistoryTableName)
			BEGIN
				RAISERROR('Log table not exists',16,1)
				RETURN
			END

			SET @sql = '
					SELECT dh.AuditTrailID, atm.DatabaseName, atm.TableName, atd.FieldName, atd.OldValue, atd.NewValue, atm.LogDate ,[dbo].[GET_User](atm.UserID) LastModifiedUserName
					, atm.UserID, atm.PropertyID, CASE WHEN atm.Action =''I'' THEN ''Created''   WHEN atm.Action =''U'' THEN ''Updated''  WHEN atm.Action =''D'' THEN ''Deleted'' END Action,
					ROW_NUMBER() OVER (PARTITION BY dh.AuditTrailID ORDER BY dh.AuditTrailID) AS RowNum,
					COUNT(*) OVER (PARTITION BY dh.AuditTrailID) AS allRowCount
					INTO #TEMPTABEL
					FROM HotelResWeb_AuditTail..' + QUOTENAME(@HistoryTableName) + ' dh
					LEFT JOIN HotelResWeb_AuditTail.[dbo].[AuditTrailDetail] atd ON atd.TrailID = dh.audittrailid
					INNER JOIN HotelResWeb_AuditTail.[dbo].[AuditTrailMaster] atm ON atm.TrailID = dh.audittrailid
					WHERE dh.id = @ID
					ORDER BY dh.AuditLoggedTxnDateTime DESC;

					SELECT distinct AuditTrailID,DatabaseName,TableName,LastModifiedUserName,UserID LastModUserID,PropertyID,Action,LogDate,(SELECT *
					FROM (SELECT * FROM #TEMPTABEL temp WHERE (temp.allRowCount=1 AND temp.RowNum =1) OR (temp.allRowCount>1 AND temp.RowNum<>1)
					) AS UnitConvertion  where UnitConvertion.AuditTrailID = TM.AuditTrailID
					FOR JSON PATH
					) AS AuditTrailData   FROM #TEMPTABEL TM WHERE (TM.allRowCount=1 AND TM.RowNum =1) OR (TM.allRowCount>1 AND TM.RowNum<>1);

					DROP TABLE #TEMPTABEL;';

				EXEC sp_executesql @sql, N'@ID INT', @ID = @ID;
		END
		ELSE
		BEGIN
			RAISERROR('Invalid table name or ID',16,1)
			RETURN
		END
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT>0
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

