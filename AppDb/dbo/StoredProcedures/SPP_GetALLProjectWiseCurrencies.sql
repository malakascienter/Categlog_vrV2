
CREATE PROCEDURE SPP_GetALLProjectWiseCurrencies 
@ProjectID INT

AS



BEGIN


Select P.Currency AS ID, P.ExchangeRate,Name from [dbo].[ProjectWiseCurrencies] AS P inner join currencymasters AS C ON C.id=P.Currency where ProjectID=@ProjectID
 

END

GO

