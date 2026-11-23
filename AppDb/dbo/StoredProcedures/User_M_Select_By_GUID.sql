-- =============================================
-- Author:		Yasiru
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[User_M_Select_By_GUID]
@GUID		Nvarchar(500)
AS
BEGIN	
	SET NOCOUNT ON;

	SELECT *
	FROM Users U
	WHERE U.Guid = @GUID 

END

GO

