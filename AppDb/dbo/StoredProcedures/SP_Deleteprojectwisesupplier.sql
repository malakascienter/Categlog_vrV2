
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SP_Deleteprojectwisesupplier
	-- Add the parameters for the stored procedure here
	@Id INT
AS
BEGIN
	
	DELETE FROM dbo.ProjectWiseSupplierPrices WHERE Id=@Id

	

END

GO

