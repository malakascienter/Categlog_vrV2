

-- =============================================
-- Author:		Banu
-- Create date: 12/10/2018
-- Description:	Select All Menu Item Alternatives
-- =============================================
CREATE PROCEDURE [dbo].[AlternativeMenuItem_M_Select] 	 
AS
BEGIN
	 
	SET NOCOUNT OFF;

    -- Insert statements for procedure here
	SELECT * FROM MenuItemWiseAlternatives
END

GO

