

CREATE PROCEDURE [dbo].[Sync_spGetReservationDetails]
@PropertyId INT,
@ReservationNo INT

AS

SELECT	ReservationNo, CONVERT(VARCHAR(50),ReservationDate,103) AS ReservationDate, CustomerName, NoOfPacks, AdvanceAmount, Remark, OrderNo, IsCancel, IsComplete, 
		CreateUser, CONVERT(VARCHAR(50),CreateDate,103) AS CreateDate, EditedUser, CONVERT(VARCHAR(50),EditedDate,103) AS EditedDate, 
		CancelUser, CONVERT(VARCHAR(50),CancelDate,103) AS CancelDate, Outlet, IsUpload, IsOnGoing, ContactNo, TableID, CONVERT(VARCHAR(50),TimeSlotID,103) AS TimeSlotID, 
		NoOfAdult, NoOfChild, NoOfInfant,CONVERT(VARCHAR(50),StartTime,13) AS FromTime, CONVERT(VARCHAR(50),ToTime,13) AS ToTime
FROM    Reservation 
WHERE	ReservationNo = @ReservationNo AND PropertyId = @PropertyId

SELECT	ReservationNo, PayCode, PayType, Amount, Remark, CreateUser, CONVERT(VARCHAR(50),CreateDate,103) AS CreateDate, IsCancel, 
		CancelUser, CONVERT(VARCHAR(50),CancelDate,103) AS CancelDate, ShiftID, Outlet
FROM	ReservationPayment
WHERE	ReservationNo = @ReservationNo AND PropertyId = @PropertyId AND IsCancel = 0

SELECT	ReservationNo, TableID
FROM	ReservationWiseTable
WHERE	ReservationNo = @ReservationNo AND PropertyId = @PropertyId

GO

