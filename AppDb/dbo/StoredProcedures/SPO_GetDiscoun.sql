-- =============================================
-- Author:		Ravindu
-- Create date: 2026-04-05
-- Description:	Get Discount
-- =============================================
-- EXEC SPO_GetDiscoun
CREATE   PROCEDURE [dbo].[SPO_GetDiscoun]
	@PropertyId INT  NULL,
	@LocationId INT  NULL,
	@IsItemWiseDiscount BIT NULL
AS
BEGIN
	SELECT Id,Description AS Name ,
	CASE WHEN IsPercentage = 1 THEN Percentage ELSE DiscountValue END AS Value,
	CASE WHEN IsPercentage = 1 THEN 'percentage' ELSE 'fixed' END AS Type,
	0 AS isCustom
	FROM DiscountHeader
	WHERE ValidationMode NOT IN ('CUSV','CUSP') AND IsActive = 1
	UNION
	SELECT Id,Description AS Name ,
	CASE WHEN IsPercentage = 1 THEN Percentage ELSE DiscountValue END AS Value,
	CASE WHEN IsPercentage = 1 THEN 'percentage' ELSE 'fixed' END AS Type,
	1 AS isCustom
	FROM DiscountHeader
	WHERE ValidationMode IN ('CUSV','CUSP') AND IsActive = 1
END

GO

