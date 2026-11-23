
------------------------------------------------------------------------------
-- LTY_GetMatchingPromotion
------------------------------------------------------------------------------
-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-17
-- Description:	Promotions a member and an order qualify for, as one flat array.
--
--              Birthday promotions are in the same array as the rest; IsBirthdayDate
--              and IsBirthdayMonth on each row say which is which. A promotion is
--              listed once however many of those flags it carries.
--
--              What gates a promotion:
--                - property, active, date range, time window (overnight safe)
--                - bill amount, when the caller gave one
--                - day, location and tier must all match
--                - IsBirthdayDate  promotions only on the member's birthday
--                - IsBirthdayMonth promotions only inside the birthday month
--                - IsNewMember     promotions only while the member is still inside
--                                  its own NewMemberDayCount window,
--                                  measured from LTY_Member.CreatedDate to TxnDate
--                - SEGMENT mode    promotions only for members of the segment the
--                                  promotion was given, read from the materialised
--                                  LTYC_SegmentMember. A gate, like tier - it is
--                                  never reported as a validation mode, because
--                                  there is nothing for the till to apply.
--
--                - validation modes:
--                    ITM / CAT / FREEITEM / BOGO are the modes this endpoint reports.
--                    A promotion configuring any of them is returned only when one
--                    of them meets this order, so it is never returned with an empty
--                    ValidationModes array while holding modes it could not apply.
--
--                    POINTITEM, PROPOINT and COU are point earning and coupon modes,
--                    not till discounts. They are never reported, and a promotion
--                    built only from them is not returned at all.
--
--                    A promotion with no modes of any kind is returned with an empty
--                    ValidationModes array - it discounts the bill, not a line.
--
--                    SEGMENT is deliberately absent from that test. It restricts WHO
--                    a promotion reaches rather than WHAT it discounts, so it is not
--                    something the promotion "could not apply" - a promotion whose
--                    only mode is SEGMENT is still a whole-bill promotion and comes
--                    back with an empty ValidationModes array, gated by the segment.
--
--              What does NOT gate it:
--                - payment type. Still carried in the payload and still shredded into
--                  #PaymentType; the predicate is kept below as a comment.
-- =============================================
-- EXEC [dbo].[LTY_GetMatchingPromotion]
--      @MobileNo         = '0702375050',
--      @OutletCode       = '300',
--      @TxnDate          = '2026-08-17 19:30:00',
--      @PropertyId       = 1,
--      @PaymentTypesJson = N'["01"]',
--      @ItemsJson        = N'[{"ItemCode":"CT02","Qty":2,"Amount":900}]'
-- =============================================
CREATE   PROCEDURE [dbo].[LTY_GetMatchingPromotion]
	@MobileNo NVARCHAR(20),
	@OutletCode VARCHAR(50),
	@TxnDate DATETIME,
	@PropertyId INT,
	@NetAmount DECIMAL(18,4) = NULL,
	@PaymentTypesJson NVARCHAR(MAX) = N'[]',
	@ItemsJson NVARCHAR(MAX) = N'[]'
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		DECLARE @MemberId INT;
		DECLARE @TierId   INT;
		DECLARE @Birthday DATETIME;
		DECLARE @MemberCreatedDate DATETIME;
		DECLARE @Json     NVARCHAR(MAX);

		DECLARE @IsBillAmountValidated BIT;
		DECLARE @IsBirthdayToday       BIT;
		DECLARE @IsBirthdayMonthNow    BIT;

		DECLARE @TxnTime TIME(0) = CONVERT(TIME(0), @TxnDate);
		DECLARE @DayCode VARCHAR(3) =
			CASE (DATEDIFF(DAY, '19000107', CONVERT(DATE, @TxnDate)) % 7)
				WHEN 0 THEN 'SUN' WHEN 1 THEN 'MON' WHEN 2 THEN 'TUE'
				WHEN 3 THEN 'WED' WHEN 4 THEN 'THU' WHEN 5 THEN 'FRI'
				ELSE 'SAT'
			END;

		---- Payment types settled against the order ----
		CREATE TABLE #PaymentType (PaymentTypeCode VARCHAR(20) NOT NULL);

		INSERT INTO #PaymentType (PaymentTypeCode)
		SELECT DISTINCT CONVERT(VARCHAR(20), [value])
		FROM OPENJSON(@PaymentTypesJson)
		WHERE NULLIF(LTRIM(RTRIM([value])), '') IS NOT NULL;

		CREATE TABLE #OrderItem
		(
			ItemCode     VARCHAR(20)   NOT NULL PRIMARY KEY,
			Qty          DECIMAL(18,4) NOT NULL,
			Amount       DECIMAL(18,4) NOT NULL,
			CategoryCode VARCHAR(20)   NULL
		);

		INSERT INTO #OrderItem (ItemCode, Qty, Amount, CategoryCode)
		SELECT
			LTRIM(RTRIM(i.ItemCode)),
			SUM(ISNULL(i.Qty, 0)),
			SUM(ISNULL(i.Amount, 0)),
			NULLIF(RTRIM(MAX(mm.Category)), '')
		FROM OPENJSON(@ItemsJson)
		WITH (
			ItemCode VARCHAR(20)   '$.ItemCode',
			Qty      DECIMAL(18,4) '$.Qty',
			Amount   DECIMAL(18,4) '$.Amount'
		) AS i
		LEFT JOIN [dbo].[MainMenu] AS mm
			ON mm.ItemCode   = LTRIM(RTRIM(i.ItemCode))
		   AND mm.PropertyId = @PropertyId
		WHERE NULLIF(LTRIM(RTRIM(i.ItemCode)), '') IS NOT NULL
		GROUP BY LTRIM(RTRIM(i.ItemCode));

		---- Resolve the member from the mobile number ----
		IF (NULLIF(LTRIM(RTRIM(@MobileNo)), '') IS NULL)
		BEGIN
			RAISERROR('A mobile number is required to match promotions.', 16, 1);
		END

		SELECT
			@MemberId = MemberId,
			@TierId   = TierId,
			@Birthday = Birthday,
			@MemberCreatedDate = CreatedDate
		FROM [dbo].[LTY_Member]
		WHERE PrimaryMobileNo = @MobileNo
		  AND PropertyId      = @PropertyId
		  AND IsActive        = 1;

		IF (@MemberId IS NULL)
		BEGIN
			RAISERROR('No active member is registered with this mobile number.', 16, 1);
		END

		SET @IsBirthdayToday =
			CASE WHEN @Birthday IS NOT NULL
				  AND MONTH(@Birthday) = MONTH(@TxnDate)
				  AND DAY(@Birthday)   = DAY(@TxnDate)
				 THEN 1 ELSE 0 END;

		SET @IsBirthdayMonthNow =
			CASE WHEN @Birthday IS NOT NULL
				  AND MONTH(@Birthday) = MONTH(@TxnDate)
				 THEN 1 ELSE 0 END;

		---- Bill amount: explicit value first, otherwise the sum of the line amounts ----
		IF (@NetAmount IS NULL)
		BEGIN
			SET @NetAmount = (SELECT SUM(Amount) FROM #OrderItem);
		END

		SET @NetAmount = ISNULL(@NetAmount, 0);
		SET @IsBillAmountValidated = CASE WHEN @NetAmount > 0 THEN 1 ELSE 0 END;

		---- Everything the member and order qualify for. One row per promotion, so a
		---- promotion carrying both birthday flags is still listed once.
		CREATE TABLE #Candidate (PromotionId INT NOT NULL PRIMARY KEY);

		INSERT INTO #Candidate (PromotionId)
		SELECT p.PromotionId
		FROM [dbo].[LTY_Promotion] AS p
		WHERE p.PropertyId = @PropertyId
		  AND p.IsActive   = 1
		  AND CONVERT(DATE, @TxnDate) BETWEEN p.StartDate AND p.EndDate
		  AND (
				(p.StartTime <= p.EndTime AND @TxnTime BETWEEN p.StartTime AND p.EndTime)
			 OR (p.StartTime >  p.EndTime AND (@TxnTime >= p.StartTime OR @TxnTime <= p.EndTime))
			  )
		  AND (
				@IsBillAmountValidated = 0
			 OR (@NetAmount >= p.MinBillAmount
				 AND (p.MaxBillAmount IS NULL OR @NetAmount <= p.MaxBillAmount))
			  )
		  AND EXISTS (SELECT 1 FROM [dbo].[LTY_DayWisePromotion] AS d
					  WHERE d.PromotionId = p.PromotionId
						AND d.Days        = @DayCode)
		  AND EXISTS (SELECT 1 FROM [dbo].[LTY_LocationWisePromotion] AS l
					  WHERE l.PromotionId  = p.PromotionId
						AND l.LocationCode = @OutletCode)
		  AND EXISTS (SELECT 1 FROM [dbo].[LTY_TierWisePromotion] AS t
					  WHERE t.PromotionId = p.PromotionId
						AND t.TierId      = @TierId)
		  -- Birthday promotions only reach the member they are meant for. A promotion
		  -- with neither flag is ordinary and always passes this test.
		  AND (
				(p.IsBirthdayDate = 0 AND p.IsBirthdayMonth = 0)
			 OR (p.IsBirthdayDate  = 1 AND @IsBirthdayToday    = 1)
			 OR (p.IsBirthdayMonth = 1 AND @IsBirthdayMonthNow = 1)
			  )
		  -- Segment promotions only reach members of the segment they were given.
		  -- Shaped like the payment-type block below, and for the same reason: the
		  -- first branch lets a promotion that restricts nothing through, the second
		  -- requires a restricted one to match.
		  --
		  -- Membership is READ, never recomputed here. LTYC_SegmentMember is what
		  -- the segment builder materialises and what the Braze sync reads, so a
		  -- promotion reaches exactly the people the segment screen says it does.
		  -- The cost is the same as the tier test: one indexed lookup.
		  --
		  -- A segment whose membership has never been refreshed is empty, so its
		  -- promotion matches nobody rather than everybody. That is the safe way
		  -- round - the alternative silently widens an audience that was chosen to
		  -- be narrow. Same for a soft-deleted segment, whose members are removed
		  -- with it by LTYC_Segment_Delete.
		  AND (
				NOT EXISTS (SELECT 1 FROM [dbo].[LTY_SegmentWisePromotion] AS sw
							WHERE sw.PromotionId = p.PromotionId
							  AND sw.PropertyId  = @PropertyId)
			 OR EXISTS (SELECT 1 FROM [dbo].[LTY_SegmentWisePromotion] AS sw
						INNER JOIN [dbo].[LTYC_SegmentMember] AS sm
						  ON sm.SegmentId  = sw.SegmentId
						 AND sm.MemberId   = @MemberId
						 AND sm.PropertyId = @PropertyId
						WHERE sw.PromotionId = p.PromotionId
						  AND sw.PropertyId  = @PropertyId)
			  )
		  -- New-member promotions only reach a member still inside the window the
		  -- promotion itself defines. Each promotion carries its own day count, so
		  -- unlike the birthday tests this cannot be resolved to one flag up front -
		  -- it is evaluated against every promotion in turn.
		  --
		  -- IsNewMember set with no NewMemberDayCount matches nothing: there is no
		  -- window to be inside. Give the promotion a count, or leave the flag off.
		  AND (
				ISNULL(p.IsNewMember, 0) = 0
			 OR (    @MemberCreatedDate  IS NOT NULL
				 AND p.NewMemberDayCount IS NOT NULL
				 AND DATEDIFF(DAY, @MemberCreatedDate, @TxnDate)
					   BETWEEN 0 AND p.NewMemberDayCount)
			  )
		  -- Discount modes filter only when the promotion configures them.
		  --
		  --   configures none  -> nothing to satisfy, the promotion stands on its own
		  --   configures some  -> at least one of them has to meet this order, or the
		  --                       promotion has nothing to discount here and is left out
		  --
		  -- The first branch is the "no modes" case; the rest are the same tests the
		  -- #Mode staging below uses to decide what to report.
		  AND (
				(
					  NOT EXISTS (SELECT 1 FROM [dbo].[LTY_ItemWisePromotion] AS iw
								  WHERE iw.PromotionId = p.PromotionId
									AND iw.PropertyId  = @PropertyId)
				  AND NOT EXISTS (SELECT 1 FROM [dbo].[LTY_CategoryWisePromotion] AS cw
								  WHERE cw.PromotionId = p.PromotionId
									AND cw.PropertyId  = @PropertyId)
				  AND NOT EXISTS (SELECT 1 FROM [dbo].[LTY_FreeItemWisePromotion] AS fw
								  WHERE fw.PromotionId = p.PromotionId
									AND fw.PropertyId  = @PropertyId)
				  -- The point and coupon modes are not till discounts and are never
				  -- reported here, so a promotion built only from them has nothing to
				  -- show and is not treated as "no modes configured".
				  AND NOT EXISTS (SELECT 1 FROM [dbo].[LTY_PointItemWisePromotion] AS pip
								  WHERE pip.PromotionId = p.PromotionId
									AND pip.PropertyId  = @PropertyId)
				  AND NOT EXISTS (SELECT 1 FROM [dbo].[LTY_PromotionWisePoint] AS pwp
								  WHERE pwp.PromotionId = p.PromotionId
									AND pwp.PropertyId  = @PropertyId)
				  AND NOT EXISTS (SELECT 1 FROM [dbo].[LTY_PromotionWiseCoupon] AS pwc
								  WHERE pwc.PromotionId = p.PromotionId
									AND pwc.PropertyId  = @PropertyId)
				  AND NOT EXISTS (SELECT 1 FROM [dbo].[LTY_BuyOneGetOneWisePromotion] AS bgw
								  WHERE bgw.PromotionId = p.PromotionId
									AND bgw.PropertyId  = @PropertyId)
				)
				-- Item discount: the order carries at least one of the listed items.
			 OR EXISTS (SELECT 1 FROM [dbo].[LTY_ItemWisePromotion] AS iw
						INNER JOIN #OrderItem AS oi ON oi.ItemCode = iw.ItemId
						WHERE iw.PromotionId = p.PromotionId
						  AND iw.PropertyId  = @PropertyId)
				-- Category discount: at least one ordered item sits in a listed category.
			 OR EXISTS (SELECT 1 FROM [dbo].[LTY_CategoryWisePromotion] AS cw
						INNER JOIN #OrderItem AS oi ON oi.CategoryCode = cw.CategoryId
						WHERE cw.PromotionId = p.PromotionId
						  AND cw.PropertyId  = @PropertyId)
				-- Free item: a giveaway, so configuring one is enough - it does not
				-- have to be on the order.
			 OR EXISTS (SELECT 1 FROM [dbo].[LTY_FreeItemWisePromotion] AS fw
						WHERE fw.PromotionId = p.PromotionId
						  AND fw.PropertyId  = @PropertyId)
				-- Buy one get one: the order has to carry enough of the item being
				-- bought. The free item is the reward and is never required.
				-- A pair saved before MainItemQty existed reads as "buy one".
			 OR EXISTS (SELECT 1 FROM [dbo].[LTY_BuyOneGetOneWisePromotion] AS bg
						INNER JOIN #OrderItem AS oi
						  ON oi.ItemCode = bg.ItemCode
						 AND oi.Qty     >= ISNULL(bg.MainItemQty, 1)
						WHERE bg.PromotionId = p.PromotionId
						  AND bg.PropertyId  = @PropertyId)
			  )
		;
		-- Payment type does NOT filter. @PaymentTypesJson is still shredded into
		-- #PaymentType above and travels with the request, but a promotion comes back
		-- whatever the order is being settled with. Uncomment the block below - as
		-- part of the WHERE, before the semicolon above - to turn it back on: the
		-- first branch lets a promotion that restricts nothing through, the second
		-- requires a restricted one to match what was tendered.
		--
		-- AND (
		--       NOT EXISTS (SELECT 1 FROM [dbo].[LTY_PaymentTypeWisePromotion] AS pt
		--                   WHERE pt.PromotionId = p.PromotionId)
		--    OR EXISTS (SELECT 1 FROM [dbo].[LTY_PaymentTypeWisePromotion] AS pt
		--               INNER JOIN #PaymentType AS op ON op.PaymentTypeCode = pt.PaymentTypeCode
		--               WHERE pt.PromotionId = p.PromotionId)
		--     )

		---- Staged one row per promotion per mode. Built here rather than inline
		---- because a derived table cannot carry an outer reference to the promotion.
		----
		---- A mode is reported only when this order actually meets it, so an empty
		---- ValidationModes array means the promotion applies with nothing
		---- item-specific to attach the discount to.
		CREATE TABLE #Mode
		(
			PromotionId     INT           NOT NULL,
			Seq             INT           NOT NULL,
			ModeCode        VARCHAR(20)   NOT NULL,
			ModeDescription VARCHAR(MAX)  NULL,
			Items           NVARCHAR(MAX) NULL
		);

		---- ITM - Item Discount. The ordered lines the promotion names directly.
		INSERT INTO #Mode (PromotionId, Seq, ModeCode, ModeDescription, Items)
		SELECT
			c.PromotionId,
			1,
			'ITM',
			(SELECT TOP (1) vm.Description
			 FROM [dbo].[LTY_ValidationModes] AS vm
			 WHERE vm.Code = 'ITM' AND vm.PropertyId = @PropertyId),
			(SELECT
				oi.ItemCode    AS ItemCode,
				mm.Description AS Description,
				oi.Qty         AS Qty,
				oi.Amount      AS Amount
			 FROM [dbo].[LTY_ItemWisePromotion] AS iw
			 INNER JOIN #OrderItem AS oi ON oi.ItemCode = iw.ItemId
			 LEFT JOIN [dbo].[MainMenu] AS mm
				ON mm.ItemCode   = oi.ItemCode
			   AND mm.PropertyId = @PropertyId
			 WHERE iw.PromotionId = c.PromotionId
			   AND iw.PropertyId  = @PropertyId
			 ORDER BY oi.ItemCode
			 FOR JSON PATH, INCLUDE_NULL_VALUES)
		FROM #Candidate AS c
		WHERE EXISTS (SELECT 1 FROM [dbo].[LTY_ItemWisePromotion] AS iw
					  INNER JOIN #OrderItem AS oi ON oi.ItemCode = iw.ItemId
					  WHERE iw.PromotionId = c.PromotionId
						AND iw.PropertyId  = @PropertyId);

		---- CAT - Category Discount. The ordered lines whose category the promotion
		---- discounts, each carrying the category it qualified through so the till can
		---- show why the line was discounted.
		INSERT INTO #Mode (PromotionId, Seq, ModeCode, ModeDescription, Items)
		SELECT
			c.PromotionId,
			2,
			'CAT',
			(SELECT TOP (1) vm.Description
			 FROM [dbo].[LTY_ValidationModes] AS vm
			 WHERE vm.Code = 'CAT' AND vm.PropertyId = @PropertyId),
			(SELECT
				oi.ItemCode    AS ItemCode,
				mm.Description AS Description,
				cw.CategoryId  AS CategoryCode,
				cr.Description AS CategoryDescription,
				oi.Qty         AS Qty,
				oi.Amount      AS Amount
			 FROM [dbo].[LTY_CategoryWisePromotion] AS cw
			 INNER JOIN #OrderItem AS oi ON oi.CategoryCode = cw.CategoryId
			 LEFT JOIN [dbo].[Category] AS cr
				ON cr.Code       = cw.CategoryId
			   AND cr.PropertyId = @PropertyId
			 LEFT JOIN [dbo].[MainMenu] AS mm
				ON mm.ItemCode   = oi.ItemCode
			   AND mm.PropertyId = @PropertyId
			 WHERE cw.PromotionId = c.PromotionId
			   AND cw.PropertyId  = @PropertyId
			 ORDER BY oi.ItemCode
			 FOR JSON PATH, INCLUDE_NULL_VALUES)
		FROM #Candidate AS c
		WHERE EXISTS (SELECT 1 FROM [dbo].[LTY_CategoryWisePromotion] AS cw
					  INNER JOIN #OrderItem AS oi ON oi.CategoryCode = cw.CategoryId
					  WHERE cw.PromotionId = c.PromotionId
						AND cw.PropertyId  = @PropertyId);

		---- FREEITEM - Free Item. The whole configured list: these are given away, so
		---- they are not filtered against what was ordered.
		INSERT INTO #Mode (PromotionId, Seq, ModeCode, ModeDescription, Items)
		SELECT
			c.PromotionId,
			3,
			'FREEITEM',
			(SELECT TOP (1) vm.Description
			 FROM [dbo].[LTY_ValidationModes] AS vm
			 WHERE vm.Code = 'FREEITEM' AND vm.PropertyId = @PropertyId),
			(SELECT
				fw.ItemId      AS ItemCode,
				mm.Description AS Description,
				fw.FreeQty     AS FreeQty
			 FROM [dbo].[LTY_FreeItemWisePromotion] AS fw
			 LEFT JOIN [dbo].[MainMenu] AS mm
				ON mm.ItemCode   = fw.ItemId
			   AND mm.PropertyId = @PropertyId
			 WHERE fw.PromotionId = c.PromotionId
			   AND fw.PropertyId  = @PropertyId
			 ORDER BY fw.ItemId
			 FOR JSON PATH, INCLUDE_NULL_VALUES)
		FROM #Candidate AS c
		WHERE EXISTS (SELECT 1 FROM [dbo].[LTY_FreeItemWisePromotion] AS fw
					  WHERE fw.PromotionId = c.PromotionId
						AND fw.PropertyId  = @PropertyId);

		---- BOGO - Buy One Get One.
		----
		---- The main items this order actually reaches, folded to one row each.
		---- Staged into a table rather than a derived table inside the JSON below,
		---- because a derived table cannot carry an outer reference to the
		---- promotion - the same reason #Mode exists at all.
		CREATE TABLE #Bogo
		(
			PromotionId   INT           NOT NULL,
			ItemCode      VARCHAR(20)   NOT NULL,
			MainItemQty   DECIMAL(18,4) NOT NULL,
			OrderedQty    DECIMAL(18,4) NOT NULL,
			OrderedAmount DECIMAL(18,4) NOT NULL,
			PRIMARY KEY (PromotionId, ItemCode)
		);

		INSERT INTO #Bogo (PromotionId, ItemCode, MainItemQty, OrderedQty, OrderedAmount)
		SELECT
			bg.PromotionId,
			bg.ItemCode,
			MAX(ISNULL(bg.MainItemQty, 1)),
			MAX(oi.Qty),
			MAX(oi.Amount)
		FROM [dbo].[LTY_BuyOneGetOneWisePromotion] AS bg
		INNER JOIN #Candidate AS c ON c.PromotionId = bg.PromotionId
		INNER JOIN #OrderItem AS oi
			ON oi.ItemCode = bg.ItemCode
		   AND oi.Qty     >= ISNULL(bg.MainItemQty, 1)      -- enough of it was bought
		WHERE bg.PropertyId = @PropertyId
		GROUP BY bg.PromotionId, bg.ItemCode;

		---- One entry per main item, carrying the free items it earns. ItemCode,
		---- Qty and Amount describe what is on the bill; RequiredQty is how many
		---- the promotion asked for; FreeItems is what the till should add.
		INSERT INTO #Mode (PromotionId, Seq, ModeCode, ModeDescription, Items)
		SELECT
			c.PromotionId,
			4,
			'BOGO',
			(SELECT TOP (1) vm.Description
			 FROM [dbo].[LTY_ValidationModes] AS vm
			 WHERE vm.Code = 'BOGO' AND vm.PropertyId = @PropertyId),
			(SELECT
				b.ItemCode      AS ItemCode,
				mm.Description  AS Description,
				b.OrderedQty    AS Qty,
				b.OrderedAmount AS Amount,
				b.MainItemQty   AS RequiredQty,
				FreeItems = JSON_QUERY(ISNULL((
					SELECT
						f.FreeItemCode AS FreeItemCode,
						fm.Description AS FreeItemDescription,
						f.FreeQty      AS FreeQty
					FROM [dbo].[LTY_BuyOneGetOneWisePromotion] AS f
					LEFT JOIN [dbo].[MainMenu] AS fm
						ON fm.ItemCode   = f.FreeItemCode
					   AND fm.PropertyId = @PropertyId
					WHERE f.PromotionId = b.PromotionId
					  AND f.PropertyId  = @PropertyId
					  AND f.ItemCode    = b.ItemCode
					ORDER BY f.FreeItemCode
					FOR JSON PATH, INCLUDE_NULL_VALUES), '[]'))
			 FROM #Bogo AS b
			 LEFT JOIN [dbo].[MainMenu] AS mm
				ON mm.ItemCode   = b.ItemCode
			   AND mm.PropertyId = @PropertyId
			 WHERE b.PromotionId = c.PromotionId
			 ORDER BY b.ItemCode
			 FOR JSON PATH, INCLUDE_NULL_VALUES)
		FROM #Candidate AS c
		WHERE EXISTS (SELECT 1 FROM #Bogo AS b WHERE b.PromotionId = c.PromotionId);

		---- One flat array for the whole result ----
		SELECT @Json = ISNULL((
			SELECT
				p.PromotionId,
				p.PromotionName,
				p.Description,
				p.PropertyId,
				p.StartDate,
				p.EndDate,
				CONVERT(VARCHAR(8), p.StartTime, 108) AS StartTime,
				CONVERT(VARCHAR(8), p.EndTime, 108)   AS EndTime,
				p.MinBillAmount,
				p.MaxBillAmount,
				p.IsDiscountPercentage,
				p.Discount,
				p.ImageURL,
				p.IsUploadImage,
				p.IsBirthdayDate,
				p.IsBirthdayMonth,
				p.IsNewMember,
				p.NewMemberDayCount,
				@MemberId              AS MemberId,
				@Birthday              AS MemberBirthday,
				@MemberCreatedDate     AS MemberCreatedDate,
				DATEDIFF(DAY, @MemberCreatedDate, @TxnDate) AS MemberDayCount,
				@NetAmount             AS OrderNetAmount,
				@IsBillAmountValidated AS IsBillAmountValidated,

				JSON_QUERY(ISNULL((
					SELECT
						m.ModeCode,
						m.ModeDescription,
						JSON_QUERY(ISNULL(m.Items, '[]')) AS Items
					FROM #Mode AS m
					WHERE m.PromotionId = p.PromotionId
					ORDER BY m.Seq
					FOR JSON PATH, INCLUDE_NULL_VALUES
				), '[]')) AS ValidationModes

			FROM [dbo].[LTY_Promotion] AS p
			INNER JOIN #Candidate AS c ON c.PromotionId = p.PromotionId
			ORDER BY p.PromotionName
			FOR JSON PATH, INCLUDE_NULL_VALUES
		), '[]');

		SELECT @Json AS PromotionsJson;

	END TRY
	BEGIN CATCH

		DECLARE @ErrMsg   NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrSev   INT            = ERROR_SEVERITY();
		DECLARE @ErrState INT            = ERROR_STATE();

		RAISERROR(@ErrMsg, @ErrSev, @ErrState);

	END CATCH
END

GO

