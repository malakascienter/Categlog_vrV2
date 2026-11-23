-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2026-09-18
-- Description:	POST Franchise Return (BR) to GL as an AR credit note.
--              Mirrors PostInventoryBIoGL; the return-specific parts (DocId 4 via @TransType 'CN',
--              segment DrCr 'D', narration and RefNo pointing at the original invoice) follow
--              GL_POSTING_INVOICE_Return_GET_OtherModulePosttoAR.
--              Amounts stay positive - direction is carried by DocId in
--              Destinity_AR_Populate_OtherModARposting (AR credited, revenue and tax debited).
--
-- [dbo].[PostInventoryBRoGL] 15207,'CN'
-- =============================================
CREATE PROCEDURE [dbo].[PostInventoryBRoGL](@StockTransactionHeaderID INT, @TransType VARCHAR(2))
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
			,@ReturnNo  VARCHAR(50) = ''
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
	,@SourceType CHAR(2), @BIHeaderID INT, @BIDocumentNo VARCHAR(50) = ''

	-- 'CN' is what the call site passes, giving DocId 4 (credit note). Same CASE as PostInventoryBIoGL.
	DECLARE @DocId VARCHAR(1) =
		CASE WHEN @TransType IN ('CC','DN') THEN '2'
			 WHEN @TransType = 'CN' THEN '4'
			 ELSE '1' END

	SELECT @CurrCode='LKR',@CrDrNo= SH.documentNo, @ExchangeRate = 1, @BSPCode= DE.CustomerBSPCode, @ReturnNo= SH.DocumentNo, @CustomerName= LO.Name
	,@GLCompCode = CO.Code,@MasterID= CO.MasterID
	FROM StockTransactionHeaders SH
	INNER JOIN Locations LO ON LO.Id = SH.InvoiceLocationID
	INNER JOIN Departments DE ON DE.Id = SH.DepartmentID
	INNER JOIN Companies CO ON CO.CompanyID = SH.PropertyID
	WHERE SH.ID = @StockTransactionHeaderID
	AND SH.TransactionType = 'BR'

	SELECT  @DayEndUserID = CU.UniqueId
	FROM StockTransactionHeaders SH
	INNER JOIN CentralUsers CU ON SH.CreatedUserID = CU.Id
	WHERE SH.Id = @StockTransactionHeaderID
	AND SH.TransactionType = 'BR'

	----------------------------------------------------------------------
	-- The invoice being credited. Same resolution SP_InsertStockTransactions
	-- uses for a 'BR': the source is either the 'BI' itself or an 'SR',
	-- which reaches its 'BI' through the franchise 'GR'.
	----------------------------------------------------------------------
	SELECT @SourceType = SRC.TransactionType
	FROM StockTransactionHeaders BR
	INNER JOIN StockTransactionHeaders SRC ON SRC.Id = BR.ReferenceID
	WHERE BR.Id = @StockTransactionHeaderID

	IF (@SourceType = 'BI')
		SELECT @BIHeaderID = BR.ReferenceID, @BIDocumentNo = BI.DocumentNo
		FROM StockTransactionHeaders BR
		INNER JOIN StockTransactionHeaders BI ON BI.Id = BR.ReferenceID AND BI.TransactionType = 'BI'
		WHERE BR.Id = @StockTransactionHeaderID
	ELSE IF (@SourceType = 'SR')
		SELECT @BIHeaderID = BI.Id, @BIDocumentNo = BI.DocumentNo
		FROM StockTransactionHeaders BR
		INNER JOIN StockTransactionHeaders SR ON SR.Id = BR.ReferenceID AND SR.TransactionType = 'SR'
		INNER JOIN StockTransactionHeaders GR ON GR.Id = SR.ReferenceID AND GR.TransactionType = 'GR'
		INNER JOIN StockTransactionHeaders BI ON BI.Id = GR.ReferenceID AND BI.TransactionType = 'BI'
		WHERE BR.Id = @StockTransactionHeaderID

	IF (@BIHeaderID IS NULL)
	BEGIN
		SET @sErrorMessage = 'Franchise Return ' + ISNULL(@ReturnNo,'') + ' is not linked to a Franchise Invoice - cannot post to GL.'
		RAISERROR (@sErrorMessage,16,1)
		RETURN 0
	END

	----------------------------------------------------------------------
	-- GUARD: every priced line must have a GL account mapping. (as PostInventoryBIoGL)
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
	-- 1. DR DETAILS  (authoritative amounts; positive, direction comes from DocId)
	----------------------------------------------------------------------
	SELECT ModCrNoteNo, MasterID, ROW_NUMBER() OVER (ORDER BY DrAccCode) AS SeqNo, DrAccCode, DrNarration, round(sum(Amount),2) as Amount, DocId
	INTO #DocDrDetails FROM (
	SELECT
	@ReturnNo AS ModCrNoteNo,
	@MasterID AS MasterID,
	MAP.AccCode AS DrAccCode,
	'Invoice Return ' + @ReturnNo + ' for Invoice ' + @BIDocumentNo + ' - ' + @CustomerName AS DrNarration,
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
	-- 2. TAX DETAILS - the tax already stored for the BR lines (copied from the
	--    original invoice by SP_InsertStockTransactions). Not recalculated here.
	----------------------------------------------------------------------
	SELECT
	@MasterID AS MasterID,
	@ReturnNo AS ModCrNoteNo,
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
	-- 3. HEADER TOTAL DERIVED FROM THE ROUNDED DETAILS
	----------------------------------------------------------------------
	SELECT @Total    = ISNULL(SUM(Amount),0)    FROM #DocDrDetails
	SELECT @TaxTotal = ISNULL(SUM(TaxAmount),0) FROM #DocTaxDetails

	----------------------------------------------------------------------
	-- 4. HEADER - BillType is the credit note type and RefNo is the invoice
	--    being credited (GL_POSTING_INVOICE_Return_GET_OtherModulePosttoAR uses BaseInvoiceNo).
	----------------------------------------------------------------------
	SELECT * INTO #DocDetails FROM (
	SELECT
	@DocId AS DocId,
	@MasterID AS MasterID,
	@BSPCode AS BSPCode,
	@ReturnNo AS ModCrNoteNo,
	IH.TransactionDate as DocDate,
	@Total + @TaxTotal AS TotalDocAmt,
	'Invoice Return ' + @ReturnNo + ' for Invoice ' + @BIDocumentNo + ' - ' + @CustomerName  AS  CrNarration,
	@DayEndUserID AS UserID,
	'' AS ModProType,
	@ReturnNo AS  ModRefNo,
	'' AS  MFCenter,
	0 AS TransType,
	1 AS NoPax,
	'' AS TourNo,
	'' AS CustName,
	'' AS DepartureDate,
	'' AS ArrivalDate,
	@CrDrNo	AS BillNo,
	@TransType AS BillType,
	0 AS FolioNo,
	'' AS VoucherNo,
	'' AS ReservationNo,
	'' AS GroupReservationNo,
	'' AS GRCNo,
	@BIDocumentNo as RefNo
	FROM StockTransactionHeaders IH
	inner join Locations l on l.id = ih.InvoiceLocationID
	WHERE IH.id = @StockTransactionHeaderID
	)X

	SELECT	@DocDetails	= (SELECT * FROM #DocDetails FOR XML PATH ('HeaderDataList'), ROOT('ArrayOfHeaderDataList') )

	----------------------------------------------------------------------
	-- 5. SEGMENT DETAILS - 'D' for a return (the invoice posting uses 'C').
	----------------------------------------------------------------------
	SELECT * INTO #DocSegDetails FROM (
	SELECT ModCrNoteNo, DocId, MasterID, SegmentID, SubSegCode, AccCode, DrCr, SUM(AMOUNT) AS AMOUNT,  ROW_NUMBER() OVER (ORDER BY AccCode) AS SeqNo FROM (
	SELECT
	@ReturnNo AS ModCrNoteNo,
	@DocId AS DocId,
	@MasterID AS MasterID,
	SegmentCode  AS SegmentID ,
	SegmentCode  AS SubSegCode,
	MAP.AccCode AS AccCode,
	'D' AS DrCr,
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
	-- 6. SAFETY NET: tally before handing over, naming the return document.
	----------------------------------------------------------------------
	IF (SELECT ISNULL(SUM(Amount),0) FROM #DocDrDetails) + (SELECT ISNULL(SUM(TaxAmount),0) FROM #DocTaxDetails)
	   <> (SELECT TotalDocAmt FROM #DocDetails)
	BEGIN
		SET @sErrorMessage = 'GL posting totals do not tally for franchise return ' + @ReturnNo
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

