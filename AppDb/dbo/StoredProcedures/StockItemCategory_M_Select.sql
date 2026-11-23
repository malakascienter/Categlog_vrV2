-- =============================================
-- Author:		Chiraj
-- Create date: 2020-10-
-- Description:	<Description,,>
-- =============================================
--StockItemCategory_M_Select 2
CREATE PROCEDURE [dbo].[StockItemCategory_M_Select] 
	@PropertyId INT
AS
BEGIN	
	SET NOCOUNT ON;
	SELECT Id,DepartmentId,Code,Name,IsActive,CompanyId FROM Categories
	WHERE IsActive=1 --AND CompanyId=@PropertyId
END

GO

