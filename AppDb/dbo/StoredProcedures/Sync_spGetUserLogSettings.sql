




CREATE PROCEDURE [dbo].[Sync_spGetUserLogSettings]
@PropertyId INT
AS

SELECT	PropertyId, AccessCode
FROM	Sync_UserLogSettings
WHERE	PropertyId = @PropertyId AND IsActive = 1
ORDER BY SortOrder

GO

