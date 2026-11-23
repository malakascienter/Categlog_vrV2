
create FUNCTION [dbo].[FN_GetTransactionDate](@PropertyId INT)
RETURNS DATE 
AS
BEGIN

DECLARE @DayEndModuleId INT
DECLARE @BusinessDate DATE
SELECT @DayEndModuleId =  DayEndModuleId  FROM Companies WHERE CompanyID = @PropertyId



IF( @DayEndModuleId = 0 )
BEGIN

 SET @BusinessDate  =GETDATE()

END
ELSE IF (@DayEndModuleId = 1) --FRONT OFFICE
BEGIN

 SET @BusinessDate  = (SELECT CurrentDate FROM HotelResWeb..FOSettings WHERE PropertyId = @PropertyId)

END
ELSE IF (@DayEndModuleId = 3) --POS BACKEND
BEGIN

 SET @BusinessDate = (SELECT  CurrentDate FROM Companies WHERE CompanyID = @PropertyId)

END
ELSE
BEGIN

 SET @BusinessDate  =GETDATE()

END

 RETURN @BusinessDate


END

GO

