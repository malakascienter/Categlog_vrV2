
CREATE FUNCTION  [dbo].[FN_GetNextDocumentNumber](@PropertyID int,@LocationID int,@TransactionType char(4))
returns varchar(max)
begin

declare @nextDocumentNumber bigint, @LengthOfFormatting INT


select  @nextDocumentNumber=NextNumber , @LengthOfFormatting=LengthOfFormatting 
--from TransactionTypeWiseNextNumbers (HOLDLOCK) --Commented by Isuru 2026-10-02 to stock deadlock issue
from TransactionTypeWiseNextNumbers WITH (UPDLOCK, HOLDLOCK)
where locationid=@LocationID and transactionType=@TransactionType and PropertyID=@PropertyID

--SELECT right('000000000000000000000'+convert(varchar(max),121),8)

return right('000000000000000000000'+convert(varchar(max),@nextDocumentNumber),@LengthOfFormatting)
end

GO

