-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-06
-- Description:	Record a promotion's uploaded image path. Called after insert, once the
--              new PromotionId is known and the file has been written.
-- =============================================
CREATE   PROCEDURE [dbo].[LTY_UpdatePromotionImage]
	@PromotionId INT,
	@PropertyId INT,
	@ImageURL NVARCHAR(MAX) = NULL,
	@IsUploadImage BIT = 0
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		UPDATE [dbo].[LTY_Promotion]
		SET ImageURL      = @ImageURL,
			IsUploadImage = @IsUploadImage
		WHERE PromotionId = @PromotionId
		  AND PropertyId  = @PropertyId;

		SELECT @PromotionId AS PromotionId;

	END TRY
	BEGIN CATCH

		DECLARE @ErrMsg   NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrSev   INT            = ERROR_SEVERITY();
		DECLARE @ErrState INT            = ERROR_STATE();

		RAISERROR(@ErrMsg, @ErrSev, @ErrState);

	END CATCH
END

GO

