
CREATE PROCEDURE [dbo].[GL_DAILYFOODCOSTINGSUMMERY] (@CurrDate AS DATE, @PropertyID AS INT, @CostingID AS INT)

AS
BEGIN

	SET DATEFORMAT DMY

	--DECLARE @CurrDate AS DATE = '08/08/2022'
	--DECLARE @PropertyID AS INT = 15
	--DECLARE @CostingID AS INT = 4

	DECLARE @F_DATE AS DATE = DATEADD(month, DATEDIFF(month, 0, @CurrDate), 0)
	DECLARE @T_DATE AS DATE = @CurrDate
	DECLARE @MASTERID AS VARCHAR(5) = FORMAT(@PROPERTYID,'00000')
	DECLARE @COMPCODE AS VARCHAR(3) = FORMAT(@PROPERTYID,'000')
	DECLARE @BLOCKCODE AS VARCHAR(3) = 'ORS'

	BEGIN TRY DROP TABLE #DFCS_Temp END TRY
	BEGIN CATCH END CATCH


	CREATE TABLE #DFCS_Temp
	(	
		Compcode char(3) not null default '',
		MasterID char(5) not null default '',
		PropertyID int not null default 0,	
		TxnDate date not null default '',
		ICID int not null default 0,
		ItemCategory varchar(200) not null default '',
		AccountName varchar(200) not null default '',
		AmountTD money not null default 0,
		AmountMTD money not null default 0,
	)
	

	-- CURRENT FINANCIAL YEAR MTD
	INSERT INTO #DFCS_Temp (Compcode, MasterID, PropertyID, TxnDate, ICID, ItemCategory, AccountName, AmountMTD)
	
	SELECT DISTINCT @COMPCODE, @MASTERID, @PROPERTYID, A.TxnDate, C.ID, C.Name ItemCategory, S.SubAccountName AccountName, (A.AccAmount*CASE WHEN A.DrCr = 'D' THEN -1 ELSE 1 END) Amount
	
	FROM eFinancials_Accounting.dbo.AccTxnDetails A
		INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping M ON A.AccCode = M.AccCode
		INNER JOIN eFinancials_Accounting.dbo.accSubAccountRef S ON A.AccCode = S.AccCode
		INNER JOIN Categlog_vrV2.dbo.ItemCategory C ON M.LEVEL2 = C.ID
		INNER JOIN Categlog_vrV2.dbo.CostingTypeWiseOutletWiseItemCategory T ON C.ID = T.ItemCategoryId AND T.Code = M.Level1

	WHERE M.BlockCode = @BLOCKCODE AND A.TxnDate BETWEEN @F_DATE AND @T_DATE AND A.MASTERID = @MASTERID	AND M.GLCompCode = @COMPCODE AND C.PropertyId = @PROPERTYID AND T.PropertyId = @PROPERTYID AND T.CostingId = @CostingID

	--GROUP BY C.ID, C.Name, S.SubAccountName

	
	-- CURRENT FINANCIAL YEAR TD
	INSERT INTO #DFCS_Temp (Compcode, MasterID, PropertyID, TxnDate, ICID, ItemCategory, AccountName, AmountTD)

	SELECT DISTINCT @COMPCODE, @MASTERID, @PROPERTYID, A.TxnDate, C.ID, C.Name ItemCategory, S.SubAccountName AccountName, (A.AccAmount*CASE WHEN A.DrCr = 'D' THEN -1 ELSE 1 END) Amount

	FROM eFinancials_Accounting.dbo.AccTxnDetails A
		INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping M ON A.AccCode = M.AccCode
		INNER JOIN eFinancials_Accounting.dbo.accSubAccountRef S ON A.AccCode = S.AccCode
		INNER JOIN Categlog_vrV2.dbo.ItemCategory C ON M.LEVEL2 = C.ID
		INNER JOIN Categlog_vrV2.dbo.CostingTypeWiseOutletWiseItemCategory T ON C.ID = T.ItemCategoryId AND T.Code = M.Level1

	WHERE M.BlockCode = @BLOCKCODE AND A.TxnDate BETWEEN @T_DATE AND @T_DATE AND A.MASTERID = @MASTERID	AND M.GLCompCode = @COMPCODE AND C.PropertyId = @PROPERTYID AND T.PropertyId = @PROPERTYID AND T.CostingId = @CostingID

	--GROUP BY C.ID, C.Name, S.SubAccountName


	-- HISTORY FINANCIAL YEAR MTD
	INSERT INTO #DFCS_Temp (Compcode, MasterID, PropertyID, TxnDate, ICID, ItemCategory, AccountName, AmountMTD)
	
	SELECT DISTINCT @COMPCODE, @MASTERID, @PROPERTYID, A.TxnDate, C.ID, C.Name ItemCategory, S.SubAccountName AccountName, (A.AccAmount*CASE WHEN A.DrCr = 'D' THEN -1 ELSE 1 END) Amount
	
	FROM eFinancials_Accounting.dbo.accHistoryAccTxnDetails A
		INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping M ON A.AccCode = M.AccCode
		INNER JOIN eFinancials_Accounting.dbo.accSubAccountRef S ON A.AccCode = S.AccCode
		INNER JOIN Categlog_vrV2.dbo.ItemCategory C ON M.LEVEL2 = C.ID
		INNER JOIN Categlog_vrV2.dbo.CostingTypeWiseOutletWiseItemCategory T ON C.ID = T.ItemCategoryId AND T.Code = M.Level1

	WHERE M.BlockCode = @BLOCKCODE AND A.TxnDate BETWEEN @F_DATE AND @T_DATE AND A.MASTERID = @MASTERID	AND M.GLCompCode = @COMPCODE AND C.PropertyId = @PROPERTYID AND T.PropertyId = @PROPERTYID AND T.CostingId = @CostingID

	--GROUP BY C.ID, C.Name, S.SubAccountName

	
	-- HISTORY FINANCIAL YEAR TD
	INSERT INTO #DFCS_Temp (Compcode, MasterID, PropertyID, TxnDate, ICID, ItemCategory, AccountName, AmountTD)

	SELECT DISTINCT @COMPCODE, @MASTERID, @PROPERTYID, A.TxnDate, C.ID, C.Name ItemCategory, S.SubAccountName AccountName, (A.AccAmount*CASE WHEN A.DrCr = 'D' THEN -1 ELSE 1 END) Amount

	FROM eFinancials_Accounting.dbo.accHistoryAccTxnDetails A
		INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping M ON A.AccCode = M.AccCode
		INNER JOIN eFinancials_Accounting.dbo.accSubAccountRef S ON A.AccCode = S.AccCode
		INNER JOIN Categlog_vrV2.dbo.ItemCategory C ON M.LEVEL2 = C.ID
		INNER JOIN Categlog_vrV2.dbo.CostingTypeWiseOutletWiseItemCategory T ON C.ID = T.ItemCategoryId AND T.Code = M.Level1

	WHERE M.BlockCode = @BLOCKCODE AND A.TxnDate BETWEEN @T_DATE AND @T_DATE AND A.MASTERID = @MASTERID	AND M.GLCompCode = @COMPCODE AND C.PropertyId = @PROPERTYID AND T.PropertyId = @PROPERTYID AND T.CostingId = @CostingID

	--GROUP BY C.ID, C.Name, S.SubAccountName


	---- ItemCategory/Account wise
	--SELECT Compcode, MasterID, PropertyID, ICID, ItemCategory, AccountName, SUM(AmountTD) AmountTD, SUM(AmountMTD) AmountMTD
	--FROM #DFCS_Temp
	--GROUP BY Compcode, MasterID, PropertyID, ICID, ItemCategory, AccountName

	-- ItemCategory/Account wise
	SELECT DISTINCT Compcode, MasterID, PropertyID, AccountName, SUM(AmountTD) AmountTD, SUM(AmountMTD) AmountMTD
	FROM #DFCS_Temp
	GROUP BY Compcode, MasterID, PropertyID, ICID, ItemCategory, AccountName


	-- ItemCategory wise
	--SELECT Compcode, MasterID, PropertyID, ICID, ItemCategory, SUM(AmountTD) AmountTD, SUM(AmountMTD) AmountMTD
	--FROM #DFCS_Temp
	--GROUP BY Compcode, MasterID, PropertyID, ICID, ItemCategory


	BEGIN TRY DROP TABLE #DFCS_Temp END TRY
	BEGIN CATCH END CATCH

END


--select * from eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping where BlockCode = 'ORS' and GLCompCode = '013'

--select * from CostingTypeWiseOutletWiseItemCategory

GO

