-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SP_GetItemWastageType
	@PropertyId INT
AS
BEGIN

	SET NOCOUNT ON;

	SELECT * FROM [ItemWastageType]

END

GO

