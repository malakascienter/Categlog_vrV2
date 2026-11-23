
-- =============================================
-- Author:		Chiraj
-- Create date: 2017-07-24
-- Description:	Select all active outlet including HOF
-- =============================================
---exec  [dbo].[Outlet_M_Select_All] 1 
CREATE PROCEDURE [dbo].[Outlet_M_Select_All]  
	@Active INT = 2
AS
BEGIN
	SET NOCOUNT ON;   
	SELECT code AS Code ,IPAddress AS IPAddress ,description AS Description ,Active ,OutletDatabase,OutletServer,OutletServerPassword,OutletServerUsername,CurrentDate
	FROM  Location_Ref
	WHERE @Active = 2 OR Active = @Active
END

GO

