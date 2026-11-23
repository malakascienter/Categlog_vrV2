-- =============================================
-- Author:		ISURU PRAMODYA
-- Create date: 2023 APRIL 04
-- Description:	PRINTIN TEMPORY ISSUE RETURN REPORTS

-- [dbo].[rptPrintApprovalIR] 7444,'THILINI'
-- =============================================
create PROCEDURE [dbo].[rptPrintApprovalIR]
(
@StockTxnID INT,
@UserName varchar(50)
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @GRNXML VARCHAR(MAX),
				@NEWGRNXML XML,
				@iDocID INT,
				@iDocIDORG INT,
				@StockItemCode VARCHAR(MAX),
				@ItemName VARCHAR(MAX),
				@Category VARCHAR(MAX),
				@Remarks varchar(max),
				@UnitPrice MONEY,
				@Quantity decimal(18,6),
				@BaseCurrency VARCHAR(10),
				@TxnCurrency VARCHAR(10),
				@ExchangeRate MONEY=1,
				@unit varchar(max),
				@DiscountValue decimal(18,6),
				@ItemTotal decimal(18,6),
				@StockItemID BIGINT,
				@SupplierID INT,
				@TaxAmount decimal(18,6),
				@Preaperduser VARCHAR(20)


	IF OBJECT_ID('tempdb..#TempDetails') IS NOT NULL
	BEGIN
	DROP TABLE #TempDetails
	END
				SELECT @GRNXML = XMLDetails FROM  [dbo].[GRNApprovalLog] WHERE Id = @StockTxnID

					SET @NEWGRNXML = CONVERT(XML,@GRNXML)

		EXEC sp_xml_preparedocument @iDocIDORG OUTPUT, @NEWGRNXML;

		SELECT * INTO #TempDetails FROM
			OPENXML(@iDocIDORG, '/StockTransactionHeader/StockDetailList/StockTransactionDetail', 2)
			WITH StockTransactionDetails

		--SELECT * FROM #TempDetails

		--SELECT * FROM  [dbo].[GRNApprovalLog] WHERE Id = 7444

			select @StockItemCode =  ST.StockItemCode, @ItemName = ST.Name, @Category = CA.Name, @Remarks = TD.Remarks,@UnitPrice = TD.UnitPrice,
			@Quantity =TD.Quantity, @unit = U.NAME,
			@DiscountValue = CASE WHEN TD.DiscountPercentage>0 and  TD.DiscountValue =0 THEN (TD.UnitPrice *TD.DiscountPercentage /100) / @ExchangeRate * TD.Quantity else TD.DiscountValue / @ExchangeRate  end
			,@StockItemID = TD. StockItemID, @ItemTotal = @UnitPrice * @Quantity / @ExchangeRate
			from #TempDetails TD 
			INNER JOIN StockItemHeaders ST ON ST.ID  = TD.StockItemID
			INNER JOIN Categories CA ON ST.CategoryID = CA.Id 
			INNER JOIN Units U ON U.Id = TD.TxnUnitID

			SELECT @Preaperduser=U.UserName
			FROM CentralUsers U
			INNER JOIN GRNApprovalLog GA ON GA.CreatedUserId = U.Id 
			WHERE GA.Id = 7444

		SELECT GR.ApprovalDocNo AS DocumentNo, GR.CreatedDate AS TransactionDate,LO.Name AS location, 
				 GR.ReferenceNo as InvoiceNo,@StockItemCode AS StockItemCode, @ItemName AS ItemNameN, @Category AS Category,
				@Remarks AS Remarks,@UnitPrice / @ExchangeRate AS UnitPrice,@Quantity as Quantity, @ItemTotal as total, @unit AS unit,
				@DiscountValue AS DiscountValue,@TaxAmount /@ExchangeRate AS TaxAmount,CO.Name,CO.Address1 AS compAdd1,CO.Address2 AS compAdd2,CO.Address3 AS compAdd3,
				CO.Telephone1 AS compTel1,CO.Email AS compEmail,CO.WebAddress,Po.PoNo,@ExchangeRate AS ExchangeRate,@Preaperduser AS Preaperduser
		FROM GRNApprovalLog GR
		INNER JOIN LOCATIONS LO  ON LO.ID = GR.LocationId
		--INNER JOIN SUPPLIERS SU ON SU.ID = GR.SupplierId
		--INNER JOIN CurrencyMasters CU ON CU.ID = SU.CurrencyID
		INNER JOIN Companies CO ON CO.CompanyID = LO.CompanyID
		left JOIN PoDetails sh ON SH.PoHeaderID = GR.ReferenceId
		left JOIN PoHeaders po ON sh.PoHeaderID = Po.ID
		WHERE GR.Id= @StockTxnID

		IF OBJECT_ID('tempdb..#TempDetails') IS NOT NULL
		BEGIN
		DROP TABLE #TempDetails
		END

   
END

GO

