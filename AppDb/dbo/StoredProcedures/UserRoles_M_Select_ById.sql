 -- =============================================
-- Author:		Yasiru
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UserRoles_M_Select_ById]
@Id       INT,
@PropertyId INT 
AS
BEGIN	
	SET NOCOUNT ON;

	SELECT * FROM UserRoles UR
	WHERE Id = @Id AND PropertyId=@PropertyId

END

GO

