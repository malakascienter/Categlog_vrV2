

CREATE function [dbo].[Get_OrderWiseSurveyCode](@OrderNo varchar(10), @OrderDate DATETIME, @OutletCode VARCHAR(5),@PropertyId INT)
returns VARCHAR(50)
as 
begin
DECLARE @SurveyCode VARCHAR(50) = ''

	IF EXISTS(SELECT OrderNo FROM BillHeader WHERE OrderNo = @OrderNo AND OrderDate = @OrderDate AND Outlet = @OutletCode AND PropertyId = @PropertyId)
		BEGIN
			

			SET @SurveyCode = (
			SELECT	SUBSTRING(@OrderNo, 6, 1) +
					SUBSTRING(LTRIM(DATEPART(YEAR,H.OrderDate)), 4, 1) +
					RIGHT(REPLICATE('0', 2) + LTRIM(DATEPART(MONTH,H.OrderDate)), 2) +
					RIGHT(REPLICATE('0', 2) + LTRIM(DATEPART(DAY,H.OrderDate)), 2) +
					RIGHT(REPLICATE('0', 6) + LTRIM(L.StoreID),6) +
					SUBSTRING(@OrderNo, 3, 4) 
			FROM	Location_Ref AS L INNER JOIN BillHeader AS H ON L.code = H.Outlet
			WHERE	H.OrderNo = @OrderNo AND H.OrderDate = @OrderDate AND H.Outlet = @OutletCode AND H.PropertyId = @PropertyId) 

			     

		END
	


		RETURN ISNULL(@SurveyCode,'')

end

GO

