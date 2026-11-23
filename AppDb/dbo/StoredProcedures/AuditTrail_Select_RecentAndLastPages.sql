
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- AuditTrail_Select_RecentAndLastPages 1
CREATE PROCEDURE [dbo].[AuditTrail_Select_RecentAndLastPages]
@UserId	INT--,
--@PropertyId INT
AS
BEGIN
---------------------ADD Last Visited page from AuditTrail_Log------------------------------
	SELECT TOP 1 
	UserId AS 'UserId',
	PageId AS 'PageId',
	DATEADD(mi,330,DateTimeUtc) AS 'LastAccessedDateTime',
	'L'	 AS 'Action',
	0	 AS 'NoOfVisits'
	INTO #tempLastVisited
	FROM AuditTrail_Log	
	WHERE PageId IS NOT NULL 
	AND UserId=@UserId --AND PropertyId=@PropertyId
	ORDER BY DateTimeUtc DESC	

------------------------------END----------------------------------------------------------

------------------------------Query Result-------------------------------------------------	 
	SELECT X.*
	INTO #tempResult 	
	FROM
	(
		SELECT TOP(8) 
		UserId,PageId,
		(
			SELECT TOP 1 
			DATEADD(mi,330,DateTimeUtc) 
			FROM AuditTrail_Log 
			WHERE PageId=A.PageId --AND PropertyId=@PropertyId
			ORDER BY DateTimeUtc DESC
		)AS 'LastAccessedDateTime',
		'R' AS 'Action' ,
		NoOfVisits
		FROM AuditTrail_UserWisePageVisitCount AS A
		WHERE UserId = @UserId  --AND PropertyId=@PropertyId
		UNION ALL
		SELECT TOP 1 * FROM #tempLastVisited
		ORDER BY NoOfVisits DESC
	)AS X

	SELECT X.*,A.Name AS 'PageName', A.[Url] AS 'PageUrl' FROM #tempResult X
	INNER JOIN [dbo].[Admin_Nav_AreasWisePages] A ON X.PageId=A.Id

---------------------------------------END------------------------------------------------
	DROP TABLE #tempLastVisited	
	DROP TABLE #tempResult
END


--ALTER TABLE [dbo].[AuditTrail_Log] ADD  CONSTRAINT [DF_AuditTrail_Log_DateTimeUtc]  DEFAULT (getutcdate()) FOR [DateTimeUtc]

GO

