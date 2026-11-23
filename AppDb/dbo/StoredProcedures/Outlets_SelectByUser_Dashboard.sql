-- Sachith , 19/09/2018
-- Refering Management Dashboard Database
CREATE PROCEDURE [dbo].[Outlets_SelectByUser_Dashboard]
	(
		@User NVARCHAR(50) --= 'scienter'
	)
AS
BEGIN
	
	WITH UserWiseOutlets AS
	(
		SELECT * 
		FROM [Dashboard-Rest].dbo.UserwiseHOtelCodes 
		WHERE RTRIM(UserID) = RTRIM(@User)
	)
	
	SELECT A.* 
	FROM Location_Ref A
	INNER JOIN UserWiseOutlets B ON RTRIM(A.code) = RTRIM(B.HOtelCode)
	WHERE Active = 1 
	ORDER BY DashboardDisplayOrder ASC

END

GO

