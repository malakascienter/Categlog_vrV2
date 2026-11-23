-- =============================================
-- Author:		<Thilini Fernando>
-- Create date: <17-10-2021>
-- Modified by : Nivesh
-- Modified date: 2024-11-29
-- Description:	<Description,,>
-- =============================================
-- [SP_SelectRecipeHeaders] ''
CREATE PROCEDURE [dbo].[SP_SelectRecipeHeaders](@Search VARCHAR(250))
AS
BEGIN
-------------------------------------------------------------------------
BEGIN TRY 
	SELECT IRH.Id, IRH.RecipeCode+'/'+IRH.RecipeName AS text,IRH.UnitId,U.Name UnitName,IRH.RecipeCode AS code,
  (
	SELECT UnitConvertion.UnitID, UnitConvertion.Unitname, UnitConvertion.Value
	FROM (
	SELECT ToUnitID AS UnitID, ToUnitName AS Unitname, convert(int ,Value) as Value FROM dbo.UnitConversions WHERE FromUnitID = IRH.UnitId
	UNION ALL
	SELECT FromUnitID AS UnitID, FromUnitName AS Unitname, convert(int ,Value) as Value FROM dbo.UnitConversions WHERE ToUnitID = IRH.UnitId
	UNION
	SELECT Id, Name, 1 AS Value FROM dbo.Units WHERE Id = U.Id
	) AS UnitConvertion
	FOR JSON PATH
	) AS UnitConvertion	
	FROM Inv_RecipeHeader IRH
	LEFT JOIN Units U ON U.Id = IRH.UnitId
	WHERE IRH.IsActive = 1 AND  IRH.RecipeCode LIKE '%' + ISNULL(@Search,'') + '%'  OR   IRH.RecipeName LIKE '%' + ISNULL(@Search,'') + '%'  
END TRY
BEGIN CATCH
	IF @@TRANCOUNT>0
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH;
-------------------------------------------------------------------------

  
END

GO

