

CREATE PROCEDURE Report_RiderWiseOrderDetail
 @FromDate DATETIME,          
 @ToDate DATETIME,
 @PropertyId VARCHAR(2),
 @Rider VARCHAR(MAX)
 
AS
BEGIN
	SET NOCOUNT ON;
	 
	SELECT BH.OrderNo,R.RiderName,BH.NetAmount ,BH.DeliveryCharge,BH.OrderDate
	FROM BillHeader BH INNER JOIN POS_Rider R ON BH.RiderID = R.RiderID
	WHERE R.RiderID IN (SELECT * FROM STRING_SPLIT(@Rider,',')) AND BH.PropertyId = @PropertyId
	AND BH.OrderDate BETWEEN   @FromDate AND @ToDate 

END

GO

