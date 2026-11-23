-- =============================================
-- Author:		Nivesh
-- Create date: 2024-12-16
-- Description:	Print Batch Transaction
-- =============================================
-- RptPrintBatchTransaction 3,4

create PROCEDURE [dbo].[RptPrintBatchTransaction]
      @StockTxnID INT = 3,
	  @UserName varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IsCentralLogin BIT

	DECLARE @UserData TABLE(
	Id INT,
	UserName NVARCHAR(200),
	EmployeeId INT
	)

	SELECT @IsCentralLogin = IsCentralLogin FROM Companies C
	INNER JOIN [dbo].[BatchTransactionHeader] BTH ON BTH.PropertyID = c.CompanyID
	WHERE BTH.Id= @StockTxnID;


	IF(@IsCentralLogin = 1)
	BEGIN
		 		
		INSERT INTO @UserData
		SELECT Id, UserName, EmpNumber
		FROM [dbo].[CentralUsers]
	
	END
	ELSE
	BEGIN
	
		INSERT INTO @UserData
		SELECT Id, UserName,EmployeeId
		FROM UserMasters

	END
--------------------------

	DECLARE @DocStatus VARCHAR(100)

	;WITH tempTable AS (SELECT DISTINCT BTD.TransactionID,
	BTH.DocNo,
	STH.DocumentNo,
	(SELECT TOP 1 Name FROM  Locations WHERE ID = STH.LocationID ) LocationName,
	(SELECT TOP 1 Name FROM Suppliers WHERE Id = STH.SupplierID) SupplierName,
	STH.InvoiceDate,
	STH.ReferenceNo InvoiceNo,
	ISNULL(L.Name,'--ALL--') BatchLocationName,
	ISNULL(S.Name,'--ALL--') BatchSupplierName,
	UD.UserName,
	BTH.CreatedDate,
	(SELECT  SUM(CASE WHEN SD.DiscountPercentage>0 AND  SD.DiscountValue =0 THEN (SD.UnitPrice *SD.DiscountPercentage /100)* SD.Quantity ELSE SD.DiscountValue END)  FROM StockTransactionDetails SD WHERE SD.stocktransactionheaderid = STH.id) DiscountValue,
	--ISNULL(St.TaxAmount,0) TaxAmount ,
	(SELECT SUM(ST.taxamount) FROM 
	StockTransactionDetails SD
	LEFT OUTER JOIN
				StockTransactionwiseTaxes AS ST ON SD.Id = ST.StockTransactionDetailID AND SD.StockItemID = ST.StockItemID AND SD.stocktransactionheaderid = STH.id) TaxAmount,
	--,C.Name CategoryName,
	--SIH.Name ItemName,
	--SIH.StockItemCode,
	--U.Name UnitName,
	--STD.UnitPrice,
	--STD.Quantity,
	(SELECT SUM(ISNULL(SD.UnitPrice,0)*ISNULL(SD.Quantity,0)) FROM StockTransactionDetails SD WHERE SD.stocktransactionheaderid = STH.id) SubTotal,
	(SELECT ISNULL(SUM(STW.ChargeAmount),0) 
		FROM StockTransactionwiseCharges STW
		INNER JOIN StockTransactionHeaders ST ON stw.StockTransactionHeaderID= ST.Id
		WHERE ST.id= STH.Id) AdditionalCharge,
	CO.Name,
	CO.Address1 compAdd1,
	CO.Telephone1 compTel1,
	 s.Address1, s.Telephone1, s.Email,
	 cm.Name AS Currency
	FROM [dbo].[BatchTransactionHeader] BTH
	INNER JOIN [dbo].[BatchTransactionDetail] BTD ON BTD.BatchTransactionHeaderID = BTH.Id
	INNER JOIN StockTransactionHeaders STH ON STH.Id = BTD.TransactionID
	INNER JOIN StockTransactionDetails STD ON STD.StockTransactionHeaderID = STH.Id
	LEFT JOIN Companies CO ON BTH.PropertyID = CO.CompanyID
	LEFT JOIN Suppliers S ON S.ID = BTH.SupplierID
	LEFT JOIN CurrencyMasters AS cm ON s.CurrencyID = cm.Id
	--LEFT JOIN StockItemHeaders SIH ON SIH.Id = STD.StockItemID
	--LEFT JOIN Units U ON U.Id = STD.TxnUnitID
	--LEFT JOIN Categories C ON C.ID = SIH.CategoryID
	LEFT JOIN Locations L ON L.Id = BTH.LocationID
	
	LEFT JOIN @UserData UD ON UD.Id = BTH.CreatedUserID
	WHERE BTH.Id = @StockTxnID
	)
	SELECT *,
	(ISNULL(SubTotal,0)+ISNULL(TaxAmount,0))-(ISNULL(DiscountValue,0)+ISNULL(AdditionalCharge,0)) GrandTotal 
	FROM temptable
END

GO

