
-- =============================================
-- Author:		chiraj
-- Create date: 2020-09-29
-- Description:	CostingSetting_M_Select_byId
-- =============================================
CREATE PROCEDURE [dbo].[CostingSetting_M_Select_byId]
	@Id iNT,
	@PropertyId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT * FROM [dbo].[CostingSetting] WHERE Id=@Id AND PropertyId=@PropertyId 
  
END

GO

