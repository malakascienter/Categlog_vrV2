
--  SP_SelectPOsFromPropertyLocationAndSupplier 1,3597,1

CREATE PROCEDURE [dbo].[SP_SelectPOsFromPropertyLocationAndSupplier]
@PropertyId	INT,
@LocationID	INT,
@SupplireID	INT
--,@CurrencyId INT

AS
BEGIN

	DECLARE @departmentID INT

	SELECT @departmentID = D.Id
	FROM Departments D
	INNER JOIN Locations L ON L.DepartmentID = D.Id
	WHERE L.ID = @LocationID




	SELECT *
	FROM (
	SELECT DISTINCT PH.Id,CASE WHEN PH.IsInvoicebased = 1 THEN CONCAT(CONVERT(DATE,PH.DocumentDate),' | ',PH.PoNo,' | ',IH.DocumentNo) ELSE CONCAT(CONVERT(DATE,PH.DocumentDate),' | ',PH.PoNo)  END AS PoNo,
	ISNULL(PH.POType,1) POType, PH.Remarks AS Remarks,0 IsBackEndInvoice, PH.IsInvoicebased,
	CAST(NULL AS VARCHAR(MAX)) AS TaxInvoiceNumber,
	CAST(NULL AS DATE) AS TransactionDate
	FROM dbo.PoHeaders PH
	INNER JOIN dbo.PoDetails PD ON PH.Id = PD.PoHeaderID
	LEFT JOIN dbo.Invoice_Header IH ON IH.ID = PH.InvoiceID
	WHERE PH.PropertyID = @PropertyId
	AND PH.LocationID = @LocationID
	AND PH.SupplierID = @SupplireID
	--AND PH.CurrencyId = @CurrencyId
	AND PH.IsApproved = 1 and DocumentStatus ='P'
	--ORDER BY PH.Id DESC

	UNION

	SELECT DISTINCT STH.Id, CONCAT(CONVERT(DATE,STH.TransactionDate), ' | ',STH.DocumentNo , ' | ', STH.TaxInvoiceNumber) AS PoNo,1 POType, STH.Remarks  AS Remarks,1 IsBackEndInvoice, 0 IsInvoicebased,
	STH.TaxInvoiceNumber AS TaxInvoiceNumber,
	STH.TransactionDate AS TransactionDate   -- added by Tharuka 2026-08-14
	FROM StockTransactionHeaders STH
	inner join StockTransactionDetails STD on STH.Id = STD.StockTransactionHeaderID
	--inner join SupplierWiseItemDetails SI on SI.LocationId = STH.InvoiceLocationID  -- commented by Tharuka 2026-08-14 
	WHERE STH.InvoiceLocationID = @LocationID AND STH.SupplierID = @SupplireID AND STH.TransactionType = 'BI' AND STH.InvoiceDocStatus = 'P' 
	--added by Isuru 2026-09-18 hide invoices with nothing left to receive (fully returned by a 'BR')
	AND (STD.Quantity - ISNULL(STD.ReturnQuantity, 0)) > 0


	) AS A
	ORDER BY A.Id DESC

END

GO

