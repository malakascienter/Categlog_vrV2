
--   [dbo].[SP_RPT_TransactionListing] '2025/01/01','2025/04/01',-999,-999,-999,'SR',5485,-999,'T',1


CREATE PROCEDURE [dbo].[SP_RPT_TransactionListing_TeaAvenue] 
( 
@DateFrom DATE='2020/08/01', 
@DateTo DATE='2020/10/10', 
@StockItemID INT =-999, 
@CategoryID INT= -999, 
@LocationID INT=5,
@TransactionType varchar(10)='TI', 
@UserID int =1, 
@DepartmentID int =-999, 
@type char(1)='T',
@PropertyID INT
)
as

--RI	Issue Requisition 
--RP	Purchase Requisition
--RT	Requisition Transfer Out
--RD	Damage Request Note

--DN	Damage Note
--IN	Issue Note
--IR	Issue Return
--TI	Transfer IN
--TO	Transfer Out

Declare  @TxnType TABLE  (ID VARCHAR(10)) 

  
CREATE TABLE #UserLocation (LocationID INT )

INSERT INTO #UserLocation
        ( LocationID )
SELECT [LocationID] FROM UserWise_Location
WHERE UserID= @UserID


IF @type='T'
BEGIN

	INSERT INTO @TxnType 
	SELECT 'DN'
	UNION ALL
	SELECT 'IN'
	UNION ALL
	SELECT 'IR'
	UNION ALL
	SELECT 'TI'
	UNION ALL
	SELECT 'TO'
	UNION ALL
	SELECT 'AA'
	UNION ALL
	SELECT 'SR'
	 


	SELECT co.Name As CompanyName, l.Name Location, h.DocumentNo,CONVERT(VARCHAR(10),h.TransactionDate,103) AS TransactionDate, tt.Name TransactionType ,
	IH.StockItemCode , IH.Name StockItemName, CAST(CONVERT(varchar, CAST(d2.Quantity AS MONEY), 1) AS varchar) AS Quantity ,
	CAST(CONVERT(varchar, CAST(d2.UnitPrice AS MONEY), 1) AS varchar) AS UnitPrice, tu.Name Unit,
	CAST(CONVERT(varchar, CAST(d2.Quantity * d2.UnitPrice AS MONEY), 1) AS varchar) AS Value,C.Name AS CatName, SB.Description AS SubCat2Name,DS.Name AS DeptName,D.Remarks
	,(select Name from Locations where id = H.TransferLocationID) as ToLocation
	,SU.Name SuppName,h.ReferenceNo,(SELECT TOP(1) DocumentNo FROM StockTransactionHeaders where id = h.ReferenceID and TransactionType = 'GR') AS GRNNO
	,DR.Name DamageCategory
	FROM dbo.StockTransactionDetails AS D
	INNER JOIN  dbo.StockTransactionHeaders AS H ON D.StockTransactionHeaderID = H.Id 
	INNER JOIN dbo.StockItemHeaders AS IH ON D.StockItemID = IH.Id
	INNER JOIN dbo.StockTransactionDetails AS D2 ON D.Id = D2.Id
	INNER JOIN dbo.StockItemDetails AS ID ON IH.Id = ID.StockItemHeaderID AND H.LocationId = ID.LocationID
	INNER JOIN dbo.Units AS U ON ID.MasterUnitID = U.Id
	INNER JOIN dbo.Units AS TU ON d2.TxnUnitID = TU.Id
	INNER JOIN dbo.Categories c ON c.Id= ih.CategoryID
	INNER JOIN dbo.Locations l ON l.Id = h.LocationID
	INNER JOIN #UserLocation ul ON ul.LocationID = l.Id
	INNER JOIN dbo.TransactionTypes tt ON tt.Code= h.TransactionType
	INNER JOIN @TxnType T ON T.ID= TT.CODE
	INNER JOIN SubCategories02 SB ON SB.Id = IH.SubCategory2ID
	INNER JOIN Companies co ON co.CompanyID = H.PropertyID
	LEFT JOIN Departments DS On DS.id =  h.DepartmentID
	LEFT JOIN Suppliers SU ON SU.ID = H.SupplierID
	LEFT JOIN DamageRequestCategories DR ON DR.ID = H.DamageCategoryID
	WHERE	IH.Id = CASE @StockItemID WHEN -999 THEN IH.ID ELSE @StockItemID END  
			AND H.LocationID = CASE @LocationID WHEN -999 THEN h.LocationID ELSE @LocationID END   
			AND H.TransactionDate BETWEEN   @DateFrom AND @DateTo
			AND IH.CategoryID =CASE @CategoryID WHEN -999 THEN IH.CategoryID ELSE @CategoryID END  
			AND H.TransactionType = CASE @TransactionType WHEN '-999' THEN H.TransactionType ELSE @TransactionType END
			AND h.DepartmentID = CASE WHEN @DepartmentID =-999 THEN  h.DepartmentID ELSE @DepartmentID END
			AND H.PropertyID =CASE @PropertyID WHEN -999 THEN H.PropertyID ELSE @PropertyID END 
	ORDER BY h.TransactionDate 
 END 
 ELSE
 BEGIN

	INSERT INTO @TxnType 
	SELECT 'RI'
	UNION ALL
	SELECT 'RP'
	UNION ALL
	SELECT 'RT'
	UNION ALL
	SELECT 'RD'


IF( @TransactionType = 'RT' )
BEGIN


	SELECT  co.Name As CompanyName, l.Name Location, h.DocumentNo,CONVERT(VARCHAR(10),h.RequestDate,103) AS TransactionDate, tt.Name TransactionType , IH.StockItemCode , IH.Name StockItemName, CAST(CONVERT(varchar, CAST(d.ApprovedQuantity AS MONEY), 1) AS varchar) AS Quantity , CAST(CONVERT(varchar, CAST(d.UnitPrice AS MONEY), 1) AS varchar) AS UnitPrice, tu.Name Unit, CAST(CONVERT(varchar, CAST(d.ApprovedQuantity * d.UnitPrice AS MONEY), 1) AS varchar) AS Value,
	C.Name AS CatName,SB.Description AS SubCat2Name, CONCAT('Location : ',L.Name)  AS DeptName
	,CAST(CONVERT(varchar, CAST(d.IssuedQuantity AS MONEY), 1) AS varchar) AS IssuedQuantity
	FROM dbo.RequestDetails AS D
	INNER JOIN  dbo.RequestHeaders AS H ON D.RequestHeaderID = H.Id 
	INNER JOIN dbo.StockItemHeaders AS IH ON D.StockItemID = IH.Id
	INNER JOIN dbo.StockItemDetails AS ID ON IH.Id = ID.StockItemHeaderID AND H.LocationId = ID.LocationID
	INNER JOIN dbo.Units AS U ON ID.MasterUnitID = U.Id
	INNER JOIN dbo.Units AS TU ON d.unitid = TU.Id
	INNER JOIN dbo.Categories c ON c.Id= ih.CategoryID
	INNER JOIN dbo.Locations l ON l.Id = h.LocationID
	INNER JOIN #UserLocation ul ON ul.LocationID = l.Id
	INNER JOIN dbo.TransactionTypes tt ON tt.Code= h.RequestType
	INNER JOIN @TxnType T ON T.ID= TT.CODE
	INNER JOIN SubCategories02 SB ON SB.Id = IH.SubCategory2ID
	INNER JOIN Companies co ON co.CompanyID = H.PropertyID
	LEFT JOIN Departments DS On DS.id =  h.DepartmentID
	WHERE	IH.Id = CASE @StockItemID WHEN -999 THEN IH.ID ELSE @StockItemID END  
			AND H.TransferLocation = CASE @LocationID WHEN -999 THEN h.TransferLocation ELSE @LocationID END   
			AND H.RequestDate BETWEEN   @DateFrom AND @DateTo
			AND IH.CategoryID =CASE @CategoryID WHEN -999 THEN IH.CategoryID ELSE @CategoryID END  
			AND H.RequestType = CASE @TransactionType WHEN '-999' THEN H.RequestType ELSE @TransactionType END
			AND h.DepartmentID = CASE WHEN @DepartmentID =-999 THEN  h.DepartmentID ELSE @DepartmentID END
			AND H.IsApproved=1 and d.ApprovedQuantity> 0
			AND H.PropertyID =CASE @PropertyID WHEN -999 THEN H.PropertyID ELSE @PropertyID END 
	ORDER BY h.RequestDate 

END
ELSE
BEGIN

	SELECT  co.Name As CompanyName, l.Name Location, h.DocumentNo,CONVERT(VARCHAR(10),h.RequestDate,103) AS TransactionDate, tt.Name TransactionType , IH.StockItemCode , IH.Name StockItemName, CAST(CONVERT(varchar, CAST(d.ApprovedQuantity AS MONEY), 1) AS varchar) AS Quantity , CAST(CONVERT(varchar, CAST(d.UnitPrice AS MONEY), 1) AS varchar) AS UnitPrice, tu.Name Unit, CAST(CONVERT(varchar, CAST(d.ApprovedQuantity * d.UnitPrice AS MONEY), 1) AS varchar) AS Value,
	C.Name AS CatName,SB.Description AS SubCat2Name, CONCAT('Department : ',DS.Name) AS DeptName
	,CAST(CONVERT(varchar, CAST(d.IssuedQuantity AS MONEY), 1) AS varchar) AS IssuedQuantity
	FROM dbo.RequestDetails AS D
	INNER JOIN  dbo.RequestHeaders AS H ON D.RequestHeaderID = H.Id 
	INNER JOIN dbo.StockItemHeaders AS IH ON D.StockItemID = IH.Id
	INNER JOIN dbo.StockItemDetails AS ID ON IH.Id = ID.StockItemHeaderID AND H.LocationId = ID.LocationID
	INNER JOIN dbo.Units AS U ON ID.MasterUnitID = U.Id
	INNER JOIN dbo.Units AS TU ON d.unitid = TU.Id
	INNER JOIN dbo.Categories c ON c.Id= ih.CategoryID
	INNER JOIN dbo.Locations l ON l.Id = h.LocationID
	INNER JOIN #UserLocation ul ON ul.LocationID = l.Id
	INNER JOIN dbo.TransactionTypes tt ON tt.Code= h.RequestType
	INNER JOIN @TxnType T ON T.ID= TT.CODE
	INNER JOIN SubCategories02 SB ON SB.Id = IH.SubCategory2ID
	INNER JOIN Companies co ON co.CompanyID = H.PropertyID
	LEFT JOIN Departments DS On DS.id =  h.DepartmentID
	WHERE	IH.Id = CASE @StockItemID WHEN -999 THEN IH.ID ELSE @StockItemID END  
			AND H.LocationID = CASE @LocationID WHEN -999 THEN h.LocationID ELSE @LocationID END   
			AND H.RequestDate BETWEEN   @DateFrom AND @DateTo
			AND IH.CategoryID =CASE @CategoryID WHEN -999 THEN IH.CategoryID ELSE @CategoryID END  
			AND H.RequestType = CASE @TransactionType WHEN '-999' THEN H.RequestType ELSE @TransactionType END
			AND h.DepartmentID = CASE WHEN @DepartmentID =-999 THEN  h.DepartmentID ELSE @DepartmentID END
			AND H.IsApproved=1 and d.ApprovedQuantity> 0
			AND H.PropertyID =CASE @PropertyID WHEN -999 THEN H.PropertyID ELSE @PropertyID END 
	ORDER BY h.RequestDate

END


 END

GO

