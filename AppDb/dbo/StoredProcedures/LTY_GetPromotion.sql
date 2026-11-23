
------------------------------------------------------------------------------
-- LTY_GetPromotion
------------------------------------------------------------------------------
-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-05
-- Description:	Get Single Promotion by PromotionId and PropertyId, returned as one
--              JSON document. Each validation mode is read from its own table and
--              returned in the shape LTY_SavePromotion accepts.
--
--              2026-08-17: IsBirthdayDate / IsBirthdayMonth added, and POINTITEM,
--              PROPOINT and COU now return the ExpireDayCount that was configured
--              rather than a date derived from it. ExpireDate is still returned
--              alongside for anything that wants the resolved value.
--
--              2026-08-18: IsNewMember / NewMemberDayCount returned as stored,
--              including NULL when the promotion never set them.
--
--              2026-08-19: SEGMENT returns the id of the segment it references, as
--              SegmentId on the mode entry - a scalar mode, like PROPOINT. The name
--              is not returned: the edit screen already loads the segment list for
--              the dropdown and names the id from it, the same way every other
--              saved code is named.
-- =============================================
-- EXEC [dbo].[LTY_GetPromotion] @PromotionId = 13, @PropertyId = 1
CREATE   PROCEDURE [dbo].[LTY_GetPromotion]
	@PromotionId INT,
	@PropertyId INT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		DECLARE @Json NVARCHAR(MAX);
		DECLARE @Modes NVARCHAR(MAX);

		SELECT @Modes = ISNULL((
			SELECT
				x.ModeCode,
				vm.Description AS ModeDescription,
				JSON_QUERY(ISNULL(x.Items, '[]')) AS Items,
				x.Rate,
				x.BaseValueId,
				x.Multiplier,
				x.ExpireDate,
				x.ExpireDayCount,
				x.SegmentId
			FROM
			(
				SELECT
					'ITM' AS ModeCode,
					(SELECT i.ItemId AS Code
					 FROM [dbo].[LTY_ItemWisePromotion] AS i
					 WHERE i.PromotionId = @PromotionId AND i.PropertyId = @PropertyId
					 FOR JSON PATH) AS Items,
					CONVERT(DECIMAL(18,4), NULL) AS Rate,
					CONVERT(INT, NULL)           AS BaseValueId,
					CONVERT(DECIMAL(18,4), NULL) AS Multiplier,
					CONVERT(DATE, NULL)          AS ExpireDate,
					CONVERT(INT, NULL)           AS ExpireDayCount,
					CONVERT(INT, NULL)           AS SegmentId
				WHERE EXISTS (SELECT 1 FROM [dbo].[LTY_ItemWisePromotion]
							  WHERE PromotionId = @PromotionId AND PropertyId = @PropertyId)

				UNION ALL

				SELECT
					'CAT',
					(SELECT c.CategoryId AS Code
					 FROM [dbo].[LTY_CategoryWisePromotion] AS c
					 WHERE c.PromotionId = @PromotionId AND c.PropertyId = @PropertyId
					 FOR JSON PATH),
					NULL, NULL, NULL, NULL, NULL, NULL
				WHERE EXISTS (SELECT 1 FROM [dbo].[LTY_CategoryWisePromotion]
							  WHERE PromotionId = @PromotionId AND PropertyId = @PropertyId)

				UNION ALL

				SELECT
					'FREEITEM',
					(SELECT f.ItemId AS Code, f.FreeQty AS Value
					 FROM [dbo].[LTY_FreeItemWisePromotion] AS f
					 WHERE f.PromotionId = @PromotionId AND f.PropertyId = @PropertyId
					 FOR JSON PATH, INCLUDE_NULL_VALUES),
					NULL, NULL, NULL, NULL, NULL, NULL
				WHERE EXISTS (SELECT 1 FROM [dbo].[LTY_FreeItemWisePromotion]
							  WHERE PromotionId = @PromotionId AND PropertyId = @PropertyId)

				UNION ALL

				-- Per-item expiry: the day count is what the screen edits, the date is
				-- what it resolved to.
				SELECT
					'POINTITEM',
					(SELECT
						pi.ItemCode       AS Code,
						pi.PointCount     AS Value,
						pi.Quantity       AS Qty,
						pi.ExpireDayCount AS ExpireDayCount,
						pi.ExpireDate     AS ExpireDate
					 FROM [dbo].[LTY_PointItemWisePromotion] AS pi
					 WHERE pi.PromotionId = @PromotionId AND pi.PropertyId = @PropertyId
					 FOR JSON PATH, INCLUDE_NULL_VALUES),
					NULL, NULL, NULL, NULL, NULL, NULL
				WHERE EXISTS (SELECT 1 FROM [dbo].[LTY_PointItemWisePromotion]
							  WHERE PromotionId = @PromotionId AND PropertyId = @PropertyId)

				UNION ALL

				-- No item list: the values sit on the mode itself.
				SELECT
					'PROPOINT',
					NULL,
					pw.Rate,
					pw.BaseValueId,
					pw.Multiplier,
					pw.ExpireDate,
					pw.ExpireDayCount,
					NULL
				FROM [dbo].[LTY_PromotionWisePoint] AS pw
				WHERE pw.PromotionId = @PromotionId AND pw.PropertyId = @PropertyId

				UNION ALL

				-- Coupon: no item list either, only the expiry window.
				SELECT
					'COU',
					NULL,
					NULL, NULL, NULL,
					CONVERT(DATE, pc.ExipireDate),
					pc.ExpireDayCount,
					NULL
				FROM [dbo].[LTY_PromotionWiseCoupon] AS pc
				WHERE pc.PromotionId = @PromotionId AND pc.PropertyId = @PropertyId

				UNION ALL

				-- Segment: a reference to a segment authored in the segment builder.
				-- No item list, so the id sits on the mode itself. The segment's rules
				-- and membership are not copied here - LTYC_Segment owns them.
				SELECT
					'SEGMENT',
					NULL,
					NULL, NULL, NULL, NULL, NULL,
					sw.SegmentId
				FROM [dbo].[LTY_SegmentWisePromotion] AS sw
				WHERE sw.PromotionId = @PromotionId AND sw.PropertyId = @PropertyId

				UNION ALL

				-- BuyOneGetOne: stored one row per main/free pair, returned nested -
				-- the main item once, with its count and the array of free items it
				-- earns. This is the shape LTY_SavePromotion accepts back.
				SELECT
					'BOGO',
					(SELECT
						d.ItemCode    AS Code,
						d.MainItemQty AS MainItemQty,
						FreeItems = JSON_QUERY(ISNULL((
							SELECT
								f.FreeItemCode AS FreeItem,
								f.FreeQty      AS FreeItemQty
							FROM [dbo].[LTY_BuyOneGetOneWisePromotion] AS f
							WHERE f.PromotionId = @PromotionId
							  AND f.PropertyId  = @PropertyId
							  AND f.ItemCode    = d.ItemCode
							ORDER BY f.FreeItemCode
							FOR JSON PATH, INCLUDE_NULL_VALUES), '[]'))
					 FROM (
						-- One entry per main item. MainItemQty is the same across a
						-- main item's rows, so MAX just picks it up.
						SELECT ItemCode, MAX(MainItemQty) AS MainItemQty
						FROM [dbo].[LTY_BuyOneGetOneWisePromotion]
						WHERE PromotionId = @PromotionId AND PropertyId = @PropertyId
						GROUP BY ItemCode
					 ) AS d
					 ORDER BY d.ItemCode
					 FOR JSON PATH, INCLUDE_NULL_VALUES),
					NULL, NULL, NULL, NULL, NULL, NULL
				WHERE EXISTS (SELECT 1 FROM [dbo].[LTY_BuyOneGetOneWisePromotion]
							  WHERE PromotionId = @PromotionId AND PropertyId = @PropertyId)
			) AS x
			LEFT JOIN [dbo].[LTY_ValidationModes] AS vm
				ON vm.Code       = x.ModeCode
			   AND vm.PropertyId = @PropertyId
			FOR JSON PATH
		), '[]');

		SELECT @Json =
		(
			SELECT
				p.PromotionId,
				p.PromotionName,
				p.Description,
				p.PropertyId,
				p.StartDate,
				p.EndDate,
				CONVERT(VARCHAR(8), p.StartTime, 108) AS StartTime,
				CONVERT(VARCHAR(8), p.EndTime, 108)   AS EndTime,
				p.IsActive,
				p.IsBirthdayDate,
				p.IsBirthdayMonth,
				p.IsNewMember,
				p.NewMemberDayCount,
				p.MinBillAmount,
				p.MaxBillAmount,
				p.IsDiscountPercentage,
				p.Discount,
				p.CreatedBy,
				p.CreatedDate,
				p.ModifyBy,
				p.ModifyDate,
				p.ImageURL,
				p.IsUploadImage,

				-- Days have no reference table, so this stays a plain string array.
				JSON_QUERY(ISNULL((
					SELECT '[' + STRING_AGG('"' + STRING_ESCAPE(d.Days, 'json') + '"', ',') + ']'
					FROM [dbo].[LTY_DayWisePromotion] AS d
					WHERE d.PromotionId = p.PromotionId
				), '[]')) AS Days,

				JSON_QUERY(ISNULL((
					SELECT
						l.LocationCode AS Code,
						lr.Description AS Description
					FROM [dbo].[LTY_LocationWisePromotion] AS l
					LEFT JOIN [dbo].[Location_Ref] AS lr
						ON lr.Code       = l.LocationCode
					   AND lr.PropertyId = p.PropertyId
					WHERE l.PromotionId = p.PromotionId
					FOR JSON PATH, INCLUDE_NULL_VALUES
				), '[]')) AS Locations,

				JSON_QUERY(ISNULL((
					SELECT
						t.PaymentTypeCode AS Code,
						pt.Description    AS Description
					FROM [dbo].[LTY_PaymentTypeWisePromotion] AS t
					LEFT JOIN [dbo].[PaymentTypes] AS pt
						ON pt.PayCode    = t.PaymentTypeCode
					   AND pt.PropertyId = p.PropertyId
					WHERE t.PromotionId = p.PromotionId
					FOR JSON PATH, INCLUDE_NULL_VALUES
				), '[]')) AS PaymentTypes,

				JSON_QUERY(ISNULL((
					SELECT
						r.TierId    AS TierId,
						tr.TierName AS TierName
					FROM [dbo].[LTY_TierWisePromotion] AS r
					LEFT JOIN [dbo].[LTY_Tier] AS tr
						ON tr.TierId     = r.TierId
					   AND tr.PropertyId = p.PropertyId
					WHERE r.PromotionId = p.PromotionId
					FOR JSON PATH, INCLUDE_NULL_VALUES
				), '[]')) AS Tiers,

				JSON_QUERY(@Modes) AS ValidationModes

			FROM [dbo].[LTY_Promotion] AS p
			WHERE p.PromotionId = @PromotionId
			  AND p.PropertyId  = @PropertyId
			FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
		);

		SELECT @Json AS PromotionJson;

	END TRY
	BEGIN CATCH

		DECLARE @ErrMsg   NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrSev   INT            = ERROR_SEVERITY();
		DECLARE @ErrState INT            = ERROR_STATE();

		RAISERROR(@ErrMsg, @ErrSev, @ErrState);

	END CATCH
END

GO

