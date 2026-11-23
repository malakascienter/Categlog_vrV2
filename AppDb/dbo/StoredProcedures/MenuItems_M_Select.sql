-- =============================================
-- Author:		Chiraj
-- Create date: 2019-8-7
-- Description:	MenuItems_M_Select
-- =============================================
CREATE PROCEDURE [dbo].[MenuItems_M_Select] 
@PropertyId INT
AS
BEGIN
	SET NOCOUNT ON;
	SELECT
	RTRIM(LTRIM(ItemCode)) AS ItemCode
      ,Description
      ,ApperOnInv      
      ,Active      
  FROM MainMenu where Active=1 AND discountNotApplicable=0 AND PropertyId=@PropertyId
   
END

GO

