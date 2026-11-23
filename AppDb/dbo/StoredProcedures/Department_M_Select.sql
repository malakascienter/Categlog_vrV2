-- =============================================
-- Author:		Chiraj
-- Create date: 2020-09-30
-- Description:	select departmrnts
-- =============================================
CREATE PROCEDURE [dbo].[Department_M_Select]
	@PropertyId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT  [Id]
      ,[LocationID]
      ,[Code]
      ,[Name]
      ,[IsApplyForFO]
      ,[IsApplyForInv]
      ,[IsApplyForBan]
      ,[IsActive]
      ,[IPAddress]
      ,[CreatedUserID]
      ,[LastModUserID]
      ,[CreatedDate]
      ,[LastModDate]
      ,[PropertyID]
  FROM [Categlog_vrV2].[dbo].[Departments] WHERE IsActive=1
   
END

GO

