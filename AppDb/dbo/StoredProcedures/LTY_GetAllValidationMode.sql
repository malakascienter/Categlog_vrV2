-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-04
-- Description:	Get Validation Mode 
-- =============================================

CREATE   PROCEDURE [dbo].[LTY_GetAllValidationMode]
	@PropertyId INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		Id,
		Code,
		Description,
		IsDiscount,
		IsPointCount,
		IsMultipleSelection,
		IsActive,
		PropertyId
	FROM [dbo].[LTY_ValidationModes]
	WHERE PropertyId = @PropertyId
	  AND IsActive   = 1
	ORDER BY Description;
END

GO

