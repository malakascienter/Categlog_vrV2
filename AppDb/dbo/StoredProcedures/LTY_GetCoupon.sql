-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-17
-- Description:	A member's coupons that are still valid on the transaction date.
--
--              @Outlet is accepted but deliberately NOT filtered on: coupons are
--              issued against the outlet that earned them, and the till should still
--              see them at any outlet. The filter is written out below, commented,
--              for the day that changes.
--
--              2026-08-17: a coupon already spent - one with an LTY_CouponUsage row
--              marked IsUse = 1 - is left out. Taking the coupon back off an order
--              deletes that row, so it reappears here.
-- =============================================
-- EXEC [dbo].[LTY_GetCoupon] @PropertyId = 1, @MemberNo = '0702375050', @TxnDate = '2026-08-17 19:30:00'
CREATE   PROCEDURE [dbo].[LTY_GetCoupon]
	@PropertyId INT,
	@MemberNo NVARCHAR(50),
	@TxnDate DATETIME,
	@Outlet VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		DECLARE @MemberId INT;

		IF (NULLIF(LTRIM(RTRIM(@MemberNo)), '') IS NULL)
		BEGIN
			RAISERROR('A member number is required to list coupons.', 16, 1);
		END

		-- The till may hold either the mobile number or the membership code, so both
		-- are accepted.
		SELECT TOP (1) @MemberId = MemberId
		FROM [dbo].[LTY_Member]
		WHERE PropertyId = @PropertyId
		  AND IsActive   = 1
		  AND (PrimaryMobileNo = @MemberNo OR MembershipCode = @MemberNo);

		IF (@MemberId IS NULL)
		BEGIN
			RAISERROR('No active member is registered with this number.', 16, 1);
		END

		SELECT
			c.Id,
			c.DocumentNo,
			c.PropertyId,
			c.MemberId,
			c.Outlet,
			c.IsPerecentage,
			c.Value,
			c.ExpireDate,
			c.CreateBy,
			c.CreatedDate
		FROM [dbo].[LTY_CouponMaster] AS c
		WHERE c.PropertyId  = @PropertyId
		  AND c.MemberId    = @MemberId
		  AND c.ExpireDate >= @TxnDate
		  -- Already spent on an order.
		  AND NOT EXISTS (SELECT 1 FROM [dbo].[LTY_CouponUsage] AS u
						  WHERE u.CouponId   = c.Id
							AND u.PropertyId = c.PropertyId
							AND u.IsUse      = 1)
		  -- Outlet is passed but not applied. Uncomment to restrict a coupon to the
		  -- outlet that issued it; a NULL @Outlet would still return everything.
		  -- AND (@Outlet IS NULL OR c.Outlet = @Outlet)
		ORDER BY c.ExpireDate ASC, c.Id ASC;

	END TRY
	BEGIN CATCH

		DECLARE @ErrMsg   NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrSev   INT            = ERROR_SEVERITY();
		DECLARE @ErrState INT            = ERROR_STATE();

		RAISERROR(@ErrMsg, @ErrSev, @ErrState);

	END CATCH
END

GO

