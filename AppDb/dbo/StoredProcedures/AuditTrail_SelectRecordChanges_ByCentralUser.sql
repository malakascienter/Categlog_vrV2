-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[AuditTrail_SelectRecordChanges_ByCentralUser] 
	@TableId				INT,
	@RecordId				INT,
	@UserId					INT = -1,
	@PropertyId				INT,
	@UserJson       NVARCHAR(MAX)
AS
BEGIN

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
	
	SELECT TOP 100 A.*, DATEADD(MI,330,DateTimeUtc) AS 'TxnDate', B.Username
	FROM AuditTrail_Log A
	INNER JOIN #TEMUSER B ON B.Id = A.UserId
	WHERE 
	--A.TableId = @TableId
	--AND UniqueColumnValue = @RecordId	
	 (@UserId = -1 OR A.UserId = @UserId)
	ORDER BY A.DateTimeUtc DESC

	DELETE FROM #TEMUSER

END

GO

