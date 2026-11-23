
CREATE PROCEDURE [dbo].[DayEnd_CheckNoSaleDayend]
	@HotelDate DATE,
	@UserId	   INT,
	@DayEndOutlet VARCHAR(MAX),
	@PropertyId INT,
	@IsLocationWiseDayendEnable BIT,
	@IsGroupLocationProperty BIT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


IF( @IsLocationWiseDayendEnable =  1)
BEGIN

 
	IF( (SELECT COUNT(*) FROM BillHeader WHERE OrderDate = @HotelDate AND Outlet  IN (SELECT * FROM STRING_SPLIT(@DayEndOutlet,','))  AND PropertyId = @PropertyId) > 0 )
	BEGIN

	 SELECT 0

	END
	ELSE 
	BEGIN

	 SELECT 1

	END

   
END
ELSE IF( @IsGroupLocationProperty =  1)
BEGIN

 
	IF( (SELECT COUNT(*) FROM BillHeader WHERE OrderDate = @HotelDate AND Outlet  IN (SELECT * FROM STRING_SPLIT(@DayEndOutlet,','))  AND PropertyId = @PropertyId) > 0 )
	BEGIN

	 SELECT 0

	END
	ELSE 
	BEGIN

	 SELECT 1

	END

   
END
ELSE
BEGIN

 
	IF( (SELECT COUNT(*) FROM BillHeader WHERE OrderDate = @HotelDate AND PropertyId = @PropertyId) > 0 )
	BEGIN

	 SELECT 0

	END
	ELSE 
	BEGIN

	 SELECT 1

	END

   
END


END

GO

