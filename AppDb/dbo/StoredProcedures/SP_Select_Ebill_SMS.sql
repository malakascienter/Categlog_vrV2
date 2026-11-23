
CREATE PROCEDURE [dbo].[SP_Select_Ebill_SMS]
AS
BEGIN
	
	SELECT CONVERT(varchar,BH.OrderDate,106) AS BillDate,L.description AS BilledStore,L.description AS StoreAddress,BH.OrderNo AS OrderNo,W.Name AS CasherID,
	'(94) 0770 234 234' AS CustomerServiceNo,CONVERT(varchar,BH.OrderTime,8) AS OrderTime ,BH.PosNo AS POSID,OT.Name AS OrderType,BH.OrderDate AS OrderDate,
	BH.Outlet AS Outlet,B.CompanyID AS CompanyID,B.BrandLOGO AS BarndLogo,B.Picture1 AS SoftlogicPic,
	B.EbillSenderEmailAddress,B.EbillSenderEmailAddressDisplayName,B.EbillEmailCCAddress,B.EbillEmailHost,B.EbillEmailPort,B.EbillEmailauthentication_Required,
	B.EbillEmailUserName,B.EbillEmailUserPassword,CONCAT( B.EbillEmailSubject,' ',CONVERT(NVARCHAR, BH.OrderDate, 106),' at ',B.Name,' ',L.description,'|',BH.OrderNo) AS EbillEmailSubject,B.EbillisNeedToCC,PE.EmailAddress AS EbillEmailToAddress, PE.EmailAddress AS EbillEmailToAddressDisplayName,
	PC.CustomerName AS MemberName,PC.ContactNo AS MemberTelNum,PC.IssuedLoyaltyPoints AS PointsEarned,PC.AvailablePoints AS PointsBalance,B.footerLine1,B.footerLine2,
	--B.BrandLOGOBase64 AS BarndLogoBase64,
	--B.Picture1Base64 AS SoftlogicPicBase64,
	'' AS BarndLogoBase64,
	'' AS SoftlogicPicBase64,
	B.FbURL,B.InstaURL,B.FooterColor,PC.LoyaltyCusID,[dbo].[Get_OrderWiseSurveyCode](BH.OrderNo, BH.OrderDate, BH.Outlet,BH.PropertyId) AS SurveyCode ,B.IsEbillSurveyEnabled,B.SurveyURL,PE.ContactNo,'Daer Customer.We thank you for your order. {ESMSUrl}'AS SMSText,
	'Dilshan' as MembershipName,
	'00001' as MembershipNo,
	0 as MembershipCreditBalance
	FROM POS_EBillOrder PE INNER JOIN BillHeader BH ON PE.OrderNo = BH.OrderNo AND CONVERT(DATE,PE.OrderDate) = CONVERT(DATE,BH.OrderDate) AND PE.Outlet = BH.Outlet AND PE.PropertyId = BH.PropertyId
	INNER JOIN Location_Ref L ON BH.Outlet = L.code AND BH.PropertyId = L.PropertyId
	INNER JOIN Waiter W ON BH.Waiter = W.Code AND BH.PropertyId = W.PropertyId
	INNER JOIN POSOrderTypes OT ON BH.OrderType = OT.Code AND BH.PropertyId = OT.PropertyId
	INNER JOIN Companies B ON L.PropertyId = B.CompanyID
	LEFT JOIN POS_CustomerDetails PC ON PE.OrderNo = PC.OrderNo AND CONVERT(date,PE.OrderDate,103) = CONVERT(date,PC.OrderDate,103) AND PE.Outlet = PC.Outlet AND PE.PropertyId = PC.PropertyId
	WHERE PE.IsEBillSend = 0 AND B.IsEBillSMSEnable = 1 AND PE.IsEBillSendFail = 0 AND IsSMS = 1




END

GO

