
CREATE   FUNCTION  [dbo].[FN_SPO_GetNextDocumentNumber]
(
	@PropertyID INT,
	@LocationID VARCHAR(5),
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
	FROM SPO_TransactionTypeWiseNextNumbers (HOLDLOCK)
	WHERE locationid=@LocationID 
		AND transactionType=@TransactionType 
		AND PropertyID=@PropertyID

	RETURN RIGHT('000000000000000000000'+CONVERT(VARCHAR(MAX),@nextDocumentNumber),@LengthOfFormatting)

END

GO

