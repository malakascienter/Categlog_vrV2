CREATE PROCEDURE [dbo].[DashboardAPI_Select_Menues]
AS
BEGIN

	--DECLARE @PropertyPrefix	NVARCHAR(100)=''
	--SET @PropertyPrefix = '{{propertyPrefix}}'

	--UPDATE DashboardAPI_Menues
	--SET Link = 'dashboard/'+@PropertyPrefix+''
	--WHERE Id=1

	SELECT
	(
		SELECT *
		FROM
		(
			SELECT 
			A.Id,
			A.ParentId,
			A.Name,
			A.Link,
			A.Icon,
			(
				SELECT *
				FROM DashboardAPI_Menues B WITH(NOLOCK) 
				WHERE A.Id = B.ParentId 
				AND IsActive=1
				FOR JSON AUTO
			) AS InnerMenueJson
			FROM DashboardAPI_Menues	A WITH(NOLOCK)
			WHERE A.ParentId IS NULL
			AND IsActive=1
		) AS X
		FOR JSON AUTO
	) AS ResultJson
END

GO

