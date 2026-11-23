--Report_DayWiseExecutiveBillDetail '01/08/2023','08/08/2023','JMB,JMR,JRO,JRT,JTA,MB','21'
CREATE PROCEDURE [dbo].[Report_DayWiseExecutiveBillDetail]
 @FromDate	VARCHAR(10),        
 @ToDate	VARCHAR(10),
 @Outlet    VARCHAR(MAX),
 @PropertyId VARCHAR(2)
AS
BEGIN	
	SET NOCOUNT ON;

	SELECT BT.OrderNo,BT.OrderDate,
	BT.Qty,BT.Rate,C.Description AS Category,BH.MemberID,PE.MemberName,PE.CreditBalance,
	PK.KOTName as MainMenu	
	FROM BillTrans AS BT
	INNER JOIN Category AS C ON C.Code=BT.Category AND C.PropertyId=BT.PropertyId
	INNER JOIN MainMenu AS MM ON MM.ItemCode=BT.MainMenuCode AND MM.PropertyId=BT.PropertyId
	INNER JOIN BillHeader AS BH ON BH.OrderNo=BT.OrderNo AND BH.OrderDate = BT.OrderDate AND BH.Outlet = BT.Outlet AND BH.PropertyId=BT.PropertyId
	INNER JOIN POS_ExecutiveMember AS PE ON BH.MemberID=PE.MemberID AND BH.PropertyId=PE.PropertyId
	LEFT JOIN POS_KotBot PK ON PK.OrderNo = BT.OrderNo AND PK.PropertyId = BT.PropertyId AND PK.OrderDate = BT.OrderDate AND PK.OutletID = BT.Outlet AND PK.MenuItemID = BT.MainMenuCode AND PK.ItemSequence = BT.ItemSeq AND PK.SortSeq = BT.SortSeq
	WHERE 
	BT.propertyId=@PropertyId and BT.OrderDate >= CONVERT(DATETIME,@FromDate,103) 
		AND BT.OrderDate <= CONVERT(DATETIME,@ToDate,103) 
		AND BT.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))
		AND MM.IsInstruction = 0
   
END

GO

