
CREATE PROCEDURE [dbo].[UserActivityLog_M_Select]
	@From DATE,
	@To DATE,
	@OutletList VARCHAR(50),
	@PropertyId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   SELECT UA.ID,UA.UserId,UA.UserId AS UserName,UA.WaiterCode,W.Name AS Waite,UA.Outlet AS OutletCode,L.description AS OutletName,UA.OrderNo,UA.TempOrderNo,UA.OrderDate,
		  UA.POSNo,UA.ComputerName,UA.AccessCode,UA.Remark,UA.SysDate,UA.ProductVersion,UA.PropertyId
   FROM POS_UserActivityLog UA 
   INNER JOIN Location_Ref L ON UA.Outlet = L.code AND UA.PropertyId = L.PropertyId 
   LEFT JOIN Waiter W ON UA.WaiterCode = W.Code AND UA.PropertyId = W.PropertyId
   where UA.OrderDate between @From and @To and L.code  = @OutletList AND UA.PropertyId = @PropertyId
   ORDER BY UA.OrderNo,UA.SysDate



END

GO

