CREATE PROCEDURE [dbo].[SP_GetStockItemHeaders] --1,1,2
	-- Add the parameters for the stored procedure here
	@Locationid INT,
	@Propertyid INT,
	@Categoryid INT
 WITH RECOMPILE
 AS
BEGIN

DECLARE @Locationid2 INT=@Locationid,
	@Propertyid2 INT=@Propertyid,
	@Categoryid2 INT =@Categoryid

DECLARE @ISGross BIT
         
		 SELECT *FROM StockItemHeaders WHERE CategoryID=@Categoryid
		  

	
END

GO

