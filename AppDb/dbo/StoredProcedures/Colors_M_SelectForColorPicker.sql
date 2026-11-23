create PROCEDURE [dbo].[Colors_M_SelectForColorPicker]
AS
BEGIN
	SELECT *
	FROM Colors
	WHERE IsActive = 1
END

GO

