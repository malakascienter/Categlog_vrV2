CREATE PROCEDURE [dbo].[SP_GET_TransactionTypes_ForApproval]
AS
BEGIN



SELECT Id,CONCAT(Code,'/',Name) AS TransactionType FROM dbo.TransactionTypes WHERE  IsActive = 1  AND ID not in(6,12)


END

GO

