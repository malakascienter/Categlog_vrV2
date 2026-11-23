
CREATE FUNCTION [dbo].[FN_GetCurrentDate](@PropertyId INT,@LocationID INT)
RETURNS DATE 
AS
BEGIN
DECLARE @BusinessDate DATE

DECLARE @IsHotelConnect BIT,@IsResturant BIT,@IsRetail BIT

DECLARE @DayEndModuleId INT

SELECT @DayEndModuleId =  DayEndModuleId  FROM Companies WHERE CompanyID = @PropertyId

SELECT @IsHotelConnect=IsHotelConnect,@IsResturant=IsRestaurant,@IsRetail=IsRetail  
FROM Companies WHERE CompanyID=@PropertyID


IF(@DayEndModuleId <>3)
BEGIN
SELECT @BusinessDate =  GEtDate()
END
ELSE
IF(@IsResturant=0)
BEGIN
	IF(@IsRetail=1)
	BEGIN
	 SELECT @BusinessDate =CONVERT(DATE,CurrentDate) FROM Locations WHERE CompanyID=@PropertyID AND ID =@LocationID
	END
	IF(@IsRetail=0)
	BEGIN
	SELECT @BusinessDate =CONVERT(DATE,CurrentDate) FROM Companies WHERE CompanyID=@PropertyID
	END
END
IF(@IsResturant=1)
BEGIN
	IF(@IsRetail=1)
	BEGIN
	 SELECT @BusinessDate =CONVERT(DATE,CurrentDate) FROM Locations WHERE CompanyID=@PropertyID AND ID =@LocationID
	END
	IF(@IsRetail=0)
	BEGIN
	 SELECT @BusinessDate =CONVERT(DATE,CurrentDate) FROM Location_Ref WHERE PropertyId=@PropertyID AND StockLocationID =@LocationID
	END
END
SET @BusinessDate = ISNULL(@BusinessDate,GETDATE())

-- Validate if @BusinessDate is older than 30 days from today
IF (@BusinessDate < DATEADD(DAY, -30, GETDATE()))							
BEGIN
    SET @BusinessDate = GETDATE();
END


 RETURN @BusinessDate

END

GO

