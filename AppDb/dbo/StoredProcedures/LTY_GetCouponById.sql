-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-18
-- Description:	One coupon, for the admin edit screen.
--
--              Named GetCouponById rather than the conventional GetCoupon
--              because LTY_GetCoupon already exists and does something else -
--              it lists a member's usable coupons for the till (script 143).
--              Renaming that one to LTY_GetMemberCoupon would free the plain
--              name, but it is in use by PosController, so it is left alone.
-- =============================================
-- EXEC [dbo].[LTY_GetCouponById] @CouponId = 1, @PropertyId = 1
CREATE   PROCEDURE [dbo].[LTY_GetCouponById]
	@CouponId INT,
	@PropertyId INT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		DECLARE @Now DATETIME = GETDATE();

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
		WHERE c.Id         = @CouponId
		  AND c.PropertyId = @PropertyId;

	END TRY
	BEGIN CATCH

		DECLARE @ErrMsg   NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrSev   INT            = ERROR_SEVERITY();
		DECLARE @ErrState INT            = ERROR_STATE();

		RAISERROR(@ErrMsg, @ErrSev, @ErrState);

	END CATCH
END

GO

