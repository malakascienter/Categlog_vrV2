-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Search_HeaderDetails]
	@StockheaderID int
AS
BEGIN
	SELECT *
		FROM ( SELECT  D.Name AS DeatailName, H.Name AS HeadName,D.id AS DeatailID,H.id AS HeadID,A.StockItemHeaderID
			,  (ROW_NUMBER() OVER(ORDER BY A.Id ASC
		)) AS RowNum FROM dbo.StockItemWiseClassificationDetails  AS A
				INNER JOIN dbo.StockItemClassificationDetails AS D ON A.ItemClassificationDetailID=D.Id		
				INNER JOIN dbo.StockItemClassificationHeaders AS H ON A.ItemClassificationHeaderID = H.Id		
				WHERE (A.StockItemHeaderID=@StockheaderID))
			AS InvDets
				ORDER BY InvDets.StockItemHeaderID ASC
END

GO

