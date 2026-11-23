-- =============================================
-- Author:		Nivesh
-- Create date: 2024-09-20
-- Description: Get Existing Mappings
-- =============================================
--SP_GetMappingCheckStockDayEnd_Validation '2024-08-08',1,1

CREATE PROCEDURE [dbo].[SP_GetMappingCheckStockDayEnd_Validation]
	@PropertyID INT,
	@LocationID INT
	
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @XMLDATA XML,@GLCOMPCODE VARCHAR(10), @BLOCKCODEID INT, @LEVEL1 VARCHAR(10), @LocationCode VARCHAR(120), @ItemDetailXml XML,@TxnDate DATE, @OUTPUTREQ VARCHAR(MAX),@TID INT = 9,@sErrorMessage VARCHAR(100)

	IF @PropertyID IS NULL
	BEGIN
		SELECT	@sErrorMessage='Provide Property'
				SELECT	@sErrorMessage '2'
				RAISERROR (@sErrorMessage,16,1)
				RETURN;
	END

	IF @LocationID IS NULL
	BEGIN
		SELECT	@sErrorMessage='Provide Location'
				SELECT	@sErrorMessage '2'
				RAISERROR (@sErrorMessage,16,1)
				RETURN;
	END

	SELECT @TxnDate=CurrentDate FROM Locations WHERE Id = @LocationID
	--SET @TxnDate = '2024-08-08' --for test
	IF (@TxnDate) IS NULL
	BEGIN
		SELECT	@sErrorMessage='Provide Location Current Date'
				SELECT	@sErrorMessage '2'
				RAISERROR (@sErrorMessage,16,1)
				RETURN;
	END

	
	CREATE TABLE #RecursiveResult (
    BLOCKCODE VARCHAR(4),
    ITEMID INT,
    LEVEL1 VARCHAR(50),
    L2 VARCHAR(50),
    L3 VARCHAR(50),
    L4 VARCHAR(50),
    comc VARCHAR(3),
	ItemName VARCHAR(100) NULL,
	LocationName VARCHAR(100) NULL,
	DepartmentName VARCHAR(100) NULL,
	CategoryName VARCHAR(100) NULL,
	SubCategoryName VARCHAR(100) NULL,
	Sub2CategoryName VARCHAR(100) NULL,
	CompanyName VARCHAR(100) NULL
    );

	IF (@TxnDate IS NULL )
	BEGIN
		SET @TxnDate = GETDATE();
	END

	
	SELECT K.BusinessDate AS TxnDate,K.CompanyID AS PropertyID,I.LocationID,k.ItemID StockItemID, SD.AveragePrice  AveragePrice, 
			Quantity * [dbo].[FN_GetUnitConvertionRate](K.CompanyID, I.MasterUnitID, I.MasterUnitID) Quantity, 
			I.MasterUnitID TxnUnitID, SL.DepartmentID AS DepartmentID
	INTO	#tempSalesData
	FROM	POS_InvoiceDetail K INNER JOIN StockItemdetails I ON K.ItemID= I.StockItemHeaderID AND K.LocationID= I.LocationID
			INNER JOIN Locations SL ON K.LocationID = SL.Id
			INNER JOIN StockItemDetails SD ON K.ItemID = SD.StockItemHeaderID AND K.LocationID = SD.LocationID AND K.CompanyID = SD.CompanyID
	WHERE	
	K.BusinessDate= @TxnDate and 
	K.CompanyID = @PropertyID and
	K.LocationID = @LocationID

	IF EXISTS (SELECT 1 FROM #tempSalesData)
	BEGIN
		SET @ItemDetailXml =(select StockItemID ITEMID 
							FROM #tempSalesData
							FOR XML PATH('ITEMDETAIL'));

		SELECT  @GLCOMPCODE= C.CODE, @LocationCode=l.Code
				FROM Companies  C
				INNER JOIN Locations L ON L.CompanyID= c.CompanyID
				where C.CompanyID= @propertyID and L.ID= @LocationID
		
	
		SELECT @LEVEL1= D.CODE FROM Departments D
		INNER JOIN Locations L
		ON D.ID = L.DepartmentID
		WHERE L.Id = @LocationID

		SELECT @BLOCKCODEID = GLBlockID FROM TransactionTypes
				WHERE  ID=  @TID 

		SET @XMLDATA ='<MYROOT>
						<HEADER>
						<GLCOMPCODE>' + @GLCOMPCODE + '</GLCOMPCODE>
						<BLOCKCODEID>'+ CONVERT(VARCHAR(MAX),@BLOCKCODEID)+'</BLOCKCODEID>
						<LEVEL1>'+ REPLACE(@LEVEL1, '&', '&amp;') +'</LEVEL1>
						<LOCATIONCODE>'+ REPLACE(@LocationCode, '&', '&amp;') +'</LOCATIONCODE>
						</HEADER>
							<DETAILS>
								'+ CONVERT(VARCHAR(MAX),@ItemDetailXml) +'
							</DETAILS>
					</MYROOT>'

		exec [eFinancials_Accounting].[dbo].SP_CheckGLMappingCheckStockDayEnd_Validation @XMLDATA,@OUTPUTREQ OUTPUT

		
		IF @OUTPUTREQ IS NOT NULL 
		BEGIN
			DECLARE @iDocID INT
			DECLARE @tempItem XML = convert(xml,@OUTPUTREQ)
			--= '<Details> <Detail><BLOCKCODE>KTI</BLOCKCODE><ITEMID>2</ITEMID><LEVEL1>RFO</LEVEL1><L2>FOD</L2><L3>DAI</L3><L4>BUT</L4><comc>001</comc></Detail><Detail><BLOCKCODE>KTI</BLOCKCODE><ITEMID>3</ITEMID><LEVEL1>RFO</LEVEL1><L2>FOD</L2><L3>DAI</L3><L4>BUT</L4><comc>001</comc></Detail><Detail><BLOCKCODE>GRN</BLOCKCODE><ITEMID>2</ITEMID><LEVEL1>008</LEVEL1><L2>FOD</L2><L3/><L4/><comc>001</comc></Detail><Detail><BLOCKCODE>GRN</BLOCKCODE><ITEMID>3</ITEMID><LEVEL1>008</LEVEL1><L2>FOD</L2><L3/><L4/><comc>001</comc></Detail> </Details>'

			-- Prepare the XML document
			EXEC sp_xml_preparedocument @iDocID OUTPUT, @tempItem

			-- Insert the XML data into #RecursiveResult
			INSERT INTO #RecursiveResult (BLOCKCODE, ITEMID, LEVEL1, L2, L3, L4, comc)
			SELECT 
				BLOCKCODE, 
				ITEMID, 
				LEVEL1, 
				L2, 
				L3, 
				L4, 
				comc
			FROM OPENXML(@iDocID, 'Details/Detail', 2)
			WITH (
				BLOCKCODE VARCHAR(4),
				ITEMID INT,
				LEVEL1 VARCHAR(50),
				L2 VARCHAR(50),
				L3 VARCHAR(50),
				L4 VARCHAR(50),
				comc VARCHAR(3)
			)

			SELECT DISTINCT R.BLOCKCODE, R.ITEMID, R.LEVEL1, R.L2, R.L3, R.L4, R.comc, SH.Name ItemName, L.Name LocationName, D.Name DepartmentName, C.Name CategoryName,
			C1.Name SubCategoryName, C2.Description Sub2CategoryName, CO.Name CompanyName FROM #RecursiveResult R
			inner join StockItemHeaders sh on sh.id = R.ITEMID
			inner join StockItemDetails sd on sd.StockItemHeaderID = sh.Id
			left join Categories C on R.L2 = c.Code
			left join SubCategories c1 on R.L3 = c1.Code AND R.BLOCKCODE = 'KTI'
			left join SubCategories02 c2 on R.L4 = c2.Code AND R.BLOCKCODE = 'KTI'
			left join Locations L on l.Code = R.LEVEL1 AND R.BLOCKCODE = 'GRN'
			left join Departments D on D.Code = R.LEVEL1 AND R.BLOCKCODE = 'KTI'
			left join Companies CO on CO.Code = R.comc
			order by R.ITEMID
			-- Remove the XML document from memory
			EXEC sp_xml_removedocument @iDocID
		END
		ELSE
		BEGIN
			SELECT * FROM #RecursiveResult
		END
	END
	DROP TABLE #tempSalesData
END

GO

