-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 05 september 2023
-- Description:	Total Transaction Quantity for BinCard Report
--  [dbo].[SP_Report_Bincard_SubTable] 1,1,1,'2023-01-01','2023-05-29'
-- =============================================
CREATE PROCEDURE [dbo].[SP_Report_Bincard_SubTable]
	@HeaderID INT,
	@LocationID INT,
	@PropertyID INT,
	@FromDate DATE,
	@ToDate DATE
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#SubBinCardTable2') IS NOT NULL
	begin
        drop table #SubBinCardTable2
	end

	DECLARE @TransactionID INT

	CREATE TABLE #SubBinCardTable2(
	TransactionType NVARCHAR(MAX),
	InQty DECIMAL(18,6),
	OutQty DECIMAL(18,6))  

	SELECT SUM(STD.Quantity* STD.MasterUnitConversion) Quantity,TR.Name TransactionType,SH.TransactionID,STD.TxnType
	INTO #TempSubTable
	FROM StockTransactionHeaders SH
	INNER JOIN StockTransactionDetails STD ON STD.StockTransactionHeaderID = SH.Id
	INNER JOIN StockItemHeaders SIH ON SIH.Id = STD.StockItemID
	INNER JOIN TransactionTypes TR ON TR.Id = SH.TransactionID
	WHERE STD.StockItemID=@HeaderID
	AND SH.LocationID = @LocationID
	AND SH.PropertyID = @PropertyID
	AND SH.TransactionDate BETWEEN @FromDate AND @ToDate
	GROUP BY TR.Name,SH.TransactionID, STD.TxnType

	WHILE(SELECT COUNT(*) FROM #TempSubTable ) > 0
	BEGIN

	SELECT TOP(1) @TransactionID = TransactionID
	FROM #TempSubTable

	INSERT INTO #SubBinCardTable2
	SELECT Top(1) TransactionType,ISNULL((SELECT Quantity FROM  #TempSubTable WHERE TransactionID = @TransactionID AND TxnType = 'P'),0),ISNULL((SELECT Quantity FROM  #TempSubTable WHERE TransactionID = @TransactionID AND TxnType = 'M'),0)
	FROM #TempSubTable
		


	DELETE #TempSubTable WHERE TransactionID = @TransactionID



	END

		
		SELECT *
		FROM #SubBinCardTable2




   
END

GO

