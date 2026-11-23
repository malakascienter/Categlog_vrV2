-- =============================================
-- Author:		chiraj
-- Create date: 2020-05-9
-- Description:	select Backend Mode
-- =============================================
CREATE PROCEDURE [dbo].[Select_Backend_Mode]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   select QSRMode from BackendSettings
END

GO

