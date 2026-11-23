
CREATE PROCEDURE [dbo].[Report_UserActivityLog]  
	@FromDate	  VARCHAR(10),        
	@ToDate		  VARCHAR(10),
	@UserLogType  VARCHAR(50),
	@PropertyId   INT
AS  
BEGIN  
	
	
	SELECT u.UserId,u.WaiterCode +'-'+W.Name as WaiterCode,l.description as Outlet,u.OrderNo,u.TempOrderNo,u.OrderDate,u.POSNo,u.ComputerName,u.AccessCode,u.Remark,u.SysDate,u.ProductVersion 
	FROM [dbo].[POS_UserActivityLog] u inner join Location_Ref l on u.Outlet = l.code and u.PropertyId = l.PropertyId
	LEFT JOIN Waiter W  on u.WaiterCode = w.Code and w.PropertyId = u.PropertyId
	WHERE SysDate BETWEEN  CONVERT(DATETIME,@FromDate,103)   AND  CONVERT(DATETIME,@ToDate,103)   AND u.PropertyId = @PropertyId


	
END

GO

