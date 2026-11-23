-- =============================================
-- Author:		Nivesh
-- Create date: 2023-12-11
-- Description:	Get all payment types
-- =============================================
--GetAllPaymentTypes

CREATE PROCEDURE [dbo].[GetAllPaymentTypes] 
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
	SET NOCOUNT ON;
	SELECT DISTINCT 
	Id,
	PayCode,
	Description,
	active ,
	SortOrder,
	Remarks,
	IsNeedPermission,
	DrawerOpen,
	IsECR,
	ISNULL(IsReturnCoupon,0) IsReturnCoupon,
	CreatedUserId,
	CreatedDateTime,
	UpdatedUserId,
	UpdatedDateTime,
	ISNULL(IsCreditCard,0) IsCreditCard,
	ISNULL(IsCredit,0) IsCredit
	FROM paymenttypes
	
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
		ROLLBACK TRANSACTION
	
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
       
    END CATCH
END;

GO

