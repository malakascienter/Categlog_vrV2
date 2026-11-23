CREATE PROCEDURE [dbo].[SP_Select_Advance_Approval]
as
SELECT Id AS id, Name AS text FROM dbo.TransactionTypes
WHERE Id = 34 OR Id = 36 OR Id = 37 OR Id = 38

GO

