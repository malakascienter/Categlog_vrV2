
CREATE PROCEDURE [dbo].[CurrencyConversions_M_Select]
	@PropertyId INT
AS
BEGIN

	SET NOCOUNT ON;

	SELECT H.Id,D1.CurrName AS  FromCurrencyName,D1.Id AS FromCurrencyID,D2.CurrName AS ToCurrencyName ,D2.Id AS ToCurrencyID,H.Value,H.IsActive,H.CompanyId,H.EffectFrom
	FROM [POS_CurrencyConversions] H 
	INNER JOIN POS_CurrencyRates D1 ON H.FromCurrencyID = D1.Id 
	INNER JOIN POS_CurrencyRates D2 ON H.ToCurrencyID = D2.Id 
	WHERE CompanyId = @PropertyId
   
END

GO

