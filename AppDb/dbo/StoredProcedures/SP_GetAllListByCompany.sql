

CREATE PROCEDURE SP_GetAllListByCompany
	-- Add the parameters for the stored procedure here
	@CompanyID INT =1,
	@LocationID INT =1
AS
BEGIN
	SELECT SH.Id,SH.Name FROM dbo.StockItemHeaders SH FULL JOIN dbo.StockItemDetails SD ON SH.Id=sd.StockItemHeaderID WHERE SH.CompanyId=@CompanyID AND SD.LocationID=@LocationID
END

GO

