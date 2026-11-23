
-- =============================================
-- Author:		<Dilshan>
-- Create date: <2025-07-17>
-- Description:	Returns 1 if the item is final (i.e., has no children in MainMenu)
-- =============================================
CREATE FUNCTION [dbo].[IsExistsPreviousMenuItems] 
(
    @MenuCode VARCHAR(20),
    @PropertyId INT
)
RETURNS BIT
AS
BEGIN
    RETURN 
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM MainMenu WITH (NOLOCK) 
            WHERE PreviousMenuCode = @MenuCode AND PropertyId = @PropertyId AND IsScanDineItem = 1
        ) 
        THEN 1
        ELSE 0 
    END
END

GO

