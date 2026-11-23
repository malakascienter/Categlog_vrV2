

CREATE PROCEDURE SP_InsertStockMasterRecord
	
AS
BEGIN
begin try

begin tran

	select 'test'

commit tran
end try

begin catch
	rollback tran
end catch

END

GO

