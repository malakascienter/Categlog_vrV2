
-- exec [dbo].[ValidateDate] 1


CREATE PROCEDURE [dbo].[ValidateDate] ( @PropertyID INT = 1,@LocationID INT=0)
AS

	DECLARE @IsHotelConnect BIT,@IsResturant BIT,@IsRetail BIT

	SELECT @IsHotelConnect=IsHotelConnect,@IsResturant=IsRestaurant,@IsRetail=IsRetail  
	FROM Companies WHERE CompanyID=@PropertyID

IF(@IsHotelConnect =1)
BEGIN
SELECT CASE WHEN CONVERT(DATE,GETDATE()) >=   [HotelResWeb].[dbo].[GetCurrentDate](@PropertyID) THEN 'TRUE' ELSE 'FALSE' END  RESULT
END
ELSE
IF(@IsResturant=0)
BEGIN
SELECT CASE WHEN CONVERT(DATE,GETDATE()) >=  (SELECT CONVERT(DATE,CurrentDate) FROM Companies WHERE CompanyID=@PropertyID) THEN 'TRUE' ELSE 'FALSE' END  RESULT
END
IF(@IsResturant=1)
BEGIN
	IF(@IsRetail=1)
	BEGIN
	SELECT CASE WHEN CONVERT(DATE,GETDATE()) >=  (SELECT CONVERT(DATE,CurrentDate) FROM Locations WHERE CompanyID=@PropertyID AND ID =@LocationID) THEN 'TRUE' ELSE 'FALSE' END  RESULT
	END
	IF(@IsRetail=0)
	BEGIN
	SELECT CASE WHEN CONVERT(DATE,GETDATE()) >=  (SELECT CONVERT(DATE,CurrentDate) FROM Location_Ref WHERE PropertyId=@PropertyID AND StockLocationID =@LocationID) THEN 'TRUE' ELSE 'FALSE' END  RESULT
	END
END

GO

