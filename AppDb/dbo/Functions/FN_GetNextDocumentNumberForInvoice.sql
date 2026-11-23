
--SELECT dbo.FN_GetNextDocumentNumberForInvoice( 1 )
CREATE FUNCTION  [dbo].[FN_GetNextDocumentNumberForInvoice](@DepartmentId INT,@PrefixSelect VARCHAR(2))
RETURNS  VARCHAR (MAX)
BEGIN 

DECLARE  @nextDocumentNumber BIGINT, @LengthOfFormatting INT,@Prefix VARCHAR(2)

SELECT   @nextDocumentNumber=NextNo , @LengthOfFormatting=LengthOfFormatting,@Prefix = Prefix FROM  InvoiceWiseNextNumbers (HOLDLOCK)
WHERE  DepartmentId=@DepartmentId AND Prefix=@PrefixSelect 

RETURN  @Prefix+RIGHT('00000000000'+CONVERT(VARCHAR(MAX),@nextDocumentNumber),@LengthOfFormatting)
END

GO

