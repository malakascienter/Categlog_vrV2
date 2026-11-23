-- [dbo].[PostInventoryProductionToGL] 6275
CREATE PROCEDURE [dbo].[PostInventoryProductionToGL](@StockTransactionHeaderID BIGINT)
as


IF OBJECT_ID(N'tempdb..#TempHeader') IS NOT NULL
BEGIN
DROP TABLE #TempHeader
END

IF OBJECT_ID(N'tempdb..#TT') IS NOT NULL
BEGIN
DROP TABLE #TT
END

DECLARE @RefStockTransactionHeaderID BIGINT, @PropertyID INT,@UserID AS UniqueIdentifier = 'B490B26A-2886-4671-8253-A8644C76660F',	@GrnBlockID INT
DECLARE @DocumentNo varchar(100) -- kapila 21/9/2026

SELECT @PropertyID = PropertyID
FROM StockTransactionHeaders WITH(NOLOCK)
WHERE Id = @StockTransactionHeaderID

SELECT @GrnBlockID=GRNBlockID FROM Companies WITH(NOLOCK)  WHERE CompanyID = @PropertyID

SELECT @DocumentNo=DocumentNo FROM StockTransactionHeaders WITH(NOLOCK)
where Id = @StockTransactionHeaderID AND TransactionType = 'PU'


SELECT *
INTO #TempHeader
FROM StockTransactionHeaders WITH(NOLOCK)
where Id = @StockTransactionHeaderID AND TransactionType = 'PU'

UNION ALL

SELECT *
FROM StockTransactionHeaders WITH(NOLOCK)
WHERE ReferenceID = @StockTransactionHeaderID  AND TransactionType = 'PI'


/* ================= ADDED 2026-10-14 - RE-ENTRY GUARD ======================
   The procedure had nothing to stop the same document being staged twice.
   A duplicated voucher still balances, so the Dr=Cr validation cannot catch
   it - it simply posts at double value. This refuses instead.
   =========================================================================== */
IF EXISTS (SELECT 1 FROM eFinancials_Accounting.dbo.GL_POSTING
           WHERE TempTxnNo = CONCAT('PROD_', @StockTransactionHeaderID))
BEGIN
    RAISERROR('This production document is already staged.', 16, 1)
    RETURN
END
/* =============== END ADDED 2026-10-14 - RE-ENTRY GUARD ==================== */


/* ============== ADDED 2026-10-14 - MAPPING VALIDATION =====================
   Both halves resolve their account through an INNER JOIN to
   Destinity_GLIntegrationAccountMapping. A missing mapping therefore drops
   rows SILENTLY - which is how production staged one-sided for six months
   without anyone seeing an error. These checks say exactly what is missing
   and stage nothing, instead of producing a half voucher.
   =========================================================================== */
DECLARE @PIBlockID INT, @MissingType varchar(5), @MissingBlock varchar(10),
        @MissingLoc varchar(50), @MissingCat varchar(50)

/* a) the ingredients document must actually be linked.
      PRD/PI/000124 and PRD/PI/000289 had their ReferenceID overwritten by a
      goods receipt, which is how two documents went unposted unnoticed. */
IF NOT EXISTS (SELECT 1 FROM #TempHeader WHERE TransactionType = 'PI')
BEGIN
    RAISERROR('No PI (ingredients) document is linked to this PU header - check StockTransactionHeaders.ReferenceID on the PI document. Nothing was staged.', 16, 1)
    RETURN
END

/* b) both blocks must be configured */
IF @GrnBlockID IS NULL
BEGIN
    RAISERROR('Companies.GRNBlockID is not set for this property. Nothing was staged.', 16, 1)
    RETURN
END

SELECT TOP (1) @PIBlockID = T.GLBLOCKID
FROM #TempHeader H
INNER JOIN TransactionTypes T WITH(NOLOCK) ON T.Id = H.TransactionID
WHERE H.TransactionType = 'PI'

IF @PIBlockID IS NULL
BEGIN
    RAISERROR('TransactionTypes.GLBLOCKID is not set for the PI transaction type (Id 15). Nothing was staged.', 16, 1)
    RETURN
END

/* c) every location/category actually used must resolve to an account */
;WITH Need AS
(
    SELECT DISTINCT
           H.TransactionType,
           CASE WHEN H.TransactionType = 'PI' THEN @PIBlockID ELSE @GrnBlockID END AS BlockID,
           L.Code AS LocCode,
           C.Code AS CatCode
    FROM #TempHeader H
    INNER JOIN StockTransactionDetails D WITH(NOLOCK) ON D.StockTransactionHeaderID = H.Id
    INNER JOIN StockItemHeaders        S WITH(NOLOCK) ON S.Id = D.StockItemID
    INNER JOIN Categories              C WITH(NOLOCK) ON C.Id = S.CategoryID
    LEFT  JOIN Locations               L WITH(NOLOCK) ON L.Id = H.LocationID
    WHERE ROUND(D.UnitPrice * D.Quantity, 4) <> 0
)
SELECT TOP (1)
       @MissingType  = N.TransactionType,
       @MissingBlock = B.BlockCode,
       @MissingLoc   = ISNULL(N.LocCode, '(no location)'),
       @MissingCat   = ISNULL(N.CatCode, '(no category)')
FROM Need N
INNER JOIN Destinity_GLIntegrationAccountMappingBlocks B WITH(NOLOCK) ON B.ID = N.BlockID
WHERE NOT EXISTS
(
    SELECT 1
    FROM Destinity_GLIntegrationAccountMapping M WITH(NOLOCK)
    INNER JOIN Companies CO WITH(NOLOCK)
            ON CO.Code = M.GLCompCode AND CO.CompanyID = @PropertyID
    WHERE M.BlockCode = B.BlockCode
      AND M.LEVEL1 = N.LocCode
      AND M.Level2 = N.CatCode
)

IF @MissingBlock IS NOT NULL
BEGIN
    RAISERROR('No GL account mapping for block %s, location %s, category %s (%s side). Nothing was staged.',
              16, 1, @MissingBlock, @MissingLoc, @MissingCat, @MissingType)
    RETURN
END
/* ============ END ADDED 2026-10-14 - MAPPING VALIDATION =================== */




SELECT *

INTO #TT

FROM (

	SELECT H.TransactionDate, H.PropertyID,B.BLOCKCODE, SEGMENTCODE, 'PU' as TransactionType ,D.TxnType,Dp.Code DepartmentID,L.Code LocationID, T.GLNarration + ' - ' + H.DocumentNo  Narration,
		C.Code CategoryID,@DocumentNo as DocumentNo,T.GLBLOCKID,M.AccCode, CASE WHEN TxnType='M' THEN 'C' ELSE 'D' END  DRCR, CASE WHEN H.TransactionType='XX' THEN  SUM(ABS((d.StockMasterQuantity - d.NewQuantity)) * D.NewAveragePrice)   ELSE SUM(ROUND(D.UnitPrice * D.Quantity,4)) END TxnValue,
		(SELECT SubAccountName FROM eFinancials_Accounting.dbo.accSubAccountRef WHERE AccCode = M.AccCode) AS AccName,(CASE WHEN H.TransactionType = 'PI' THEN  H.ReferenceID ELSE H.Id END)   Ref

	FROM #TempHeader H WITH(NOLOCK)
		INNER JOIN StockTransactionDetails D WITH(NOLOCK) ON h.Id= D.StockTransactionHeaderID
		INNER JOIN StockItemHeaders S WITH(NOLOCK) ON S.Id= D.StockItemID
		INNER JOIN TransactionTypes T WITH(NOLOCK) ON T.Id = H.TransactionID
		INNER JOIN Destinity_GLIntegrationAccountMappingBlocks B WITH(NOLOCK) ON B.ID = T.GLBLOCKID
		INNER JOIN Categories C WITH(NOLOCK) ON C.ID= S.CategoryID
		INNER JOIN SubCategories SC WITH(NOLOCK) ON SC.Id = S.SubCategoryID
		INNER JOIN SubCategories02 SSC WITH(NOLOCK) ON SSC.Id = S.SubCategory2ID
		LEFT OUTER JOIN Locations L WITH(NOLOCK) ON L.ID= H.LocationID
		LEFT OUTER JOIN Departments Dp WITH(NOLOCK) ON Dp.Id = H.DepartmentID
		INNER JOIN Destinity_GLIntegrationAccountMapping M WITH(NOLOCK) ON B.BlockCode= M.BlockCode
		INNER JOIN Companies CO WITH(NOLOCK) ON CO.Code = M.GLCompCode and H.PropertyID = CO.CompanyID AND M.LEVEL1 =  L.Code  AND M.Level2 = C.Code

	WHERE H.PropertyID = @PropertyID AND H.TransactionType IN ('PI','PU') AND H.TransactionType = 'PI'
	--AND H.DOCUMENTNO IN ('KIT/PI/000307','KIT/PU/000307')


	GROUP BY H.TransactionDate,H.TransactionType,D.TxnType,Dp.Code ,L.Code , C.Code,H.DocumentNo,GLBLOCKID,M.AccCode, T.GLNarration, H.PropertyID,B.BLOCKCODE, SEGMENTCODE, H.ReferenceID, H.Id

	UNION ALL

	SELECT H.TransactionDate, H.PropertyID,B.BLOCKCODE, SEGMENTCODE,'PU' as TransactionType,D.TxnType,Dp.Code DepartmentID,L.Code LocationID, T.GLNarration + ' - ' + H.DocumentNo  Narration, C.Code CategoryID,@DocumentNo as DocumentNo,@GrnBlockID GLBLOCKID, AccCode,
		CASE WHEN TxnType='M' THEN CASE WHEN H.TransactionType = 'PI' THEN 'D' ELSE 'C' END ELSE CASE WHEN H.TransactionType = 'PU' THEN 'D' ELSE 'C' END END  DRCR,
		CASE WHEN H.TransactionType='XX' THEN SUM(ABS((d.StockMasterQuantity - d.NewQuantity)) * D.NewAveragePrice) ELSE SUM(ROUND(D.UnitPrice * D.Quantity,4)) END TxnValue,
		(SELECT SubAccountName FROM eFinancials_Accounting.dbo.accSubAccountRef WHERE AccCode = M.AccCode) AS AccName, (CASE WHEN H.TransactionType = 'PI' THEN  H.ReferenceID ELSE H.Id END)  Ref

	FROM #TempHeader H WITH(NOLOCK)
		INNER JOIN StockTransactionDetails D WITH(NOLOCK) ON h.Id= D.StockTransactionHeaderID
		INNER JOIN StockItemHeaders S WITH(NOLOCK) ON S.Id= D.StockItemID
		INNER JOIN Categories C WITH(NOLOCK) ON C.ID= S.CategoryID
		INNER JOIN SubCategories SC WITH(NOLOCK) ON SC.Id = S.SubCategoryID
		INNER JOIN SubCategories02 SSC WITH(NOLOCK) ON SSC.Id = S.SubCategory2ID
		INNER JOIN TransactionTypes T WITH(NOLOCK) ON T.Id = H.TransactionID
		LEFT OUTER JOIN Locations L WITH(NOLOCK) ON L.ID= H.LocationID
		LEFT OUTER JOIN Departments Dp WITH(NOLOCK) ON Dp.Id = H.DepartmentID
		INNER JOIN Destinity_GLIntegrationAccountMappingBlocks B WITH(NOLOCK) ON B.ID = @GrnBlockID
		INNER JOIN Destinity_GLIntegrationAccountMapping M WITH(NOLOCK) ON B.BlockCode= M.BlockCode
		INNER JOIN Companies CO WITH(NOLOCK) ON CO.Code = M.GLCompCode and H.PropertyID = CO.CompanyID AND M.LEVEL2 = C.Code AND M.LEVEL1 = L.Code

	WHERE H.PropertyID = @PropertyID AND H.TransactionType IN ('PI','PU') AND H.TransactionType = 'PU'
	--AND H.DOCUMENTNO IN ('KIT/PI/000307','KIT/PU/000307')

	GROUP BY H.TransactionDate,H.TransactionType,D.TxnType,Dp.Code ,L.Code , C.Code,H.DocumentNo,GLBLOCKID, T.GLNarration, H.PropertyID,B.BLOCKCODE, SEGMENTCODE,ACCCODE, H.ReferenceID, H.Id

) A
WHERE A.TxnValue <> 0
ORDER BY A.ref


/* ====================== ADDED 2026-10-14 - OPTION B ========================
   Make debits equal credits before staging.

   Debit is the PU side (output received), Credit is the PI side (ingredients
   consumed). They differ because the output's unit price is derived by
   division and stored at decimal(18,6), so price x quantity cannot reproduce
   the ingredient total except when the division is exact. Measured over
   1,608 production pairs from 03/04/2026: 249 tally exactly, worst gap
   0.1038, nothing above 1.00, net across the period -0.7407.

   destinity_Acc_GLPostValidation compares the Dr and Cr totals per TxnNo with
   a plain <>, so any difference at all is refused with "Debit And Credit
   Amounts Do Not Tally".

   This reduces the largest line on the heavier side by the difference. No
   variance account and no new mapping. @MaxGap is a safety rail: a document
   differing by more than a rupee is a costing fault, not rounding, and is
   refused rather than quietly absorbed.
   =========================================================================== */
DECLARE @Dr MONEY, @Cr MONEY, @Gap MONEY, @FixSide CHAR(1), @MaxGap MONEY = 1.00

SELECT @Dr = SUM(CASE WHEN DRCR = 'D' THEN TxnValue ELSE 0 END),
       @Cr = SUM(CASE WHEN DRCR = 'C' THEN TxnValue ELSE 0 END)
FROM #TT

SET @Gap = ISNULL(@Dr,0) - ISNULL(@Cr,0)

IF ISNULL(@Dr,0) = 0 OR ISNULL(@Cr,0) = 0
BEGIN
    RAISERROR('Only one side was produced - check TransactionTypes.GLBLOCKID and the account mapping. Nothing was staged.', 16, 1)
    RETURN
END

IF @Gap <> 0
BEGIN
    IF ABS(@Gap) > @MaxGap
    BEGIN
        RAISERROR('Debits and credits differ by more than one rupee - this is a costing fault, not rounding. Nothing was staged.', 16, 1)
        RETURN
    END

    SET @FixSide = CASE WHEN @Gap > 0 THEN 'D' ELSE 'C' END

    IF NOT EXISTS (SELECT 1 FROM #TT WHERE DRCR = @FixSide AND TxnValue > ABS(@Gap))
    BEGIN
        RAISERROR('No line large enough to absorb the rounding difference. Nothing was staged.', 16, 1)
        RETURN
    END

    ;WITH Biggest AS
    (
        SELECT TOP (1) TxnValue
        FROM #TT
        WHERE DRCR = @FixSide AND TxnValue > ABS(@Gap)
        ORDER BY TxnValue DESC
    )
    UPDATE Biggest SET TxnValue = TxnValue - ABS(@Gap)
END
/* ==================== END ADDED 2026-10-14 - OPTION B ====================== */


INSERT INTO eFinancials_Accounting.dbo.GL_POSTING
([TxnDate], [compcode], [DeptCode], [Outlet], [Amount], [Narration], [AccCode], [DrCr],
[SeqNo], [TransType],
[TempTxnNo], [TxnNo], [TxnID], [DocumentNo], [ModName], [CurrCode], [ExRate], [FCAmount], [BSPCode], [ValidationStatus], [PostedStatus],
[logdatetime], [UserID], [BlockCode], [SegmentCode])


SELECT TransactionDate, C.Code , ISNULL(DepartmentID,''),'00', TxnValue , Narration, AccCode, DRCR,
ROW_NUMBER() OVER(PARTITION BY TransactionType,[DocumentNo],LocationID, DepartmentID ORDER BY [DocumentNo] DESC) , CASE WHEN TransactionType='DN' THEN 'DM' ELSE TransactionType END ,
CONCAT('PROD_',REF),'','J',[DocumentNo],'I','LKR',1,0,null,'FALSE','FALSE',
GETDATE(),@UserID,BlockCode, SegmentCode
FROM #TT T
INNER JOIN Companies c ON c.[CompanyID]= t.propertyID



IF OBJECT_ID(N'tempdb..#TempHeader') IS NOT NULL
BEGIN
DROP TABLE #TempHeader
END

IF OBJECT_ID(N'tempdb..#TT') IS NOT NULL
BEGIN
DROP TABLE #TT
END

GO

