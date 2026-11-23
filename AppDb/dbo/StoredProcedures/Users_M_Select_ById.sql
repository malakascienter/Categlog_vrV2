
-- =============================================
-- Author:		Yasiru	
-- Create date: 2017/12/11
-- Description:	Select AlertTypes by Id
-- =============================================
CREATE PROCEDURE [dbo].[Users_M_Select_ById] 
@Id		INT,
@PropertyId INT
AS
BEGIN
	SET NOCOUNT ON;
	SELECT *
	FROM Users 
	WHERE Id = @Id AND PropertyId=@PropertyId
END

GO

