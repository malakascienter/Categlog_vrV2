
CREATE PROCEDURE [dbo].[ComboItemBreakDown_M_Select]
    @MainMenuCode CHAR(4)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        C.mainmenucode,
        C.subItemcode,
        M.Description,
        ISNULL(DefaultAlternative.Qty, 1) AS Qty
    FROM ComboItemBreakDown AS C
    INNER JOIN MainMenu AS M
        ON M.ItemCode = C.subItemcode
    LEFT JOIN MenuItemWiseAlternatives AS DefaultAlternative
        ON DefaultAlternative.MainMenuCode = C.mainmenucode
       AND DefaultAlternative.MenuCode = C.subItemcode
       AND DefaultAlternative.AlternateMenuCode = C.subItemcode
       AND DefaultAlternative.ActionButtonID = 5
    WHERE C.mainmenucode = @MainMenuCode
END

GO

