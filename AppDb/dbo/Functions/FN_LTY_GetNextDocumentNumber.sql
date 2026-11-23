
CREATE     FUNCTION  [dbo].[FN_LTY_GetNextDocumentNumber]
(
	@PropertyID INT,
	@LocationCode VARCHAR(5),
	@TransactionType CHAR(4)
)
RETURNS VARCHAR(MAX)
BEGIN

DECLARE 
	@nextDocumentNumber BIGINT,
	@LengthOfFormatting INT

	SELECT  
		@nextDocumentNumber=NextNumber ,
		@LengthOfFormatting=LengthOfFormatting 
	FROM LTY_TransactionTypeWiseNextNumbers (HOLDLOCK)
	WHERE LocationCode=@LocationCode
		AND TransactionType=@TransactionType 
		AND PropertyID=@PropertyID

	RETURN RIGHT('000000000000000000000'+CONVERT(VARCHAR(MAX),@nextDocumentNumber),@LengthOfFormatting)

END

GO

