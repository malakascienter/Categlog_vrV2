
CREATE PROCEDURE [dbo].[DayEndGL_Posting_Retail_LocationWise](@PropertyID INT ,@currDate Date,@LocationId INT)
AS
BEGIN
BEGIN TRY
BEGIN TRANSACTION

	SET DATEFORMAT DMY

	insert into [dbo].[DayEndGL_Posting_SP_Para]
	([PropertyId], [Date])
	VALUES (@PropertyID, @currDate)

	DECLARE @UserID AS UniqueIdentifier = 'B490B26A-2886-4671-8253-A8644C76660F',
	@GrnBlockID INT


	EXEC [InsertPOSSalesToStockTransactions_LocationWise] @PropertyID,@currDate,@LocationId
	EXEC [InsertPOSSalesReturnToStockTransactions_LocationWise] @PropertyID,@currDate,@LocationId

	SELECT @GrnBlockID=GRNBlockID 
	FROM Companies
	WHERE CompanyID = @PropertyID

	UPDATE D
	SET D.SkipGL=1
	FROM StockTransactionDetails D 
	INNER JOIN StockTransactionHeaders H
	ON h.Id= D.StockTransactionHeaderID 
	WHERE H.PropertyID = @PropertyID AND convert(DATE,H.GLDATE ) =@currDate and H.TransactionType='XX' 
	-- Skip ALL XX Records from GL Entry, DINITH Confirmed 

	SELECT H.TransactionDate, H.PropertyID,B.BLOCKCODE, SEGMENTCODE, H.TransactionType,D.TxnType,Dp.Code DepartmentID,L.Code LocationID, T.GLNarration + ' - ' + H.DocumentNo  Narration, 
	C.Code CategoryID,H.DocumentNo,T.GLBLOCKID,M.AccCode, CASE WHEN TxnType='M' THEN 'D' ELSE 'C' END  DRCR, CASE WHEN H.TransactionType='XX' THEN  SUM(ABS((d.StockMasterQuantity - d.NewQuantity)) * D.NewAveragePrice)   ELSE SUM(ROUND(D.UnitPrice * D.Quantity,4)) END TxnValue
	INTO #TxnList
	FROM StockTransactionHeaders H
	INNER JOIN StockTransactionDetails D ON h.Id= D.StockTransactionHeaderID 
	INNER JOIN StockItemHeaders S ON S.Id= D.StockItemID
	INNER JOIN TransactionTypes T ON T.Id = H.TransactionID
	INNER JOIN Destinity_GLIntegrationAccountMappingBlocks B ON B.ID = T.GLBLOCKID
	INNER JOIN Categories C ON C.ID= S.CategoryID
	INNER JOIN SubCategories SC ON SC.Id = S.SubCategoryID
	INNER JOIN SubCategories02 SSC ON SSC.Id = S.SubCategory2ID
	LEFT OUTER JOIN Locations L ON L.ID= H.LocationID
	LEFT OUTER JOIN Departments Dp ON Dp.Id = H.DepartmentID
	INNER JOIN Destinity_GLIntegrationAccountMapping M ON B.BlockCode= M.BlockCode 
	INNER JOIN Companies CO ON CO.Code = M.GLCompCode and H.PropertyID = CO.CompanyID
		AND M.LEVEL1 = CASE WHEN H.TransactionType='IN' OR H.TransactionType='IR'   OR H.TransactionType='IF'  OR H.TransactionType='RC'   THEN Dp.Code ELSE  L.Code END 
		AND M.Level2 = C.Code 
		AND  M.Level3 = CASE WHEN H.TransactionType='IN'  OR H.TransactionType='IR'  OR H.TransactionType='IF' OR H.TransactionType='RC'  THEN  SC.Code ELSE M.Level3 END 
		AND M.Level4  = CASE WHEN H.TransactionType='IN'  OR H.TransactionType='IR' OR H.TransactionType='IF'  OR H.TransactionType='RC'    THEN  SSC.Code ELSE M.Level4 END 
	WHERE H.PropertyID = @PropertyID AND T.PostGLAtDayend=1 and convert(DATE,H.GLDATE ) =@currDate  and SkipGL= 0
	GROUP BY H.TransactionDate,H.TransactionType,D.TxnType,Dp.Code ,L.Code , C.Code,H.DocumentNo,GLBLOCKID,M.AccCode, T.GLNarration, H.PropertyID,B.BLOCKCODE, SEGMENTCODE

	INSERT INTO #TxnList
	SELECT H.TransactionDate, H.PropertyID,B.BLOCKCODE, SEGMENTCODE, H.TransactionType,D.TxnType,Dp.Code DepartmentID,L.Code LocationID, T.GLNarration + ' - ' + H.DocumentNo  Narration, C.Code CategoryID,H.DocumentNo,@GrnBlockID GLBLOCKID, AccCode, 
	CASE WHEN TxnType='M' THEN 'C' ELSE 'D' END  DRCR, CASE WHEN H.TransactionType='XX' THEN SUM(ABS((d.StockMasterQuantity - d.NewQuantity)) * D.NewAveragePrice) ELSE SUM(ROUND(D.UnitPrice * D.Quantity,4)) END TxnValue
	FROM StockTransactionHeaders H
	INNER JOIN StockTransactionDetails D ON h.Id= D.StockTransactionHeaderID 
	INNER JOIN StockItemHeaders S ON S.Id= D.StockItemID
	INNER JOIN Categories C ON C.ID= S.CategoryID
	INNER JOIN SubCategories SC ON SC.Id = S.SubCategoryID
	INNER JOIN SubCategories02 SSC ON SSC.Id = S.SubCategory2ID
	INNER JOIN TransactionTypes T ON T.Id = H.TransactionID
	LEFT OUTER JOIN Locations L ON L.ID= H.LocationID
	LEFT OUTER JOIN Departments Dp ON Dp.Id = H.DepartmentID
	INNER JOIN Destinity_GLIntegrationAccountMappingBlocks B ON B.ID = @GrnBlockID
	INNER JOIN Destinity_GLIntegrationAccountMapping M ON B.BlockCode= M.BlockCode 
	INNER JOIN Companies CO ON CO.Code = M.GLCompCode and H.PropertyID = CO.CompanyID
		AND M.LEVEL2 = C.Code AND M.LEVEL1 = L.Code
	WHERE H.PropertyID = @PropertyID AND T.PostGLAtDayend=1 and convert(DATE,H.GLDATE ) =@currDate     and SkipGL= 0
	GROUP BY H.TransactionDate,H.TransactionType,D.TxnType,Dp.Code ,L.Code , C.Code,H.DocumentNo,GLBLOCKID, T.GLNarration, H.PropertyID,B.BLOCKCODE, 
	SEGMENTCODE,ACCCODE


	SELECT * FROM #TxnList

	INSERT INTO eFinancials_Accounting.dbo.GL_POSTING 
	([TxnDate], [compcode], [DeptCode], [Outlet], [Amount], [Narration], [AccCode], [DrCr], 
	[SeqNo], [TransType], 
	[TempTxnNo], [TxnNo], [TxnID], [DocumentNo], [ModName], [CurrCode], [ExRate], [FCAmount], [BSPCode], [ValidationStatus], [PostedStatus], 
	[logdatetime], [UserID], [BlockCode], [SegmentCode])

	SELECT TransactionDate, C.Code , ISNULL(DepartmentID,''),'00', TxnValue , Narration, AccCode, DRCR, 
	ROW_NUMBER() OVER(PARTITION BY TransactionType,[DocumentNo],LocationID, DepartmentID ORDER BY [DocumentNo] DESC) , CASE WHEN TransactionType='DN' THEN 'DM' ELSE TransactionType END ,
	[DocumentNo],'','J',[DocumentNo],'I','LKR',1,0,null,'FALSE','FALSE',
	GETDATE(),@UserID,BlockCode, SegmentCode
	FROM #TxnList T
	INNER JOIN Companies c ON c.[CompanyID]= t.propertyID

COMMIT TRANSACTION 
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	
	DECLARE @ErrorMessage NVARCHAR(4000);  
	DECLARE @ErrorSeverity INT;  
	DECLARE @ErrorState INT;  

	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage,SysDate)
	VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE(),GETDATE())

	SELECT   
    @ErrorMessage = ERROR_MESSAGE(),  
    @ErrorSeverity = ERROR_SEVERITY(),  
    @ErrorState = ERROR_STATE(); 
	RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);

END CATCH

END



--select * from stockitemheaders 

GO

