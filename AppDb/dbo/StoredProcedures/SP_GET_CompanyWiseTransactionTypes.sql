CREATE PROCEDURE [dbo].[SP_GET_CompanyWiseTransactionTypes] (@CompanyId INT)
AS
BEGIN



SELECT Id,CONCAT(Code,'/',Name) AS TransactionType FROM dbo.TransactionTypes WHERE CompanyId = @CompanyId


END

GO

