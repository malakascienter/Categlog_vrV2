 -- =============================================
-- Author:		Yasiru
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[POS_KioskMenuCategory_M_Select_ById]
@CategoryID INT
AS
BEGIN	
	SET NOCOUNT ON;

	SELECT * FROM POS_KioskMenuCategory UR
	WHERE CategoryID = @CategoryID 

END

GO

