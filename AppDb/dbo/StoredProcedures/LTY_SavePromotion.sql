
------------------------------------------------------------------------------
-- LTY_SavePromotion
------------------------------------------------------------------------------
-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-05
-- Description:	Save Promotion (Insert or Update) with day/location/payment type/
--              tier sets, and the item/category/free item/point item/promotion
--              point/coupon sets each validation mode drives. Image columns are owned
--              by LTY_UpdatePromotionImage and are not touched here.
--
--              2026-08-17: IsBirthdayDate / IsBirthdayMonth added, and POINTITEM and
--              PROPOINT switched from an absolute ExpireDate to an ExpireDayCount, the
--              way COU already worked. The count is stored as given and the date is
--              computed from it at save time, so LTY_PointEarn keeps comparing dates
--              while the edit screen gets the original number back.
--
--              2026-08-18: IsNewMember / NewMemberDayCount added. Both nullable and
--              stored exactly as sent - a promotion that says nothing about new
--              members leaves them NULL rather than defaulting to a value it was
--              never given.
--
--              2026-08-18: BOGO (BuyOneGetOne) added. Its items are pairs - a bought
--              item and the item that comes free with it - so one bought item can
--              appear more than once with different free items.
--
--              2026-08-19: SEGMENT added. It holds a REFERENCE to a segment authored
--              in the segment builder (LTYC_Segment), never a copy of its rules or
--              its membership - those stay where they are maintained, and
--              LTY_GetMatchingPromotion reads the materialised LTYC_SegmentMember.
--              A scalar mode like PROPOINT: no item list, the id sits on the mode
--              itself as SegmentId.
-- =============================================
CREATE   PROCEDURE [dbo].[LTY_SavePromotion]
	@PromotionId INT = NULL,
	@PromotionName NVARCHAR(200),
	@Description VARCHAR(500),
	@PropertyId INT,
	@StartDate DATE,
	@EndDate DATE,
	@StartTime TIME(0),
	@EndTime TIME(0),
	@IsActive BIT = 1,
	@IsBirthdayDate BIT = 0,
	@IsBirthdayMonth BIT = 0,
	@IsNewMember BIT = NULL,
	@NewMemberDayCount INT = NULL,
	@MinBillAmount DECIMAL(18,4),
	@MaxBillAmount DECIMAL(18,4) = NULL,
	@IsDiscountPercentage BIT = NULL,
	@Discount DECIMAL(18,4) = NULL,
	@CreateBy INT,
	@DaysJson NVARCHAR(MAX) = N'[]',
	@LocationsJson NVARCHAR(MAX) = N'[]',
	@PaymentTypesJson NVARCHAR(MAX) = N'[]',
	@TiersJson NVARCHAR(MAX) = N'[]',
	@ValidationModesJson NVARCHAR(MAX) = N'[]'
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @CouponExpireDayCount INT;
	DECLARE @SegmentId INT;

	BEGIN TRY

		BEGIN TRANSACTION;

		-- Validation: EndDate must not be before StartDate
		IF (@EndDate < @StartDate)
		BEGIN
			RAISERROR('EndDate cannot be earlier than StartDate.', 16, 1);
		END

		-- Optional: remove if a max below the min is legitimate for you.
		IF (@MaxBillAmount IS NOT NULL AND @MaxBillAmount < @MinBillAmount)
		BEGIN
			RAISERROR('MaxBillAmount cannot be less than MinBillAmount.', 16, 1);
		END

		IF (@PromotionId IS NULL OR @PromotionId = 0)
		BEGIN
			-- INSERT
			INSERT INTO [dbo].[LTY_Promotion]
			(
				PromotionName,
				Description,
				PropertyId,
				StartDate,
				EndDate,
				StartTime,
				EndTime,
				IsActive,
				IsBirthdayDate,
				IsBirthdayMonth,
				IsNewMember,
				NewMemberDayCount,
				MinBillAmount,
				MaxBillAmount,
				IsDiscountPercentage,
				Discount,
				CreatedBy,
				CreatedDate
			)
			VALUES
			(
				@PromotionName,
				@Description,
				@PropertyId,
				@StartDate,
				@EndDate,
				@StartTime,
				@EndTime,
				@IsActive,
				ISNULL(@IsBirthdayDate, 0),
				ISNULL(@IsBirthdayMonth, 0),
				@IsNewMember,
				@NewMemberDayCount,
				@MinBillAmount,
				@MaxBillAmount,
				@IsDiscountPercentage,
				@Discount,
				@CreateBy,
				GETDATE()
			);

			SET @PromotionId = SCOPE_IDENTITY();
		END
		ELSE
		BEGIN
			-- UPDATE
			UPDATE [dbo].[LTY_Promotion]
			SET
				PromotionName         = @PromotionName,
				Description           = @Description,
				PropertyId            = @PropertyId,
				StartDate             = @StartDate,
				EndDate               = @EndDate,
				StartTime             = @StartTime,
				EndTime               = @EndTime,
				IsActive              = @IsActive,
				IsBirthdayDate        = ISNULL(@IsBirthdayDate, 0),
				IsBirthdayMonth       = ISNULL(@IsBirthdayMonth, 0),
				IsNewMember           = @IsNewMember,
				NewMemberDayCount     = @NewMemberDayCount,
				MinBillAmount         = @MinBillAmount,
				MaxBillAmount         = @MaxBillAmount,
				IsDiscountPercentage  = @IsDiscountPercentage,
				Discount              = @Discount,
				ModifyBy              = @CreateBy,
				ModifyDate            = GETDATE()
			WHERE PromotionId = @PromotionId;
		END

		-- Child sets: replaced wholesale. On insert the deletes match nothing, so one
		-- block serves both branches. The payload is the complete state, so an empty
		-- array clears the set.
		DELETE FROM [dbo].[LTY_DayWisePromotion]         WHERE PromotionId = @PromotionId;
		DELETE FROM [dbo].[LTY_LocationWisePromotion]    WHERE PromotionId = @PromotionId;
		DELETE FROM [dbo].[LTY_PaymentTypeWisePromotion] WHERE PromotionId = @PromotionId;
		DELETE FROM [dbo].[LTY_TierWisePromotion]        WHERE PromotionId = @PromotionId;
		DELETE FROM [dbo].[LTY_ItemWisePromotion]        WHERE PromotionId = @PromotionId AND PropertyId = @PropertyId;
		DELETE FROM [dbo].[LTY_CategoryWisePromotion]    WHERE PromotionId = @PromotionId AND PropertyId = @PropertyId;
		DELETE FROM [dbo].[LTY_FreeItemWisePromotion]    WHERE PromotionId = @PromotionId AND PropertyId = @PropertyId;
		DELETE FROM [dbo].[LTY_PointItemWisePromotion]   WHERE PromotionId = @PromotionId AND PropertyId = @PropertyId;
		DELETE FROM [dbo].[LTY_PromotionWisePoint]       WHERE PromotionId = @PromotionId AND PropertyId = @PropertyId;
		DELETE FROM [dbo].[LTY_PromotionWiseCoupon]      WHERE PromotionId = @PromotionId AND PropertyId = @PropertyId;
		DELETE FROM [dbo].[LTY_BuyOneGetOneWisePromotion] WHERE PromotionId = @PromotionId AND PropertyId = @PropertyId;
		DELETE FROM [dbo].[LTY_SegmentWisePromotion]     WHERE PromotionId = @PromotionId AND PropertyId = @PropertyId;

		INSERT INTO [dbo].[LTY_DayWisePromotion] (PromotionId, Days)
		SELECT @PromotionId, CONVERT(VARCHAR(20), [value])
		FROM OPENJSON(@DaysJson)
		WHERE NULLIF(LTRIM(RTRIM([value])), '') IS NOT NULL;

		INSERT INTO [dbo].[LTY_LocationWisePromotion] (PromotionId, LocationCode)
		SELECT @PromotionId, CONVERT(VARCHAR(20), [value])
		FROM OPENJSON(@LocationsJson)
		WHERE NULLIF(LTRIM(RTRIM([value])), '') IS NOT NULL;

		INSERT INTO [dbo].[LTY_PaymentTypeWisePromotion] (PromotionId, PaymentTypeCode)
		SELECT @PromotionId, CONVERT(VARCHAR(20), [value])
		FROM OPENJSON(@PaymentTypesJson)
		WHERE NULLIF(LTRIM(RTRIM([value])), '') IS NOT NULL;

		INSERT INTO [dbo].[LTY_TierWisePromotion] (PromotionId, TierId)
		SELECT @PromotionId, CONVERT(INT, [value])
		FROM OPENJSON(@TiersJson)
		WHERE NULLIF(LTRIM(RTRIM([value])), '') IS NOT NULL;

		-- Each validation mode routes to its own table, selected by ModeCode.
		-- A mode with no block here is ignored; add one per mode as they arrive.
		INSERT INTO [dbo].[LTY_ItemWisePromotion] (PropertyId, PromotionId, ItemId)
		SELECT @PropertyId, @PromotionId, i.Code
		FROM OPENJSON(@ValidationModesJson)
		WITH (
			ModeCode VARCHAR(20)   '$.ModeCode',
			Items    NVARCHAR(MAX) '$.Items' AS JSON
		) AS m
		CROSS APPLY OPENJSON(m.Items)
		WITH (
			Code VARCHAR(20) '$.Code'
		) AS i
		WHERE m.ModeCode = 'ITM'
		  AND NULLIF(LTRIM(RTRIM(i.Code)), '') IS NOT NULL;

		INSERT INTO [dbo].[LTY_CategoryWisePromotion] (PropertyId, PromotionId, CategoryId)
		SELECT @PropertyId, @PromotionId, i.Code
		FROM OPENJSON(@ValidationModesJson)
		WITH (
			ModeCode VARCHAR(20)   '$.ModeCode',
			Items    NVARCHAR(MAX) '$.Items' AS JSON
		) AS m
		CROSS APPLY OPENJSON(m.Items)
		WITH (
			Code VARCHAR(20) '$.Code'
		) AS i
		WHERE m.ModeCode = 'CAT'
		  AND NULLIF(LTRIM(RTRIM(i.Code)), '') IS NOT NULL;

		-- Free item carries its quantity in Value. The mode is single-select, so this
		-- is one row, but shredding the array keeps it working if that ever changes.
		INSERT INTO [dbo].[LTY_FreeItemWisePromotion] (PropertyId, PromotionId, ItemId, FreeQty)
		SELECT @PropertyId, @PromotionId, i.Code, i.Value
		FROM OPENJSON(@ValidationModesJson)
		WITH (
			ModeCode VARCHAR(20)   '$.ModeCode',
			Items    NVARCHAR(MAX) '$.Items' AS JSON
		) AS m
		CROSS APPLY OPENJSON(m.Items)
		WITH (
			Code  VARCHAR(20)   '$.Code',
			Value DECIMAL(18,4) '$.Value'
		) AS i
		WHERE m.ModeCode = 'FREEITEM'
		  AND NULLIF(LTRIM(RTRIM(i.Code)), '') IS NOT NULL;

		-- Point item carries a per-item point count in Value, a required Qty, and an
		-- optional per-item ExpireDayCount. The count is kept and the date computed
		-- from it; both are null when the item has no expiry.
		INSERT INTO [dbo].[LTY_PointItemWisePromotion] (PropertyId, PromotionId, ItemCode, PointCount, ExpireDayCount, ExpireDate, Quantity)
		SELECT
			@PropertyId,
			@PromotionId,
			i.Code,
			i.Value,
			i.ExpireDayCount,
			CASE WHEN i.ExpireDayCount IS NOT NULL
				 THEN DATEADD(DAY, i.ExpireDayCount, GETDATE()) END,
			ISNULL(i.Qty, 0)
		FROM OPENJSON(@ValidationModesJson)
		WITH (
			ModeCode VARCHAR(20)   '$.ModeCode',
			Items    NVARCHAR(MAX) '$.Items' AS JSON
		) AS m
		CROSS APPLY OPENJSON(m.Items)
		WITH (
			Code           VARCHAR(20)   '$.Code',
			Value          DECIMAL(18,4) '$.Value',
			ExpireDayCount INT           '$.ExpireDayCount',
			Qty            INT           '$.Qty'
		) AS i
		WHERE m.ModeCode = 'POINTITEM'
		  AND NULLIF(LTRIM(RTRIM(i.Code)), '') IS NOT NULL;

		-- Promotion wise point has no item list; its values sit on the mode itself,
		-- so there is no nested array to shred.
		INSERT INTO [dbo].[LTY_PromotionWisePoint] (PropertyId, PromotionId, Rate, BaseValueId, Multiplier, ExpireDayCount, ExpireDate)
		SELECT
			@PropertyId,
			@PromotionId,
			m.Rate,
			m.BaseValueId,
			m.Multiplier,
			m.ExpireDayCount,
			CASE WHEN m.ExpireDayCount IS NOT NULL
				 THEN DATEADD(DAY, m.ExpireDayCount, GETDATE()) END
		FROM OPENJSON(@ValidationModesJson)
		WITH (
			ModeCode       VARCHAR(20)   '$.ModeCode',
			Rate           DECIMAL(18,4) '$.Rate',
			BaseValueId    INT           '$.BaseValueId',
			Multiplier     DECIMAL(18,4) '$.Multiplier',
			ExpireDayCount INT           '$.ExpireDayCount'
		) AS m
		WHERE m.ModeCode = 'PROPOINT';

		-- SEGMENT - audience restriction. Like PROPOINT there is no item list, so the
		-- id sits on the mode itself. Only the REFERENCE is stored: the rules and the
		-- membership stay in LTYC_Segment / LTYC_SegmentMember, where the segment
		-- builder maintains them.
		SELECT @SegmentId = m.SegmentId
		FROM OPENJSON(@ValidationModesJson)
		WITH (
			ModeCode  VARCHAR(20) '$.ModeCode',
			SegmentId INT         '$.SegmentId'
		) AS m
		WHERE m.ModeCode = 'SEGMENT';

		IF EXISTS (SELECT 1 FROM OPENJSON(@ValidationModesJson)
				   WITH (ModeCode VARCHAR(20) '$.ModeCode') AS m
				   WHERE m.ModeCode = 'SEGMENT')
		BEGIN
			-- The mode is only worth storing with a segment behind it: without one it
			-- would restrict the promotion to nobody while looking configured.
			IF (@SegmentId IS NULL)
			BEGIN
				RAISERROR('Please select a segment for the Segment validation mode.', 16, 1);
			END

			IF NOT EXISTS (SELECT 1 FROM [dbo].[LTYC_Segment]
						   WHERE SegmentId  = @SegmentId
							 AND PropertyId = @PropertyId
							 AND IsDeleted  = 0)
			BEGIN
				RAISERROR('The selected segment no longer exists.', 16, 1);
			END

			INSERT INTO [dbo].[LTY_SegmentWisePromotion] (PropertyId, PromotionId, SegmentId)
			VALUES (@PropertyId, @PromotionId, @SegmentId);
		END

		-- BOGO. Two shapes are accepted while the portal moves over:
		--
		--   nested (preferred) - one Items entry per main item, owning a FreeItems
		--                        array, so the main item can never arrive twice
		--                        with conflicting counts
		--   flat (legacy)      - one Items entry per main/free pair, with FreeItem
		--                        and FreeItemQty sitting directly on the entry
		--
		-- Storage is the same either way: one row per main/free pair, MainItemQty
		-- repeated across a main item's rows. LTY_GetPromotion groups it back and
		-- always returns the nested shape.
		--
		-- The flat branch is skipped whenever FreeItems has anything in it, so an
		-- entry carrying both cannot be inserted twice. Drop the second branch once
		-- the portal sends nested only.
		INSERT INTO [dbo].[LTY_BuyOneGetOneWisePromotion] (PropertyId, PromotionId, ItemCode, MainItemQty, FreeItemCode, FreeQty)
		SELECT @PropertyId, @PromotionId, src.Code, src.MainItemQty, src.FreeItem, src.FreeItemQty
		FROM (
			-- nested
			SELECT
				Code        = i.Code,
				MainItemQty = i.MainItemQty,
				FreeItem    = f.FreeItem,
				FreeItemQty = f.FreeItemQty
			FROM OPENJSON(@ValidationModesJson)
			WITH (
				ModeCode VARCHAR(20)   '$.ModeCode',
				Items    NVARCHAR(MAX) '$.Items' AS JSON
			) AS m
			CROSS APPLY OPENJSON(m.Items)
			WITH (
				Code        VARCHAR(20)   '$.Code',
				MainItemQty DECIMAL(18,4) '$.MainItemQty',
				FreeItems   NVARCHAR(MAX) '$.FreeItems' AS JSON
			) AS i
			CROSS APPLY OPENJSON(i.FreeItems)
			WITH (
				FreeItem    VARCHAR(20)   '$.FreeItem',
				FreeItemQty DECIMAL(18,4) '$.FreeItemQty'
			) AS f
			WHERE m.ModeCode = 'BOGO'

			UNION ALL

			-- flat, only where the nested array is absent or empty
			SELECT
				Code        = i.Code,
				MainItemQty = i.MainItemQty,
				FreeItem    = i.FreeItem,
				FreeItemQty = i.FreeItemQty
			FROM OPENJSON(@ValidationModesJson)
			WITH (
				ModeCode VARCHAR(20)   '$.ModeCode',
				Items    NVARCHAR(MAX) '$.Items' AS JSON
			) AS m
			CROSS APPLY OPENJSON(m.Items)
			WITH (
				Code        VARCHAR(20)   '$.Code',
				MainItemQty DECIMAL(18,4) '$.MainItemQty',
				FreeItem    VARCHAR(20)   '$.FreeItem',
				FreeItemQty DECIMAL(18,4) '$.FreeItemQty',
				FreeItems   NVARCHAR(MAX) '$.FreeItems' AS JSON
			) AS i
			-- How many entries the nested array holds. CROSS APPLY rather than a
			-- correlated OPENJSON inside EXISTS: passing an outer column to a
			-- table-valued function is what APPLY is for.
			CROSS APPLY (
				SELECT COUNT(1) AS NestedCount
				FROM OPENJSON(ISNULL(NULLIF(i.FreeItems, ''), '[]'))
			) AS fc
			WHERE m.ModeCode = 'BOGO'
			  AND fc.NestedCount = 0
		) AS src
		WHERE NULLIF(LTRIM(RTRIM(src.Code)), '') IS NOT NULL
		  AND NULLIF(LTRIM(RTRIM(src.FreeItem)), '') IS NOT NULL;

		---- COU - Coupon. Only a day count, kept as given with the date computed from it.
		SELECT @CouponExpireDayCount = m.ExpireDayCount
		FROM OPENJSON(@ValidationModesJson)
		WITH (
			ModeCode       VARCHAR(20) '$.ModeCode',
			ExpireDayCount INT         '$.ExpireDayCount'
		) AS m
		WHERE m.ModeCode = 'COU';

		IF (@CouponExpireDayCount IS NOT NULL)
		BEGIN
			INSERT INTO [dbo].[LTY_PromotionWiseCoupon] (PropertyId, PromotionId, ExpireDayCount, ExipireDate)
			VALUES (@PropertyId, @PromotionId, @CouponExpireDayCount,
					DATEADD(DAY, @CouponExpireDayCount, GETDATE()));
		END

		COMMIT TRANSACTION;

		SELECT @PromotionId AS PromotionId;

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

