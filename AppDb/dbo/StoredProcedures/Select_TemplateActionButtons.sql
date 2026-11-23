
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	Select_TemplateActionButtons
-- =============================================
Create PROCEDURE [dbo].[Select_TemplateActionButtons] 
	@templateId INT,
	@PropertyId INT
AS
BEGIN

	SET NOCOUNT ON;
	SELECT AB.ID,AB.Name,AT.Name As Template
      
  FROM ActionTemplate AS AT  INNER JOIN 
   ActionButtons AS AB  ON AT.ActionButtonID=AB.ID 
   WHERE AT.ID=@templateId AND AT.PropertyId=@PropertyId
  
END

GO

