
-- =============================================
-- Author:		Banu
-- ALTER date: 07/02/2019
-- Description:	ALTER report Item Consumption
-- =============================================
----EXECUTE Report_ItemConsumption '01/02/2019','01/02/2019','001'
CREATE PROCEDURE [dbo].[Report_ItemConsumption]
	@FromDate		VARCHAR(30),
	@ToDate			VARCHAR(30),
	@Outlet			VARCHAR(MAX)			
AS
BEGIN
	 SELECT ST.docno AS 'DocNo', ST.quantity AS 'Quantity', ST.unit AS 'Unit', ST.NewAvg AS 'AvgPrice',
			(ST.quantity * ST.NewAvg) AS 'Amount', ST.Location AS 'OutletCode', SM.Description AS 'ItemDescription',
			SM.ItemNo AS 'ItemCode', L.description AS 'OutletDescription',ST.date1 AS 'Date'
	 FROM stocktransaction ST
	 INNER JOIN Location L ON ST.Location = L.code
	 INNER JOIN StockMaster SM ON ST.itemcode = SM.ItemNo AND SM.Location = ST.Location
	 WHERE ST.Location IN (SELECT * FROM STRING_SPLIT(@Outlet,','))
	 AND ST.date1 >= CONVERT(DATETIME,@FromDate,103) 
	 AND ST.date1 <= CONVERT(DATETIME,@ToDate,103)
	 AND ST.docid = 'i' AND ST.txnid = 'i'
END

GO

