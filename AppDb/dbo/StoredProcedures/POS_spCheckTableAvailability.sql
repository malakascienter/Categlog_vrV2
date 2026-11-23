--exec [POS_spCheckTableAvailability] '2024-02-15',2,
CREATE PROCEDURE [dbo].[POS_spCheckTableAvailability]
@ReservationDate AS DATE,
@TimeSlotID INT,
@ReservationWiseTableJson VARCHAR(MAX),
@Outlet VARCHAR(5),
@PropertyId INT
AS 
SET NOCOUNT ON

SELECT TableID
INTO #TempTable
FROM OPENJSON(@ReservationWiseTableJson)  
WITH 
(		
	TableID  INT '$.TableID'
)

SELECT R.ReservationNo, ReservationDate,CONVERT(VARCHAR, ReservationDate, 23) AS ReservationDateStr, CustomerName, NoOfPacks, AdvanceAmount, Remark, OrderNo, 
		CASE WHEN OrderNo <> '' THEN 'On Hold' ELSE '' END AS Status ,R.ContactNo, T.TableID, T.TableName,
		R.TimeSlotID, S.Description AS TimeSlot,R.PropertyId,L.code AS Outlet,L.description AS OutletName
FROM	Reservation R 
inner JOIN ReservationWiseTable RWT ON R.ReservationNo = RWT.ReservationNo
INNER JOIN POS_TableList T ON R.TableID = RWT.TableID
		INNER JOIN POS_ReservationTimeSlot S ON R.TimeSlotID = S.TimeSlotID
		INNER JOIN Location_Ref L ON R.PropertyId = L.PropertyId AND R.Outlet = L.code
WHERE	R.ReservationDate = @ReservationDate AND R.TimeSlotID = @TimeSlotID  AND R.PropertyId = @PropertyId AND RWT.TableID IN  (SELECT TableID FROM #TempTable) AND R.Outlet = @Outlet and r.IsCancel = 0

GO

