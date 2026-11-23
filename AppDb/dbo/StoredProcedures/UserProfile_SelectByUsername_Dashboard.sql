-- Sachith , 19/09/2018
-- Refering Management Dashboard Database
CREATE procedure [dbo].[UserProfile_SelectByUsername_Dashboard]
(
	@UserName varchar(max)
)
AS

SELECT * 
FROM [Dashboard-Rest].[dbo].UserProfile
WHERE userName=@UserName

GO

