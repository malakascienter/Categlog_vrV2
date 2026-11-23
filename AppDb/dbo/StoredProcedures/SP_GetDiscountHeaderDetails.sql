-- =============================================
-- Author:		<Nivesh>
-- Create date: <2023-12-13>
-- Description:	<Get all Discount Header Details>
-- =============================================
--SP_GetDiscountHeaderDetails
CREATE PROCEDURE [dbo].[SP_GetDiscountHeaderDetails] (@PropertyID int) 
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;
		SELECT DISTINCT 
		Id,
		Code,
		Description,
		IsActive
		FROM
		DiscountHeader where PropertyId = @PropertyID
		COMMIT TRANSACTION;
	END TRY 
	BEGIN CATCH
		ROLLBACK TRANSACTION;	
	END CATCH;
END

GO

