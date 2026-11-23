--	EXEC [DayEnd_PendingReconciliationLocationWise_Check] 1,'T01'

CREATE PROCEDURE [dbo].[DayEnd_PendingReconciliationLocationWise_Check]
@PropertyId INT,
@Outlet VARCHAR(3)
AS
BEGIN


DECLARE @LocationID INT,@TxnDate DATE,@DayEndItemTempId INT,@LocationName VARCHAR(MAX),@SaleCount INT

SELECT @LocationID = StockLocationID,@TxnDate = CurrentDate
FROM Location_Ref
WHERE CODE = @Outlet



SELECT @DayEndItemTempId = ISNULL(DayEndItemTempId,0),@LocationName = Name
FROM Locations
WHERE ID = @LocationID

SELECT @SaleCount =ISNULL(COUNT(ID),0)
FROM BillHeader
WHERE Outlet = @Outlet
AND OrderDate = @TxnDate


IF (@DayEndItemTempId >0 AND @SaleCount >0)
BEGIN
	IF EXISTS(
				SELECT 1
				FROM RequestTemplateDetails
				WHERE TemplateHeaderID = @DayEndItemTempId
				AND StockItemHeaderID NOT IN (
					SELECT STD.StockItemID
					FROM StockSpotCheckHeader SH
					INNER JOIN StockSpotCheckDetail STD ON SH.ID = STD.StockSpotHeaderID
					WHERE SH.LocationID = @LocationID
					AND CONVERT(DATE,SH.SpotCheckDate) = @TxnDate
					AND SH.PropertyID = @PropertyID
					AND SH.FirstLevel = 1
				)

				
)
	BEGIN
	
		SELECT DISTINCT SH.Name AS Name,SH.StockItemCode StockItemCode,@LocationName LocationName,0 Variance
		FROM RequestTemplateDetails RD
		INNER JOIN StockItemHeaders SH ON RD.StockItemHeaderID = SH.Id
		WHERE RD.TemplateHeaderID = @DayEndItemTempId
		AND RD.StockItemHeaderID NOT IN (
		SELECT STD.StockItemID
		FROM StockSpotCheckHeader H
		INNER JOIN StockSpotCheckDetail STD 
						ON H.ID = STD.StockSpotHeaderID
		WHERE H.LocationID = @LocationID
		AND CONVERT(DATE,H.SpotCheckDate) = @TxnDate
		AND H.PropertyID = @PropertyID
		AND H.FirstLevel = 1)


	END


END




--declare @IsReconciliationValidateInDayend BIT
--SELECT @IsReconciliationValidateInDayend = IsReconciliationValidateInDayend FROM Companies WHERE CompanyID = @PropertyId

--CREATE TABLE #TempStockSpotCheck
--(
--	LocationID INT ,
--	PropertyID INT ,
--	StockItemID INT ,
--	Variance MONEY ,
--	LocationName VARCHAR(50) ,
--	StockItemCode VARCHAR(50) ,
--	Name VARCHAR(250) ,
--)

--CREATE TABLE #TempPendingReconciliation
--(
--	StockItemCode VARCHAR(50) ,
--	Name VARCHAR(250) ,
--	LocationName VARCHAR(50) ,
--	Variance MONEY ,
--)

--INSERT INTO #TempStockSpotCheck (LocationID,PropertyID,StockItemID,Variance,StockItemCode,Name)
--SELECT SPH.LocationID,SPH.PropertyID,SPD.StockItemID ,(SPD.QuantityInHand - SPD.PhysicalQty),sih.StockItemCode,sih.Name
--FROM StockSpotCheckHeader SPH
--inner join StockSpotCheckDetail SPD  ON SPH.ID = SPD.StockSpotHeaderID
--inner join Locations l on sph.LocationID = l.Id
--inner join StockItemHeaders sih on SPD.StockItemID = sih.Id
--WHERE CONVERT(DATE,SPH.SpotCheckDate) = CONVERT(DATE,GETDATE())  AND SPD.QuantityInHand <> SPD.PhysicalQty

--DECLARE @LocationID INT,@StockItemID INT,@Variance MONEY,@LocationName VARCHAR(50),@StockItemCode VARCHAR(50) ,@Name VARCHAR(250)

--WHILE EXISTS( SELECT * FROM #TempStockSpotCheck )
--BEGIN

--    SELECT TOP(1) @LocationID = LocationID,@StockItemID = StockItemID,@Variance = Variance,@LocationName = LocationName,@StockItemCode = StockItemCode,@Name = Name 
--	FROM #TempStockSpotCheck


--	IF NOT EXISTS
--	(    
--		 SELECT * FROM StockTransactionHeaders sh inner join StockTransactionDetails sd on sh.Id = sd.StockTransactionHeaderID
--		 inner join StockItemHeaders sih on sd.StockItemID = sih.Id
--		 inner join Locations l on sh.LocationID = l.Id
--		 where CONVERT(date,sh.TransactionDate) = CONVERT(date,GETDATE()) and sh.LocationID = @LocationID and sd.StockItemID = @StockItemID and sh.PropertyID = @PropertyId and sh.TransactionType = 'AA' 
--	 )
--	BEGIN

--        INSERT INTO #TempPendingReconciliation (LocationID,PropertyID,StockItemID,Variance,LocationName,StockItemCode,Name)
--		VALUES(@LocationID,@PropertyId,@StockItemID,@Variance,@LocationName,@StockItemCode,@Name)

--	END





-- DELETE TOP(1) FROM #TempStockSpotCheck

--END


--IF( @IsReconciliationValidateInDayend = 1 )
--BEGIN

-- SELECT * FROM #TempPendingReconciliation

--END
--ELSE
--BEGIN

-- DELETE FROM #TempPendingReconciliation
-- SELECT * FROM #TempPendingReconciliation

--END

--DROP TABLE #TempStockSpotCheck
--DROP TABLE #TempPendingReconciliation
	
END

GO

