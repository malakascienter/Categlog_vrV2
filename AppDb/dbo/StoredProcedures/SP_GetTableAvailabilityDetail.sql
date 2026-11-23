--EXEC [SP_GetTableAvailabilityDetail] '2023-12-21','300',179,1
CREATE PROCEDURE [dbo].[SP_GetTableAvailabilityDetail]
	 @ResDate		DATE, 
	 @Outlet		VARCHAR(3),
	 @TimeSlot		INT,
	 @PropertyId	INT
AS
BEGIN

	SET NOCOUNT ON;

	IF OBJECT_ID(N'tempdb..#TempRes') IS NOT NULL
	BEGIN
	DROP TABLE #TempRes
	END


	CREATE TABLE #TempRes(
	   [ReservationDate] DATE  NULL,
	   TimeSlotName VARCHAR(50)  NULL,
	   TimeSlotID [int]  NULL,
	   Outlet VARCHAR(5)  NULL,
	   OutletName VARCHAR(50)  NULL,
	   Status VARCHAR(50)  NULL,
	   ReservationNo [int]  NULL,
	   TableName VARCHAR(50)  NULL,
	   TableID [int]  NULL,
	)

	INSERT INTO #TempRes(ReservationDate,TimeSlotName,TimeSlotID,Outlet,OutletName,Status,ReservationNo,TableName,TableID)
    SELECT R.ReservationDate, RT.Description AS TimeSlotName,RT.TimeSlotID ,L.code AS Outlet,L.description AS OutletName,'Reserved' AS Status,R.ReservationNo,CONCAT(T.TableName,' (',TC.TableCategoryName,')'),T.TableID
	FROM POS_TableList T
	INNER JOIN POS_TableCategories TC ON T.TableCategoryID = TC.TableCategoryID
	INNER JOIN ReservationWiseTable RWT ON RWT.TableID = T.TableID AND RWT.PropertyId = T.PropertyId
	INNER JOIN Reservation R ON RWT.ReservationNo = R.ReservationNo AND RWT.PropertyId = R.PropertyId
	INNER JOIN POS_ReservationTimeSlot RT ON R.TimeSlotID = RT.TimeSlotID
	INNER JOIN Location_Ref L ON R.Outlet = L.code AND R.PropertyId = L.PropertyId
	WHERE  R.ReservationDate = @ResDate AND R.PropertyId = @PropertyId AND R.Outlet = @Outlet AND R.TimeSlotID = @TimeSlot AND T.PropertyId = @PropertyId AND T.IsActive = 1 and r.IsCancel = 0
	GROUP BY R.ReservationDate, RT.Description,RT.TimeSlotID ,L.code ,L.description ,R.ReservationNo,T.TableName,T.TableID,TC.TableCategoryName



	INSERT INTO #TempRes(ReservationDate,TimeSlotName,TimeSlotID,Outlet,OutletName,Status,ReservationNo,TableName,TableID)
	SELECT @ResDate,'NA',0,'','','Available',0,CONCAT(T.TableName,' (',TC.TableCategoryName,')'),T.TableID FROM POS_TableList T INNER JOIN POS_TableCategories TC ON T.TableCategoryID = TC.TableCategoryID WHERE TableID NOT IN (SELECT TableID FROM #TempRes) AND T.PropertyId = @PropertyId AND T.IsActive = 1

	SELECT * FROM #TempRes


	IF OBJECT_ID(N'tempdb..#TempRes') IS NOT NULL
	BEGIN
	DROP TABLE #TempRes
	END



END

GO

