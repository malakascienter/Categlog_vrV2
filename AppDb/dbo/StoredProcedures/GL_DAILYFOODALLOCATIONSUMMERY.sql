
CREATE PROCEDURE [dbo].[GL_DAILYFOODALLOCATIONSUMMERY] (@CurrDate AS DATE, @PropertyID AS INT, @CostingID AS INT)

AS
BEGIN

	SET DATEFORMAT DMY

	--DECLARE @CurrDate AS DATE = '21/08/2022'
	--DECLARE @PropertyID AS INT = 19
	--DECLARE @CostingID AS INT = 45

	DECLARE @F_DATE AS DATE = DATEADD(month, DATEDIFF(month, 0, @CurrDate), 0)
	DECLARE @T_DATE AS DATE = @CurrDate
	DECLARE @MASTERID AS VARCHAR(5) = FORMAT(@PROPERTYID,'00000')
	DECLARE @COMPCODE AS VARCHAR(3) = FORMAT(@PROPERTYID,'000')


	BEGIN TRY DROP TABLE #DFAS_Temp END TRY
	BEGIN CATCH END CATCH

	BEGIN TRY DROP TABLE #DFAS_TempBlocks END TRY
	BEGIN CATCH END CATCH


	CREATE TABLE #DFAS_TempBlocks
	(	
		Blockcode char(4) not null default '',
	)

	INSERT INTO #DFAS_TempBlocks (Blockcode) VALUES ('POF')
	INSERT INTO #DFAS_TempBlocks (Blockcode) VALUES ('POB')


	CREATE TABLE #DFAS_Temp
	(	
		Compcode char(3) not null default '',
		MasterID char(5) not null default '',
		PropertyID int not null default 0,	
		TxnDate Date not null default '',
		ICID int not null default 0,
		ItemCategory varchar(200) not null default '',
		AccountName varchar(200) not null default '',
		AmountTD money not null default 0,
		AmountMTD money not null default 0,
	)
	

	-- CURRENT FINANCIAL YEAR MTD
	INSERT INTO #DFAS_Temp (Compcode, MasterID, PropertyID, TxnDate, ICID, ItemCategory, AccountName, AmountMTD)
	
	SELECT DISTINCT @COMPCODE, @MASTERID, @PROPERTYID, A.TxnDate, C.ID, C.Name ItemCategory, S.SubAccountName AccountName, (A.AccAmount*CASE WHEN A.DrCr = 'D' THEN -1 ELSE 1 END) Amount
	
	FROM eFinancials_Accounting.dbo.AccTxnDetails A
		INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping M ON A.AccCode = M.AccCode
		INNER JOIN eFinancials_Accounting.dbo.accSubAccountRef S ON A.AccCode = S.AccCode
		INNER JOIN HotelResWeb..PostingTypes C ON M.LEVEL1 = CAST(C.ID AS VARCHAR)
		INNER JOIN #DFAS_TempBlocks B ON B.Blockcode = M.BlockCode
		INNER JOIN CostingTypeWiseChargeCodes T ON T.ChargeTypeId = C.ChargeCodeId

	WHERE A.TxnDate BETWEEN @F_DATE AND @T_DATE AND A.MASTERID = @MASTERID	AND M.GLCompCode = @COMPCODE AND T.PropertyId = @PropertyID AND T.CostingId = @CostingID

	--GROUP BY C.ID, C.Name, S.SubAccountName

	
	-- CURRENT FINANCIAL YEAR TD
	INSERT INTO #DFAS_Temp (Compcode, MasterID, PropertyID, TxnDate, ICID, ItemCategory, AccountName, AmountTD)

	SELECT DISTINCT @COMPCODE, @MASTERID, @PROPERTYID, A.TxnDate, C.ID, C.Name ItemCategory, S.SubAccountName AccountName, (A.AccAmount*CASE WHEN A.DrCr = 'D' THEN -1 ELSE 1 END) Amount

	FROM eFinancials_Accounting.dbo.AccTxnDetails A
		INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping M ON A.AccCode = M.AccCode
		INNER JOIN eFinancials_Accounting.dbo.accSubAccountRef S ON A.AccCode = S.AccCode
		INNER JOIN HotelResWeb..PostingTypes C ON M.LEVEL1 = CAST(C.ID AS VARCHAR)
		INNER JOIN #DFAS_TempBlocks B ON B.Blockcode = M.BlockCode
		INNER JOIN CostingTypeWiseChargeCodes T ON T.ChargeTypeId = C.ChargeCodeId

	WHERE A.TxnDate BETWEEN @T_DATE AND @T_DATE AND A.MASTERID = @MASTERID	AND M.GLCompCode = @COMPCODE AND T.PropertyId = @PropertyID AND T.CostingId = @CostingID

	--GROUP BY C.ID, C.Name, S.SubAccountName


	-- HISTORY FINANCIAL YEAR MTD
	INSERT INTO #DFAS_Temp (Compcode, MasterID, PropertyID, TxnDate, ICID, ItemCategory, AccountName, AmountMTD)
	
	SELECT DISTINCT @COMPCODE, @MASTERID, @PROPERTYID, A.TxnDate, C.ID, C.Name ItemCategory, S.SubAccountName AccountName, (A.AccAmount*CASE WHEN A.DrCr = 'D' THEN -1 ELSE 1 END) Amount
	
	FROM eFinancials_Accounting.dbo.accHistoryAccTxnDetails A
		INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping M ON A.AccCode = M.AccCode
		INNER JOIN eFinancials_Accounting.dbo.accSubAccountRef S ON A.AccCode = S.AccCode
		INNER JOIN HotelResWeb..PostingTypes C ON M.LEVEL1 = CAST(C.ID AS VARCHAR)
		INNER JOIN #DFAS_TempBlocks B ON B.Blockcode = M.BlockCode
		INNER JOIN CostingTypeWiseChargeCodes T ON T.ChargeTypeId = C.ChargeCodeId

	WHERE A.TxnDate BETWEEN @F_DATE AND @T_DATE AND A.MASTERID = @MASTERID	AND M.GLCompCode = @COMPCODE AND T.PropertyId = @PropertyID AND T.CostingId = @CostingID

	--GROUP BY C.ID, C.Name, S.SubAccountName

	
	-- HISTORY FINANCIAL YEAR TD
	INSERT INTO #DFAS_Temp (Compcode, MasterID, PropertyID, TxnDate, ICID, ItemCategory, AccountName, AmountTD)

	SELECT DISTINCT @COMPCODE, @MASTERID, @PROPERTYID, A.TxnDate, C.ID, C.Name ItemCategory, S.SubAccountName AccountName, (A.AccAmount*CASE WHEN A.DrCr = 'D' THEN -1 ELSE 1 END) Amount

	FROM eFinancials_Accounting.dbo.accHistoryAccTxnDetails A
		INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping M ON A.AccCode = M.AccCode
		INNER JOIN eFinancials_Accounting.dbo.accSubAccountRef S ON A.AccCode = S.AccCode
		INNER JOIN HotelResWeb..PostingTypes C ON M.LEVEL1 = CAST(C.ID AS VARCHAR)
		INNER JOIN #DFAS_TempBlocks B ON B.Blockcode = M.BlockCode
		INNER JOIN CostingTypeWiseChargeCodes T ON T.ChargeTypeId = C.ChargeCodeId

	WHERE A.TxnDate BETWEEN @T_DATE AND @T_DATE AND A.MASTERID = @MASTERID	AND M.GLCompCode = @COMPCODE AND T.PropertyId = @PropertyID AND T.CostingId = @CostingID

	--GROUP BY C.ID, C.Name, S.SubAccountName


	-- ItemCategory/Account wise
	--SELECT Compcode, MasterID, PropertyID, ICID, ItemCategory, AccountName, SUM(AmountTD) AmountTD, SUM(AmountMTD) AmountMTD
	--FROM #DFAS_Temp
	--GROUP BY Compcode, MasterID, PropertyID, ICID, ItemCategory, AccountName

	-- ItemCategory/Account wise
	SELECT DISTINCT Compcode, MasterID, PropertyID, AccountName, SUM(AmountTD) AmountTD, SUM(AmountMTD) AmountMTD
	FROM #DFAS_Temp
	GROUP BY Compcode, MasterID, PropertyID, ICID, ItemCategory, AccountName


	-- ItemCategory wise
	--SELECT Compcode, MasterID, PropertyID, ICID, ItemCategory, SUM(AmountTD) AmountTD, SUM(AmountMTD) AmountMTD
	--FROM #DFAS_Temp
	--GROUP BY Compcode, MasterID, PropertyID, ICID, ItemCategory


	BEGIN TRY DROP TABLE #DFAS_Temp END TRY
	BEGIN CATCH END CATCH

	BEGIN TRY DROP TABLE #DFAS_TempBlocks END TRY
	BEGIN CATCH END CATCH

END

GO

