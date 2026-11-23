-- =============================================
-- Author:		Chiraj
-- Create date: 2020-6-30
-- Description:	Report_ExecutiveBillDetail
-- =============================================
--Report_ExecutiveBillDetail '26/06/2020','26/06/2020','D01','1'
CREATE PROCEDURE [dbo].[Report_ExecutiveBillDetail]
 @FromMonthNo INT,          
 @FromYear INT,  
 @Outlet    VARCHAR(MAX),
 @PropertyId VARCHAR(2)
AS
BEGIN	
	SET NOCOUNT ON;

	--SELECT BT.OrderNo,BT.OrderDate,
	----BT.Category,
	----BT.MainMenuCode,
	--BT.Qty,BT.Rate,C.Description AS Category,MM.Description AS MainMenu,BH.MemberID,PE.MemberName,PE.CreditBalance
	--FROM BillTrans AS BT
	--INNER JOIN Category AS C ON C.Code=BT.Category AND C.PropertyId=BT.PropertyId
	--INNER JOIN MainMenu AS MM ON MM.ItemCode=BT.MainMenuCode AND MM.PropertyId=BT.PropertyId
	--INNER JOIN BillHeader AS BH ON BH.OrderNo=BT.OrderNo AND BH.PropertyId=BT.PropertyId
	--INNER JOIN POS_ExecutiveMember AS PE ON BH.MemberID=PE.MemberID AND BH.PropertyId=PE.PropertyId
	--WHERE BT.OrderDate >= CONVERT(datetime,'01'+'/'+CONVERT(VARCHAR,@FromYear)+'/'+CONVERT(VARCHAR,@FromMonthNo),103)         
 --   AND BT.OrderDate < DATEADD(MONTH,1,CONVERT(datetime,'01'+'/'+CONVERT(VARCHAR,@FromYear)+'/'+CONVERT(VARCHAR,@FromMonthNo),103))        
 --   AND BT.propertyId=@PropertyId 
	--AND BT.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))

	----AND 
	----SELECT BH.OrderDate,Bh.OrderNo,BH.MemberID FROM BillHeader AS BH INNER JOIN POS_ExecutiveMember AS PE ON BH.MemberID=PE.MemberID
   
   SELECT BT.OrderNo,BT.OrderDate,
	--BT.Category,
	--BT.MainMenuCode,
	BT.Qty,BT.Rate,C.Description AS Category,MM.Description AS MainMenu,BH.MemberID,PE.MemberName,
	(
	SELECT PE.CreditLimit-SUM(BH2.Subtotal+BH2.TaxVal1+BH2.TaxVal2+BH2.TaxVal3+BH2.TaxVal4+BH2.ServiceCharge) FROM BillHeader BH2 
	WHERE BH2.OrderDate >= CONVERT(datetime,'01'+'/'+CONVERT(VARCHAR,@FromYear)+'/'+CONVERT(VARCHAR,@FromMonthNo),103)         
    AND BH2.OrderDate < DATEADD(MONTH,1,CONVERT(datetime,'01'+'/'+CONVERT(VARCHAR,@FromYear)+'/'+CONVERT(VARCHAR,@FromMonthNo),103))        
    AND BH2.propertyId=@PropertyId 
	AND BH2.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,',')) AND  BH2.MemberID =  BH.MemberID
	) AS CreditBalance

	FROM BillTrans AS BT
	INNER JOIN Category AS C ON C.Code=BT.Category AND C.PropertyId=BT.PropertyId
	INNER JOIN MainMenu AS MM ON MM.ItemCode=BT.MainMenuCode AND MM.PropertyId=BT.PropertyId
	INNER JOIN BillHeader AS BH ON BH.OrderNo=BT.OrderNo AND BH.PropertyId=BT.PropertyId
	INNER JOIN POS_ExecutiveMember AS PE ON BH.MemberID=PE.MemberID AND BH.PropertyId=PE.PropertyId
	WHERE BT.OrderDate >= CONVERT(datetime,'01'+'/'+CONVERT(VARCHAR,@FromYear)+'/'+CONVERT(VARCHAR,@FromMonthNo),103)         
    AND BT.OrderDate < DATEADD(MONTH,1,CONVERT(datetime,'01'+'/'+CONVERT(VARCHAR,@FromYear)+'/'+CONVERT(VARCHAR,@FromMonthNo),103))        
    AND BT.propertyId=@PropertyId 
	AND BT.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))

END

GO

