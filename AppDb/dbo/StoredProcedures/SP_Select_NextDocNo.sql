-- =============================================
-- Author:		Sachith
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Select_NextDocNo]
	@FileType VARCHAR(MAX),
	@PropertyId INT
AS
BEGIN
	
	SELECT [dbo].[GetNextDocNo](@FileType,@PropertyId) AS DocumentNo

END

GO

