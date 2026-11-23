-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2026-01-29
-- Description:	SP to auto dayend and posting in GL posting
-- =============================================
CREATE   PROCEDURE [dbo].[DayEndGL_Posting_AutoMate] 
AS
BEGIN
	BEGIN TRY
	BEGIN TRANSACTION

	SET DATEFORMAT DMY
	SET NOCOUNT ON;

	
	IF OBJECT_ID(N'tempdb..#TempAutoDayEndLocations') IS NOT NULL
	BEGIN
	DROP TABLE #TempAutoDayEndLocations
	END

	DECLARE @LocationID INT,@CurrentDate DATE,@PropertyId INT
	DECLARE @UserID AS UniqueIdentifier = 'B490B26A-2886-4671-8253-A8644C76660F',
	@GrnBlockID INT

	DECLARE @B_DATE AS DATE

	SELECT @B_DATE = DATEADD(DAY, 0, CurrentDate) FROM Categlog_vrV2..BackendSettings

	SELECT ID LocationID,CONVERT(DATE,CurrentDate) CurrentDate,PropertyId
	INTO #TempAutoDayEndLocations
	FROM Locations
	WHERE IsAutoDayEndEnable = 1


	WHILE EXISTS(SELECT 1 FROM #TempAutoDayEndLocations)
	BEGIN
		SELECT TOP (1)@LocationID = LocationID,@CurrentDate = CurrentDate,@PropertyId = PropertyId
		FROM #TempAutoDayEndLocations

		IF NOT EXISTS(SELECT 1 FROM AutoDayEnd_Completed_Log WHERE PropertyID = @PropertyId AND
		LocationID = @LocationID AND DATE = @CurrentDate)
		BEGIN
			SELECT @GrnBlockID=GRNBlockID 
			FROM Companies
			WHERE CompanyID = @PropertyID

			UPDATE D
			SET D.SkipGL=1
			FROM StockTransactionDetails D 
			INNER JOIN StockTransactionHeaders H
			ON h.Id= D.StockTransactionHeaderID 
			WHERE H.PropertyID = @PropertyID AND convert(DATE,H.GLDATE ) =@CurrentDate and H.TransactionType='XX' 
			AND H.LocationID = @LocationID

			UPDATE D
			SET D.SkipGL=1
			FROM StockTransactionDetails D 
			INNER JOIN StockTransactionHeaders H ON h.Id= D.StockTransactionHeaderID 
			INNER JOIN Locations L ON H.LocationID = L.Id
			WHERE H.PropertyID = @PropertyID AND convert(DATE,H.GLDATE ) =@CurrentDate and H.TransactionType<>'XX'  AND L.IsGLEnabled = 0
			AND H.LocationID = @LocationID

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
				AND M.LEVEL1 = CASE WHEN H.TransactionType='IN' OR H.TransactionType='IR'   OR H.TransactionType='IF'  OR H.TransactionType='FW'  THEN Dp.Code ELSE  L.Code END 
				AND M.Level2 = C.Code 
				AND  M.Level3 = CASE WHEN H.TransactionType='IN'  OR H.TransactionType='IR'  OR H.TransactionType='IF' OR H.TransactionType='FW' THEN  SC.Code ELSE M.Level3 END 
				AND M.Level4  = CASE WHEN H.TransactionType='IN'  OR H.TransactionType='IR' OR H.TransactionType='IF'  OR H.TransactionType='FW'   THEN  SSC.Code ELSE M.Level4 END 
			WHERE H.PropertyID = @PropertyID AND T.PostGLAtDayend=1 and convert(DATE,H.GLDATE ) =@CurrentDate  and SkipGL= 0
			AND H.LocationID = @LocationID
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
			WHERE H.PropertyID = @PropertyID AND T.PostGLAtDayend=1 and convert(DATE,H.GLDATE ) =@CurrentDate     and SkipGL= 0
			AND H.LocationID = @LocationID
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


			INSERT INTO AutoDayEnd_Completed_Log(PropertyID, Date, LocationID, SysDateTime)
			SELECT @PropertyId,@CurrentDate,@LocationID,GETDATE()


			UPDATE Locations
			SET CurrentDate = DATEADD(DAY, 1, ISNULL(CurrentDate, CAST(GETDATE() AS DATE)))
			WHERE ID = @LocationID; 
		END


		DELETE TOP (1) FROM #TempAutoDayEndLocations

		INSERT INTO HotelResWeb..DayEndCompleteTime([HotelDate], [PropertyId],DayEndUserID)
		SELECT @B_DATE ,PropertyId,@UserID
		FROM Locations
		WHERE IsAutoDayEndEnable = 1
		GROUP BY PropertyId

		UPDATE Categlog_vrV2..BackendSettings SET CurrentDate = DATEADD(DAY, 1, @B_DATE)


	END

    
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

GO

