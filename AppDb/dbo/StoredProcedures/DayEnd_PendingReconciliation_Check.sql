--EXEC [DayEnd_PendingReconciliation_Check] 1 
CREATE PROCEDURE [dbo].[DayEnd_PendingReconciliation_Check]
@PropertyId INT
AS
BEGIN

declare @IsReconciliationValidateInDayend BIT
SELECT @IsReconciliationValidateInDayend = IsReconciliationValidateInDayend FROM Companies WHERE CompanyID = @PropertyId

CREATE TABLE #TempStockSpotCheck
(
	LocationID INT ,
	PropertyID INT ,
	StockItemID INT ,
	Variance MONEY ,
	LocationName VARCHAR(50) ,
	StockItemCode VARCHAR(50) ,
	Name VARCHAR(250) ,
)

CREATE TABLE #TempPendingReconciliation
(
	StockItemCode VARCHAR(50) ,
	Name VARCHAR(250) ,
	LocationName VARCHAR(50) ,
	Variance MONEY ,
)

INSERT INTO #TempStockSpotCheck (LocationID,PropertyID,StockItemID,Variance,StockItemCode,Name)
SELECT SPH.LocationID,SPH.PropertyID,SPD.StockItemID ,(SPD.QuantityInHand - SPD.PhysicalQty),sih.StockItemCode,sih.Name
FROM StockSpotCheckHeader SPH
inner join StockSpotCheckDetail SPD  ON SPH.ID = SPD.StockSpotHeaderID
inner join Locations l on sph.LocationID = l.Id
inner join StockItemHeaders sih on SPD.StockItemID = sih.Id
WHERE CONVERT(DATE,SPH.SpotCheckDate) = CONVERT(DATE,GETDATE())  AND SPD.QuantityInHand <> SPD.PhysicalQty

DECLARE @LocationID INT,@StockItemID INT,@Variance MONEY,@LocationName VARCHAR(50),@StockItemCode VARCHAR(50) ,@Name VARCHAR(250)

WHILE EXISTS( SELECT * FROM #TempStockSpotCheck )
BEGIN

    SELECT TOP(1) @LocationID = LocationID,@StockItemID = StockItemID,@Variance = Variance,@LocationName = LocationName,@StockItemCode = StockItemCode,@Name = Name 
	FROM #TempStockSpotCheck


	IF NOT EXISTS
	(    
		 SELECT * FROM StockTransactionHeaders sh inner join StockTransactionDetails sd on sh.Id = sd.StockTransactionHeaderID
		 inner join StockItemHeaders sih on sd.StockItemID = sih.Id
		 inner join Locations l on sh.LocationID = l.Id
		 where CONVERT(date,sh.TransactionDate) = CONVERT(date,GETDATE()) and sh.LocationID = @LocationID and sd.StockItemID = @StockItemID and sh.PropertyID = @PropertyId and sh.TransactionType = 'AA' 
	 )
	BEGIN

        INSERT INTO #TempPendingReconciliation (LocationID,PropertyID,StockItemID,Variance,LocationName,StockItemCode,Name)
		VALUES(@LocationID,@PropertyId,@StockItemID,@Variance,@LocationName,@StockItemCode,@Name)

	END





 DELETE TOP(1) FROM #TempStockSpotCheck

END


IF( @IsReconciliationValidateInDayend = 1 )
BEGIN

 SELECT * FROM #TempPendingReconciliation

END
ELSE
BEGIN

 DELETE FROM #TempPendingReconciliation
 SELECT * FROM #TempPendingReconciliation

END

DROP TABLE #TempStockSpotCheck
DROP TABLE #TempPendingReconciliation
	
END

GO

