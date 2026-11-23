-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-14
-- Description:	Number of earning visits the member has made in the current
--              calendar month. Counts TransactionType 'G' rows, so redemptions
--              are not visits. Returns 0 when the number is unknown.
-- =============================================
-- SELECT dbo.FN_LTY_GetMemberMonthlyVisitCount(1, '0702375050')
CREATE   FUNCTION [dbo].[FN_LTY_GetMemberMonthlyVisitCount]
(
	@PropertyId INT,
	@MobileNo NVARCHAR(20)
)
RETURNS INT
AS
BEGIN
	DECLARE @VisitCount INT;

	SELECT @VisitCount = COUNT(1)
	FROM [dbo].[LTY_MemberWisePointTransaction] AS t
	INNER JOIN [dbo].[LTY_Member] AS m
		ON m.MemberId   = t.MemberId
	   AND m.PropertyId = t.PropertyId
	WHERE m.PropertyId      = @PropertyId
	  AND m.PrimaryMobileNo = @MobileNo
	  AND m.IsActive        = 1
	  AND t.TransactionType = 'G'
	  AND t.TxnDate >= DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
	  AND t.TxnDate <  DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 1, 0);

	RETURN ISNULL(@VisitCount, 0);
END

GO

