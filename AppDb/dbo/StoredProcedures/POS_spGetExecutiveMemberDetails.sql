

CREATE PROCEDURE [dbo].[POS_spGetExecutiveMemberDetails]
@MemberID INT
AS 
SET NOCOUNT ON
DECLARE @CurrentValue NUMERIC(18,2)




SET @CurrentValue = (SELECT	ISNULL(SUM(Subtotal + ServiceCharge + TaxVal1 + TaxVal2 + TaxVal3 + TaxVal4),0)
					FROM	BillHeader
					WHERE  MemberID = @MemberID AND CONVERT(DATE, OrderDate) >= CONVERT(DATE,(SELECT DATEADD(s,1,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0))))
					GROUP BY MemberID)


SELECT	MemberID, MemberName, EPFNo, CreditLimit, (CreditLimit - ISNULL(@CurrentValue,0)) AS CreditBalance, DiscountPercentage, 0 AS MemDiscountCategoryID,
		IsExecutivePrice, ChargeHeaderID
FROM	POS_ExecutiveMember 
WHERE	MemberID = @MemberID

GO

