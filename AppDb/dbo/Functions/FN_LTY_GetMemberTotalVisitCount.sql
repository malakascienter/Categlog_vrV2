-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-14
-- Description:	Total earning visits the member has ever made. Counts
--              TransactionType 'G' rows across all dates, so redemptions are not
--              visits. Returns 0 when the number is unknown.
-- =============================================
-- SELECT dbo.FN_LTY_GetMemberTotalVisitCount(1, '0702375050')
CREATE   FUNCTION [dbo].[FN_LTY_GetMemberTotalVisitCount]
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
	  AND t.TransactionType = 'G';

	RETURN ISNULL(@VisitCount, 0);
END

GO

