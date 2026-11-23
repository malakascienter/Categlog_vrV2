
CREATE   FUNCTION [dbo].[LTYM_fn_MemberPointsBalance] (@MemberId INT, @PropertyId INT)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Balance DECIMAL(18,2);

    SELECT TOP (1) @Balance = PointsBalance
    FROM   dbo.LTY_MemberWisePointTransaction
    WHERE  MemberId = @MemberId
      AND  PropertyId = @PropertyId
    ORDER BY Id DESC;

    RETURN CASE WHEN ISNULL(@Balance, 0) < 0 THEN 0 ELSE ISNULL(@Balance, 0) END;
END

GO

