-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-07
-- Description:	Earn points for a settled POS order.
--
--              2026-08-17: coupon issuing added at the end. It is additive - the
--              staging, the best-option comparison and the single row written to
--              LTY_MemberWisePointTransaction all behave exactly as before.
--
--              Coupons are not a point movement, so nothing about them touches
--              LTY_MemberWisePointTransaction. They also do not compete with the
--              point options: a coupon is issued for every COU promotion the order
--              and member qualify for, whichever point option happened to win.
--
--              2026-08-17: the coupon is stamped with MemberId, the member already
--              resolved from the mobile number at the top of the procedure.
-- =============================================
CREATE   PROCEDURE [dbo].[LTY_PointEarn]
	@MobileNo NVARCHAR(20),
	@NetAmount DECIMAL(18,4),
	@GrossAmount DECIMAL(18,4),
	@WithoutCharge DECIMAL(18,4),
	@OutletCode VARCHAR(50),
	@OrderDate DATETIME,
	@OrderNo VARCHAR(MAX),
	@PropertyId INT,
	@UserId INT,
	@PaymentTypesJson NVARCHAR(MAX) = N'[]',
	@ItemsJson NVARCHAR(MAX) = N'[]'
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @MemberId       INT;
	DECLARE @Rate           DECIMAL(18,4);
	DECLARE @BaseValueId    INT;
	DECLARE @Multiplier     DECIMAL(18,4);
	DECLARE @BaseAmount     DECIMAL(18,4);
	DECLARE @ExpireDayCount INT;
	DECLARE @TierId         INT;
	DECLARE @RuleId         INT;
	DECLARE @PointsBefore   DECIMAL(18,2);
	DECLARE @TransactionId  INT;
	DECLARE @NeverExpires   DATETIME = CONVERT(DATETIME, '9999-12-31');

	DECLARE @WinNoPoints   DECIMAL(18,2);
	DECLARE @WinBillValue  DECIMAL(18,4);
	DECLARE @WinTxnType    VARCHAR(10);
	DECLARE @WinRemark     VARCHAR(MAX);
	DECLARE @WinExpireDate DATETIME;
	DECLARE @OptionCount   INT;

	-- Coupon issuing
	DECLARE @CouponTxnType     CHAR(4) = 'COU';
	DECLARE @CouponDocNo       NVARCHAR(300);
	DECLARE @CouponPromotionId INT;
	DECLARE @CouponIsPercent   BIT;
	DECLARE @CouponValue       DECIMAL(18,4);
	DECLARE @CouponExpireDate  DATETIME;
	DECLARE @CouponCount       INT = 0;

	DECLARE @OrderTime TIME(0) = CONVERT(TIME(0), @OrderDate);
	DECLARE @DayCode   VARCHAR(3) =
		CASE (DATEDIFF(DAY, '19000107', CONVERT(DATE, @OrderDate)) % 7)
			WHEN 0 THEN 'SUN' WHEN 1 THEN 'MON' WHEN 2 THEN 'TUE'
			WHEN 3 THEN 'WED' WHEN 4 THEN 'THU' WHEN 5 THEN 'FRI'
			ELSE 'SAT'
		END;


	CREATE TABLE #PointEarn
	(
		RowNo           INT IDENTITY(1,1) NOT NULL,
		NoPoints        DECIMAL(18,2) NOT NULL,
		BillValue       DECIMAL(18,4) NOT NULL,
		TransactionType VARCHAR(10)   NOT NULL,
		Remark          VARCHAR(MAX)  NULL,
		ExpireDate      DATETIME      NOT NULL
	);

	CREATE TABLE #PaymentType (PaymentTypeCode VARCHAR(20) NOT NULL);

	INSERT INTO #PaymentType (PaymentTypeCode)
	SELECT CONVERT(VARCHAR(20), [value])
	FROM OPENJSON(@PaymentTypesJson)
	WHERE NULLIF(LTRIM(RTRIM([value])), '') IS NOT NULL;

	CREATE TABLE #OrderItem
	(
		ItemCode VARCHAR(20)   NOT NULL,
		Qty      DECIMAL(18,4) NOT NULL
	);

	INSERT INTO #OrderItem (ItemCode, Qty)
	SELECT i.ItemCode, ISNULL(i.Qty, 0)
	FROM OPENJSON(@ItemsJson)
	WITH (
		ItemCode VARCHAR(20)   '$.ItemCode',
		Qty      DECIMAL(18,4) '$.Qty'
	) AS i
	WHERE NULLIF(LTRIM(RTRIM(i.ItemCode)), '') IS NOT NULL;

	BEGIN TRY

		BEGIN TRANSACTION;

		IF (NULLIF(LTRIM(RTRIM(@MobileNo)), '') IS NULL)
		BEGIN
			RAISERROR('A mobile number is required to earn points.', 16, 1);
		END

		---- Resolve the member from the mobile number ----
		SELECT @MemberId = MemberId
		FROM [dbo].[LTY_Member]
		WHERE PrimaryMobileNo = @MobileNo
		  AND PropertyId      = @PropertyId
		  AND IsActive        = 1;

		IF (@MemberId IS NULL)
		BEGIN
			RAISERROR('No active member is registered with this mobile number.', 16, 1);
		END

		IF EXISTS (SELECT 1 FROM [dbo].[LTY_MemberWisePointTransaction]
				   WHERE OrderNo     = @OrderNo
					 AND PropertyId  = @PropertyId
					 AND OutletCode  = @OutletCode)
		BEGIN
			RAISERROR('Points have already been earned for this order.', 16, 1);
		END

		---- Stage 1: the rule attached to the member's tier
		SELECT @TierId = TierId
		FROM [dbo].[LTY_Member]
		WHERE MemberId = @MemberId AND PropertyId = @PropertyId AND IsActive = 1;

		SELECT @RuleId = RuleId
		FROM [dbo].[LTY_Tier]
		WHERE TierId = @TierId AND PropertyId = @PropertyId AND IsActive = 1;

		SELECT TOP (1)
			@Rate           = r.Rate,
			@BaseValueId    = r.BaseValueId,
			@Multiplier     = r.Multiplier,
			@ExpireDayCount = r.ExpireDayCount
		FROM [dbo].[LTY_PointEarningRule] AS r
		WHERE r.PropertyId = @PropertyId
		  AND r.IsActive   = 1
		  AND r.RuleId     = @RuleId;

		IF (ISNULL(@Rate, 0) = 0)
		BEGIN
			RAISERROR('No active point earning rule is configured for this member''s tier.', 16, 1);
		END

		SET @BaseAmount =
			CASE @BaseValueId
				WHEN 1 THEN @NetAmount
				WHEN 2 THEN @GrossAmount
				WHEN 3 THEN @WithoutCharge
				ELSE @NetAmount
			END;

		INSERT INTO #PointEarn (NoPoints, BillValue, TransactionType, Remark, ExpireDate)
		VALUES
		(
			ROUND(@BaseAmount / @Rate * ISNULL(@Multiplier, 1), 2),
			@BaseAmount,
			'G',
			'Points earned for order ' + @OrderNo,
			CASE WHEN ISNULL(@ExpireDayCount, 0) > 0
				 THEN DATEADD(DAY, @ExpireDayCount, @OrderDate)
				 ELSE @NeverExpires END
		);

		---- Stage 2: every promotion this order and member qualify for
		INSERT INTO #PointEarn (NoPoints, BillValue, TransactionType, Remark, ExpireDate)
		SELECT
			ROUND(
				CASE pw.BaseValueId
					WHEN 1 THEN @NetAmount
					WHEN 2 THEN @GrossAmount
					WHEN 3 THEN @WithoutCharge
					ELSE @NetAmount
				END / pw.Rate * ISNULL(pw.Multiplier, 1), 2),
			CASE pw.BaseValueId
				WHEN 1 THEN @NetAmount
				WHEN 2 THEN @GrossAmount
				WHEN 3 THEN @WithoutCharge
				ELSE @NetAmount
			END,
			'G',
			CONCAT('Promotion points - ', p.PromotionName, ' for order ', @OrderNo),
			ISNULL(pw.ExpireDate, @NeverExpires)
		FROM [dbo].[LTY_Promotion] AS p
		INNER JOIN [dbo].[LTY_PromotionWisePoint] AS pw
			ON pw.PromotionId = p.PromotionId
		   AND pw.PropertyId  = p.PropertyId
		WHERE p.PropertyId = @PropertyId
		  AND p.IsActive   = 1
		  AND ISNULL(pw.Rate, 0) <> 0
		  AND CONVERT(DATE, @OrderDate) BETWEEN p.StartDate AND p.EndDate
		  AND (
				(p.StartTime <= p.EndTime AND @OrderTime BETWEEN p.StartTime AND p.EndTime)
			 OR (p.StartTime >  p.EndTime AND (@OrderTime >= p.StartTime OR @OrderTime <= p.EndTime))
			  )
		  AND @NetAmount >= p.MinBillAmount
		  AND (p.MaxBillAmount IS NULL OR @NetAmount <= p.MaxBillAmount)
		  AND EXISTS (SELECT 1 FROM [dbo].[LTY_DayWisePromotion] AS d
					  WHERE d.PromotionId = p.PromotionId
						AND d.Days        = @DayCode)
		  AND EXISTS (SELECT 1 FROM [dbo].[LTY_LocationWisePromotion] AS l
					  WHERE l.PromotionId  = p.PromotionId
						AND l.LocationCode = @OutletCode)
		  AND EXISTS (SELECT 1 FROM [dbo].[LTY_TierWisePromotion] AS t
					  WHERE t.PromotionId = p.PromotionId
						AND t.TierId      = @TierId)
		  AND EXISTS (SELECT 1 FROM [dbo].[LTY_PaymentTypeWisePromotion] AS pt
					  INNER JOIN #PaymentType AS op ON op.PaymentTypeCode = pt.PaymentTypeCode
					  WHERE pt.PromotionId = p.PromotionId);



			---- Stage 3: point-per-item promotions (POINTITEM)
			INSERT INTO #PointEarn (NoPoints, BillValue, TransactionType, Remark, ExpireDate)
			SELECT
				ROUND(SUM(pi.PointCount), 2),
				@NetAmount,
				'G',
				CONCAT('Promotion item points - ', p.PromotionName, ' for order ', @OrderNo),
				ISNULL(MIN(CONVERT(DATETIME, pi.ExpireDate)), @NeverExpires)
			FROM [dbo].[LTY_Promotion] AS p
			INNER JOIN [dbo].[LTY_PointItemWisePromotion] AS pi
				ON pi.PromotionId = p.PromotionId
			   AND pi.PropertyId  = p.PropertyId
			INNER JOIN #OrderItem AS oi
				ON oi.ItemCode = pi.ItemCode
			   AND oi.Qty     >= pi.Quantity      -- the order carries enough of this item
			WHERE p.PropertyId = @PropertyId
			  AND p.IsActive   = 1
			  AND ISNULL(pi.PointCount, 0) <> 0
			  AND CONVERT(DATE, @OrderDate) BETWEEN p.StartDate AND p.EndDate
			  AND (
					(p.StartTime <= p.EndTime AND @OrderTime BETWEEN p.StartTime AND p.EndTime)
				 OR (p.StartTime >  p.EndTime AND (@OrderTime >= p.StartTime OR @OrderTime <= p.EndTime))
				  )
			  AND @NetAmount >= p.MinBillAmount
			  AND (p.MaxBillAmount IS NULL OR @NetAmount <= p.MaxBillAmount)
			  AND EXISTS (SELECT 1 FROM [dbo].[LTY_DayWisePromotion] AS d
						  WHERE d.PromotionId = p.PromotionId
							AND d.Days        = @DayCode)
			  AND EXISTS (SELECT 1 FROM [dbo].[LTY_LocationWisePromotion] AS l
						  WHERE l.PromotionId  = p.PromotionId
							AND l.LocationCode = @OutletCode)
			  AND EXISTS (SELECT 1 FROM [dbo].[LTY_TierWisePromotion] AS t
						  WHERE t.PromotionId = p.PromotionId
							AND t.TierId      = @TierId)
			  AND EXISTS (SELECT 1 FROM [dbo].[LTY_PaymentTypeWisePromotion] AS pt
						  INNER JOIN #PaymentType AS op ON op.PaymentTypeCode = pt.PaymentTypeCode
						  WHERE pt.PromotionId = p.PromotionId)
			GROUP BY p.PromotionId, p.PromotionName
			HAVING SUM(pi.PointCount) > 0;


		---- Compare: the best-earning staged row wins
		SET @OptionCount = (SELECT COUNT(1) FROM #PointEarn);

		SELECT TOP (1)
			@WinNoPoints   = e.NoPoints,
			@WinBillValue  = e.BillValue,
			@WinTxnType    = e.TransactionType,
			@WinRemark     = e.Remark,
			@WinExpireDate = e.ExpireDate
		FROM #PointEarn AS e
		ORDER BY e.NoPoints DESC, e.RowNo ASC;   -- highest points; ties go to the tier rule

		IF (@WinNoPoints IS NULL)
		BEGIN
			RAISERROR('No point earning option was found for this order.', 16, 1);
		END

		---- The member's balance before this transaction ----
		SELECT TOP (1) @PointsBefore = t.PointsBalance
		FROM [dbo].[LTY_MemberWisePointTransaction] AS t
		WHERE t.MemberId   = @MemberId
		  AND t.PropertyId = @PropertyId
		ORDER BY t.Id DESC;

		SET @PointsBefore = ISNULL(@PointsBefore, 0);

		INSERT INTO [dbo].[LTY_MemberWisePointTransaction]
		(
			MemberId, NoPoints, OutletCode, PropertyId, BillValue,
			PointsBefore, PointsBalance, TransactionType, Remark, TxnDate,
			CreatedUserId, CreatedDateTime, OrderNo, ExpireDate
		)
		VALUES
		(
			@MemberId,
			@WinNoPoints,
			@OutletCode,
			@PropertyId,
			@WinBillValue,
			@PointsBefore,
			@PointsBefore + @WinNoPoints,
			@WinTxnType,
			@WinRemark,
			@OrderDate,
			@UserId,
			GETDATE(),
			@OrderNo,
			@WinExpireDate
		);

		SET @TransactionId = SCOPE_IDENTITY();

		---- Coupons -------------------------------------------------------------
		---- Additional to everything above and independent of it. Every COU
		---- promotion the order and member qualify for issues its own coupon into
		---- LTY_CouponMaster; nothing is written to LTY_MemberWisePointTransaction,
		---- because a coupon is not a point movement.
		----
		---- The gates are the same ones stages 2 and 3 apply, joined to
		---- LTY_PromotionWiseCoupon instead of the point tables.
		DECLARE coupon_cursor CURSOR LOCAL FAST_FORWARD FOR
			SELECT
				p.PromotionId,
				ISNULL(p.IsDiscountPercentage, 0),
				ISNULL(p.Discount, 0),
				pc.ExipireDate
			FROM [dbo].[LTY_Promotion] AS p
			INNER JOIN [dbo].[LTY_PromotionWiseCoupon] AS pc
				ON pc.PromotionId = p.PromotionId
			   AND pc.PropertyId  = p.PropertyId
			WHERE p.PropertyId = @PropertyId
			  AND p.IsActive   = 1
			  AND CONVERT(DATE, @OrderDate) BETWEEN p.StartDate AND p.EndDate
			  AND (
					(p.StartTime <= p.EndTime AND @OrderTime BETWEEN p.StartTime AND p.EndTime)
				 OR (p.StartTime >  p.EndTime AND (@OrderTime >= p.StartTime OR @OrderTime <= p.EndTime))
				  )
			  AND @NetAmount >= p.MinBillAmount
			  AND (p.MaxBillAmount IS NULL OR @NetAmount <= p.MaxBillAmount)
			  AND EXISTS (SELECT 1 FROM [dbo].[LTY_DayWisePromotion] AS d
						  WHERE d.PromotionId = p.PromotionId
							AND d.Days        = @DayCode)
			  AND EXISTS (SELECT 1 FROM [dbo].[LTY_LocationWisePromotion] AS l
						  WHERE l.PromotionId  = p.PromotionId
							AND l.LocationCode = @OutletCode)
			  AND EXISTS (SELECT 1 FROM [dbo].[LTY_TierWisePromotion] AS t
						  WHERE t.PromotionId = p.PromotionId
							AND t.TierId      = @TierId)
			  AND EXISTS (SELECT 1 FROM [dbo].[LTY_PaymentTypeWisePromotion] AS pt
						  INNER JOIN #PaymentType AS op ON op.PaymentTypeCode = pt.PaymentTypeCode
						  WHERE pt.PromotionId = p.PromotionId);

		OPEN coupon_cursor;
		FETCH NEXT FROM coupon_cursor
			INTO @CouponPromotionId, @CouponIsPercent, @CouponValue, @CouponExpireDate;

		WHILE @@FETCH_STATUS = 0
		BEGIN

			---- Get Doc No. The outlet is the one the till sent; its running number
			---- comes from LTY_TransactionTypeWiseNextNumbers under TransactionType
			---- 'COU', seeded on first use for an outlet that has none yet.
			SELECT @CouponDocNo = [dbo].[FN_LTY_GetNextDocumentNumber](@PropertyId, @OutletCode, @CouponTxnType);
			IF (@CouponDocNo IS NULL)
			BEGIN
				EXEC [dbo].[LTY_InsertDocumentNumber] @PropertyId, @OutletCode, @CouponTxnType;
				SELECT @CouponDocNo = [dbo].[FN_LTY_GetNextDocumentNumber](@PropertyId, @OutletCode, @CouponTxnType);
			END

			INSERT INTO [dbo].[LTY_CouponMaster]
			(
				DocumentNo,
				PropertyId,
				MemberId,
				Outlet,
				IsPerecentage,
				Value,
				ExpireDate,
				CreateBy,
				CreatedDate
			)
			VALUES
			(
				CONCAT(TRIM(@CouponTxnType), '/', @OutletCode, '/', @CouponDocNo),
				@PropertyId,
				@MemberId,
				@OutletCode,
				@CouponIsPercent,
				@CouponValue,
				@CouponExpireDate,
				@UserId,
				GETDATE()
			);

			UPDATE [dbo].[LTY_TransactionTypeWiseNextNumbers]
			SET NextNumber = NextNumber + 1
			WHERE PropertyID      = @PropertyId
			  AND LocationCode    = @OutletCode
			  AND TransactionType = @CouponTxnType;

			SET @CouponCount = @CouponCount + 1;

			FETCH NEXT FROM coupon_cursor
				INTO @CouponPromotionId, @CouponIsPercent, @CouponValue, @CouponExpireDate;

		END

		CLOSE coupon_cursor;
		DEALLOCATE coupon_cursor;
		---- End coupons ---------------------------------------------------------

		COMMIT TRANSACTION;

		SELECT
			@TransactionId               AS TransactionId,
			@WinNoPoints                 AS NoPoints,
			@PointsBefore                AS PointsBefore,
			@PointsBefore + @WinNoPoints AS PointsBalance,
			@WinTxnType                  AS TransactionType,
			@WinExpireDate               AS ExpireDate,
			@OptionCount                 AS OptionsConsidered,
			@CouponCount                 AS CouponsIssued;

	END TRY
	BEGIN CATCH

		IF XACT_STATE() <> 0
			ROLLBACK TRANSACTION;

		DECLARE @ErrMsg   NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrSev   INT            = ERROR_SEVERITY();
		DECLARE @ErrState INT            = ERROR_STATE();

		RAISERROR(@ErrMsg, @ErrSev, @ErrState);

	END CATCH
END

GO

