

CREATE PROCEDURE [dbo].[Sync_spUpdateUplodedCharges]

@PropertyId INT,
@ChargeHeaderID INT
AS
UPDATE	Gen_ChargeGroupHeader SET IsUpload = 1
WHERE	ChargeHeaderID = @ChargeHeaderID AND PropertyId = @PropertyId

GO

