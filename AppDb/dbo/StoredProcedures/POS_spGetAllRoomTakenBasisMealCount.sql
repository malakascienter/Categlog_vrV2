-- =============================================
-- Author:		Nivesh
-- Create date: 2025-10-22
-- Description:	Get Taken Basis Meal Count
-- =============================================
CREATE   PROCEDURE [dbo].[POS_spGetAllRoomTakenBasisMealCount] (
@XMLString NVARCHAR(MAX))
AS
BEGIN
	
	SET NOCOUNT ON;
    DECLARE 
        @iDocID INT
        
    EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLString;
     
     CREATE TABLE #TempTable (
       [ReservationNo] [varchar](20),
	    [RoomID] [int]
     )

     INSERT INTO #TempTable (
            [ReservationNo]
           ,[RoomID])
     SELECT 
            [ReservationNo]
           ,[RoomID]
			FROM
            OPENXML(@iDocID, '/ArrayOfClsRoomList/clsRoomList', 2)
            WITH (
	        [ReservationNo] [varchar](20),
	        [RoomID] [int]
            );

    SELECT BMT.HotelReservationNo,
        BMT.MealCode,
        BMT.RoomID,
        BMT.PropertyId,
        ISNULL(SUM(BMT.Pax),0) AS ServedPaxCount,
        BMT.HeadCount
    FROM [dbo].[BasisMealTemp] BMT 
    INNER JOIN #TempTable TT ON TT.ReservationNo = BMT.HotelReservationNo AND TT.RoomID = BMT.RoomID
    WHERE BMT.MealCode = (SELECT TOP 1 MealCode FROM POS_MealSchedule WHERE CONVERT(TIME,GETDATE()) BETWEEN FromTime AND ToTime)
    GROUP BY BMT.HotelReservationNo,
        BMT.MealCode,
        BMT.RoomID,
        BMT.PropertyId,
        BMT.HeadCount
    
END

GO

