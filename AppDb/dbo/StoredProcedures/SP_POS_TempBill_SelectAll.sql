-- =============================================
-- Author:		Chiraj
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_POS_TempBill_SelectAll]
	--@Code VARCHAR(3),
	--@PropertyId INT
AS
BEGIN

   SELECT	T.OrderNo,T.StationID,T.Name AS MenuItemName,T.KOTName AS KotBot,T.Rate,T.Quantity AS Qty,
   CASE 
   WHEN T.IsCloseTable = 1 THEN 'YES'
   ELSE 'NO'
   END AS CloseTable,
   T.IsCloseTable,
   L.description as OutletName,
   T.TableID AS TableName


   FROM		POS_TempBill T  INNER JOIN Location_Ref L ON T.OutletID = L.code 
  
END

GO

