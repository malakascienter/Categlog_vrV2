-- [dbo].[SP_Transaction_ListingReport_TransactionTypes] 'T'

CREATE PROCEDURE [dbo].[SP_Transaction_ListingReport_TransactionTypes]
	(@Type CHAR(1)='T')
AS
BEGIN

	IF(@Type ='S') -- FOR STOCK ITEM TEMPLATE
	BEGIN
	SELECT Id,Code AS id , Name AS text FROM dbo.TransactionTypes
	WHERE  CODE IN ('RP','PO','RT','AA','CR')
	END

	ELSE IF @type='T'
	BEGIN
		SELECT Id,Code AS id , Name AS text FROM dbo.TransactionTypes
		WHERE  id=4 OR Id = 5 OR id = 6 OR Id = 12 OR Id = 13 
		--OR id = 14 
		OR id = 7 OR ID=10
	END 

	--Added by ravindu 2025-11-12
	ELSE IF @Type = 'X'
	BEGIN
	     SELECT Id,Code AS id, Name AS text, RejectedReportName FROM dbo.TransactionTypes
		 WHERE Id = 3 OR Id = 10 OR Id = 4 OR Id = 7
	END

	ELSE
	BEGIN
		SELECT Id,Code AS id , Name AS text FROM dbo.TransactionTypes
		WHERE Id = 1 OR Id = 8 OR Id = 11 OR Id = 14   
	END
END

GO

