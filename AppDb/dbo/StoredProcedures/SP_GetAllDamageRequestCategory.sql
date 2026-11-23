-- =============================================
-- Author:		Ravindu
-- Create date: 2025-09-22
-- Description:	Get Damage Reuest Catrgory by company id
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetAllDamageRequestCategory]
      @CompanyId INT
	
AS
BEGIN
    SELECT DRC.ID,DRC.Name,DRC.IsActive FROM DamageRequestCategories DRC WHERE DRC.CompanyId = @CompanyId ORDER BY DRC.ID DESC;
END

GO

