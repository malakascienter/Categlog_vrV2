

CREATE PROCEDURE SP_Rider_Select

AS
BEGIN
	SET NOCOUNT ON;
	 
	
	SELECT [RiderID]
      ,[RiderName]
      ,[Outlet]
      ,[IsActive]
      ,[EditUser]
      ,[EditDate]
    FROM [dbo].[POS_Rider]


END

GO

