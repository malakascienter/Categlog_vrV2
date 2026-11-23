
-- [dbo].[SP_Report_Bincard] 1014,4,1,'2024-03-19','2024-08-29'
CREATE PROCEDURE [dbo].[SP_Report_Bincard] --1,2,1,'2018/01/01','2018/04/24'

@HeaderID INT,
@LocationID INT,
@PropertyID INT,
@FromDate DATE,
@ToDate DATE

AS

DECLARE @tabletemp AS TABLE (name VARCHAR(MAX), TransactionType VARCHAR(100),Reference VARCHAR(MAX), TransactionDate DATE,DocumentNo VARCHAR(100),  Unit VARCHAR(100), Quentity DECIMAL(18,6), UnitPrice DECIMAL(18,6),
Value DECIMAL(18,6) , NewQuantity DECIMAL(18,6), BalanceValue DECIMAL(18,6) ,StockItemCode VARCHAR(300) , InvoiceDate DATE)

DECLARE @tabletemp2 AS TABLE (name VARCHAR(MAX), TransactionType VARCHAR(100),Reference VARCHAR(MAX), TransactionDate DATE,DocumentNo VARCHAR(100),  Unit VARCHAR(100), Quentity DECIMAL(18,6), UnitPrice DECIMAL(18,6),
Value DECIMAL(18,6) , NewQuantity DECIMAL(18,6), BalanceValue DECIMAL(18,6),StockItemCode VARCHAR(300) , InvoiceDate DATE)

INSERT INTO @tabletemp
SELECT TOP(1) IH.Name,'Oppening Balance' as TransactionType,'' AS Reference, @FromDate AS TransactionDate,'' as DocumentNo,U.Name AS Unit, NULL,NULL,NULL,
 D.NewQuantity, (D.NewQuantity * D.NewAveragePrice) AS BalanceValue,IH.StockItemCode,CASE WHEN H.TransactionType='GR' THEN  CONVERt(DATE,H.InvoiceDate) ELSE NULL END AS InvoiceDate --, D.*, H.* --U.Name ,
FROM dbo.StockTransactionDetails AS D
INNER JOIN  dbo.StockTransactionHeaders AS H ON D.StockTransactionHeaderID = H.Id 
INNER JOIN dbo.StockItemHeaders AS IH ON D.StockItemID = IH.Id
INNER JOIN dbo.StockTransactionDetails AS D2 ON D.Id = D2.Id
INNER JOIN dbo.StockItemDetails AS ID ON IH.Id = ID.StockItemHeaderID AND H.LocationId = ID.LocationID
INNER JOIN dbo.Units AS U ON ID.MasterUnitID = U.Id
WHERE IH.Id = @HeaderID AND H.LocationID = @LocationID AND h.PropertyID = CASE WHEN @PropertyID = -999 THEN h.PropertyID ELSE @PropertyID END 
AND H.TransactionDate < @FromDate 
ORDER BY H.TransactionDate DESC, H.CreatedDate DESC 

INSERT INTO @tabletemp2
SELECT TOP(1) IH.Name,'Closing Balance' as TransactionType,'' AS Reference, @ToDate AS TransactionDate,'' as DocumentNo,U.Name AS Unit, NULL,NULL,NULL,
 D.NewQuantity, (D.NewQuantity * D.NewAveragePrice) AS BalanceValue,IH.StockItemCode,CASE WHEN H.TransactionType='GR' THEN  CONVERt(DATE,H.InvoiceDate) ELSE NULL END AS InvoiceDate --, D.*, H.* --U.Name ,
FROM dbo.StockTransactionDetails AS D
INNER JOIN  dbo.StockTransactionHeaders AS H ON D.StockTransactionHeaderID = H.Id 
INNER JOIN dbo.StockItemHeaders AS IH ON D.StockItemID = IH.Id
INNER JOIN dbo.StockTransactionDetails AS D2 ON D.Id = D2.Id
INNER JOIN dbo.StockItemDetails AS ID ON IH.Id = ID.StockItemHeaderID AND H.LocationId = ID.LocationID
INNER JOIN dbo.Units AS U ON ID.MasterUnitID = U.Id
WHERE IH.Id = @HeaderID AND H.LocationID = @LocationID AND h.PropertyID = CASE WHEN @PropertyID = -999 THEN h.PropertyID ELSE @PropertyID END  
AND H.TransactionDate <= @ToDate
 ORDER BY H.TransactionDate DESC,H.CreatedDate  DESC


DECLARE @CurrentDate DATE
DECLARE @SalesQty MONEY
SET @CurrentDate =  [dbo].[GetBusinessDate_Retail](@PropertyID,@LocationID)

IF( @CurrentDate <=  @ToDate )
BEGIN


	INSERT INTO @tabletemp2
	SELECT SH.Name,'Sales' as TransactionType,'' AS Reference, @CurrentDate AS TransactionDate,'' as DocumentNo,'', NULL,NULL,NULL,
	 SUM(D.Quantity), 0,D.ItemCode,null --, D.*, H.* --U.Name ,
	FROM dbo.POS_InvoiceDetail AS D
	INNER JOIN StockItemHeaders SH ON D.ItemID = SH.Id
	WHERE D.ItemID = @HeaderID AND D.CompanyID = @PropertyID
	AND D.BusinessDate = @CurrentDate
	GROUP BY SH.Name,D.ItemCode

	SELECT @SalesQty = SUM(D.Quantity)
	FROM dbo.POS_InvoiceDetail AS D
	INNER JOIN StockItemHeaders SH ON D.ItemID = SH.Id
	WHERE D.ItemID = @HeaderID AND D.CompanyID = @PropertyID
	AND D.BusinessDate = @CurrentDate
	GROUP BY SH.Name,D.ItemCode 


	INSERT INTO @tabletemp2
	SELECT TOP(1) IH.Name,'Current Stock In Hand' as TransactionType,'' AS Reference, @CurrentDate AS TransactionDate,'' as DocumentNo,'', NULL,NULL,NULL,
	isnull(D.NewQuantity,0)-isnull(@SalesQty,0), 0,IH.StockItemCode,CASE WHEN H.TransactionType='GR' THEN  CONVERt(DATE,H.InvoiceDate) ELSE NULL END AS InvoiceDate --, D.*, H.* --U.Name ,
	FROM dbo.StockTransactionDetails AS D
	INNER JOIN  dbo.StockTransactionHeaders AS H ON D.StockTransactionHeaderID = H.Id 
	INNER JOIN dbo.StockItemHeaders AS IH ON D.StockItemID = IH.Id
	INNER JOIN dbo.StockTransactionDetails AS D2 ON D.Id = D2.Id
	INNER JOIN dbo.StockItemDetails AS ID ON IH.Id = ID.StockItemHeaderID AND H.LocationId = ID.LocationID
	INNER JOIN dbo.Units AS U ON ID.MasterUnitID = U.Id
	WHERE IH.Id = @HeaderID AND H.LocationID = @LocationID AND h.PropertyID = CASE WHEN @PropertyID = -999 THEN h.PropertyID ELSE @PropertyID END  
	AND H.TransactionDate <= @ToDate
	ORDER BY H.TransactionDate DESC,H.CreatedDate  DESC

END

IF(SELECT COUNT(*) FROM @tabletemp) = 0
BEGIN

INSERT INTO @tabletemp
SELECT TOP(1) IH.Name,'Oppening Balance' as TransactionType,'' AS Reference, @FromDate AS TransactionDate,'' as DocumentNo,U.Name AS Unit, NULL,NULL,NULL,
 0, 0,IH.StockItemCode,null --, D.*, H.* --U.Name ,
FROM  dbo.StockItemHeaders AS IH  
INNER JOIN dbo.StockItemDetails AS ID ON IH.Id = ID.StockItemHeaderID  
INNER JOIN dbo.Units AS U ON ID.MasterUnitID = U.Id
WHERE IH.Id = @HeaderID AND ID.LocationID = @LocationID AND IH.CompanyId = CASE WHEN @PropertyID = -999 THEN IH.CompanyId ELSE @PropertyID END  
END


SELECT ROW_NUMBER ( )   OVER (ORDER BY H.TransactionDate , H.CreatedDate) SEQ, IH.Name itemname,  t.Name  ,
CASE 
--WHEN H.TransactionType = 'AA' THEN LO.Name 
WHEN H.TransactionType = 'AA' AND SPT.TransactionHeaderID IS NOT NULL THEN 'SPOT CHECK'
WHEN H.TransactionType = 'AA' AND SPT.TransactionHeaderID IS  NULL THEN CONCAT('Submitted: ',CONVERT(DATE,h.CreatedDate))
WHEN H.TransactionType = 'GR' THEN SUP.Name 
--WHEN H.TransactionType = 'SR' THEN SUP.Name 
WHEN H.TransactionType = 'IN' THEN DE.Name 
WHEN H.TransactionType = 'IR' THEN DE.Name 
WHEN H.TransactionType IN ('PI','PU','SR','XX') THEN SH2.DocumentNo
WHEN H.TransactionType = 'TO' THEN LO2.Name  
WHEN H.TransactionType = 'TI' THEN LO2.Name 
WHEN H.TransactionType = 'BI' THEN LO3.Name  END AS Reference, 
H.TransactionDate AS TransactionDate, H.DocumentNo,U.Name AS Unit, (D.Quantity * 
(
	(CASE WHEN H.TransactionType in ('GR' , 'IR', 'DI', 'TI','PU') THEN 1 ELSE  CASE WHEN H.TransactionType='AA' AND D.TxnType='P' THEN   1 ELSE -1 END  END )    
)
) AS Quentity,
 CASE   WHEN (D.DiscountPercentage = 0 AND D.Quantity = 0) THEN D.UnitPrice WHEN  D.DiscountPercentage = 0 THEN (D.UnitPrice - (D.DiscountValue/D.Quantity))
  ELSE d.UnitPrice- ( D.UnitPrice * D.DiscountPercentage /100) END AS UnitPrice,
   (D.Quantity * (CASE WHEN (D.DiscountPercentage = 0 AND D.Quantity = 0) THEN D.UnitPrice WHEN D.DiscountPercentage = 0
    THEN (D.UnitPrice -( D.DiscountValue/D.Quantity))
	 ELSE D.UnitPrice- (D.UnitPrice * D.DiscountPercentage/100) END) * (CASE WHEN H.TransactionType in ('GR' , 'IR', 'DI', 'TI','PU') THEN 1
	  ELSE CASE WHEN H.TransactionType='AA' AND D.TxnType='P' THEN   1 ELSE -1 END END ) 
) AS Value, D.NewQuantity, (D.NewQuantity * D.NewAveragePrice) AS BalanceValue,IH.StockItemCode,CASE WHEN H.TransactionType='GR' THEN  CONVERt(DATE,H.InvoiceDate) ELSE NULL END AS InvoiceDate --, D.*, H.* --U.Name ,
INTO #TranData
FROM dbo.StockTransactionDetails AS D
INNER JOIN  dbo.StockTransactionHeaders AS H ON D.StockTransactionHeaderID = H.Id 
INNER JOIN dbo.StockItemHeaders AS IH ON D.StockItemID = IH.Id
INNER JOIN dbo.StockTransactionDetails AS D2 ON D.Id = D2.Id
INNER JOIN TransactionTypes t ON t.Id = h.TransactionID
INNER JOIN dbo.Units AS U ON D.TxnUnitID = U.Id
LEFT JOIN Suppliers SUP ON SUP.ID = H.SupplierID
INNER JOIN LOCATIONS LO ON LO.ID = H.LocationID
LEFT JOIN Departments DE ON DE.Id = H.DepartmentID
LEFT JOIN Locations LO2 ON LO2.ID = H.TransferLocationID
LEFT JOIN StockTransactionHeaders SH2 ON SH2.ID = H.ReferenceID
LEFT JOIN StockSpotCheckHeader SPT ON SPT.TransactionHeaderID = H.Id
LEFT JOIN LOCATIONS LO3 ON LO3.ID = H.InvoiceLocationID
WHERE IH.Id = @HeaderID AND H.LocationID = @LocationID AND h.PropertyID = CASE WHEN @PropertyID = -999 THEN h.PropertyID ELSE @PropertyID END   
AND H.TransactionDate BETWEEN @FromDate AND @ToDate
ORDER BY H.TransactionDate , H.CreatedDate

DECLARE @MAXSEQ INT
Select @MAXSEQ = MAX(SEQ)+1 FROM #TranData


IF(SELECT COUNT(*) FROM @tabletemp2) = 0
BEGIN

INSERT INTO @tabletemp2
SELECT TOP(1) IH.Name,'Closing Balance' as TransactionType,'' AS Reference, @ToDate AS TransactionDate,'' as DocumentNo,U.Name AS Unit, NULL,NULL,NULL, 0, 0
,IH.StockItemCode,null --, D.*, H.* --U.Name ,
FROM dbo.StockItemHeaders AS IH
INNER JOIN dbo.StockItemDetails AS ID ON IH.Id = ID.StockItemHeaderID AND ID.LocationId = ID.LocationID
INNER JOIN dbo.Units AS U ON ID.MasterUnitID = U.Id
WHERE IH.Id = @HeaderID AND IH.LocationID = @LocationID AND IH.CompanyId = CASE WHEN @PropertyID = -999 THEN IH.CompanyId ELSE @PropertyID END   
END
 

SELECT * FROM (
SELECT -1 SEQ, * FROM @tabletemp
UNION ALL
-- CASE WHEN H.TransactionType='GR' THEN 'Good recieved note'  WHEN  H.TransactionType='II' THEN 'Invoice' ELSE  H.TransactionType END
SELECT * FROM #TranData
UNION ALL
SELECT @MAXSEQ,* FROM @tabletemp2
) X 
ORDER BY seq asc,TransactionDate

GO

