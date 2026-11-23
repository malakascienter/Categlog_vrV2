-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-03-06
-- Description:	Supplier Wise GRN Listing Summary Report

-- [dbo].[Report_SupplierWiseGRNListing] '2025/03/01','2025/03/06',1,-999

-- =============================================
create PROCEDURE [dbo].[Report_SupplierWiseGRNListing]
@From DATE,
@TO DATE,
@CompanyId INT,
@SupplierID INT

AS
BEGIN
		SET NOCOUNT ON;

		SELECT  SU.Name SupplierName,PH.PoNo,PH.DocumentDate PODate,SH.DocumentNo GRNNO,SH.TransactionDate GRNDate,SH.ReferenceNo InvNo,LO.NAME LocationName,
		sum(SD.Quantity * SD.UnitPrice)- SUM( CASE WHEN SD.DiscountValue=0 THEN SD.Quantity * SD.UnitPrice * SD.DiscountPercentage /100 ELSE  SD.DiscountValue END ) + ISNULL(SUM(SA.ChargeAmount),0) + ISNULL(SUM(TX.TaxAmount),0) GRNAmount
		INTO #TempGRN
		FROM STOCKTRANSACTIONHEADERS SH
		INNER JOIN STOCKTRANSACTIONDETAILS SD ON SH.ID = SD.StockTransactionHeaderID
		INNER JOIN SUPPLIERS SU ON SU.ID = SH.SupplierID
		INNER JOIN LOCATIONS LO ON LO.ID = SH.LocationID
		LEFT JOIN POHEADERS PH ON PH.ID = SH.ReferenceID
		LEFT JOIN StockTransactionwiseCharges SA ON SA.StockTransactionHeaderID = SH.Id
		LEFT JOIN StockTransactionwiseTaxes TX ON TX.StockTransactionDetailID = SD.Id
		WHERE SH.TRANSACTIONTYPE='GR'
		AND SH.PropertyID = @CompanyId
		AND SH.TransactionDate BETWEEN @From AND @TO
		AND SH.SupplierID = CASE WHEN @SupplierID = -999 THEN SH.SupplierID ELSE @SupplierID END
		GROUP BY SU.Name,PH.PoNo,PH.DocumentDate,SH.DocumentNo ,SH.TransactionDate ,SH.ReferenceNo,LO.NAME 
		ORDER BY SH.TransactionDate

		SELECT *
		FROM #TempGRN
		WHERE GRNAmount >0


   
END

GO

