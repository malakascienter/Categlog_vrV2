
CREATE PROCEDURE [dbo].[POS_spGetReservationByContactNo]
@ContactNo AS VARCHAR(20),
@PropertyId INT
AS 
SET NOCOUNT ON


SELECT ReservationNo, ReservationDate,CONVERT(VARCHAR, ReservationDate, 23) AS ReservationDateStr, CustomerName, NoOfPacks,NoOfAdult,NoOfChild,NoOfInfant, AdvanceAmount, Remark, OrderNo, 
				CASE WHEN OrderNo <> '' THEN 'On Hold' ELSE '' END AS Status ,R.ContactNo,-- T.TableID, T.TableName,
				R.TimeSlotID, S.Description AS TimeSlot,R.PropertyId,L.code AS Outlet,L.description AS OutletName,CASE WHEN CONVERT(VARCHAR, ReservationDate, 23) = CONVERT(VARCHAR, GETDATE(), 23) THEN '#D35400' ELSE 'black' END as ColorCode
		FROM	Reservation R 
				--INNER JOIN POS_TableList T ON R.TableID = T.TableID
				INNER JOIN POS_ReservationTimeSlot S ON R.TimeSlotID = S.TimeSlotID
				INNER JOIN Location_Ref L ON R.PropertyId = L.PropertyId AND R.Outlet = L.code
		WHERE	IsCancel = 0 AND R.PropertyId = @PropertyId  AND R.ContactNo = @ContactNo and CONVERT(DATE,R.ReservationDate)  >= CONVERT(DATE,GETDATE()) 
		ORDER BY ReservationDate DESC

GO

