
CREATE PROCEDURE [dbo].[DayEnd_UpdateHotelDateByGroupLocationCode]
@GroupLocationCode VARCHAR(3)
AS
BEGIN
	UPDATE Companies
	SET CurrentDate = DATEADD(D,1,CurrentDate)
	WHERE GroupLocationCode = @GroupLocationCode

	
END

GO

