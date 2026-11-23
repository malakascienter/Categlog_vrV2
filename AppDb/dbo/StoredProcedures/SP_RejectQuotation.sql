-- =============================================
-- Author:		Ravindu
-- Create date:2025-12-1
-- Description:  Reject Quotation
-- =============================================
-- [dbo].[SP_RejectQuotation] 15,"test", 4168
CREATE PROCEDURE [dbo].[SP_RejectQuotation] 
(
	@QuotationRequestId INT,
	@RejectReason VARCHAR(MAX),
	@RejectUserId INT,
	@Result INT OUTPUT
)
	
AS
BEGIN
    SET NOCOUNT ON;

	BEGIN TRY
		UPDATE QuotationRequestHeader SET 
			Status = 'X',
			RejectedUser = @RejectUserId,
			RejectedDate = GETDATE(),
			RejectedReason = @RejectReason
		WHERE Id = @QuotationRequestId;

		UPDATE RH
			SET RH.QuotationStatus = 'X'
			FROM RequestHeaders RH
		INNER JOIN QuotationRequestHeader QH ON RH.Id = QH.PurchaseRequestID
		WHERE QH.Id = @QuotationRequestId;
		
		SET @Result = 1;
	END TRY
	BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
       SET @Result = -1;
    END CATCH
END

GO

