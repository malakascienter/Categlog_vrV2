-- =============================================
-- Author:		Nivesh
-- Create date: 2024-12-12
-- Description:	Getting batch transactions
-- =============================================
-- GetBatchTransactions 'GR',-999,'2025-01-01','2025-12-13',-999

CREATE PROCEDURE [dbo].[GetBatchTransactions]
	@TransactionType CHAR(2) = 'GR',
	@LocationID INT = -999,
	@FromDate DATE = '2024-09-11',
	@ToDate DATE = '2024-12-13',
	@SupplierID INT = -999
AS
BEGIN
	SET NOCOUNT ON;
	
	-- Create filtered temp table first to reduce dataset size early
	CREATE TABLE #FilteredHeaders (
		ID INT,
		DocumentNo NVARCHAR(100),
		TransactionType CHAR(2),
		TransactionDate DATE,
		PropertyID INT,
		LocationID INT,
		ReferenceNo NVARCHAR(100),
		SupplierID INT,
		Remarks NVARCHAR(500),
		ReferenceID INT,
		UserProfileID INT,
		TransactionID INT,
		Mode NVARCHAR(50),
		CreatedUserID INT,
		LastModUserID INT,
		CreatedDate DATETIME,
		LastModDate DATETIME,
		IsPrint BIT,
		IsApproved BIT,
		InvoiceDate DATE,
		GRNTypeID INT,
		BudgetID INT,
		PaidAmount DECIMAL(18,2),
		SendMail BIT,
		IsProdGenerate BIT
	);
	
	INSERT INTO #FilteredHeaders
	SELECT 
		STH.ID, STH.DocumentNo, STH.TransactionType, STH.TransactionDate,
		STH.PropertyID, STH.LocationID, STH.ReferenceNo, STH.SupplierID,
		STH.Remarks, STH.ReferenceID, STH.UserProfileID, STH.TransactionID,
		STH.Mode, STH.CreatedUserID, STH.LastModUserID, STH.CreatedDate,
		STH.LastModDate, STH.IsPrint, STH.IsApproved, STH.InvoiceDate,
		STH.GRNTypeID, STH.BudgetID, STH.PaidAmount, STH.SendMail,
		STH.IsProdGenerate
	FROM StockTransactionHeaders STH WITH (NOLOCK)
	WHERE STH.TransactionType = @TransactionType
		AND STH.TransactionDate BETWEEN @FromDate AND @ToDate
		AND (@LocationID = -999 OR STH.LocationID = @LocationID)
		AND (@SupplierID = -999 OR STH.SupplierID = @SupplierID)
		AND NOT EXISTS (SELECT 1 FROM [dbo].[BatchTransactionDetail] BTD WITH (NOLOCK) 
                       WHERE BTD.TransactionID = STH.ID);

	-- Create indexes on temp table
	CREATE CLUSTERED INDEX IX_FilteredHeaders_ID ON #FilteredHeaders (ID);
	
	;WITH AggregatedData AS (
		SELECT 
			STH.ID,
			SUM(CASE WHEN SD.DiscountPercentage > 0 AND SD.DiscountValue = 0 
					THEN (SD.UnitPrice * SD.DiscountPercentage / 100) * SD.Quantity 
					ELSE SD.DiscountValue END) AS DiscountValue,
			SUM(ISNULL(ST.taxamount, 0)) AS TaxAmount,
			SUM(ISNULL(SD.UnitPrice, 0) * ISNULL(SD.Quantity, 0)) AS SubTotal
		FROM #FilteredHeaders STH
		INNER JOIN StockTransactionDetails SD WITH (NOLOCK) 
			ON SD.StockTransactionHeaderID = STH.ID
		LEFT JOIN StockTransactionwiseTaxes ST WITH (NOLOCK) 
			ON SD.Id = ST.StockTransactionDetailID 
			AND SD.StockItemID = ST.StockItemID
		GROUP BY STH.ID
	),
	AdditionalCharges AS (
		SELECT 
			STW.StockTransactionHeaderID,
			SUM(ISNULL(STW.ChargeAmount, 0)) AS AdditionalCharge
		FROM StockTransactionwiseCharges STW WITH (NOLOCK)
		INNER JOIN #FilteredHeaders STH ON STW.StockTransactionHeaderID = STH.ID
		GROUP BY STW.StockTransactionHeaderID
	),
	UserNames AS (
		SELECT 
			UserProfileID,
			Username
		FROM (
			SELECT 
				UserProfileID,
				Username,
				ROW_NUMBER() OVER (PARTITION BY UserProfileID ORDER BY (SELECT NULL)) as rn
			FROM (
				SELECT DISTINCT 
					FH.UserProfileID,
					U.Username
				FROM #FilteredHeaders FH
				INNER JOIN Categlog_vrV2..users U ON U.Id = FH.UserProfileID
				UNION ALL
				SELECT DISTINCT 
					FH.UserProfileID,
					CU.Username
				FROM #FilteredHeaders FH
				INNER JOIN Categlog_vrV2..CentralUsers CU ON CU.Id = FH.UserProfileID
			) CombinedUsers
		) RankedUsers
		WHERE rn = 1
	),
	TransactionDetails AS (
		SELECT 
			FH.ID AS StockTransactionHeaderID,
			(SELECT 
				SD.StockItemID, 
				SD.Quantity AS GRNQty,
				SD.UnitPrice, 
				U.Name AS Unit, 
				SH.Name AS ItemName,  
				SD.Remarks,
				@LocationId AS LocationId,
				SID.QuantityInHand,
				SD.DiscountValue, 
				SD.DiscountPercentage,
				SD.UnitPrice * SD.Quantity AS GRossTotal
			FROM StockTransactionDetails SD
			INNER JOIN Units U WITH (NOLOCK) ON U.Id = SD.TxnUnitId
			INNER JOIN StockItemHeaders SH WITH (NOLOCK) ON SH.Id = SD.StockItemID
			LEFT JOIN StockItemDetails SID WITH (NOLOCK) 
				ON SID.StockItemHeaderID = SD.StockItemID 
				AND SID.LocationID = CASE WHEN @LocationId = -999 THEN SID.LocationID ELSE @LocationId END
			WHERE SD.StockTransactionHeaderID = FH.ID
			FOR JSON PATH
			) AS StockTransactionDetailJson
		FROM #FilteredHeaders FH
	)
	SELECT 
		STH.ID,
		STH.DocumentNo,
		STH.TransactionType,
		STH.TransactionDate,
		STH.PropertyID,
		STH.LocationID,
		STH.ReferenceNo,
		STH.SupplierID,
		STH.Remarks,
		STH.ReferenceID,
		STH.UserProfileID,
		STH.TransactionID,
		STH.Mode,
		STH.CreatedUserID,
		STH.LastModUserID,
		STH.CreatedDate,
		STH.LastModDate,
		STH.IsPrint,
		STH.IsApproved,
		STH.InvoiceDate,
		STH.GRNTypeID,
		STH.BudgetID,
		STH.PaidAmount,
		STH.SendMail,
		S.Name AS SupplierName,
		L.Name AS LocationName,
		STH.IsProdGenerate,
		ISNULL(AD.DiscountValue, 0) AS DiscountValue,
		ISNULL(AD.TaxAmount, 0) AS TaxAmount,
		ISNULL(AD.SubTotal, 0) AS SubTotal,
		ISNULL(AC.AdditionalCharge, 0) AS AdditionalCharge,
		UN.Username AS UserName,
		TD.StockTransactionDetailJson,
		(ISNULL(AD.SubTotal, 0) + ISNULL(AD.TaxAmount, 0)) - 
		(ISNULL(AD.DiscountValue, 0) + ISNULL(AC.AdditionalCharge, 0)) AS GrandTotal
	FROM #FilteredHeaders STH
	LEFT JOIN Locations L WITH (NOLOCK) ON L.Id = STH.LocationID
	LEFT JOIN Suppliers S WITH (NOLOCK) ON S.ID = STH.SupplierID
	LEFT JOIN AggregatedData AD ON AD.ID = STH.ID
	LEFT JOIN AdditionalCharges AC ON AC.StockTransactionHeaderID = STH.ID
	LEFT JOIN UserNames UN ON UN.UserProfileID = STH.UserProfileID
	LEFT JOIN TransactionDetails TD ON TD.StockTransactionHeaderID = STH.ID
	ORDER BY STH.TransactionDate DESC;

	DROP TABLE #FilteredHeaders;
END

GO

