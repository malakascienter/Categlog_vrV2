--EXEC IsDetailItem 9451
CREATE PROCEDURE [dbo].[IsDetailItem] (@stockItemHeaderID INT)
AS 
BEGIN
	SELECT * FROM StockItemHeaders SIH
	INNER JOIN StockItemWiseAttributes SIA ON SIA.StockItemHeaderID = SIH.Id
	WHERE SIH.Id = @stockItemHeaderID
END

GO

