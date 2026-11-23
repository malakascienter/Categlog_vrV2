

--select dbo.[FN_GetActualPriceWithoutTax] (259,2)

--SELECT td.Rate, tgd.ChargeRate FROM dbo.TaxGroupDetails tgd
--INNER JOIN dbo.TaxDetails td ON td.TaxTypeId= tgd.TaxTypeId
--WHERE TaxGroupId=2
--GO 

CREATE FUNCTION  [dbo].[FN_GetActualPriceWithoutTax]
(
	@Price money,
	@TaxGroupID DECIMAL
)
RETURNS MONEY 
AS
BEGIN
DECLARE @TaxRate money,@TaxTotal money, @id INT 

DECLARE @TaxTemp AS TABLE (id int IDENTITY(1,1),Rate money, ChargeRate money )



INSERT INTO @TaxTemp (Rate,ChargeRate)
SELECT td.Rate, tgd.ChargeRate FROM dbo.TaxGroupDetails tgd
INNER JOIN dbo.TaxDetails td ON td.TaxTypeId= tgd.TaxTypeId
WHERE TaxGroupId=@TaxGroupID
ORDER BY SortSequance DESC 

--WHILE (SELECT COUNT(*) FROM @TaxTemp)>0
--begin
	
	--SELECT TOP (1)@TaxRate= ChargeRate , @id = id FROM @TaxTemp
	--ORDER BY id 

	--rate

	select @Price=  (@Price /(100+SUM(ChargeRate)*1.000)*100.0000) FROM @TaxTemp
	
	--DELETE TOP (1) FROM @TaxTemp WHERE  id =@id
--END 

RETURN ROUND(@Price,2)





END

GO

