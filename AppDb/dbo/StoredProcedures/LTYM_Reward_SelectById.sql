
CREATE   PROCEDURE [dbo].[LTYM_Reward_SelectById]
    @RewardId   INT,
    @MemberId   INT
AS
BEGIN
    SET NOCOUNT ON;


    -- PropertyId is not part of this module's interface; it comes from the member row.
    DECLARE @PropertyId INT = (SELECT TOP (1) PropertyId FROM dbo.LTY_Member WHERE MemberId = @MemberId);
    DECLARE @Balance DECIMAL(18,2) = dbo.LTYM_fn_MemberPointsBalance(@MemberId, @PropertyId);

    SELECT R.Id,
           R.Name,
           R.Description,
           R.Category,
           R.PointsCost,
           R.DiscountValue,
           R.IsPercentage,
           R.ValidityDays,
           R.ImagePath,
           CAST(CASE WHEN @Balance >= R.PointsCost THEN 1 ELSE 0 END AS BIT) AS CanAfford,
           @Balance AS CurrentBalance
    FROM   dbo.LTYM_Rewards AS R
    WHERE  R.Id = @RewardId
      AND  R.IsActive = 1
      AND (R.StartDate IS NULL OR R.StartDate <= SYSUTCDATETIME())
      AND (R.EndDate   IS NULL OR R.EndDate   >= SYSUTCDATETIME());
END

GO

