
-- =============================================
-- Author:		Yasiru
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Products_M_Select]
@IsActive       INT = 2
AS
BEGIN	
	SET NOCOUNT ON;

	SELECT * FROM Products UR
	WHERE(@IsActive = 2 OR @IsActive = UR.IsActive)

END

GO

