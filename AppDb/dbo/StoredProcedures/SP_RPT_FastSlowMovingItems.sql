-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2023-12-13
-- Description:	Fast/Slow Moving Items

--  [dbo].[SP_RPT_FastSlowMovingItems] '12','2024/03/01','2024/03/06',1,20,1

-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_FastSlowMovingItems]
@LocationID VARCHAR(MAX),
@FromDate DATE,
@ToDate DATE,
@PropertyID INT,
@NoOfItem INT,
@MovingSpeed INT
AS
BEGIN

	DECLARE @ReportName VARCHAR(MAX),@MovingName VARCHAR(MAX)

	
	SET NOCOUNT ON;

	IF(@MovingSpeed =1)
	BEGIN
	SELECT @MovingName = 'Fast'
	END
	ELSE
	BEGIN
	SELECT @MovingName = 'Slow'
	END


	SET @ReportName = @MovingName+' '+'Moving Top'+' '+convert(varchar,@NoOfItem)+' '+'Items'


    
		SELECT TOP (@NoOfItem)SH.Id ItemID, SH.StockItemCode,SH.Name ItemName,SUM(IVN.Quantity) Quantity, SUM(IVN.SellingPrice) SellingPrice,@ReportName ReportName,LO.Name LocationName,(SUM(IVN.Quantity) * SUM(IVN.SellingPrice)) Value
		,SUM(IVN.Quantity * IVN.AveragePrice) CostValue,(SUM(IVN.Quantity * IVN.AveragePrice))/SUM(IVN.Quantity) AVGCostPrice
		INTO #TempItemMovement
		FROM POS_InvoiceDetail IVN
		INNER JOIN StockItemHeaders SH ON IVN.ItemID = SH.Id
		INNER JOIN Locations LO ON LO.Id = IVN.LocationID
		WHERE IVN.LocationID IN (SELECT * FROM string_split(@LocationID,N','))  AND IVN.BusinessDate BETWEEN @FromDate AND @ToDate AND IVN.CompanyID =@PropertyID
		GROUP BY SH.Id , SH.StockItemCode,SH.Name ,LO.Name




		IF(@MovingSpeed = 1) -- FAST ITEMS
		BEGIN
		SELECT *
		FROM #TempItemMovement
		ORDER BY Quantity DESC
		END

		IF(@MovingSpeed = 0) -- SLOW ITEMS
		BEGIN
		SELECT *
		FROM #TempItemMovement
		ORDER BY Quantity ASC
		END



END

GO

