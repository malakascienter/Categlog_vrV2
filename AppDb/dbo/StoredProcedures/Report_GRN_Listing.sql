
-- =============================================
-- Author:		Banu
-- ALTER date: 21/12/2018
-- Description:	Report GRN Listing
-- =============================================
CREATE PROCEDURE [dbo].[Report_GRN_Listing]
	@FromDate VARCHAR(10),
	@ToDate VARCHAR(10),
	@Suplier VARCHAR(MAX),
	@Outlet VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT Docno AS 'GRN Number', G.SuppInvNo AS 'Invoice Number', Date2 AS 'Date',
		G.Suppcode AS 'Supplier Code', S.SuppName AS 'Supplier Name', Remarks,
		0 AS 'Quantity', TotValue AS 'Gross Value', (TaxVal2) AS 'Vat',
		(TotValue + TaxVal2 ) AS 'Net Value',
		L.code as 'OutletCode', L.description As 'Outlet',
		G.SupInvDate AS 'SupInvDate'
	FROM GRNHeader G
	INNER JOIN SupplierMaster S ON G.Suppcode = S.SuppCode 
	INNER JOIN Location L ON G.Location = L.code
	WHERE G.Date2 >= CONVERT(DATETIME,@FromDate,103)
		AND G.Date2 <= CONVERT(DATETIME,@ToDate,103)
		AND G.Location IN (SELECT * FROM STRING_SPLIT(@Outlet,','))
		AND G.Suppcode IN (SELECT * FROM STRING_SPLIT(@Suplier,','))
END

GO

