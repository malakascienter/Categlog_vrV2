

CREATE PROCEDURE [dbo].[Sync_spGetUserDetails]
@PropertyId INT,
@UserID INT

AS

SELECT	U.Username ,A.AccessCode
FROM	POS_UserAccessTemp AS UA INNER JOIN POS_AccessCodes AS A ON UA.AccessCodeId = A.Id 
		INNER JOIN Users AS U ON UA.UserId = U.Id
WHERE	UA.UserId = @UserID AND U.PropertyId = @PropertyId

GO

