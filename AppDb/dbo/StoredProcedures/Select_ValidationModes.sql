
-- =============================================
-- Author:		chiraj	
-- Create date: 2020-06-2
-- Description:	Select_DiscountTypes

-- Select_ValidationModes 1

-- =============================================
CREATE PROCEDURE [dbo].[Select_ValidationModes]
	@PropertyId INT
AS
BEGIN
	
	SET NOCOUNT ON;
	SELECT DISTINCT * FROM [dbo].[ValidationModes] WHERE PropertyId=1 AND IsActive = 1
END

GO

