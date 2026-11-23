--[dbo].[SP_RPT_GRNanalysis_Eden]1,-999,-999,-999,'2024/01/01','2024/06/04'
CREATE PROCEDURE [dbo].[SP_RPT_GRNanalysis_Eden](@CompanyId INT, @LocationId INT,@CatId INT,@SubCatId INT,@FromDate DATE,@ToDate DATE,@SupplierID INT)
AS
BEGIN
	SELECT h.name as Item,sh.DocumentNo,PO.PoNo,sh.TransactionDate,sh.ReferenceNo  AS InvoiceNo,sh.InvoiceDate, S.Name AS Supplier,
	U.Name AS UOM, sd.Quantity,sd.UnitPrice, sd.Quantity * sd.UnitPrice AS Value, ISNULL( ST.TaxAmount,0) AS TaxAmount,  
	sd.DiscountPercentage,sd.DiscountValue/NULLIF(sd.Quantity,0) AS  DiscountValue ,(sd.UnitPrice - case when DiscountValue<> 0 THEN sd.DiscountValue/NULLIF(sd.Quantity,0)  ELSE (sd.UnitPrice * sd.DiscountPercentage /100) END )  AS UnitPriceWithDis,
	(sd.UnitPrice - case when DiscountValue<> 0 THEN sd.DiscountValue/NULLIF(sd.Quantity,0)  ELSE (sd.UnitPrice * sd.DiscountPercentage /100) END ) * sd.Quantity + ISNULL( ST.TaxAmount,0) AS BillAmount,sc.Name AS SubCat,l.Name AS Location, FORMAT(sh.CreatedDate,'dd/MM/yyyy') CreatedDate
	--,CASE WHEN PO.POType IS NULL THEN 'General'ELSE POT.Name END AS POTypeName
	,ISNULL(POT.Name,'General') AS POTypeName
	,CU.UserName
	FROM StockTransactionDetails sd
	INNER JOIN StockTransactionHeaders sh ON sd.StockTransactionHeaderID = sh.Id
	INNER JOIN StockItemHeaders h ON h.Id = sd.StockItemID 
	INNER JOIN SubCategories sc On sc.Id = h.SubCategoryID
	INNER JOIN Locations l ON l.Id = sh.LocationID
	INNER JOIN Suppliers S On S.ID = sh.SupplierID
	INNER JOIN Units U ON U.Id = sd.TxnUnitID
	LEFT JOIN  StockTransactionwiseTaxes ST ON ST.StockTransactionDetailID = sd.Id

	LEFT JOIN  [dbo].[PoHeaders] PO ON PO.Id = sh.ReferenceID
	--LEFT JOIN  [dbo].[PoWisePRs] PW ON PW.PoHeaderID = PO.Id
	--LEFT JOIN  [dbo].[RequestHeaders] PR ON PR.Id = PW.RequestHeaderID
	LEFT JOIN PoTypesNew POT ON POT.Id =PO.POType
	LEFT JOIN CENTRALuSERS CU ON CU.ID = SH.CreatedUserID


	WHERE sh.PropertyID = CASE WHEN @CompanyId = -999 THEN sh.PropertyID ELSE @CompanyId END
	AND sh.LocationID = CASE WHEN @LocationId = -999 THEN sh.LocationID ELSE @LocationId END
	AND h.CategoryID = CASE WHEN @CatId = -999 THEN  h.CategoryID ELSE @CatId END
	AND h.SubCategoryID = CASE WHEN @SubCatId = -999 THEN h.SubCategoryID ELSE @SubCatId END 
	AND sh.TransactionType = 'GR' AND sh.TransactionDate BETWEEN @FromDate AND @ToDate
	AND SH.SupplierID = CASE WHEN @SupplierID = -999 THEN SH.SupplierID ELSE @SupplierID END

	Order by TransactionDate asc

	--AND PR.RequestType ='RP'

END

 
 --select * from StockTransactionHeaders where TransactionType = 'gr'

GO

