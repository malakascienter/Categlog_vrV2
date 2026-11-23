-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-18
-- Description:	Everything the Loyalty dashboard draws, as one JSON document.
--
--              Returned in a single nvarchar(max) column the same way
--              LTY_GetPromotion does, so the API deserialises it to a JsonElement
--              and hands it to the page untouched - no per-panel mapping code.
--
--              @OutletCode narrows the transaction-driven panels only. Member,
--              tier, coupon and promotion counts are property-wide, because an
--              outlet does not own a member.
--
--              NOTE on voids: LTY_PointRedeem @TxnType='V' writes two rows - a 'V'
--              carrying the negative of the earn, and a 'G' carrying the returned
--              redemption. That second row is a real 'G' and is indistinguishable
--              from a genuine earn except by its Remark, so it is matched on that
--              text below. A dedicated transaction type for the giveback would make
--              this robust; until then the pattern is the only discriminator.
-- =============================================
-- EXEC [dbo].[LTY_GetDashboard] @PropertyId = 1
-- EXEC [dbo].[LTY_GetDashboard] @PropertyId = 1, @OutletCode = '300'
-- =============================================
CREATE   PROCEDURE [dbo].[LTY_GetDashboard]
	@PropertyId INT,
	@FromDate DATE = NULL,
	@ToDate DATE = NULL,
	@OutletCode VARCHAR(50) = NULL,
	@RedemptionTarget DECIMAL(9,4) = 0.70,
	@FreshWarnMins INT = 60,
	@FreshCritMins INT = 360
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		---- Window ---------------------------------------------------------------
		SET @ToDate   = ISNULL(@ToDate, CAST(GETDATE() AS DATE));
		SET @FromDate = ISNULL(@FromDate,
						DATEADD(MONTH, -11, DATEFROMPARTS(YEAR(@ToDate), MONTH(@ToDate), 1)));
		SET @OutletCode = NULLIF(LTRIM(RTRIM(@OutletCode)), '');

		DECLARE @Today     DATE = CAST(GETDATE() AS DATE);
		DECLARE @PeriodLen INT  = DATEDIFF(DAY, @FromDate, @ToDate);
		DECLARE @PrevTo    DATE = DATEADD(DAY, -1, @FromDate);
		DECLARE @PrevFrom  DATE = DATEADD(DAY, -(@PeriodLen + 1), @FromDate);

		DECLARE @Json NVARCHAR(MAX);

		---- Transactions in scope. The giveback flag is computed once here so no
		---- panel below has to know about the Remark pattern.
		CREATE TABLE #Tx
		(
			MemberId    INT           NOT NULL,
			NoPoints    DECIMAL(18,2) NOT NULL,
			OutletCode  VARCHAR(50)   NOT NULL,
			BillValue   DECIMAL(18,4) NOT NULL,
			TxnType     VARCHAR(10)   NOT NULL,
			TxnDate     DATETIME      NOT NULL,
			CreatedAt   DATETIME      NOT NULL,
			ExpireDate  DATETIME      NOT NULL,
			IsGiveback  BIT           NOT NULL
		);

		INSERT INTO #Tx (MemberId, NoPoints, OutletCode, BillValue, TxnType, TxnDate, CreatedAt, ExpireDate, IsGiveback)
		SELECT
			t.MemberId, t.NoPoints, t.OutletCode, t.BillValue, t.TransactionType,
			t.TxnDate, t.CreatedDateTime, t.ExpireDate,
			CASE WHEN t.TransactionType = 'G'
				  AND t.Remark LIKE 'Points returned on void of order%'
				 THEN 1 ELSE 0 END
		FROM [dbo].[LTY_MemberWisePointTransaction] AS t
		WHERE t.PropertyId = @PropertyId
		  AND (@OutletCode IS NULL OR t.OutletCode = @OutletCode);

		CREATE INDEX IX_Tx ON #Tx (TxnDate, TxnType);

		---- 12-month spine, oldest first --------------------------------------
		CREATE TABLE #Months (Ord INT NOT NULL, MStart DATE NOT NULL, MEnd DATE NOT NULL, Label VARCHAR(10) NOT NULL);

		;WITH m AS (
			SELECT 0 AS n, DATEFROMPARTS(YEAR(@ToDate), MONTH(@ToDate), 1) AS s
			UNION ALL
			SELECT n + 1, DATEADD(MONTH, -1, s) FROM m WHERE n < 11
		)
		INSERT INTO #Months (Ord, MStart, MEnd, Label)
		SELECT 11 - n, s, EOMONTH(s), FORMAT(s, 'MMM yy')
		FROM m;

		---- KPI scalars ---------------------------------------------------------
		DECLARE @Liability DECIMAL(18,2) = (
			SELECT ISNULL(SUM(x.NoPoints), 0)
			FROM #Tx AS x
			INNER JOIN [dbo].[LTY_Member] AS mem
				ON mem.MemberId = x.MemberId AND mem.PropertyId = @PropertyId AND mem.IsActive = 1
			WHERE x.NoPoints < 0 OR x.ExpireDate >= @Today);

		/* Earned nets the void reversals out and ignores the giveback rows.
		   Redeemed nets the returned points off the redemptions. */
		DECLARE @Earned DECIMAL(18,2) = (
			SELECT ISNULL(SUM(CASE WHEN TxnType = 'G' AND IsGiveback = 0 THEN NoPoints
								   WHEN TxnType = 'V' THEN NoPoints ELSE 0 END), 0)
			FROM #Tx WHERE TxnDate >= @FromDate AND TxnDate < DATEADD(DAY, 1, @ToDate));

		DECLARE @Redeemed DECIMAL(18,2) = (
			SELECT ISNULL(SUM(CASE WHEN TxnType = 'R' THEN ABS(NoPoints)
								   WHEN IsGiveback = 1 THEN -NoPoints ELSE 0 END), 0)
			FROM #Tx WHERE TxnDate >= @FromDate AND TxnDate < DATEADD(DAY, 1, @ToDate));

		DECLARE @PrevEarned DECIMAL(18,2) = (
			SELECT ISNULL(SUM(CASE WHEN TxnType = 'G' AND IsGiveback = 0 THEN NoPoints
								   WHEN TxnType = 'V' THEN NoPoints ELSE 0 END), 0)
			FROM #Tx WHERE TxnDate >= @PrevFrom AND TxnDate < DATEADD(DAY, 1, @PrevTo));

		DECLARE @PrevRedeemed DECIMAL(18,2) = (
			SELECT ISNULL(SUM(CASE WHEN TxnType = 'R' THEN ABS(NoPoints)
								   WHEN IsGiveback = 1 THEN -NoPoints ELSE 0 END), 0)
			FROM #Tx WHERE TxnDate >= @PrevFrom AND TxnDate < DATEADD(DAY, 1, @PrevTo));

		DECLARE @PrevLiability DECIMAL(18,2) = (
			SELECT ISNULL(SUM(x.NoPoints), 0)
			FROM #Tx AS x
			WHERE x.TxnDate <= @PrevTo AND (x.NoPoints < 0 OR x.ExpireDate > @PrevTo));

		DECLARE @Members INT = (
			SELECT COUNT(1) FROM [dbo].[LTY_Member]
			WHERE PropertyId = @PropertyId AND IsActive = 1);

		DECLARE @PrevMembers INT = (
			SELECT COUNT(1) FROM [dbo].[LTY_Member]
			WHERE PropertyId = @PropertyId AND IsActive = 1
			  AND CreatedDate < @FromDate);

		DECLARE @Expiring30 DECIMAL(18,2) = (
			SELECT ISNULL(SUM(NoPoints), 0) FROM #Tx
			WHERE NoPoints > 0 AND ExpireDate >= @Today
			  AND ExpireDate < DATEADD(DAY, 30, @Today));

		DECLARE @Kpi NVARCHAR(MAX) = (
			SELECT
				liability          = @Liability,
				liabilityDelta     = CASE WHEN @PrevLiability = 0 THEN 0
									 ELSE (@Liability - @PrevLiability) / @PrevLiability END,
				activeMembers      = @Members,
				activeMembersDelta = CASE WHEN @PrevMembers = 0 THEN 0
									 ELSE CONVERT(DECIMAL(18,6), @Members - @PrevMembers) / @PrevMembers END,
				earned             = @Earned,
				earnedDelta        = CASE WHEN @PrevEarned = 0 THEN 0
									 ELSE (@Earned - @PrevEarned) / @PrevEarned END,
				redeemed           = @Redeemed,
				redeemedDelta      = CASE WHEN @PrevRedeemed = 0 THEN 0
									 ELSE (@Redeemed - @PrevRedeemed) / @PrevRedeemed END,
				expiring30         = @Expiring30,
				redemptionRate     = CASE WHEN @Earned = 0 THEN 0 ELSE @Redeemed / @Earned END,
				redemptionTarget   = @RedemptionTarget
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

		---- Points movement by month -------------------------------------------
		DECLARE @Movement NVARCHAR(MAX) = ISNULL((
			SELECT
				m.Label AS m,
				earned = ISNULL((SELECT SUM(CASE WHEN x.TxnType = 'G' AND x.IsGiveback = 0 THEN x.NoPoints
												 WHEN x.TxnType = 'V' THEN x.NoPoints ELSE 0 END)
								 FROM #Tx AS x
								 WHERE x.TxnDate >= m.MStart AND x.TxnDate < DATEADD(DAY, 1, m.MEnd)), 0),
				redeemed = ISNULL((SELECT SUM(CASE WHEN x.TxnType = 'R' THEN ABS(x.NoPoints)
												   WHEN x.IsGiveback = 1 THEN -x.NoPoints ELSE 0 END)
								   FROM #Tx AS x
								   WHERE x.TxnDate >= m.MStart AND x.TxnDate < DATEADD(DAY, 1, m.MEnd)), 0)
			FROM #Months AS m
			ORDER BY m.Ord
			FOR JSON PATH), '[]');

		---- Liability at each month end ----------------------------------------
		DECLARE @LiabilityTrend NVARCHAR(MAX) = ISNULL((
			SELECT
				m.Label AS m,
				v = ISNULL((SELECT SUM(x.NoPoints) FROM #Tx AS x
							WHERE x.TxnDate <= DATEADD(DAY, 1, m.MEnd)
							  AND (x.NoPoints < 0 OR x.ExpireDate > m.MEnd)), 0)
			FROM #Months AS m
			ORDER BY m.Ord
			FOR JSON PATH), '[]');

		---- Expiry runway, next 12 months --------------------------------------
		DECLARE @Expiry NVARCHAR(MAX) = ISNULL((
			SELECT FORMAT(e.MStart, 'MMM yy') AS m,
				   v = ISNULL((SELECT SUM(x.NoPoints) FROM #Tx AS x
							   WHERE x.NoPoints > 0
								 AND x.ExpireDate >= e.MStart
								 AND x.ExpireDate < DATEADD(MONTH, 1, e.MStart)), 0)
			FROM (SELECT DATEADD(MONTH, n.v, DATEFROMPARTS(YEAR(@Today), MONTH(@Today), 1)) AS MStart
				  FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11)) AS n(v)) AS e
			ORDER BY e.MStart
			FOR JSON PATH), '[]');

		---- Tiers. Ordered by SortOrder - the chart ramp follows this order. ----
		DECLARE @Tiers NVARCHAR(MAX) = ISNULL((
			SELECT t.TierName AS name,
				   members = (SELECT COUNT(1) FROM [dbo].[LTY_Member] AS mem
							  WHERE mem.TierId = t.TierId AND mem.PropertyId = @PropertyId
								AND mem.IsActive = 1)
			FROM [dbo].[LTY_Tier] AS t
			WHERE t.PropertyId = @PropertyId AND t.IsActive = 1
			ORDER BY t.SortOrder, t.TierId
			FOR JSON PATH), '[]');

		---- Outlets. '-999' is the adjustment pseudo-outlet, not a real one. ----
		DECLARE @Outlets NVARCHAR(MAX) = ISNULL((
			SELECT
				x.OutletCode AS code,
				ISNULL(lr.Description, x.OutletCode) AS name,
				earned   = SUM(CASE WHEN x.TxnType = 'G' AND x.IsGiveback = 0 THEN x.NoPoints
									WHEN x.TxnType = 'V' THEN x.NoPoints ELSE 0 END),
				redeemed = SUM(CASE WHEN x.TxnType = 'R' THEN ABS(x.NoPoints)
									WHEN x.IsGiveback = 1 THEN -x.NoPoints ELSE 0 END),
				bill     = SUM(x.BillValue),
				txns     = COUNT(1)
			FROM #Tx AS x
			LEFT JOIN [dbo].[Location_Ref] AS lr
				ON lr.Code = x.OutletCode AND lr.PropertyId = @PropertyId
			WHERE x.OutletCode <> '-999'
			  AND x.TxnDate >= @FromDate AND x.TxnDate < DATEADD(DAY, 1, @ToDate)
			GROUP BY x.OutletCode, lr.Description
			ORDER BY SUM(CASE WHEN x.TxnType = 'G' AND x.IsGiveback = 0 THEN x.NoPoints ELSE 0 END) DESC
			FOR JSON PATH), '[]');

		---- Coupon funnel -------------------------------------------------------
		DECLARE @Coupons NVARCHAR(MAX) = (
			SELECT
				used = (SELECT COUNT(1) FROM [dbo].[LTY_CouponUsage]
						WHERE PropertyId = @PropertyId AND IsUse = 1),
				live = (SELECT COUNT(1) FROM [dbo].[LTY_CouponMaster] AS c
						WHERE c.PropertyId = @PropertyId AND c.ExpireDate >= GETDATE()
						  AND NOT EXISTS (SELECT 1 FROM [dbo].[LTY_CouponUsage] AS u
										  WHERE u.CouponId = c.Id AND u.IsUse = 1)),
				expiredUnused = (SELECT COUNT(1) FROM [dbo].[LTY_CouponMaster] AS c
						WHERE c.PropertyId = @PropertyId AND c.ExpireDate < GETDATE()
						  AND NOT EXISTS (SELECT 1 FROM [dbo].[LTY_CouponUsage] AS u
										  WHERE u.CouponId = c.Id AND u.IsUse = 1))
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

		---- Outlet freshness. Ignores the outlet filter on purpose - the point of
		---- this panel is to show an outlet that has gone quiet.
		DECLARE @Freshness NVARCHAR(MAX) = ISNULL((
			SELECT
				f.OutletCode AS code,
				ISNULL(lr.Description, f.OutletCode) AS name,
				FORMAT(f.LastAt, 'dd MMM HH:mm') AS last,
				f.Mins AS mins,
				status = CASE WHEN f.Mins <= @FreshWarnMins THEN 'good'
							  WHEN f.Mins <= @FreshCritMins THEN 'warning'
							  ELSE 'critical' END
			FROM (
				SELECT t.OutletCode,
					   MAX(t.CreatedDateTime) AS LastAt,
					   DATEDIFF(MINUTE, MAX(t.CreatedDateTime), GETDATE()) AS Mins
				FROM [dbo].[LTY_MemberWisePointTransaction] AS t
				WHERE t.PropertyId = @PropertyId AND t.OutletCode <> '-999'
				GROUP BY t.OutletCode
			) AS f
			LEFT JOIN [dbo].[Location_Ref] AS lr
				ON lr.Code = f.OutletCode AND lr.PropertyId = @PropertyId
			ORDER BY f.Mins DESC
			FOR JSON PATH), '[]');

		---- Birthdays this month ------------------------------------------------
		DECLARE @Birthdays NVARCHAR(MAX) = ISNULL((
			SELECT TOP (50)
				LTRIM(RTRIM(ISNULL(mem.FirstName, '') + ' ' + ISNULL(mem.LastName, ''))) AS name,
				mem.PrimaryMobileNo AS mobile,
				ISNULL(t.TierName, '') AS tier,
				FORMAT(mem.Birthday, 'dd MMM') AS date
			FROM [dbo].[LTY_Member] AS mem
			LEFT JOIN [dbo].[LTY_Tier] AS t
				ON t.TierId = mem.TierId AND t.PropertyId = mem.PropertyId
			WHERE mem.PropertyId = @PropertyId
			  AND mem.IsActive = 1
			  AND mem.Birthday IS NOT NULL
			  AND MONTH(mem.Birthday) = MONTH(@Today)
			ORDER BY DAY(mem.Birthday)
			FOR JSON PATH), '[]');

		---- Promotions ending inside 14 days ------------------------------------
		DECLARE @PromoExpiring NVARCHAR(MAX) = ISNULL((
			SELECT
				p.PromotionName AS name,
				FORMAT(p.EndDate, 'dd MMM yyyy') AS ends,
				DATEDIFF(DAY, @Today, p.EndDate) AS days,
				kind = ISNULL((
					SELECT STRING_AGG(k.Label, ', ')
					FROM (
						SELECT 'Item discount' AS Label WHERE EXISTS
							(SELECT 1 FROM [dbo].[LTY_ItemWisePromotion]
							 WHERE PromotionId = p.PromotionId AND PropertyId = @PropertyId)
						UNION ALL SELECT 'Category discount' WHERE EXISTS
							(SELECT 1 FROM [dbo].[LTY_CategoryWisePromotion]
							 WHERE PromotionId = p.PromotionId AND PropertyId = @PropertyId)
						UNION ALL SELECT 'Free item' WHERE EXISTS
							(SELECT 1 FROM [dbo].[LTY_FreeItemWisePromotion]
							 WHERE PromotionId = p.PromotionId AND PropertyId = @PropertyId)
						UNION ALL SELECT 'Point item' WHERE EXISTS
							(SELECT 1 FROM [dbo].[LTY_PointItemWisePromotion]
							 WHERE PromotionId = p.PromotionId AND PropertyId = @PropertyId)
						UNION ALL SELECT 'Promotion point' WHERE EXISTS
							(SELECT 1 FROM [dbo].[LTY_PromotionWisePoint]
							 WHERE PromotionId = p.PromotionId AND PropertyId = @PropertyId)
						UNION ALL SELECT 'Coupon' WHERE EXISTS
							(SELECT 1 FROM [dbo].[LTY_PromotionWiseCoupon]
							 WHERE PromotionId = p.PromotionId AND PropertyId = @PropertyId)
					) AS k), 'Bill discount')
			FROM [dbo].[LTY_Promotion] AS p
			WHERE p.PropertyId = @PropertyId
			  AND p.IsActive = 1
			  AND p.EndDate >= @Today
			  AND p.EndDate < DATEADD(DAY, 15, @Today)
			ORDER BY p.EndDate
			FOR JSON PATH), '[]');

		---- Assemble ------------------------------------------------------------
		SET @Json =
		(
			SELECT
				asOf       = FORMAT(GETDATE(), 'dd MMM yyyy, HH:mm'),
				fromDate   = FORMAT(@FromDate, 'yyyy-MM-dd'),
				toDate     = FORMAT(@ToDate, 'yyyy-MM-dd'),
				outletCode = @OutletCode,
				kpi             = JSON_QUERY(@Kpi),
				movement        = JSON_QUERY(@Movement),
				liabilityTrend  = JSON_QUERY(@LiabilityTrend),
				expiry          = JSON_QUERY(@Expiry),
				tiers           = JSON_QUERY(@Tiers),
				outlets         = JSON_QUERY(@Outlets),
				coupons         = JSON_QUERY(@Coupons),
				freshness       = JSON_QUERY(@Freshness),
				birthdays       = JSON_QUERY(@Birthdays),
				promoExpiring   = JSON_QUERY(@PromoExpiring)
			FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
		);

		SELECT @Json AS DashboardJson;

	END TRY
	BEGIN CATCH

		DECLARE @ErrMsg   NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrSev   INT            = ERROR_SEVERITY();
		DECLARE @ErrState INT            = ERROR_STATE();

		RAISERROR(@ErrMsg, @ErrSev, @ErrState);

	END CATCH
END

GO

