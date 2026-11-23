
CREATE PROCEDURE [dbo].[Report_LoyaltyMemberWiseBillDetails](          
 @FromDate	VARCHAR(10),        
 @ToDate	VARCHAR(10),
 @Outlet    VARCHAR(MAX),
 @PropertyId VARCHAR(2),
 @MemberId   VARCHAR(MAX)
)        
AS        
BEGIN         

	SELECT MM.MembershipNo,ISNULL(MM.FirstName,'')+' '+ISNULL(MM.LastName,'') AS MemberName,BT.OrderNo,LR.description AS Outlet,bt.OrderDate,IT.ItemCode,IT.Description AS ItemName,
	bt.Rate,BT.Qty
	FROM LoyaltyCustomer..MemberPointTrans MT 
	INNER JOIN LoyaltyCustomer..Members MM ON MT.MemberId = MM.Id
	INNER JOIN LoyaltyCustomer..Location L ON MT.OutletId = L.Id
	INNER JOIN Categlog_vrV2..Location_Ref LR ON LR.code = L.Outlet
	INNER JOIN Categlog_vrV2..BillTrans BT ON MT.TxnDate = BT.OrderDate AND MT.OrderNo = BT.OrderNo AND BT.Outlet = LR.code
	INNER JOIN Categlog_vrV2..MainMenu IT ON IT.ItemCode = BT.MainMenuCode AND IT.PropertyId = BT.PropertyId 
	WHERE BT.OrderDate >= CONVERT(DATETIME,@FromDate,103) 
		AND BT.OrderDate <= CONVERT(DATETIME,@ToDate,103) 
		AND BT.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))  AND BT.PropertyId=@PropertyId   AND MM.ID = CASE WHEN @MemberId = '0' THEN  MM.ID ELSE @MemberId END AND MT.TransactionType = 'G'

END;

GO

