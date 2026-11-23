--EXEC [SP_GetReservationWiseItemDetails] N'[{"ReservationNo":"R000000001","PropertyId":1},{"ReservationNo":"R000000002","PropertyId":1}]'
CREATE PROCEDURE [dbo].[SP_GetReservationWiseItemDetails] 
@ReservationListJson VARCHAR(MAX)
AS
BEGIN
	 
	SET NOCOUNT OFF;


	IF OBJECT_ID(N'tempdb..#TempReservationList') IS NOT NULL
	BEGIN
	DROP TABLE #TempReservationList
	END

	SELECT * 
	INTO #TempReservationList
	FROM OPENJSON(@ReservationListJson)  
	WITH 
	(
		ReservationNo			VARCHAR(20) '$.ReservationNo',
		PropertyId				INT '$.PropertyId'
		
	)

	--SELECT * FROM #TempReservationList


	SELECT BH.OrderNo,BH.OrderDate,BH.Outlet,BH.PropertyId, MM.ItemCode,MM.Description,BT.Qty,BT.Rate
	FROM BillHeader BH WITH(NOLOCK) INNER JOIN BillTrans BT WITH(NOLOCK) ON BH.OrderNo = BT.OrderNo AND BH.OrderDate = BT.OrderDate AND BH.Outlet = BT.Outlet AND BH.PropertyId = BT.PropertyId
	INNER JOIN MainMenu MM WITH(NOLOCK) ON BT.MainMenuCode = MM.ItemCode AND BT.PropertyId = MM.PropertyId
	INNER JOIN #TempReservationList TR ON BH.HotelReservationNo = TR.ReservationNo AND BH.PropertyId = TR.PropertyId 



	IF OBJECT_ID(N'tempdb..#TempReservationList') IS NOT NULL
	BEGIN
	DROP TABLE #TempReservationList
	END

END

GO

