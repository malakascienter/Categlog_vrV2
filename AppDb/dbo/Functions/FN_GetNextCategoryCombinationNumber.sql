
CREATE FUNCTION  [dbo].[FN_GetNextCategoryCombinationNumber](@PrefixCombination VARCHAR(MAX))
returns varchar(max)
begin

DECLARE @nextDocumentNumber BIGINT

	SELECT @nextDocumentNumber=NextNumber
	FROM AutoStockItemCodeCombination (HOLDLOCK) 
	WHERE PrefixCombination = @PrefixCombination
	
	RETURN RIGHT('00000'+ CONVERT(VARCHAR(MAX),@nextDocumentNumber),6)

END

GO

