-- =============================================
-- Author:		Isuru
-- Create date: 2026-09-22
-- Description:	GRN and SRN summary spplier wise report

-- [dbo].[RPT_GRNSummarySupplierWise] '2026-01-07' , '2026-01-07',1,-999,1

-- =============================================
create PROCEDURE [dbo].[RPT_GRNSummarySupplierWise] 
	@FromDate VARCHAR(100),
	@ToDate VARCHAR(100),
	@LocationID INT,
	@SupplierID INT,
	@PropertyID INT
AS
BEGIN
	SET NOCOUNT ON;

		SELECT TR.Name TransactionType,SU.Code,SU.Name SupplierName,STH.DocumentNo,STH.TransactionDate
		,sum(STD.Quantity * STD.UnitPrice) SubTotal
		,SUM( CASE WHEN STD.DiscountValue=0 THEN STD.Quantity * STD.UnitPrice * STD.DiscountPercentage /100 ELSE  STD.DiscountValue END ) Discount
		,SUM(ISNULL(STX.TaxAmount,0)) TaxAmount
		,MAX(ISNULL(STC.ChargeAmount, 0)) AS ChargeAmount
		
		,sum(STD.Quantity * STD.UnitPrice) -
		SUM( CASE WHEN STD.DiscountValue=0 THEN STD.Quantity * STD.UnitPrice * STD.DiscountPercentage /100 ELSE  STD.DiscountValue END ) 
		+ SUM(ISNULL(STX.TaxAmount,0)) + MAX(ISNULL(STC.ChargeAmount, 0)) AS InvoiceAmount 
		FROM StockTransactionHeaders STH
		INNER JOIN StockTransactionDetails STD ON STH.ID = STD.StockTransactionHeaderID
		INNER JOIN Suppliers SU ON SU.ID = STH.SupplierID
		INNER JOIN Locations LO ON STH.LocationID = LO.Id
		LEFT JOIN StockTransactionwiseTaxes STX ON STX.StockTransactionDetailID = STD.Id AND STX.StockItemID = STD.StockItemID
		INNER JOIN TransactionTypes TR ON TR.Code = STH.TransactionType
		LEFT JOIN StockTransactionwiseCharges STC ON STC.StockTransactionHeaderID = STH.Id
		WHERE STH.TransactionType IN ('GR','SR')
		AND STH.TransactionDate BETWEEN @FromDate AND @ToDate
		AND STH.LocationID = CASE WHEN @LocationID = -999 THEN STH.LocationID ELSE @LocationID END
		AND STH.SupplierID = CASE WHEN @SupplierID = -999 THEN STH.SupplierID ELSE @SupplierID END
		GROUP BY TR.Name,SU.Code,SU.Name ,STH.DocumentNo,STH.TransactionDate
		ORDER BY STH.TransactionDate, SU.Name

  
END

GO

