
CREATE FUNCTION [dbo].[GetBusinessDate_Retail](@PropertyId int ,@LocationId int) 
RETURNs DATE
AS
begin

DECLARE @BusinessDate AS DATE
DECLARE @IsRestaurant AS BIT

SELECT @IsRestaurant = IsRestaurant  FROM Companies WHERE CompanyID = @PropertyId


IF( @IsRestaurant = 1 )
BEGIN

SELECT @BusinessDate = CurrentDate FROM Locations WHERE Id =  @LocationId

END
ELSE
BEGIN

 SELECT @BusinessDate = CurrentDate  FROM Companies WHERE CompanyID = @PropertyId

END
	
	
RETURN ISNULL(@BusinessDate,GETDATE())


end

GO

