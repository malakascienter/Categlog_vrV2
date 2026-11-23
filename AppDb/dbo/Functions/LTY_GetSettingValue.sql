-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-04
-- Description:	Get Setting Value by Id and PropertyId
-- =============================================
CREATE   FUNCTION [dbo].[LTY_GetSettingValue]
(
	@Id INT,
	@PropertyId INT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @Value NVARCHAR(MAX);

	SELECT @Value = [Value]
	FROM [dbo].[LTY_Settings]
	WHERE Id = @Id
	  AND PropertyId = @PropertyId;

	RETURN @Value;
END

GO

