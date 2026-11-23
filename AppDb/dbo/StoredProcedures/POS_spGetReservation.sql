--exec [POS_spGetReservation] 'A',1
CREATE PROCEDURE [dbo].[POS_spGetReservation]
@Type AS VARCHAR(1),
@PropertyId INT
AS 
SET NOCOUNT ON


IF @Type = 'A'
	BEGIN
		SELECT ReservationNo, ReservationDate,CONVERT(VARCHAR, ReservationDate, 23) AS ReservationDateStr, CONCAT(ISNULL(ST.Name ,''),' ',CustomerName) AS CustomerName, NoOfPacks,NoOfAdult,NoOfChild,NoOfInfant, AdvanceAmount, Remark, OrderNo, 
				CASE WHEN OrderNo <> '' THEN 'On Hold' ELSE '' END AS Status ,R.ContactNo, --T.TableID, T.TableName,
				R.TimeSlotID, S.Description AS TimeSlot,R.PropertyId,L.code AS Outlet,L.description AS OutletName,CASE WHEN CONVERT(VARCHAR, ReservationDate, 23) = CONVERT(VARCHAR, GETDATE(), 23) THEN '#D35400' ELSE 'black' END as ColorCode,
				CASE WHEN R.IsUpload = 0 THEN 'NOT SYNC' ELSE 'SYNC' END AS SyncStatus
		FROM	Reservation R 
				--INNER JOIN POS_TableList T ON R.TableID = T.TableID
				INNER JOIN POS_ReservationTimeSlot S ON R.TimeSlotID = S.TimeSlotID
				INNER JOIN Location_Ref L ON R.PropertyId = L.PropertyId AND R.Outlet = L.code
				LEFT JOIN Salutations ST ON R.SalutationId = ST.ID
		WHERE	IsCancel = 0 AND IsComplete = 0  AND R.PropertyId = @PropertyId AND CONVERT(DATE,ReservationDate) >= CONVERT(DATE,GETDATE())
		ORDER BY ReservationDate DESC
	END
ELSE IF @Type = 'T'
	BEGIN
		SELECT ReservationNo, ReservationDate,CONVERT(VARCHAR, ReservationDate, 23) AS ReservationDateStr, CONCAT(ISNULL(ST.Name ,''),' ',CustomerName) AS CustomerName, NoOfPacks,NoOfAdult,NoOfChild,NoOfInfant, AdvanceAmount, Remark, OrderNo, 
				CASE WHEN OrderNo <> '' THEN 'On Hold' ELSE '' END AS Status ,R.ContactNo, --T.TableID, T.TableName,
				R.TimeSlotID, S.Description AS TimeSlot,R.PropertyId,L.code AS Outlet,L.description AS OutletName,CASE WHEN CONVERT(VARCHAR, ReservationDate, 23) = CONVERT(VARCHAR, GETDATE(), 23) THEN '#D35400' ELSE 'black' END as ColorCode,
				CASE WHEN R.IsUpload = 0 THEN 'NOT SYNC' ELSE 'SYNC' END AS SyncStatus
		FROM	Reservation R 
				--INNER JOIN POS_TableList T ON R.TableID = T.TableID
				INNER JOIN POS_ReservationTimeSlot S ON R.TimeSlotID = S.TimeSlotID
				INNER JOIN Location_Ref L ON R.PropertyId = L.PropertyId AND R.Outlet = L.code
				LEFT JOIN Salutations ST ON R.SalutationId = ST.ID
		WHERE	IsCancel = 0 AND IsComplete = 0 AND CONVERT(DATE,ReservationDate) = (SELECT CONVERT(DATE,CurrentDate) FROM Companies WHERE CompanyID = @PropertyId) 
		AND R.PropertyId = @PropertyId AND CONVERT(DATE,ReservationDate) >= CONVERT(DATE,GETDATE())
		ORDER BY ReservationDate DESC
	END
ELSE IF @Type = 'C'
	BEGIN
		SELECT ReservationNo, ReservationDate,CONVERT(VARCHAR, ReservationDate, 23) AS ReservationDateStr, CONCAT(ISNULL(ST.Name ,''),' ',CustomerName) AS CustomerName, NoOfPacks,NoOfAdult,NoOfChild,NoOfInfant, AdvanceAmount, Remark, OrderNo, 
				CASE WHEN OrderNo <> '' THEN 'On Hold' ELSE '' END AS Status ,R.ContactNo, --T.TableID, T.TableName,
				R.TimeSlotID, S.Description AS TimeSlot,R.PropertyId,L.code AS Outlet,L.description AS OutletName,CASE WHEN CONVERT(VARCHAR, ReservationDate, 23) = CONVERT(VARCHAR, GETDATE(), 23) THEN '#D35400' ELSE 'black' END as ColorCode,
				CASE WHEN R.IsUpload = 0 THEN 'NOT SYNC' ELSE 'SYNC' END AS SyncStatus
		FROM	Reservation R 
				--INNER JOIN POS_TableList T ON R.TableID = T.TableID
				INNER JOIN POS_ReservationTimeSlot S ON R.TimeSlotID = S.TimeSlotID
				INNER JOIN Location_Ref L ON R.PropertyId = L.PropertyId AND R.Outlet = L.code
				LEFT JOIN Salutations ST ON R.SalutationId = ST.ID
		WHERE	IsCancel = 1 AND R.PropertyId = @PropertyId AND CONVERT(DATE,ReservationDate) >= CONVERT(DATE,GETDATE())
		ORDER BY ReservationDate DESC
	END
ELSE IF @Type = 'RT'
	BEGIN
		SELECT ReservationNo, ReservationDate,CONVERT(VARCHAR, ReservationDate, 23) AS ReservationDateStr, CONCAT(ISNULL(ST.Name ,''),' ',CustomerName) AS CustomerName, NoOfPacks,NoOfAdult,NoOfChild,NoOfInfant, AdvanceAmount, Remark, OrderNo, 
				CASE WHEN OrderNo <> '' THEN 'On Hold' ELSE '' END AS Status ,R.ContactNo,-- T.TableID, T.TableName,
				R.TimeSlotID, S.Description AS TimeSlot,R.PropertyId,L.code AS Outlet,L.description AS OutletName,CASE WHEN CONVERT(VARCHAR, ReservationDate, 23) = CONVERT(VARCHAR, GETDATE(), 23) THEN '#D35400' ELSE 'black' END as ColorCode,
				CASE WHEN R.IsUpload = 0 THEN 'NOT SYNC' ELSE 'SYNC' END AS SyncStatus
		FROM	Reservation R 
				--INNER JOIN POS_TableList T ON R.TableID = T.TableID
				INNER JOIN POS_ReservationTimeSlot S ON R.TimeSlotID = S.TimeSlotID
				INNER JOIN Location_Ref L ON R.PropertyId = L.PropertyId AND R.Outlet = L.code
				LEFT JOIN Salutations ST ON R.SalutationId = ST.ID
		WHERE	IsCancel = 1 AND R.PropertyId = @PropertyId AND CONVERT(DATE,ReservationDate) >= CONVERT(DATE,GETDATE())
		ORDER BY ReservationDate DESC
	END

GO

