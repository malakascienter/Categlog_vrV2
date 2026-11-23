
-- =============================================
-- Author:		Banu
-- ALTER date: 21/12/2018
-- Description:	Report SRN Listing Details
-- =============================================
CREATE PROCEDURE [dbo].[Report_SRN_Listing_Details]
	@FromDate VARCHAR(10),
	@ToDate VARCHAR(10),
	@Suplier VARCHAR(MAX),
	@Outlet VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT * INTO #TempStockTrn 
	FROM stocktransaction st
	WHERE st.date1 >=CONVERT(DATETIME,@FromDate,103)
		AND st.date1 <= CONVERT(DATETIME,@ToDate,103)
		AND st.Location IN (SELECT * FROM STRING_SPLIT(@Outlet,','))
		AND docid = 's' AND txnid = 's' -----Filter Supplier Return Transactions Only



	SELECT G.Date2 AS 'Document Date', '' AS 'Return Number', #TempStockTrn.date1 AS 'Date',
		G.Suppcode AS 'Supplier Code', SM.ItemNo AS 'Item Code', SM.Description AS 'Item Description',
		G.Remarks, #TempStockTrn.unitprice AS 'Unit Price', TaxPerc2 AS 'Vat Rate', SM.Quantity AS 'Item Quantity',
		0 AS 'Quantity', TotValue AS 'Gross Value', (G.TaxVal1+G.TaxVal2+G.TaxVal3+G.TaxVal4) AS 'Vat',
		(TotValue + G.TaxVal1 + G.TaxVal2 + G.TaxVal3 + G.TaxVal4) AS 'Net Value', 
		((TotValue + G.TaxVal1 + G.TaxVal2 + G.TaxVal3 + G.TaxVal4)/CASE SM.Quantity WHEN 0 THEN 1 ELSE SM.Quantity END) As 'Item Value',
		L.code as 'OutletCode', L.description As 'Outlet'
	FROM  StockMaster SM 
	INNER JOIN #TempStockTrn ON SM.Location = #TempStockTrn.Location 
		AND #TempStockTrn.Itemcode = SM.ItemNo 
	LEFT OUTER JOIN GRNHeader G ON #TempStockTrn.docid = G.Docid AND SM.Location = G.Location
	INNER JOIN Location L ON G.Location = L.code
	WHERE G.Date2 >= CONVERT(DATETIME,@FromDate,103)
		AND G.Date2 <= CONVERT(DATETIME,@ToDate,103)
		AND G.Location IN (SELECT * FROM STRING_SPLIT(@Outlet,','))
		AND G.Suppcode IN (SELECT * FROM STRING_SPLIT(@Suplier,','))
END

GO

