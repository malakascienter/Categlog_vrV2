CREATE PROCEDURE [dbo].[Report_UserActivityLog_ReinstateAfterDeleteItem]  
    @FromDate     VARCHAR(10),        
    @ToDate       VARCHAR(10),
    @PropertyId   INT,
    @Outlet    VARCHAR(MAX)
AS  
BEGIN  

    SELECT u.OrderNo AS OrderNo_H,
           l.Code AS OutletCode_H,
           u.OrderDate AS OrderDate_H,
           u.PropertyId AS PropertyId_H,
           l.description AS OutletName_H,
           MIN(u.ID) AS ActivityId
    INTO #TempReinstateBill
    FROM [dbo].[POS_UserActivityLog] u 
    INNER JOIN Location_Ref l ON u.Outlet = l.code AND u.PropertyId = l.PropertyId
    LEFT JOIN Waiter W ON u.WaiterCode = W.Code AND W.PropertyId = u.PropertyId
    WHERE u.SysDate BETWEEN CONVERT(DATETIME, @FromDate, 103) AND CONVERT(DATETIME, @ToDate, 103)
      AND u.PropertyId = @PropertyId 
      AND u.AccessCode = 'ReinstateCloseTable'
    GROUP BY u.OrderNo,
             l.Code,
             u.OrderDate,
             u.PropertyId,
             l.description

    SELECT u.UserId AS UserId_D,
           u.WaiterCode +'-'+W.Name AS WaiterCode_D,
           l.description AS Outlet_D,
           u.TempOrderNo AS TempOrderNo_D,
           u.POSNo AS POSNo_D,
           u.ComputerName AS ComputerName_D,
           u.AccessCode AS AccessCode_D,
           u.Remark AS Remark_D,
           u.SysDate AS SysDate_D,
           u.ProductVersion AS ProductVersion_D,
           u.OrderNo AS OrderNo_D,
           l.Code AS OutletCode_D,
           u.OrderDate AS OrderDate_D,
           u.PropertyId AS PropertyId_D,
           TR.ActivityId
    INTO #TempDeleteBill
    FROM [dbo].[POS_UserActivityLog] u 
    INNER JOIN Location_Ref l ON u.Outlet = l.code AND u.PropertyId = l.PropertyId
    LEFT JOIN Waiter W ON u.WaiterCode = W.Code AND W.PropertyId = u.PropertyId
    INNER JOIN #TempReinstateBill TR ON TR.OrderNo_H = u.OrderNo 
                                    AND TR.OutletCode_H = l.Code 
                                    AND TR.OrderDate_H = u.OrderDate 
                                    AND TR.PropertyId_H = u.PropertyId
                                    AND u.Id > TR.ActivityId  -- ✅ Moved here from the FROM clause
    WHERE u.SysDate BETWEEN CONVERT(DATETIME, @FromDate, 103) AND CONVERT(DATETIME, @ToDate, 103)
      AND u.PropertyId = @PropertyId 
      AND u.AccessCode = 'DeleteItem'

    SELECT * 
    FROM #TempReinstateBill T1 
    INNER JOIN #TempDeleteBill T2 ON T1.OrderNo_H = T2.OrderNo_D 
                                  AND T1.OutletCode_H = T2.OutletCode_D 
                                  AND T1.OrderDate_H = T2.OrderDate_D  -- ✅ Fixed missing dot
                                  AND T1.PropertyId_H = T2.PropertyId_D
    WHERE  T1.OutletCode_H IN (SELECT * FROM STRING_SPLIT(@Outlet,','))

    DROP TABLE #TempReinstateBill
    DROP TABLE #TempDeleteBill

END

GO

