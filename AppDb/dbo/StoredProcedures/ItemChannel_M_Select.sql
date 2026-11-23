-- =============================================
-- Author:		Chamathka Sooriyapala
-- Create date: 2021-07-02
-- Description:	Select Order Types
-- =============================================
CREATE PROCEDURE [dbo].[ItemChannel_M_Select] 
	@PropertyId INT 
AS
BEGIN
	SELECT	*
	FROM	ItemChannel
	WHERE	PropertyId = @PropertyId
END

GO

