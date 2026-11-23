-- =============================================
-- Author:		Chiraj
-- Create date: 2019-2-8
-- Description:	Select Recipe Details by recipe code
-- =============================================
CREATE PROCEDURE [dbo].[RecipeDetails_M_SelectBy_RecipeCode]
@RecipeCode VARCHAR(6),
@PropertyId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT RD.[RecipeCode]
      ,RD.[StockItemCode]  
	   ,SH.StockItemCode AS StockItemCodeStr
     --,U.Code AS Unit
	  ,U.Name AS Unit
      ,RD.[Qty]      
      ,RD.[PropertyId],
	  CONCAT(SH.Name,' - ',SH.StockItemCode,' - ', (CASE WHEN  RD.Ord_Type = 'R' THEN '(Eat In)' WHEN  RD.Ord_Type = 'T' THEN '(Take Away)' WHEN  RD.Ord_Type = 'B' THEN '(BOTH)' END) ) AS ItemName
  FROM [RecipeDetails] AS RD
  INNER JOIN StockItemHeaders AS SH ON SH.Id=RD.StockItemCode AND RD.PropertyId = SH.CompanyId
   INNER JOIN Units AS U ON RD.Unit=U.Id  
  WHERE PropertyId=@PropertyId AND RD.RecipeCode=@RecipeCode

	--SELECT rd.* 
	--,sm.Name As ItemName 
	--FROM RecipeDetails as rd 
	--inner join StockItemHeaders As sm On sm.StockItemCode=rd.StockItemCode and sm.LocationId=rd.Loc
	-- where rd.RecipeCode=@RecipeCode AND rd.PropertyId=@PropertyId
	--SELECT RecipeCode,
	--Description
 -- FROM RecipeHeader
 -- WHERE  RecipeCode=@RecipeCode

  -- SELECT RD.RecipeCode
	 -- ,SM.Description	
  --    ,RD.StockItemCode
  --    ,RD.Seq
  --    ,RD.Unit
  --    ,RD.Qty
  --    ,RD.Cost
  --    ,RD.Yeild
  --    ,RD.Ord_Type
  --    ,RD.Loc
  --    ,RD.isMainItem
  --    ,RD.Type
  --FROM RecipeDetails AS RD
  --INNER JOIN StockMaster AS SM ON RD.StockItemCode=SM.ItemNo AND RD.Loc=SM.Location
  --WHERE  RecipeCode=@RecipeCode
END

GO

