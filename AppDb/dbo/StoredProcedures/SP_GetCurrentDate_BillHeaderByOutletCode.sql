
CREATE PROCEDURE [dbo].[SP_GetCurrentDate_BillHeaderByOutletCode] 
	@OultletCode	VARCHAR(10),
	@CurrentDate	DATETIME,
	@PropertyId     INT
AS
BEGIN
SELECT *
  FROM [dbo].[BillHeader]
  WHERE [Outlet] = @OultletCode AND convert(date,[OrderDate]) = convert(date,@CurrentDate) --AND PropertyId = @PropertyId
END

GO

