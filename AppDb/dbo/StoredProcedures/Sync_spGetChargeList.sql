

CREATE PROCEDURE [dbo].[Sync_spGetChargeList]
@PropertyId INT
AS

SELECT	ChargeHeaderID, Name, ResNetVal
FROM	Gen_ChargeGroupHeader
WHERE	PropertyId = @PropertyId AND IsUpload = 0

GO

