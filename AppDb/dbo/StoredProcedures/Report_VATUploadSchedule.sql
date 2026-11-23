
-- =============================================
-- Author:		Banu
-- ALTER date: 23/11/2018
-- Description:	Report VAT Upload Schedule
-- =============================================
-----EXEC Report_VATUploadSchedule '001,002,003', '01/09/2018', '01/11/2018','All' 
CREATE PROCEDURE [dbo].[Report_VATUploadSchedule]
	@Outlet VARCHAR(MAX),
	@FromDate VARCHAR(10),
	@ToDate VARCHAR(10),
	@Suplier VARCHAR(MAX)
AS
BEGIN
    SELECT G.Docno AS 'GRN_No', G.SuppInvNo AS 'SupplierInvNo', G.Suppcode AS 'SupplierCode',
		S.VatRegNo AS 'SupplierTIN' , S.SuppName  AS 'SupplierName', G.Remarks AS 'Description',
		G.TotValue AS 'ValOfPurchase', G.Date2 AS 'InvDate' ,
		CASE WHEN TaxPerc2 > 0 THEN (TotValue*TaxPerc2)/100 ELSE 0 END AS 'VATAmount'
	FROM GRNHeader G
	INNER JOIN SupplierMaster S ON G.Suppcode = S.SuppCode 
	WHERE Date2 >= CONVERT(datetime,@FromDate,103)
		AND Date2 <= CONVERT(datetime,@ToDate,103)
		AND G.Location IN (SELECT * FROM string_split(@Outlet,','))
		AND (@Suplier = 'All' OR S.SuppCode IN (SELECT * FROM string_split(@Suplier,',')))
		AND G.Docid = 'G'
END

GO

