-- =============================================
-- Author:		chiraj	
-- Create date: 2020-06-2
-- Description:	Select_DiscountTypes
-- =============================================
CREATE PROCEDURE [dbo].[Select_DiscountTypes] 
	@PropertyId INT
AS
BEGIN
	
	SET NOCOUNT ON;
	SELECT * FROM DiscountTypes  WHERE PropertyID=@PropertyId
END

GO

