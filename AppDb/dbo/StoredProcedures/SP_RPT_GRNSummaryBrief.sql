-- =============================================
-- Author:		Nivesh
-- Create date: 2025-07-02
-- Description:	Report GRN summary Breif
-- =============================================
-- SP_RPT_GRNSummaryBrief 1,-999,-999,'2025-01-01', '2025-12-01'

CREATE PROCEDURE [dbo].[SP_RPT_GRNSummaryBrief]
	@PropertyID INT,
	@LocationID INT = -999,
	@SupplierID INT = -999,
	@FromDate DATE = NULL,
	@ToDate DATE = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @FromDate IS NULL OR @FromDate = ''
	SET @FromDate = GETDATE()

	IF @ToDate IS NULL OR @ToDate = ''
	SET @ToDate = GETDATE()

	SELECT 
		SH.DocumentNo,
		S.Name AS Supplier,
		L.Name AS [Location],
		ISNULL((select ISNULL(sum(stw.ChargeAmount),0) 
		from StockTransactionwiseCharges STW
		inner join StockTransactionHeaders ST on stw.StockTransactionHeaderID= st.Id
		where st.id= SH.Id),0) AdditionalCharge,
		 ISNULL(SUM(SD.unitprice*SD.quantity),0) AS netTotal,
		 ISNULL(SUM(CASE WHEN Sd.DiscountPercentage>0 and  sd.DiscountValue =0 THEN (UnitPrice *Sd.DiscountPercentage /100)* Quantity else sd.DiscountValue end ),0) DiscountValue,
		 ISNULL(SUM(ST.TaxAmount),0) TaxAmoun,
		 PH.PoNo,
		FORMAT(SH.TransactionDate,'yyyy-MM-dd') TransactionDate,
		SH.ReferenceNo InvoiceNo,
		FORMAT(SH.InvoiceDate,'yyyy-MM-dd') InvoiceDate
	FROM
	StockTransactionHeaders SH
	INNER JOIN StockTransactionDetails SD ON SD.StockTransactionHeaderID = SH.Id
	INNER JOIN Locations L ON L.ID = SH.LocationID
	INNER JOIN Suppliers S ON S.ID = SH.SupplierID
	LEFT OUTER JOIN StockTransactionwiseTaxes AS st ON sd.Id = st.StockTransactionDetailID AND sd.StockItemID = st.StockItemID
	LEFT OUTER JOIN PoHeaders PH on PH.Id = SH.ReferenceID AND PH.PropertyID = SH.PropertyID
	WHERE SH.TransactionType = 'GR'
	AND SH.TransactionDate BETWEEN @FromDate AND @ToDate
	AND SH.LocationID = CASE WHEN @LocationID = -999 THEN SH.LocationID ELSE @LocationID END
	AND SH.SupplierID = CASE WHEN @SupplierID = -999 THEN SH.SupplierID ELSE @SupplierID END
	AND SH.PropertyID = @PropertyID
	GROUP BY SH.DocumentNo,S.Name,L.Name,SH.TransactionDate, SH.ReferenceNo,SH.InvoiceDate,SH.Id,PH.PoNo
	ORDER BY SH.DocumentNo

END

GO

