-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-05
-- Description:	Get Active Payment Types by PropertyId
-- =============================================
CREATE   PROCEDURE [dbo].[LTY_GetAllPaymentType]
	@PropertyId INT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		SELECT PayCode, Description
		FROM [dbo].[PaymentTypes]
		WHERE Active     = 1
		  AND PropertyId = @PropertyId;

	END TRY
	BEGIN CATCH

		DECLARE @ErrMsg   NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrSev   INT            = ERROR_SEVERITY();
		DECLARE @ErrState INT            = ERROR_STATE();

		RAISERROR(@ErrMsg, @ErrSev, @ErrState);

	END CATCH
END

GO

