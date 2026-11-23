-- =============================================
-- Author:		Ravindu
-- Create date: 2026-01-08
-- Description:	Production common settings
--  [dbo].[SP_ProductionSetting]1
-- =============================================
CREATE PROCEDURE [dbo].[SP_ProductionSetting]
(
  @CompanyId INT
)
	
AS
BEGIN
	SELECT ISNULL(PS.IsRecipeMaintainLocation,0) AS IsRecipeMaintainLocation,
	ISNULL(PS.IsProductionOutQty,0) AS IsProductionOutQty
	FROM ProductionSetting AS PS 
	WHERE PS.CompanyId = @CompanyId
END

GO

