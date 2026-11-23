CREATE PROCEDURE [dbo].[SP_CheckNameExistence](@value nvarchar(250),@globalCRUDMode int, @id INT,@table CHAR,@Count INT OUTPUT,@CompanyId INT =0)
AS
BEGIN
	--DECLARE @CompanyId INT;
	--SELECT  @CompanyId = CompanyId FROM Stockitemheaders WHERE Id = @id

	IF(@globalCRUDMode = 1)
	BEGIN
		IF(@table = 'S')
			SELECT @Count =COUNT(*) FROM Suppliers WHERE Name = @value
		IF(@table = 'I')
			SELECT @Count =COUNT(*) FROM StockItemHeaders WHERE Name = @value AND CompanyId = @CompanyId
	END
	IF(@globalCRUDMode = 2)
	BEGIN
		IF(@table = 'S')
			SELECT @Count =COUNT(*) FROM Suppliers WHERE Name = @value AND Id <> @id 
		IF(@table = 'I')
			SELECT @Count =COUNT(*) FROM StockItemHeaders WHERE Name = @value AND Id <> @id AND CompanyId = @CompanyId  
	END

	SELECT @Count
END

GO

