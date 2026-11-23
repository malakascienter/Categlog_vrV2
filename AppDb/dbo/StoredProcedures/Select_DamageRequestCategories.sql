-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-09-22
-- Description:	Loading Damage Request Categories
-- Select_DamageRequestCategories 1
-- =============================================
create PROCEDURE [dbo].[Select_DamageRequestCategories]
@PropertyID INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT  ID as id, Name as text
	FROM     DamageRequestCategories
	WHERE CompanyId = @PropertyID
	AND IsActive=1
  
END

GO

