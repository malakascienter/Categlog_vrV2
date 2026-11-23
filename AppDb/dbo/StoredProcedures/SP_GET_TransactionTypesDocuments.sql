create PROCEDURE [dbo].[SP_GET_TransactionTypesDocuments]
AS
BEGIN



SELECT Id,Name AS TransactionType FROM [dbo].[TransactionDocumentTypes]


END

GO

