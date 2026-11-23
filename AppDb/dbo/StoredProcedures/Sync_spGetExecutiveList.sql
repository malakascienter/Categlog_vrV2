

CREATE PROCEDURE [dbo].[Sync_spGetExecutiveList]
@PropertyId INT
AS


SELECT	MemberID, MemberName, EPFNo, CreditLimit, CreditBalance, Active, DiscountPercentage, IsExecutivePrice, ChargeHeaderID
FROM	POS_ExecutiveMember
WHERE	PropertyId = @PropertyId AND IsUpload = 0

GO

