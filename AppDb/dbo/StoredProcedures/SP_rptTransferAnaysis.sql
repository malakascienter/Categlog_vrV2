-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-02-17
-- Description:	Transfer Analysis Report SP

-- [dbo].[SP_rptTransferAnaysis] '15,14,16,7,12,1,8,13,19','2025/01/17','2025/02/17'

-- =============================================
CREATE PROCEDURE [dbo].[SP_rptTransferAnaysis]
@LocationID VARCHAR(MAX),
@FromDate DATE,
@ToDate DATE
AS
BEGIN
		SET NOCOUNT ON;


		SELECT DISTINCT SH.TransactionDate 'TOTransactionDate',SH.DocumentNo 'TODocNO',SH2.TransactionDate 'TITransactionDate',SH2.DocumentNo 'TIDocNO',SIH.Name ItemName,SD.Quantity 'TOQuantity',ISNULL(SD2.Quantity,0) 'TIQuantity'
		,LO.Name 'TOLocationName',LO2.Name 'TILocationName',CU.UserName 'TOUserName'
		INTO #TempTransfer	
		FROM StockTransactionHeaders SH
		INNER JOIN StockTransactionDetails SD ON SH.Id = SD.StockTransactionHeaderID
		INNER JOIN StockItemHeaders SIH ON SIH.Id = SD.StockItemID
		LEFT JOIN StockTransactionHeaders SH2 ON SH2.ReferenceID = SH.Id AND SH2.TransactionType = 'TI'
		LEFT JOIN StockTransactionDetails SD2 ON SD2.StockTransactionHeaderID = SH2.Id AND SD.StockItemID = SD2.StockItemID
		INNER JOIN Locations LO ON LO.Id = SH.LocationID
		LEFT JOIN Locations LO2 ON LO2.Id = SH2.LocationID
		INNER JOIN CentralUsers CU ON CU.Id = SH.UserProfileID
		WHERE SH.TransactionType='TO'
		AND SH.TransactionDate BETWEEN @FromDate AND @ToDate
		AND SH.LocationID IN (SELECT * FROM string_split(@LocationID,N',')) 
		--AND SD.Quantity <> SD2.Quantity
		


		SELECT DISTINCT *,(TOQuantity -TIQuantity) DIFF
		FROM #TempTransfer
		WHERE TOQuantity >TIQuantity
		ORDER BY TOTransactionDate DESC
    
END

GO

