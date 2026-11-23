CREATE PROCEDURE [dbo].[SP_Search_GetAttributesWithStockItemHeaders]

	@value INT
	AS 
	BEGIN

		SELECT SA.id AS AttributeID, SA.Name AS AttName, S.Remarks FROM dbo.StockItemWiseAttributes AS S 
                                     INNER JOIN dbo.StockItemAttributes AS SA ON S.StockItemAttributeID = SA.Id  
                                     WHERE S.StockItemHeaderID = @value

	END

GO

