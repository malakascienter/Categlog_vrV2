
CREATE PROCEDURE [dbo].[POS_spSelectReservation]
@ReservationNo INT,
@PropertyId INT
AS

BEGIN
  SELECT R.*,REPLACE (REPLACE(CONVERT(VARCHAR(15), R.ArrivalTime, 100) , 'AM', ' AM'), 'PM', ' PM') AS ArrivalTimeStr ,
  (
	   SELECT RT.ReservationNo, RT.TableID,RT.PropertyId,CONCAT(T.TableName,' (',TC.TableCategoryName,')') AS TableName 
	   FROM ReservationWiseTable RT 
	   INNER JOIN POS_TableList T ON RT.TableID = T.TableID AND RT.PropertyId = T.PropertyId 
	   INNER JOIN POS_TableCategories TC ON T.TableCategoryID = TC.TableCategoryID
	   WHERE RT.ReservationNo = R.ReservationNo AND RT.PropertyId = R.PropertyId  FOR JSON PATH ,INCLUDE_NULL_VALUES
  ) as ReservationWiseTableJson,TTC.TableCategoryID,TTC.TableCategoryName,RTS.Description AS TimeSlot
  FROM Reservation R 
  inner join POS_ReservationTimeSlot RTS ON R.TimeSlotID = RTS.TimeSlotID
  INNER JOIN POS_TableCategories TTC ON R.TableCategoryID = TTC.TableCategoryID
  WHERE ReservationNo = @ReservationNo  AND R.PropertyId = @PropertyId 
END

GO

