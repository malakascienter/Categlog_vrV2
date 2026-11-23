

-- =============================================
-- Author:		Chiraj
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SelectMainMenu_ByMofiers 
@PropertyId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
SELECT *,FullName as 'LongName' From MainMenu 
Where IsModifier = 1 AND PropertyId=@PropertyId
END

GO

