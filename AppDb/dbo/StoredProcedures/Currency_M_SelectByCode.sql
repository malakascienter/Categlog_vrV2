
CREATE PROCEDURE [dbo].[Currency_M_SelectByCode]
	@Code VARCHAR(3),
	@PropertyId INT
AS
BEGIN

	SET NOCOUNT ON;

	SELECT [CurrCode]
      ,[CurrName]
      ,[ConversionRate]
      ,[AllowBalance]
      ,[AllowPayments]
      ,[AllowSignOn]
      ,[SortOrder]
      ,[PropertyId]
      ,[CreatedUserId]
      ,[CreatedDateTime]
      ,[ModifiedUserId]
      ,[ModifiedDateTime]
      ,[IsActive]
      ,[IsUpload]
      ,[Id]
      ,CASE WHEN CONVERT(date,[EffectFrom]) < CONVERT(date,GETDATE()) THEN CONVERT(date,GETDATE()) ELSE [EffectFrom] END  AS EffectFrom
      ,[IsBaseCurrency]
      ,[BaseCurrencyId] FROM POS_CurrencyRates WHERE PropertyId = @PropertyId AND CurrCode = @Code
   
END

GO

