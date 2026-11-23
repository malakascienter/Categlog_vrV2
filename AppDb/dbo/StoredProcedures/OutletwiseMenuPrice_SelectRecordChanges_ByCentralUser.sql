
-- =============================================
-- Author:		BANU
-- Create date: 18/01/2019
-- Description:	Select outletwise table record changes
-- =============================================
-----EXECUTE OutletwiseMenuPrice_SelectRecordChanges 31, 1443, 1
CREATE PROCEDURE [dbo].[OutletwiseMenuPrice_SelectRecordChanges_ByCentralUser]
	@TableId				INT,
	@RecordId				INT, -------REFERS MainMenu TABLE Id COLUMN
	@UserId					INT = -1,
	@UserJson       NVARCHAR(MAX)
AS
BEGIN
	DECLARE @OutletwisePriceRecId INT
	 
	CREATE TABLE #TempRecordChanges(
		Id					BIGINT,
		DateTimeUtc			DATETIME,
		Code				VARCHAR(100),
		UserId				INT,
		TableId				INT,
		UniqueColumnName	VARCHAR(200),
		UniqueColumnValue	VARCHAR(500),
		PageId				INT,
		ActionType			VARCHAR(10),
		Remark				VARCHAR(MAX),
		Changes				VARCHAR(MAX),
		TxnDate				DATETIME,
		UserName			VARCHAR(100),
	)

	CREATE TABLE #TempId(
		TempId INT
	)

	CREATE TABLE #TEMUSER (
		[Id] INT NOT NULL,
		[Username] NVARCHAR(100) NULL
	)

	INSERT INTO #TEMUSER(Id,Username)  
	SELECT Id,Username  
	FROM   
	OpenJson(@UserJson)  
	WITH  
	(  
	Id INT '$.Id',  
	Username NVARCHAR(100) '$.Username'  
	)

	INSERT INTO #TempId
	SELECT OP.Id 
	FROM OutletwiseMenuItemPrice OP
	INNER JOIN MainMenu MM ON OP.MainMenuCode = MM.ItemCode
	WHERE MM.Id = @RecordId 

	WHILE EXISTS(SELECT TOP 1 TempId FROM #TempId ORDER BY TempId)
	BEGIN
		SELECT TOP 1 @OutletwisePriceRecId = TempId FROM #TempId ORDER BY TempId  

		INSERT INTO #TempRecordChanges(Id, DateTimeUtc, Code, UserId, TableId,  UniqueColumnName, 
						UniqueColumnValue, PageId, ActionType, Remark, Changes,TxnDate, UserName)
		SELECT  A.*, DATEADD(MI,330,DateTimeUtc) AS 'TxnDate', B.Username
		FROM AuditTrail_Log A
		INNER JOIN #TEMUSER B ON B.Id = A.UserId
		WHERE A.TableId = @TableId
		AND UniqueColumnValue = @OutletwisePriceRecId	
		AND (@UserId = -1 OR A.UserId = @UserId)
		ORDER BY A.DateTimeUtc DESC

		DELETE FROM #TempId WHERE TempId = @OutletwisePriceRecId
	END

	SELECT * FROM #TempRecordChanges

	DROP TABLE #TempId
	DROP TABLE #TempRecordChanges
	DELETE FROM #TEMUSER
END

GO

