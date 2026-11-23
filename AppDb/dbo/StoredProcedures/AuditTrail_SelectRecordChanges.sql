-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[AuditTrail_SelectRecordChanges] 
	@TableId				INT,
	@RecordId				INT,
	@UserId					INT = -1,
	@PropertyId				INT
AS
BEGIN
	
	SELECT TOP 100 A.*, DATEADD(MI,330,DateTimeUtc) AS 'TxnDate', B.Username
	FROM AuditTrail_Log A
	INNER JOIN Users B ON B.Id = A.UserId
	WHERE 
	--A.TableId = @TableId
	--AND UniqueColumnValue = @RecordId	
	 (@UserId = -1 OR A.UserId = @UserId)
	ORDER BY A.DateTimeUtc DESC

END

GO

