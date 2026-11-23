-- =============================================
-- Author:		ISURU PRAMODYA
-- Create date: FEB 16 2023
-- Description:	SSRS Reprint Select

-- exec [dbo].[rptPrintAllReports] 64,'thilini',SR

-- exec [dbo].[rptPrintAllReports] 118,'thilini',IR

-- exec [dbo].[rptPrintAllReports] 119,'thilini',DN

-- exec [dbo].[rptPrintAllReports] 2208,'thilini',AA
-- =============================================
CREATE   PROCEDURE [dbo].[rptPrintAllReports]
	(
	  @StockTxnID INT,
	  @UserName varchar(50),
	  @TransactionType varchar(5)
	)
AS
BEGIN

 --  select RH.DocumentNo,RH.RequestDate,RH.UserProfileID,SH.StockItemCode,SH.Name AS StockItemName,U.Name as UnitName,RT.Remarks,RT.UnitPrice,RT.ApprovedQuantity,RT.UnitPrice*RT.ApprovedQuantity AS Total,
 --  l.Name as Location
 --  from RequestHeaders RH
 --  INNER JOIN RequestDetails RT on RT.RequestHeaderID=RH.Id
 --  INNER JOIN StockItemDetails SD on SD.StockItemHeaderID=RT.StockItemID and RH.LocationID=sd.LocationID
 --  INNER JOIN StockItemHeaders SH on SH.Id = RT.StockItemID
 --   INNER JOIN Locations AS l ON RH.LocationID = l.Id
	--INNER JOIN Companies ON l.CompanyID = Companies.CompanyID
	--INNER JOIN Units AS U ON U.Id=RT.UnitID
 --  where RequestType='RP' and RH.ID=@StockTxnID

 
 DECLARE @ApprovedUserName VARCHAR(MAX)

 		SELECT @ApprovedUserName = STUFF((
		SELECT DISTINCT ' | ' + ISNULL(CU.UserName, '')
		FROM grnapprovallog AP
		INNER JOIN CentralUsers CU 
		ON CU.Id = AP.UserProfileId 
		AND AP.TransactionType = @TransactionType
		WHERE AP.StockTransactionHeaderID = @StockTxnID
		FOR XML PATH('')
		), 1, 3, '');

   IF(@TransactionType='SR') --Supplier Return
   BEGIN

   DECLARE @TaxAmount decimal

     SELECT @TaxAmount =sum(tt.TaxAmount)
    FROM    dbo.StockTransactionwiseTaxes tt
            INNER JOIN dbo.StockTransactionDetails sd ON sd.Id = tt.StockTransactionDetailID
                                                AND sd.StockItemID = tt.StockItemID
            INNER JOIN dbo.TaxDetails td ON td.TaxTypeId = tt.TaxTypeID
    WHERE   sd.StockTransactionHeaderID = @StockTxnID
           

			SELECT   sh.DocumentNo, sh.TransactionDate, l.Name AS location,s.Name AS supplierName, s.Address1, s.Telephone1, s.Email,  sh.ReferenceNo as InvoiceNo, s.Code AS suppCode,si.StockItemCode, si.Name AS ItemName, ct.Name AS Category, 
						sd.Remarks, sd.UnitPrice, sd.Quantity,sd.unitprice*sd.quantity as total, u.Name AS unit, CASE WHEN Sd.DiscountPercentage>0 and  sd.DiscountValue =0 THEN (UnitPrice *Sd.DiscountPercentage /100) * Quantity else sd.DiscountValue end DiscountValue ,@TaxAmount as TaxAmount,
						Companies.Name, Companies.Address1 AS compAdd1, Companies.Address2 AS compAdd2, --CM.Name AS SupplyCurrency
						Companies.Address3 AS compAdd3, Companies.Telephone1 AS compTel1, Companies.Email AS compEmail, Companies.WebAddress, CE.UserName AS Preaperduser,
						concat( si.name, case when (select Temperature from StockItemWiseTemperature where StockItemID=sd.StockItemID and LocationID=sh.LocationID 
						and sh.TransactionID=sd.StockTransactionHeaderID and TransactionType='SR')is not null then 
						concat (' Temp: ' , (select Temperature from StockItemWiseTemperature where StockItemID=sd.StockItemID and LocationID=sh.LocationID 
						and sh.TransactionID=sd.StockTransactionHeaderID and TransactionType='SR') ) else '' end,
						case when (select convert(char(10),EXPDate,103) from StockItemWiseEXPDateIns where StockItemID=sd.StockItemID and LocationID=sh.LocationID 
						and TransactionID=sd.StockTransactionHeaderID and TransactionType='SR') is not null then 
						concat(' Exp:',(select convert(char(10),EXPDate,103) from StockItemWiseEXPDateIns where StockItemID=sd.StockItemID and LocationID=sh.LocationID 
						and TransactionID=sd.StockTransactionHeaderID and TransactionType='SR')) else '' end) as ItemNameN,
						(SELECT TOP(1) DocumentNo FROM StockTransactionHeaders where id = sh.ReferenceID and TransactionType = 'GR') AS GRNNO
						,SH.Remarks HeaderRemark,S.VatNo,Companies.TaxRegistrationNumber1,'' PoNo
						,SH2.DocumentNo GRNDoc
						,(SD.Quantity * SD.MasterUnitConversion) as MasterUnitQty
						,u1.Name as MasterUnit
		FROM        StockTransactionHeaders AS sh INNER JOIN
						StockTransactionDetails AS sd ON sh.Id = sd.StockTransactionHeaderID INNER JOIN
						Locations AS l ON sh.LocationID = l.Id INNER JOIN
						Suppliers AS s ON sh.SupplierID = s.ID 
						LEFT OUTER JOIN CurrencyMasters AS cm ON sh.SuppCurrencyID = cm.Id 
						INNER JOIN Units AS u ON sd.TxnUnitID = u.Id
						INNER JOIN Units AS u1 ON sd.MasterUnitID = u1.Id
						INNER JOIN StockItemHeaders AS si 
						INNER JOIN Categories AS ct ON si.CategoryID = ct.Id ON sd.StockItemID = si.Id 
						INNER JOIN Companies ON l.CompanyID = Companies.CompanyID
						INNER JOIN CentralUsers CE ON CE.Id = SH.UserProfileID
						INNER JOIN StockTransactionHeaders SH2 ON SH2.Id = SH.ReferenceID AND SH2.TransactionType ='GR'
		WHERE		sh.id=@StockTxnID and sh.TransactionType=@TransactionType--'SR'
	END

	IF(@TransactionType='IR') --Issue Return
	BEGIN


		  SELECT   sh.DocumentNo, sh.TransactionDate, l.Name AS location, sh.ReferenceNo as InvoiceNo,si.StockItemCode, si.Name AS ItemName, ct.Name AS Category, 
						sd.Remarks, sd.UnitPrice, sd.Quantity,sd.unitprice*sd.quantity as total, u.Name AS unit, CASE WHEN Sd.DiscountPercentage>0 and  sd.DiscountValue =0 THEN (UnitPrice *Sd.DiscountPercentage /100) * Quantity else sd.DiscountValue end DiscountValue , St.TaxAmount,
						Companies.Name, Companies.Address1 AS compAdd1, Companies.Address2 AS compAdd2, 
						Companies.Address3 AS compAdd3, Companies.Telephone1 AS compTel1, Companies.Email AS compEmail, Companies.WebAddress, CE.UserName AS Preaperduser,
						concat( si.name, case when (select Temperature from StockItemWiseTemperature where StockItemID=sd.StockItemID and LocationID=sh.LocationID 
						and TransactionID=sd.StockTransactionHeaderID and TransactionType='SR')is not null then 
						concat (' Temp: ' , (select Temperature from StockItemWiseTemperature where StockItemID=sd.StockItemID and LocationID=sh.LocationID 
						and TransactionID=sd.StockTransactionHeaderID and TransactionType='SR') ) else '' end,
						case when (select convert(char(10),EXPDate,103) from StockItemWiseEXPDateIns where StockItemID=sd.StockItemID and LocationID=sh.LocationID 
						and TransactionID=sd.StockTransactionHeaderID and TransactionType='SR') is not null then 
						concat(' Exp:',(select convert(char(10),EXPDate,103) from StockItemWiseEXPDateIns where StockItemID=sd.StockItemID and LocationID=sh.LocationID 
						and TransactionID=sd.StockTransactionHeaderID and TransactionType='SR')) else '' end) as ItemNameN
		FROM        StockTransactionHeaders AS sh 
					INNER JOIN StockTransactionDetails AS sd ON sh.Id = sd.StockTransactionHeaderID 
					INNER JOIN Locations AS l ON sh.LocationID = l.Id 
					--INNER JOIN Suppliers AS s ON sh.SupplierID = s.ID 
					----	INNER JOIN CurrencyMasters AS cm ON sh.SuppCurrencyID = cm.Id 
					INNER JOIN Units AS u ON sd.TxnUnitID = u.Id
					INNER JOIN StockItemHeaders AS si 
					INNER JOIN Categories AS ct ON si.CategoryID = ct.Id ON sd.StockItemID = si.Id 
					INNER JOIN Companies ON l.CompanyID = Companies.CompanyID
					LEFT OUTER JOIN StockTransactionwiseTaxes AS st ON sd.Id = st.StockTransactionDetailID AND sd.StockItemID = st.StockItemID
					INNER JOIN CentralUsers CE ON CE.Id = SH.UserProfileID
		WHERE		sh.id=@StockTxnID and sh.TransactionType=@TransactionType--'IR'
	END
	IF(@TransactionType = 'DN') --DAMAMGE NOTE
	BEGIN
	 SELECT   sh.DocumentNo, sh.TransactionDate, l.Name AS location, sh.ReferenceNo as InvoiceNo,si.StockItemCode, si.Name AS ItemName, ct.Name AS Category, 
						sd.Remarks, sd.UnitPrice, sd.Quantity,sd.unitprice*sd.quantity as total, u.Name AS unit, CASE WHEN Sd.DiscountPercentage>0 and  sd.DiscountValue =0 THEN (UnitPrice *Sd.DiscountPercentage /100) * Quantity else sd.DiscountValue end DiscountValue , St.TaxAmount,
						Companies.Name, Companies.Address1 AS compAdd1, Companies.Address2 AS compAdd2, 
						Companies.Address3 AS compAdd3, Companies.Telephone1 AS compTel1, Companies.Email AS compEmail, Companies.WebAddress, CE.UserName AS Preaperduser,
						concat( si.name, case when (select Temperature from StockItemWiseTemperature where StockItemID=sd.StockItemID and LocationID=sh.LocationID 
						and TransactionID=sd.StockTransactionHeaderID and TransactionType='SR')is not null then 
						concat (' Temp: ' , (select Temperature from StockItemWiseTemperature where StockItemID=sd.StockItemID and LocationID=sh.LocationID 
						and TransactionID=sd.StockTransactionHeaderID and TransactionType='SR') ) else '' end,
						case when (select convert(char(10),EXPDate,103) from StockItemWiseEXPDateIns where StockItemID=sd.StockItemID and LocationID=sh.LocationID 
						and TransactionID=sd.StockTransactionHeaderID and TransactionType='SR') is not null then 
						concat(' Exp:',(select convert(char(10),EXPDate,103) from StockItemWiseEXPDateIns where StockItemID=sd.StockItemID and LocationID=sh.LocationID 
						and TransactionID=sd.StockTransactionHeaderID and TransactionType='SR')) else '' end) as ItemNameN
		FROM        StockTransactionHeaders AS sh 
					INNER JOIN StockTransactionDetails AS sd ON sh.Id = sd.StockTransactionHeaderID 
						INNER JOIN Locations AS l ON sh.LocationID = l.Id 
					--INNER JOIN Suppliers AS s ON sh.SupplierID = s.ID 
					----	INNER JOIN CurrencyMasters AS cm ON sh.SuppCurrencyID = cm.Id 
					INNER JOIN Units AS u ON sd.TxnUnitID = u.Id
					INNER JOIN StockItemHeaders AS si 
					INNER JOIN Categories AS ct ON si.CategoryID = ct.Id ON sd.StockItemID = si.Id 
					INNER JOIN Companies ON l.CompanyID = Companies.CompanyID
					LEFT OUTER JOIN StockTransactionwiseTaxes AS st ON sd.Id = st.StockTransactionDetailID AND sd.StockItemID = st.StockItemID
					INNER JOIN CentralUsers CE ON CE.Id = SH.UserProfileID
		WHERE		sh.id=@StockTxnID and sh.TransactionType=@TransactionType--'IR'
		END
		IF(@TransactionType='AA') --stock Reconciliation
		BEGIN
		SELECT   sh.DocumentNo, sh.TransactionDate, l.Name AS location, sh.ReferenceNo as InvoiceNo,si.StockItemCode, si.Name AS ItemName, ct.Name AS Category, 
						sd.Remarks, sd.UnitPrice,  FORMAT( sd.Quantity, '#,0.') as Quantity1,sd.unitprice*sd.quantity as total, u.Name AS unit, CASE WHEN Sd.DiscountPercentage>0 and  sd.DiscountValue =0 THEN (UnitPrice *Sd.DiscountPercentage /100) * Quantity else sd.DiscountValue end DiscountValue , St.TaxAmount,
						Companies.Name, Companies.Address1 AS compAdd1, Companies.Address2 AS compAdd2,  FORMAT(sd.StockMasterQuantity, '#,0.') as StockMasterQuantity1,FORMAT(sd.Quantity - sd.StockMasterQuantity, '#,0.') as Variance1,
						Companies.Address3 AS compAdd3, Companies.Telephone1 AS compTel1, Companies.Email AS compEmail, Companies.WebAddress, CE.UserName AS Preaperduser, 
						concat( si.name, case when (select Temperature from StockItemWiseTemperature where StockItemID=sd.StockItemID and LocationID=sh.LocationID 
						and TransactionID=sd.StockTransactionHeaderID and TransactionType='SR')is not null then 
						concat (' Temp: ' , (select Temperature from StockItemWiseTemperature where StockItemID=sd.StockItemID and LocationID=sh.LocationID 
						and TransactionID=sd.StockTransactionHeaderID and TransactionType='SR') ) else '' end,
						case when (select convert(char(10),EXPDate,103) from StockItemWiseEXPDateIns where StockItemID=sd.StockItemID and LocationID=sh.LocationID 
						and TransactionID=sd.StockTransactionHeaderID and TransactionType='SR') is not null then 
						concat(' Exp:',(select convert(char(10),EXPDate,103) from StockItemWiseEXPDateIns where StockItemID=sd.StockItemID and LocationID=sh.LocationID 
						and TransactionID=sd.StockTransactionHeaderID and TransactionType='SR')) else '' end) as ItemNameN
						--,sd.Quantity as Variance,
						,sd.StockMasterQuantity as Quantity, sd.NewQuantity as StockMasterQuantity
						,(sd.NewQuantity - sd.StockMasterQuantity) as Variance
						,ISNULL(@ApprovedUserName,'N/A') ApprovedUserName
						, ISNULL(WA.WastageAmount,0) WastageAmount
						,ISNULL(WA.WastagePercentage,0) WastagePercentage
		FROM        StockTransactionHeaders AS sh 
					INNER JOIN StockTransactionDetails AS sd ON sh.Id = sd.StockTransactionHeaderID 
						INNER JOIN Locations AS l ON sh.LocationID = l.Id 
					--INNER JOIN Suppliers AS s ON sh.SupplierID = s.ID 
					----	INNER JOIN CurrencyMasters AS cm ON sh.SuppCurrencyID = cm.Id 
					INNER JOIN Units AS u ON sd.TxnUnitID = u.Id
					INNER JOIN StockItemHeaders AS si 
					INNER JOIN Categories AS ct ON si.CategoryID = ct.Id ON sd.StockItemID = si.Id 
					INNER JOIN Companies ON l.CompanyID = Companies.CompanyID
					LEFT OUTER JOIN StockTransactionwiseTaxes AS st ON sd.Id = st.StockTransactionDetailID AND sd.StockItemID = st.StockItemID
					INNER JOIN CentralUsers CE ON CE.Id = SH.UserProfileID
					OUTER APPLY dbo.fn_GetWastageAmount(sd.StockItemID, sh.TransactionDate, sh.LocationID) WA
	 WHERE	        sh.id=@StockTxnID and sh.TransactionType=@TransactionType--'AA'
		END

		--Added by Tharuka 2026-09-17 : Franchise Invoice Return (rptFranchiseInvoiceReturn)
		IF(@TransactionType='BR')
		BEGIN
		
			SELECT  sh.DocumentNo, sh.TransactionDate, l.Name AS location, BI.DocumentNo AS InvoiceNo, si.StockItemCode, si.Name AS ItemName, ct.Name AS Category,
					sd.Remarks, ISNULL(sd.SellingPrice, 0) AS UnitPrice, sd.Quantity, ISNULL(sd.SellingPrice, 0) * sd.Quantity AS total, u.Name AS unit,
					CAST(0 AS DECIMAL(18, 6)) AS DiscountValue, CAST(0 AS DECIMAL(18, 6)) AS TaxAmount,
					Companies.Name, Companies.Address1 AS compAdd1, Companies.Address2 AS compAdd2,
					Companies.Address3 AS compAdd3, Companies.Telephone1 AS compTel1, Companies.Email AS compEmail, Companies.WebAddress, CE.UserName AS Preaperduser,
					concat( si.name,
							case when (select TOP (1) convert(char(10),EXPDate,103) from StockItemWiseEXPDateIns where StockItemID=sd.StockItemID and LocationID=sh.LocationID
									   and TransactionID=sd.StockTransactionHeaderID and TransactionType='BR') is not null then
							concat(' Exp:',(select TOP (1) convert(char(10),EXPDate,103) from StockItemWiseEXPDateIns where StockItemID=sd.StockItemID and LocationID=sh.LocationID
									   and TransactionID=sd.StockTransactionHeaderID and TransactionType='BR')) else '' end) as ItemNameN,
					ISNULL(D.Name, FL.Name) AS FranchiseLocation,
					sh.ReferenceNo AS SourceDocumentNo,
				--added by Isuru 2026-09-18 source document straight from the referenced header (SR or BI) and its type,
					--so rptFranchiseInvoiceReturn shows the Supplier Return No row for an SR-sourced return
					SRC.DocumentNo AS SourceDocumentNo,
					SRC.TransactionType AS SourceDocumentType,

					BI.TaxInvoiceNumber,
					sh.Remarks AS HeaderRemark,
					ISNULL(sd.UnitPrice, 0) AS CostPrice
			FROM        StockTransactionHeaders AS sh
						INNER JOIN StockTransactionDetails AS sd ON sh.Id = sd.StockTransactionHeaderID
						INNER JOIN Locations AS l ON sh.LocationID = l.Id
						INNER JOIN Units AS u ON sd.TxnUnitID = u.Id
						INNER JOIN StockItemHeaders AS si
						INNER JOIN Categories AS ct ON si.CategoryID = ct.Id ON sd.StockItemID = si.Id
						INNER JOIN Companies ON l.CompanyID = Companies.CompanyID
						INNER JOIN CentralUsers CE ON CE.Id = SH.UserProfileID
						LEFT JOIN Departments AS D ON D.Id = sh.DepartmentID
						LEFT JOIN Locations AS FL ON FL.Id = sh.InvoiceLocationID
						LEFT JOIN StockTransactionHeaders AS SRC ON SRC.Id = sh.ReferenceID
						LEFT JOIN StockTransactionHeaders AS GR ON GR.Id = SRC.ReferenceID AND SRC.TransactionType = 'SR' AND GR.TransactionType = 'GR'
						LEFT JOIN StockTransactionHeaders AS BI ON BI.TransactionType = 'BI'
															   AND BI.Id = CASE WHEN SRC.TransactionType = 'BI' THEN SRC.Id ELSE GR.ReferenceID END
			WHERE		sh.id=@StockTxnID and sh.TransactionType=@TransactionType--'BR'
			ORDER BY si.Name
		END
		--End

END

GO

