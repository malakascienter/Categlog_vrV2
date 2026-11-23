

CREATE PROCEDURE [dbo].[Sync_spGetChargeDetails]
@PropertyId INT,
@ChargeHeaderID INT

AS

SELECT	ChargeDetailID, ChargeHeaderID, ChargeTypeID, ActualPercentage, ChargeTypeSequence
FROM	Gen_ChargeGroupDetail
WHERE	ChargeHeaderID = @ChargeHeaderID AND PropertyId = @PropertyId

GO

