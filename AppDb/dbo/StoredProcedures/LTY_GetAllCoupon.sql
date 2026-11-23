-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-18
-- Description:	Coupons for the admin grid.
--
--              @IsUse defaults to 0 - unused coupons only, which is what the
--              grid wants. Pass 1 for spent ones, or NULL for everything.
--              "Used" means an LTY_CouponUsage row with IsUse = 1; taking a
--              coupon back off an order deletes that row, so it returns here.
--
--              @IsExpired is separate on purpose: an unused coupon that has
--              passed its date is still unused, and hiding it would make the
--              grid disagree with the dashboard's coupon funnel.
-- =============================================
-- EXEC [dbo].[LTY_GetAllCoupon] @PropertyId = 1
-- EXEC [dbo].[LTY_GetAllCoupon] @PropertyId = 1, @IsUse = NULL
CREATE   PROCEDURE [dbo].[LTY_GetAllCoupon]
	@PropertyId INT,
	@IsUse BIT = 0,                  -- 0 unused (default), 1 used, NULL both
	@MemberId INT = NULL,
	@Outlet VARCHAR(20) = NULL,
	@IsExpired BIT = NULL            -- NULL both, 0 live only, 1 expired only
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		DECLARE @Now DATETIME = GETDATE();

		SET @Outlet = NULLIF(LTRIM(RTRIM(@Outlet)), '');

		SELECT
			c.Id,
			c.DocumentNo,
			c.PropertyId,
			c.MemberId,
			MemberName     = LTRIM(RTRIM(ISNULL(m.FirstName, '') + ' ' + ISNULL(m.LastName, ''))),
			MembershipCode = m.MembershipCode,
			c.Outlet,
			OutletName     = ISNULL(lr.Description, c.Outlet),
			c.IsPerecentage,
			c.Value,
			c.ExpireDate,
			-- The count the client sent, recovered exactly: the save wrote
			-- ExpireDate as CreatedDate + n, so this is the same n.
			ExpireDayCount = DATEDIFF(DAY, c.CreatedDate, c.ExpireDate),
			c.CreateBy,
			c.CreatedDate,
			IsUse     = CONVERT(BIT, CASE WHEN u.CouponId IS NULL THEN 0 ELSE 1 END),
			IsExpired = CONVERT(BIT, CASE WHEN c.ExpireDate < @Now THEN 1 ELSE 0 END),
			UsedOnOrderNo = u.OrderNo,
			UsedOn        = u.OrderDate
		FROM [dbo].[LTY_CouponMaster] AS c
		LEFT JOIN [dbo].[LTY_Member] AS m
			ON m.MemberId = c.MemberId AND m.PropertyId = c.PropertyId
		LEFT JOIN [dbo].[Location_Ref] AS lr
			ON lr.Code = c.Outlet AND lr.PropertyId = c.PropertyId
		LEFT JOIN [dbo].[LTY_CouponUsage] AS u
			ON u.CouponId = c.Id AND u.PropertyId = c.PropertyId AND u.IsUse = 1
		WHERE c.PropertyId = @PropertyId
		  AND (@MemberId IS NULL OR c.MemberId = @MemberId)
		  AND (@Outlet   IS NULL OR c.Outlet   = @Outlet)
		  AND (@IsUse    IS NULL
			   OR (@IsUse = 1 AND u.CouponId IS NOT NULL)
			   OR (@IsUse = 0 AND u.CouponId IS NULL))
		  AND (@IsExpired IS NULL
			   OR (@IsExpired = 1 AND c.ExpireDate <  @Now)
			   OR (@IsExpired = 0 AND c.ExpireDate >= @Now))
		ORDER BY c.Id DESC;

	END TRY
	BEGIN CATCH

		DECLARE @ErrMsg   NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrSev   INT            = ERROR_SEVERITY();
		DECLARE @ErrState INT            = ERROR_STATE();

		RAISERROR(@ErrMsg, @ErrSev, @ErrState);

	END CATCH
END

GO

