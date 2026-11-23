

-- =============================================
-- Author:		Yasiru	
-- Create date: 2017/12/11
-- Description:	Select AlertTypes by Id
-- =============================================
CREATE PROCEDURE [dbo].[Products_M_Select_ById] 
@Id		INT
AS
BEGIN
	SET NOCOUNT ON;
	SELECT *
	FROM Products 
	WHERE Id = @Id
END

GO

