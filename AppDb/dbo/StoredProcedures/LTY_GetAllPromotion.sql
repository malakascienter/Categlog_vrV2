-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-05
-- Description:	Get All Promotions by PropertyId, optional IsActive filter.
-- =============================================
-- EXEC [dbo].[LTY_GetAllPromotion] @PropertyId = 1, @IsActive = 1
CREATE     PROCEDURE [dbo].[LTY_GetAllPromotion]
	@PropertyId INT,
	@IsActive BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		SELECT
			PromotionId,
			PromotionName,
			Description,
			PropertyId,
			StartDate,
			EndDate,
			CONVERT(VARCHAR(8), StartTime, 108) AS StartTime,
			CONVERT(VARCHAR(8), EndTime, 108)   AS EndTime,
			IsActive,
			MinBillAmount,
			IsDiscountPercentage,
			Discount,
			CreatedBy,
			CreatedDate,
			ModifyBy,
			ModifyDate,
			MaxBillAmount
		FROM [dbo].[LTY_Promotion]
		WHERE PropertyId = @PropertyId
		  AND (@IsActive IS NULL OR IsActive = @IsActive)
		ORDER BY PromotionId DESC;

	END TRY
	BEGIN CATCH

		DECLARE @ErrMsg   NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrSev   INT            = ERROR_SEVERITY();
		DECLARE @ErrState INT            = ERROR_STATE();

		RAISERROR(@ErrMsg, @ErrSev, @ErrState);

	END CATCH
END

GO

