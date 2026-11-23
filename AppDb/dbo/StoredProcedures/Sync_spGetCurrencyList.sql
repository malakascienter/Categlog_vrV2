
CREATE PROCEDURE [dbo].[Sync_spGetCurrencyList]
@PropertyId INT,
@IsRestaurant BIT,
@OutletCode VARCHAR(5)
AS

IF @IsRestaurant = 0 
	BEGIN
		--SELECT	CurrCode, CurrName, ConversionRate, AllowBalance, AllowPayments, AllowSignOn, SortOrder, IsActive
		--FROM	POS_CurrencyRates
		--WHERE	PropertyId = @PropertyId AND IsUpload = 0

		SELECT	F.CurrCode AS BasedCurrency, T.CurrCode , T.CurrName, C.Value AS ConversionRate, T.AllowBalance, T.AllowPayments, T.AllowSignOn, T.SortOrder, C.IsActive, C.EffectFrom
		FROM	POS_CurrencyConversions AS C INNER JOIN POS_CurrencyRates AS F ON C.FromCurrencyID = F.Id 
				INNER JOIN POS_CurrencyRates AS T ON C.ToCurrencyID = T.Id
		WHERE	C.CompanyId = @PropertyId AND T.IsUpload = 0
	END
ELSE
	BEGIN
		--SELECT  CurrCode, CurrName, ConversionRate, AllowBalance, AllowPayments, AllowSignOn, SortOrder, IsActive
		--FROM    Sync_MasterDataTransferStatus S INNER JOIN POS_CurrencyRates C ON S.Code = C.CurrCode AND S.PropertyId = C.PropertyId
		--WHERE	S.DataType = 'Currency' AND S.PropertyId = @PropertyId AND S.Outlet = @OutletCode

		SELECT	F.CurrCode AS BasedCurrency, T.CurrCode , T.CurrName, C.Value AS ConversionRate, T.AllowBalance, T.AllowPayments, T.AllowSignOn, T.SortOrder, C.IsActive, C.EffectFrom
		FROM	POS_CurrencyConversions AS C INNER JOIN POS_CurrencyRates AS F ON C.FromCurrencyID = F.Id 
				INNER JOIN POS_CurrencyRates AS T ON C.ToCurrencyID = T.Id
				INNER JOIN Sync_MasterDataTransferStatus S ON T.CurrCode = S.Code AND S.PropertyId = C.CompanyId
		WHERE	S.DataType = 'Currency' AND S.PropertyId = @PropertyId AND S.Outlet = @OutletCode
	END

GO

