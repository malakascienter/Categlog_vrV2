
CREATE FUNCTION  [dbo].[FN_getTransactionID]
(@code char(2))
returns int
begin

return (select Id from TransactionTypes where Code =@code)

end

GO

