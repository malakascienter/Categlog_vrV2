
CREATE PROCEDURE [dbo].[Select_OutletWiseItemBreakDown]
	@MainMenuCode VARCHAR(10),
	@OutletJson VARCHAR(MAX),
	@PropertyId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF OBJECT_ID(N'tempdb..#TmpOutlet') IS NOT NULL
	BEGIN
	DROP TABLE #TmpOutlet
	END

	SELECT * INTO #TmpOutlet FROM OPENJSON(@OutletJson)
	WITH
	(
			OutletCode VARCHAR(5) '$.OutletCode'
	)

	select R.Description,R.Ord_Type,R.LowerVariencePerc,R.HigherVariencePerc ,'' AS RecipeDetailJson, LTRIM(RTRIM(R.RecipeCode))AS RecipeCode,T.Qty ,
	T.Outlet,L.description AS OutletName
	from OutletWiseItemBreakDown T inner join RecipeHeader R ON T.RecipeCode = R.RecipeCode  AND T.PropertyId = R.PropertyId
	INNER JOIN Location_Ref L ON T.Outlet = L.code  AND T.PropertyId = L.PropertyId
	where T.MainMenuCode=@MainMenuCode AND L.code IN (SELECT OutletCode FROM #TmpOutlet) 
	AND T.PropertyId=@PropertyId AND R.PropertyId = @PropertyId AND L.PropertyId = @PropertyId


	IF OBJECT_ID(N'tempdb..#TmpOutlet') IS NOT NULL
	BEGIN
	DROP TABLE #TmpOutlet
	END

END

GO

