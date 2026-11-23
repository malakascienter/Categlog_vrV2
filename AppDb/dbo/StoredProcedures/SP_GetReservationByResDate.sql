--EXEC [SP_GetReservationByResDate] '2024-02-08','300',1,1
CREATE PROCEDURE [dbo].[SP_GetReservationByResDate]
	 @ResDate		DATE, 
	 @Outlet		VARCHAR(3),
	 @PropertyId	INT,
	 @TimeSlot		INT
AS
BEGIN

	SET NOCOUNT ON;


	--SELECT RTS.TimeSlotID,RTS.Description AS TimeSlot, TCL.TableCategoryID ,TCL.TableCategoryName,TCL.MaxPaxLimit INTO #TempTimeWiseTableCategory FROM POS_ReservationTimeSlot RTS CROSS JOIN POS_TableCategories TCL  WHERE TCL.PropertyId = @PropertyId


	--SELECT @ResDate AS ReservationDate, RT.TimeSlot AS TimeSlotName,RT.TimeSlotID ,SUM(R.NoOfPacks) AS NoOfPacks,RT.MaxPaxLimit AS MaxPaxCount,(RT.MaxPaxLimit)-ISNULL((SELECT SUM(TRT.NoOfPacks) FROM Reservation TRT WHERE TRT.ReservationDate = @ResDate AND TRT.Outlet = @Outlet AND TRT.PropertyId = @PropertyId AND TRT.TimeSlotID = RT.TimeSlotID AND TRT.TableCategoryID = R.TableCategoryID ),0) AS AvailablePaxCount,
	--RT.TableCategoryID ,RT.TableCategoryName
	--FROM #TempTimeWiseTableCategory RT LEFT JOIN Reservation R  ON RT.TimeSlotID = R.TimeSlotID
	----INNER JOIN POS_TableList T ON R.TableID = T.TableID
	----INNER JOIN Location_Ref L ON R.Outlet = L.code AND R.PropertyId = L.PropertyId
	--WHERE  R.ReservationDate = @ResDate AND R.PropertyId = @PropertyId AND R.Outlet = @Outlet  AND R.IsCancel = 0
	--GROUP BY R.ReservationDate, RT.TimeSlot ,RT.TimeSlotID ,RT.MaxPaxLimit,RT.TableCategoryID ,RT.TableCategoryName,R.TableCategoryID

 --   SELECT @ResDate AS ReservationDate, RT.Description AS TimeSlotName,RT.TimeSlotID ,L.code AS Outlet,L.description AS OutletName,SUM(R.NoOfPacks) AS NoOfPacks,TC.MaxPaxLimit AS MaxPaxCount,(TC.MaxPaxLimit)-ISNULL((SELECT SUM(NoOfPacks) FROM Reservation TRT WHERE TRT.ReservationDate = @ResDate AND TRT.Outlet = @Outlet AND TRT.PropertyId = @PropertyId AND TRT.TimeSlotID = RT.TimeSlotID AND TRT.TableCategoryID = R.TableCategoryID),0) AS AvailablePaxCount,
	--TC.TableCategoryID ,TC.TableCategoryName
	--FROM Reservation R 
	--INNER JOIN POS_ReservationTimeSlot RT ON R.TimeSlotID = RT.TimeSlotID
	----INNER JOIN POS_TableList T ON R.TableID = T.TableID
	--INNER JOIN Location_Ref L ON R.Outlet = L.code AND R.PropertyId = L.PropertyId
	--INNER JOIN POS_TableCategories TC ON R.TableCategoryID = TC.TableCategoryID
	--WHERE  R.ReservationDate = @ResDate AND R.PropertyId = @PropertyId AND R.Outlet = @Outlet  AND R.IsCancel = 0
	--GROUP BY R.ReservationDate, RT.Description ,RT.TimeSlotID ,L.code ,L.description,TC.MaxPaxLimit,TC.TableCategoryID ,TC.TableCategoryName,R.TableCategoryID

	SELECT (MaxPaxLimit - ISNULL((SELECT SUM(TRT.NoOfPacks) FROM Reservation TRT WHERE TRT.IsCancel = 0 AND TRT.ReservationDate = @ResDate AND TRT.Outlet = @Outlet AND TRT.PropertyId = @PropertyId AND TRT.TimeSlotID = @TimeSlot AND TRT.TableCategoryID = TCL.TableCategoryID ),0))   AS AvailablePaxCount,
	ISNULL((SELECT SUM(TRT.NoOfPacks) FROM Reservation TRT WHERE TRT.IsCancel = 0  AND TRT.ReservationDate = @ResDate AND TRT.Outlet = @Outlet AND TRT.PropertyId = @PropertyId AND TRT.TimeSlotID = @TimeSlot AND TRT.TableCategoryID = TCL.TableCategoryID ),0) AS NoOfPacks,
	TCL.MaxPaxLimit AS MaxPaxCount,TCL.TableCategoryID ,TCL.TableCategoryName,@TimeSlot AS TimeSlotID
	FROM POS_TableCategories TCL WHERE TCL.PropertyId = @PropertyId
	
END

GO

