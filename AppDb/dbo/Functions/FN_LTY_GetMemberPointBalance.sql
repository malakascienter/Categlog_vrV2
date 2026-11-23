-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-11
-- Description:	Current point balance for the member holding this mobile number,
--              excluding points whose expiry has passed. Returns 0 when the number
--              is unknown or nothing usable remains.
--
--              2026-08-17: reverts the "TransactionType <> 'V'" filter added in
--              script 145.
--
--              145 belonged to the design where a void UPDATEd the earn row to 'V';
--              the row still held its original plus, so it had to be excluded.
--              Script 147 replaced that with an INSERT: the 'V' row now carries the
--              NEGATIVE of what was earned, and cancels the earn by being counted,
--              not by being skipped. Excluding it would leave the earned points in
--              the balance and make the void do nothing.
--
--              Run this whenever 147 is applied. Safe to run either way if 145 was
--              never applied - it restores the original body.
-- =============================================
-- SELECT dbo.FN_LTY_GetMemberPointBalance(1, '0702375050')
CREATE   FUNCTION [dbo].[FN_LTY_GetMemberPointBalance]
(
	@PropertyId INT,
	@MobileNo NVARCHAR(20)
)
RETURNS DECIMAL(18,2)
AS
BEGIN
	DECLARE @Balance DECIMAL(18,2);

	SELECT @Balance = SUM(t.NoPoints)
	FROM [dbo].[LTY_MemberWisePointTransaction] AS t
	INNER JOIN [dbo].[LTY_Member] AS m
		ON m.MemberId   = t.MemberId
	   AND m.PropertyId = t.PropertyId
	WHERE m.PropertyId      = @PropertyId
	  AND m.PrimaryMobileNo = @MobileNo
	  AND m.IsActive        = 1
	  AND (t.NoPoints < 0 OR t.ExpireDate >= CAST(GETDATE() AS DATE));
	RETURN CASE WHEN ISNULL(@Balance, 0) < 0 THEN 0 ELSE ISNULL(@Balance, 0) END;
END

GO

