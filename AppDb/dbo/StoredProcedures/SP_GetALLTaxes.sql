

CREATE PROCEDURE  [dbo].[SP_GetALLTaxes]

AS
BEGIN
	
	select TaxTypeId as Id ,Name,Rate from TaxDetails

END

GO

