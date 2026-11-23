-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[AuditTrail_SelectUserWiseActivityLog_ByCentralUser]	
	@UserId					INT = -1,
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
	
	SELECT TOP 500 A.*,DATEADD(MI,330,DateTimeUtc) AS 'TxnDate', B.Username
	FROM AuditTrail_Log A
	INNER JOIN #TEMUSER B ON B.Id = A.UserId
	WHERE (@UserId = -1 OR A.UserId = @UserId)
	ORDER BY DateTimeUtc DESC

	DELETE FROM #TEMUSER

END

GO

