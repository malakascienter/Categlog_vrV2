-- =============================================
-- Author:		Nivesh Wanninayaka
-- Create date: 2026-05-29
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_SupplierGRNValue]
	@FromDate DATE,
	@ToDate DATE,
	@PropertyID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	--SELECT 
	--	PH.Id,
	--	S.Name AS SupplierName,
	--	S.Code AS SupplierCode,
	--	AVG(PH.NetTotal),
	--	AVG(PH.GrossTotal),
	--	AVG(PH.TaxTotal),
	--	AVG(PH.TotalDiscount)--,
	--	--PH.DocumentDate
	--FROM PoHeaders PH
	--inner JOIN StockTransactionHeaders ST ON ST.ReferenceID = PH.Id
	--INNER JOIN Suppliers S ON S.ID = PH.SupplierID
	--WHERE PH.IsApproved = 1
	--AND ST.TransactionType = 'GR'
	--AND PH.DocumentDate BETWEEN @FromDate AND @ToDate 
	--GROUP BY PH.Id, S.Name, S.Code
		SELECT  
			SU.Name SupplierName,
			SU.Code AS SupplierCode,
			--LO.Name AS LocationName,
			ISNULL(SUM(TX.TaxAmount),0) AS TaxAmount,
			--SUM( CASE WHEN SD.DiscountValue=0 THEN SD.Quantity * SD.UnitPrice * SD.DiscountPercentage /100 ELSE  SD.DiscountValue END ) AS DiscountAmount,
			sum(SD.Quantity * SD.UnitPrice) AS NetAmount,
			--ISNULL(SUM(SA.ChargeAmount),0) AS ChargeAmount,
			sum(SD.Quantity * SD.UnitPrice) -- net value
			- SUM( CASE WHEN SD.DiscountValue=0 THEN SD.Quantity * SD.UnitPrice * SD.DiscountPercentage /100 ELSE  SD.DiscountValue END ) -- discount
			+ ISNULL(SUM(SA.ChargeAmount),0) -- additional charges
			+ ISNULL(SUM(TX.TaxAmount),0) GRNAmount -- tax
		--INTO #TempGRN
		FROM STOCKTRANSACTIONHEADERS SH
		INNER JOIN STOCKTRANSACTIONDETAILS SD ON SH.ID = SD.StockTransactionHeaderID
		INNER JOIN SUPPLIERS SU ON SU.ID = SH.SupplierID
		--INNER JOIN LOCATIONS LO ON LO.ID = SH.LocationID
		--LEFT JOIN POHEADERS PH ON PH.ID = SH.ReferenceID
		LEFT JOIN StockTransactionwiseCharges SA ON SA.StockTransactionHeaderID = SH.Id
		LEFT JOIN StockTransactionwiseTaxes TX ON TX.StockTransactionDetailID = SD.Id
		WHERE SH.TRANSACTIONTYPE='GR'
		AND SH.PropertyID = @PropertyID
		AND SH.TransactionDate BETWEEN @FromDate AND @ToDate
		--AND SH.SupplierID = CASE WHEN @SupplierID = -999 THEN SH.SupplierID ELSE @SupplierID END
		GROUP BY SU.Name,SU.Code--,LO.Name
END

GO

