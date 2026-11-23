
CREATE PROCEDURE [dbo].[Report_ItemWiseMemberOrderDetails](          
 @FromDate	VARCHAR(10),        
 @ToDate	VARCHAR(10),
 @ItemCodeList    VARCHAR(MAX),
 @PropertyId VARCHAR(2)
)        
AS        
BEGIN         


SELECT BH.MemberName as MemberCode, BH.MemberName,BH.OrderNo,BH.OrderDate,M.Description AS ItemName,BT.Rate,BT.Qty,BT.Rate*BT.Qty AS Amount,M.ItemCode
FROM BillHeader  BH
INNER JOIN BillTrans BT ON BH.OrderNo = BT.OrderNo AND BH.Outlet = BT.Outlet AND BH.OrderDate = BT.OrderDate AND BH.PropertyId = BT.PropertyId
INNER JOIN MainMenu M ON BT.MainMenuCode = M.ItemCode AND BT.PropertyId = M.PropertyId
WHERE BH.OrderDate >= CONVERT(DATETIME,@FromDate,103) AND BH.Orderdate <= CONVERT(DATETIME,@ToDate,103) and BT.MainMenuCode IN (SELECT * FROM STRING_SPLIT(@ItemCodeList,','))  

END;

GO

