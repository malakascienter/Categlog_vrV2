
CREATE PROCEDURE Currency_M_Select
	@PropertyId INT
AS
BEGIN

	SET NOCOUNT ON;

	SELECT * FROM POS_CurrencyRates WHERE PropertyId = @PropertyId ORDER BY SortOrder ASC
   
END

GO

