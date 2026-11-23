
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SelectMainMenu_ByCode] 
@Code NVARCHAR(5),
@PropertyId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
SELECT *,FullName as 'LongName',Description as ItemName  From MainMenu 
Where ItemCode = @Code AND PropertyId=@PropertyId
END

GO

