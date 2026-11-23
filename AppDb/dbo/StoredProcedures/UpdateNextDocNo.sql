-- =============================================
-- Author:		Sachith
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UpdateNextDocNo]
	@Code VARCHAR(MAX),
	@PropertyId INT
AS
BEGIN
	
	UPDATE [dbo].[DocumentNumbers]
	SET [NextNo] = [NextNo]+1
	WHERE Code = @Code AND PropertyId = @PropertyId

END

GO

