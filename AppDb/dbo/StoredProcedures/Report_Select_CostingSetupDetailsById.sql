-- =============================================
-- Author:		chiraj
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--Report_Select_CostingSetupDetails 2
CREATE PROCEDURE [dbo].[Report_Select_CostingSetupDetailsById] 
	@PropertyId Int,
	@Id INT
AS
BEGIN
	
	SET NOCOUNT ON;
SELECT [Id]
      ,[CostingName]
      ,[Percentage]
      ,[Active]
      ,[PropertyId]
      ,[CreatedUserId]
      ,[CreatedDateTime]
      ,[LastEditedUserId]
      ,[LastEditedDateTime]
  FROM [dbo].[CostingSetting] WHERE PropertyId=@PropertyId AND Id = @Id 
END

GO

