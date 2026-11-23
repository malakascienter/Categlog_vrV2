
CREATE   PROCEDURE [dbo].[LTYM_Reward_RedemptionHistory]
    @MemberId   INT,
    @Page       INT = 1,
    @PageSize   INT = 20
AS
BEGIN
    SET NOCOUNT ON;


    -- PropertyId is not part of this module's interface; it comes from the member row.
    DECLARE @PropertyId INT = (SELECT TOP (1) PropertyId FROM dbo.LTY_Member WHERE MemberId = @MemberId);
    IF @Page < 1 SET @Page = 1;
    IF @PageSize < 1 OR @PageSize > 100 SET @PageSize = 20;

    SELECT RR.Id,
           RR.CouponCode,
           RR.PointsSpent,
           RR.CreatedAt,
           R.Name                                  AS RewardName,
           R.Category,
           CM.Value                                AS DiscountValue,
           CM.IsPerecentage                        AS IsPercentage,
           CM.CreatedDate                          AS ValidFrom,
           CM.ExpireDate                           AS ValidTo,
           CAST(CASE WHEN EXISTS (SELECT 1 FROM dbo.LTY_CouponUsage CU
                                  WHERE CU.CouponId = CM.Id AND CU.IsUse = 1)
                     THEN 1 ELSE 0 END AS BIT)     AS IsUsed,
           CAST(CASE WHEN CM.ExpireDate > GETDATE()
                      AND NOT EXISTS (SELECT 1 FROM dbo.LTY_CouponUsage CU
                                      WHERE CU.CouponId = CM.Id AND CU.IsUse = 1)
                     THEN 1 ELSE 0 END AS BIT)     AS IsActiveCoupon
    FROM   dbo.LTYM_RewardRedemptions AS RR
    INNER JOIN dbo.LTYM_Rewards      AS R  ON R.Id  = RR.RewardId
    LEFT  JOIN dbo.LTY_CouponMaster  AS CM ON CM.Id = RR.CouponId
    WHERE  RR.MemberId = @MemberId
    ORDER BY RR.Id DESC
    OFFSET (@Page - 1) * @PageSize ROWS FETCH NEXT @PageSize ROWS ONLY;

    SELECT COUNT(*)
    FROM   dbo.LTYM_RewardRedemptions AS RR
    WHERE  RR.MemberId = @MemberId;
END

GO

