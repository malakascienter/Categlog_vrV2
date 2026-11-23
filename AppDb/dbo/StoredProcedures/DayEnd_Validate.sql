
---exec DayEnd_Validate '2021-09-16 00:00:00.000',1
CREATE PROCEDURE [dbo].[DayEnd_Validate]
    @HotelDate	DATE,
	@PropertyId INT
AS
BEGIN
	SELECT * 
	FROM ReservationHeaders
	WHERE IsCompleted=0
	AND ReservationDate=@HotelDate
	AND PropertyId=@PropertyId
END

GO

