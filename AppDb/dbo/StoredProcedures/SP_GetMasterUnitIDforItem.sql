-- =============================================
-- Author:		vinuki
-- Create date:2024.05.22
-- Description:	Get Master Unit for Item
--SP_GetMasterUnitIDforItem 'ENG/ELC/00106' , 4
-- =============================================
CREATE PROCEDURE SP_GetMasterUnitIDforItem
	@StockItemCode varchar(50),
	@LocationID Int
AS
BEGIN
		SELECT U.Name  FROM dbo.StockItemHeaders SH INNER jOIN
		dbo.StockItemDetails SD on SH.id= SD.StockItemHeaderID INNER JOIN 
		dbo.Units U ON U.id=SD.MasterUnitID WHERE SH.StockItemCode= @StockItemCode AND SD.LocationID= @LocationID
END

GO

