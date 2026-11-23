CREATE PROCEDURE [dbo].[SP_Search_GetAllAttributes]


	AS 
	BEGIN

		SELECT Name AS AttributeName,id AS AttrBID FROM [dbo].[StockItemAttributes] WHERE IsRemarksApplicable=1
	END

GO

