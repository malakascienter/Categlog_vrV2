

-- =============================================
-- Author:		Banu
-- Create date: 19/10/2018
-- Description:	Select Menu Item By Id
-- =============================================
CREATE PROCEDURE [dbo].[MenuItem_Select_By_ID] 
	@Id INT,
	@propertyId INT
AS
BEGIN  
	SET NOCOUNT OFF

	CREATE TABLE #TempSales(
		MainMenuCode CHAR(4)
	);
	INSERT INTO #TempSales(MainMenuCode) 
	SELECT DISTINCT MainMenuCode FROM BillTrans

	SELECT MainMenuCode,MM.Id 
	FROM #TempSales BT
	INNER JOIN MainMenu MM ON BT.MainMenuCode = MM.ItemCode  
	WHERE MM.Id = @Id AND MM.propertyId=@propertyId

	DROP TABLE #TempSales
END

GO

