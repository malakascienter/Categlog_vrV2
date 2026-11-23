
CREATE PROCEDURE [dbo].[DayEnd_UpdateHotelDateLocationWise_Retails]
@LocationId INT,
@PropertyId INT
AS
BEGIN

	UPDATE Locations
	SET CurrentDate = DATEADD(D,1,CurrentDate)
	WHERE Id = @LocationId and PropertyId = @PropertyId

	
END

GO

