-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2026-05-25
-- Description:	POST Backend Invoice to GL

-- [dbo].[PostInventoryBIoGL] 17,'IV'
-- =============================================
CREATE PROCEDURE [dbo].[PostInventoryBIoGL](@StockTransactionHeaderID INT,@TransType VARCHAR(2))
AS
BEGIN
	BEGIN TRY
	SET NOCOUNT ON;

	DECLARE
			 @CurrCode CHAR(3) = ''
			,@CrDrNo VARCHAR(50) = ''
			,@ExchangeRate MONEY
			,@DayEndUserID UNIQUEIDENTIFIER
			,@BSPCode VARCHAR(50) = ''
			,@InvoiceNo  VARCHAR(50) = ''
			,@MasterID VARCHAR(5)= '00001'

	DECLARE	@DocDetails XML = '',
			@DocDrDetails XML = '',
			@DocSegDetails XML = '',
			@DocTax XML = '',
			@Total DECIMAL(18,2) =0

	DECLARE @iErrorNumber		INT,
			@sErrorMessage		VARCHAR(250),
			@sErrorProcedure	VARCHAR(50)
			, @GLCompCode AS VARCHAR(3)
	DECLARE @BlockCode AS VARCHAR(4) = 'INV', @CustomerName Varchar(500)
	,@TaxTotal DECIMAL(18,2) = 0

	-- DocId was repeated as a nested CASE in four places; compute it once.
	DECLARE @DocId VARCHAR(1) =
		CASE WHEN @TransType IN ('CC','DN') THEN '2'
			 WHEN @TransType = 'CN' THEN '4'
			 ELSE '1' END

	SELECT @CurrCode='LKR',@CrDrNo= SH.documentNo, @ExchangeRate = 1, @BSPCode= DE.CustomerBSPCode, @InvoiceNo= SH.DocumentNo, @CustomerName= LO.Name
	,@GLCompCode = CO.Code,@MasterID= CO.MasterID
	FROM StockTransactionHeaders SH
	INNER JOIN Locations LO ON LO.Id = SH.InvoiceLocationID
	INNER JOIN Departments DE ON DE.Id = SH.DepartmentID
	INNER JOIN Companies CO ON CO.CompanyID = SH.PropertyID
	WHERE SH.ID = @StockTransactionHeaderID
	AND SH.TransactionType = 'BI'

	SELECT  @DayEndUserID = CU.UniqueId
	FROM StockTransactionHeaders SH
	INNER JOIN CentralUsers CU ON SH.CreatedUserID = CU.Id
	WHERE SH.Id = @StockTransactionHeaderID
	AND SH.TransactionType = 'BI'

	----------------------------------------------------------------------
	-- GUARD: every priced line must have a GL account mapping.
	-- Without this an unmapped line is silently dropped from the details
	-- (INNER JOIN) but still counted in the header -> a large tally mismatch
	-- with no indication of which item caused it.
	----------------------------------------------------------------------
	DECLARE @Unmapped VARCHAR(300)
	SELECT TOP 1 @Unmapped = L.Code + ' / ' + C.Code + ' / ' + SB.Code
	FROM StockTransactionHeaders IH
	INNER JOIN StockTransactionDetails ID2 ON IH.Id = ID2.StockTransactionHeaderID
	INNER JOIN StockItemHeaders SH2 ON SH2.Id = ID2.StockItemID
	INNER JOIN Locations L ON L.Id = IH.InvoiceLocationID
	INNER JOIN Categories C ON C.Id = SH2.CategoryID
	INNER JOIN SubCategories SB ON SH2.SubCategoryID = SB.ID
	WHERE IH.Id = @StockTransactionHeaderID AND ID2.SellingPrice > 0
	AND NOT EXISTS (SELECT 1 FROM Destinity_GLIntegrationAccountMapping M
					WHERE M.BlockCode = 'INV' AND M.Level1 = L.Code AND M.Level2 = C.Code AND M.Level3 = SB.Code)

	IF @Unmapped IS NOT NULL
	BEGIN
		SET @sErrorMessage = 'No GL account mapping for Location/Category/SubCategory: ' + @Unmapped
		RAISERROR (@sErrorMessage,16,1)
		RETURN 0
	END

	----------------------------------------------------------------------
	-- 1. DR DETAILS  (built FIRST - these are now the authoritative amounts)
	----------------------------------------------------------------------
	SELECT ModCrNoteNo, MasterID, ROW_NUMBER() OVER (ORDER BY DrAccCode) AS SeqNo, DrAccCode, DrNarration, round(sum(Amount),2) as Amount, DocId
	INTO #DocDrDetails FROM (
	SELECT
	@InvoiceNo AS ModCrNoteNo,
	@MasterID AS MasterID,
	MAP.AccCode AS DrAccCode,
	'Invoice ' + @InvoiceNo + ' for ' + @CustomerName AS DrNarration,
	ROUND(SUM(ID.Quantity*ID.SellingPrice),2) AS Amount,
	@DocId AS DocId
	FROM StockTransactionHeaders IH
	Inner join  StockTransactionDetails ID on IH.id = id.StockTransactionHeaderID
	Inner join StockItemHeaders sh on sh.Id = id.StockItemID
	inner join Locations l on l.id = ih.InvoiceLocationID
	inner join Categories C on C.id = sh.CategoryID
	inner join SubCategories SB on sh.subCategoryID = SB.ID
	Inner Join Destinity_GLIntegrationAccountMapping MAP on BlockCode = 'INV' And L.Code= map.Level1 and C.Code= MAP.Level2
	and SB.Code = MAP.Level3
	WHERE IH.Id = @StockTransactionHeaderID And Id.SellingPrice >0
	GROUP BY SH.TaxGroupID, MAP.AccCode, SB.Code
	)X
	GROUP BY ModCrNoteNo, MasterID, DrAccCode, DrNarration,  DocId

	SELECT	@DocDrDetails = (SELECT * FROM #DocDrDetails FOR XML PATH ('DatalList'), ROOT('ArrayOfDatalList'))

	----------------------------------------------------------------------
	-- 2. TAX DETAILS  (materialised so the header can be derived from it)
	----------------------------------------------------------------------
	SELECT
	@MasterID AS MasterID,
	@InvoiceNo AS ModCrNoteNo,
	@DocId AS DocId,
	S.TaxTypeID AS TaxID,
	T.Rate AS TaxRate,
	ROUND(Sum(TaxAmount),2) AS TaxAmount
	INTO #DocTaxDetails
	FROM StockTransactionwiseTaxes S
	INNER JOIN TaxDetails T ON S.TaxTypeID= T.TaxTypeID
	INNER JOIN [dbo].[StockTransactionDetails] D ON D.ID= S.[StockTransactionDetailID]
	WHERE D.StockTransactionHeaderID=@StockTransactionHeaderID
	GROUP BY S.TaxTypeID,T.Rate

	SELECT @DocTax = (SELECT MasterID, ModCrNoteNo, DocId, TaxID, TaxRate, TaxAmount
					  FROM #DocTaxDetails FOR XML PATH ('ARTaxList'), ROOT('ArrayOfARTaxList'))

	----------------------------------------------------------------------
	-- 3. HEADER TOTAL DERIVED FROM THE ROUNDED DETAILS   <<< THE FIX
	--    Was: @Total = SUM(raw Qty*Price) over ALL rows, rounded once at the end.
	--    Now: @Total = SUM of the exact rows being handed to the GL SP.
	----------------------------------------------------------------------
	SELECT @Total    = ISNULL(SUM(Amount),0)    FROM #DocDrDetails
	SELECT @TaxTotal = ISNULL(SUM(TaxAmount),0) FROM #DocTaxDetails

	----------------------------------------------------------------------
	-- 4. HEADER
	----------------------------------------------------------------------
	SELECT * INTO #DocDetails FROM (
	SELECT
	@DocId AS DocId,
	@MasterID AS MasterID,
	@BSPCode AS BSPCode,
	@InvoiceNo AS ModCrNoteNo,
	IH.TransactionDate as DocDate,
	@Total + @TaxTotal AS TotalDocAmt,
	'Invoice ' + @InvoiceNo + ' for ' + @CustomerName  AS  CrNarration,
	@DayEndUserID AS UserID,
	'' AS ModProType,
	@InvoiceNo AS  ModRefNo,
	'' AS  MFCenter,
	0 AS TransType,
	1 AS NoPax,
	'' AS TourNo,
	'' AS CustName,
	'' AS DepartureDate,
	'' AS ArrivalDate,
	@CrDrNo	AS BillNo,
	'IV' AS BillType,
	0 AS FolioNo,
	'' AS VoucherNo,
	'' AS ReservationNo,
	'' AS GroupReservationNo,
	'' AS GRCNo,
	@InvoiceNo as RefNo
	FROM StockTransactionHeaders IH
	inner join Locations l on l.id = ih.InvoiceLocationID
	WHERE IH.id = @StockTransactionHeaderID
	)X

	SELECT	@DocDetails	= (SELECT * FROM #DocDetails FOR XML PATH ('HeaderDataList'), ROOT('ArrayOfHeaderDataList') )

	----------------------------------------------------------------------
	-- 5. SEGMENT DETAILS
	--    NOTE: "And ID.SellingPrice > 0" added so the segment rows cover exactly
	--    the same lines as the Dr rows (previously they did not match).
	----------------------------------------------------------------------
	SELECT * INTO #DocSegDetails FROM (
	SELECT ModCrNoteNo, DocId, MasterID, SegmentID, SubSegCode, AccCode, DrCr, SUM(AMOUNT) AS AMOUNT,  ROW_NUMBER() OVER (ORDER BY AccCode) AS SeqNo FROM (
	SELECT
	@InvoiceNo AS ModCrNoteNo,
	@DocId AS DocId,
	@MasterID AS MasterID,
	SegmentCode  AS SegmentID ,
	SegmentCode  AS SubSegCode,
	MAP.AccCode AS AccCode,
	'C' AS DrCr,
	ROUND(SUM(ID.Quantity*ID.SellingPrice),2)  AS Amount,
	1 AS SeqNo
	FROM StockTransactionHeaders IH
	Inner join StockTransactionDetails ID on IH.id = id.StockTransactionHeaderID
	Inner join StockItemHeaders sh on sh.id = id.StockItemID
	inner join Locations l on l.id = ih.InvoiceLocationID
	inner join Categories C on C.id = sh.CategoryID
	inner join SubCategories SB on sh.subCategoryID = SB.ID
	Inner Join Destinity_GLIntegrationAccountMapping MAP on BlockCode = 'INV' And L.Code= map.Level1 and C.Code= MAP.Level2
	and SB.Code = MAP.Level3
	WHERE IH.ID = @StockTransactionHeaderID And ID.SellingPrice > 0
	GROUP BY SH.TaxGroupID,  C.Name, MAP.AccCode, SegmentCode
	)X GROUP BY ModCrNoteNo, DocId, MasterID, SegmentID, SubSegCode, AccCode, DrCr, SEQNO
	)Y

	SELECT @DocSegDetails = (SELECT * FROM #DocSegDetails FOR XML PATH ('ARSegmentList'), ROOT('ArrayOfARSegmentList'))

	----------------------------------------------------------------------
	-- 6. SAFETY NET: assert the tally here, with a message naming the invoice,
	--    before handing over. Stops the GL SP's unqualified ROLLBACK from
	--    tearing down the outer save transaction and masking the real error.
	----------------------------------------------------------------------
	IF (SELECT ISNULL(SUM(Amount),0) FROM #DocDrDetails) + (SELECT ISNULL(SUM(TaxAmount),0) FROM #DocTaxDetails)
	   <> (SELECT TotalDocAmt FROM #DocDetails)
	BEGIN
		SET @sErrorMessage = 'GL posting totals do not tally for invoice ' + @InvoiceNo
		RAISERROR (@sErrorMessage,16,1)
		RETURN 0
	END

	SELECT 'I' ModName, @DocDetails, @DocDrDetails, @DocSegDetails, @DocTax, @DayEndUserID, @CurrCode, @ExchangeRate, @GLCompCode, @CrDrNo
	
	EXEC [eFinancials_Accounting].dbo.[Destinity_AR_Populate_OtherModARposting] 'I', @DocDetails, @DocDrDetails, @DocSegDetails, @DocTax, @DayEndUserID, @CurrCode, @ExchangeRate, @GLCompCode, @CrDrNo OUTPUT

END TRY
BEGIN CATCH

		SELECT	@sErrorProcedure=ERROR_PROCEDURE()
		SELECT	@sErrorMessage	= ERROR_MESSAGE()
		SELECT	@iErrorNumber=ERROR_NUMBER()

		RAISERROR (@sErrorMessage,16,1)

		RETURN 0
	END CATCH
END

GO

