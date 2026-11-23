
CREATE   PROCEDURE [dbo].[LTYM_Coupons_SelectAvailable]
    @MemberId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CM.Id,
           CM.DocumentNo                                   AS CouponCode,
           CM.Value                                        AS DiscountValue,
           CM.IsPerecentage                                AS IsPercentage,
           CM.CreatedDate                                  AS IssuedOn,
           CM.ExpireDate                                   AS ExpiresOn,
           CASE WHEN DATEDIFF(DAY, GETDATE(), CM.ExpireDate) < 0
                THEN 0 ELSE DATEDIFF(DAY, GETDATE(), CM.ExpireDate) END AS DaysRemaining,
           CM.Outlet                                       AS OutletCode,
           L.Description                                   AS OutletName,
           CASE WHEN RR.Id IS NULL THEN 'OUTLET' ELSE 'PORTAL' END      AS Source,
           R.Name                                          AS RewardName,
           RR.PointsSpent
    FROM   dbo.LTY_CouponMaster AS CM
    LEFT JOIN dbo.Location                 AS L  ON L.Code   = CM.Outlet
    LEFT JOIN dbo.LTYM_RewardRedemptions   AS RR ON RR.CouponId = CM.Id
    LEFT JOIN dbo.LTYM_Rewards             AS R  ON R.Id     = RR.RewardId
    WHERE  CM.MemberId   = @MemberId
      AND  CM.ExpireDate > GETDATE()
      AND  NOT EXISTS (SELECT 1 FROM dbo.LTY_CouponUsage CU
                       WHERE CU.CouponId = CM.Id AND CU.IsUse = 1)
    ORDER BY CM.ExpireDate, CM.Id DESC;
END

GO

