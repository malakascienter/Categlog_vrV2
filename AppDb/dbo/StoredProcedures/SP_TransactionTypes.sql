CREATE PROCEDURE [dbo].[SP_TransactionTypes]
	
AS
BEGIN
	SELECT Id AS id , Name AS text FROM dbo.TransactionTypes
	--WHERE Id = 3 OR id=2 OR Id = 5 OR id = 6 OR Id = 1 OR Id = 8 OR Id = 11 OR id = 14 OR Id =13 OR Id=9
	WHERE Id IN(3,4,2,5,6,1,8,11,14,13,9,10,7,12,70,71,72,74,85,87,88)
END

GO

