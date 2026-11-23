-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[SP_GetALLTaxRates]
@Id INT
	
AS
BEGIN
	SELECT SUM(ChargeRate) FROM dbo.TaxGroupDetails WHERE TaxGroupId=@Id
END

GO

