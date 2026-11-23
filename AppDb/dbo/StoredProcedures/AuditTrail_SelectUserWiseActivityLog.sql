-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[AuditTrail_SelectUserWiseActivityLog]	
	@UserId					INT = -1
AS
BEGIN
	
	SELECT TOP 500 A.*,DATEADD(MI,330,DateTimeUtc) AS 'TxnDate', B.Username
	FROM AuditTrail_Log A
	INNER JOIN Users B ON B.Id = A.UserId
	WHERE (@UserId = -1 OR A.UserId = @UserId)
	ORDER BY DateTimeUtc DESC

END

GO

