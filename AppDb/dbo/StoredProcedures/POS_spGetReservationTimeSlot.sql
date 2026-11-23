CREATE PROCEDURE [dbo].[POS_spGetReservationTimeSlot]

AS

	SELECT	TimeSlotID, Description + ' - ' + LEFT(CONVERT(TIME, FromTime),5) + ' to ' + LEFT(CONVERT(TIME, ToTime),5) AS Description
	FROM	POS_ReservationTimeSlot

GO

