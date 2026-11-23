
------------------------------------------------------------------------------
-- LTY_DeletePromotion
------------------------------------------------------------------------------
-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-05
-- Description:	Delete Promotion by PromotionId and PropertyId, including every
--              mapping table.
--
--              2026-08-17: the COU mode's row in LTY_PromotionWiseCoupon is removed
--              with the rest of the promotion's children.
--
--              2026-08-18: the BOGO mode's rows in LTY_BuyOneGetOneWisePromotion go
--              the same way.
--
--              2026-08-19: the SEGMENT mode's row in LTY_SegmentWisePromotion goes
--              with it. Only the reference - the segment stays.
--
--              2026-08-17: the "points have been earned" guard was dropped. Deleting
--              a promotion does not touch LTY_MemberWisePointTransaction, so past
--              transactions keep their points and their remark text.
-- =============================================
-- EXEC [dbo].[LTY_DeletePromotion] @PromotionId = 1, @PropertyId = 1
CREATE   PROCEDURE [dbo].[LTY_DeletePromotion]
	@PromotionId INT,
	@PropertyId INT
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	BEGIN TRY

		BEGIN TRANSACTION;

		-- Tenancy check up front. The day/location/payment type/tier tables carry no
		-- PropertyId, so this is what stops another property's promotion being
		-- deleted through them.
		IF NOT EXISTS (SELECT 1 FROM [dbo].[LTY_Promotion]
					   WHERE PromotionId = @PromotionId
						 AND PropertyId  = @PropertyId)
		BEGIN
			RAISERROR('The promotion no longer exists.', 16, 1);
		END

		-- Children first, or the foreign keys block the parent delete.
		DELETE FROM [dbo].[LTY_DayWisePromotion]         WHERE PromotionId = @PromotionId;
		DELETE FROM [dbo].[LTY_LocationWisePromotion]    WHERE PromotionId = @PromotionId;
		DELETE FROM [dbo].[LTY_PaymentTypeWisePromotion] WHERE PromotionId = @PromotionId;
		DELETE FROM [dbo].[LTY_TierWisePromotion]        WHERE PromotionId = @PromotionId;

		-- Validation mode sets, one table per mode.
		DELETE FROM [dbo].[LTY_ItemWisePromotion]      WHERE PromotionId = @PromotionId AND PropertyId = @PropertyId;
		DELETE FROM [dbo].[LTY_CategoryWisePromotion]  WHERE PromotionId = @PromotionId AND PropertyId = @PropertyId;
		DELETE FROM [dbo].[LTY_FreeItemWisePromotion]  WHERE PromotionId = @PromotionId AND PropertyId = @PropertyId;
		DELETE FROM [dbo].[LTY_PointItemWisePromotion] WHERE PromotionId = @PromotionId AND PropertyId = @PropertyId;
		DELETE FROM [dbo].[LTY_PromotionWisePoint]     WHERE PromotionId = @PromotionId AND PropertyId = @PropertyId;

		DELETE FROM [dbo].[LTY_PromotionWiseCoupon]    WHERE PromotionId = @PromotionId AND PropertyId = @PropertyId;
		DELETE FROM [dbo].[LTY_BuyOneGetOneWisePromotion] WHERE PromotionId = @PromotionId AND PropertyId = @PropertyId;

		-- The SEGMENT mode's reference only. The segment itself, its rules and its
		-- membership belong to the segment builder and are left alone - deleting a
		-- promotion must not delete an audience other promotions may also use.
		DELETE FROM [dbo].[LTY_SegmentWisePromotion]   WHERE PromotionId = @PromotionId AND PropertyId = @PropertyId;

		-- Legacy table, no longer written to. Remove this line when you drop it.
		DELETE FROM [dbo].[LTY_ValidationModeWisePromotion] WHERE PromotionId = @PromotionId;

		DELETE FROM [dbo].[LTY_Promotion]
		WHERE PromotionId = @PromotionId
		  AND PropertyId  = @PropertyId;

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

