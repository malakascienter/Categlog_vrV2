
CREATE PROCEDURE SP_ReturnPartialResult --'c'
	@term varchar(100)
AS
BEGIN

	if @term is not null
	begin
		select id,Name from StockItemHeaders  where name like '%' + @term + '%';
	end
END

GO

