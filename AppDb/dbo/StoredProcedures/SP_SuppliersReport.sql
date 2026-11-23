CREATE PROCEDURE [dbo].[SP_SuppliersReport]
	@PropertyID INT
AS
BEGIN
	SELECT ID AS id, Name AS text FROM dbo.Suppliers
END

GO

