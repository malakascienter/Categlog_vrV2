-- =============================================
-- Author:		ISURU PRAMODYA
-- Create date: 28 JULY 2023
-- Description:	SELECT SP FROM POReportTypes
-- [dbo].[SelectPOReportTypes] -999
-- =============================================
CREATE PROCEDURE  [dbo].[SelectPOReportTypes]
	@ID INT
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT '-999' AS ID, '--All--' AS Name, 'A' as Code

	UNION ALL

	SELECT ID,Name,Code
	FROM [dbo].[POReportTypes]
	WHERE ID =  CASE WHEN @ID=-999 THEN ID ELSE @ID END
	AND IsActive=1 
END

GO

