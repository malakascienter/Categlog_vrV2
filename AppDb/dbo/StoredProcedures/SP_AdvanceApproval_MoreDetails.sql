--SP_AdvanceApproval_MoreDetails 11,7307
CREATE PROCEDURE [dbo].[SP_AdvanceApproval_MoreDetails]
	@TransactionType INT, -- bill 34, out sourse 36, work done 37, client provide 38
	@HeaderID INT
AS
BEGIN

	IF(@TransactionType = 34)
	BEGIN

	SELECT 'Document No' AS ColumnDiscription1, B.BillNumber AS ColumnValue1, 'Project Name' AS ColumnDiscription2, P.ProjectName AS ColumnValue2, 
	'Custermer' AS ColumnDiscription3, C.Name AS ColumnValue3, 'Total' AS ColumnDiscription4, B.TotalVal AS ColumnValue4, 'Document Date' AS ColumnDiscription5, 
	B.BillDate AS ColumnValue5, 'Created Date' AS ColumnDiscription6, B.CreatedDate AS ColumnValue6, 'Create By' AS ColumnDiscription7 , U.FirstName + ' ' + U.LastName AS ColumnValue7
	FROM dbo.BillHeaders AS B
	INNER JOIN dbo.ProjectDetails AS P ON P.Id = B.ProjectID
	INNER JOIN dbo.Clients AS C ON C.Id = B.CustomerId
	INNER JOIN dbo.UserMasters AS U ON u.Id = B.CreatedUserID
	WHERE B.Id = @HeaderID

	SELECT 'word done name' AS ColumnValue1, 'Main Work' AS ColumnValue2, 'WokeID' AS ColumnValue3, 'Tax Group' AS ColumnValue4, 'Ammount' AS ColumnValue5, 
	'Inv Ammount' AS ColumnValue6
	 
	SELECT M.Description AS ColumnValue1, S.Description AS ColumnValue2, 
	D.Description AS ColumnValue3 , T.Name AS ColumnValue4, B.amount AS ColumnValue5, B.InvAmount AS ColumnValue6
	FROM dbo.BillDetails AS B
	INNER JOIN dbo.BOQMainWorkAllocations AS M ON M.Id = B.WorkDoneID
	INNER JOIN BOQSubWorkAllocations AS S ON S.Id = B.MainWorkID
	INNER JOIN dbo.WorkHeaders AS D ON D.Id = B.WokeID
	INNER JOIN dbo.TaxGroups AS T ON T.TaxGroupId = D.Id 
	WHERE BillID = @HeaderID

	END
    
	ELSE IF(@TransactionType = 36)
	BEGIN
	
	SELECT 'Document No' AS ColumnDiscription1, O.TxnNumber AS ColumnValue1, 'Project Name' AS ColumnDiscription2, P.ProjectName AS ColumnValue2, 
	'Custermer' AS ColumnDiscription3, S.Name AS ColumnValue3, 'Total' AS ColumnDiscription4, O.Amount AS ColumnValue4, 'Document Date' AS ColumnDiscription5, 
	O.TxnDate AS ColumnValue5, 'Created Date' AS ColumnDiscription6, O.CreatedDate AS ColumnValue6, 'Create By' AS ColumnDiscription7 , U.FirstName + ' ' + U.LastName AS ColumnValue7
	FROM dbo.OutSourceLabourHeaders AS O
	INNER JOIN dbo.ProjectDetails AS P ON P.Id = O.ProjectId
	INNER JOIN dbo.Suppliers AS S ON S.ID = O.LaborMasterId
	INNER JOIN dbo.UserMasters AS U ON u.Id = O.CreatedUserID
	WHERE O.Id = @HeaderID

	SELECT 'Department' AS ColumnValue1, 'Labour Type' AS ColumnValue2, 'Labour Unit' AS ColumnValue3, 'Quantity' AS ColumnValue4, 'Rate' AS ColumnValue5, 
	'Total' AS ColumnValue6
	 
	SELECT D.Name AS ColumnValue1, L.LabourName AS ColumnValue2, 
	U.LaborUnitName AS ColumnValue3 , O.Qty AS ColumnValue4, O.Rate AS ColumnValue5, O.Total AS ColumnValue6		
	FROM dbo.OutSourceLabourDetails AS O
	INNER JOIN dbo.Departments AS D ON D.Id = O.DeptId
	INNER JOIN dbo.LabourTypes AS L ON L.Id = O.LaborTypeId
	INNER JOIN dbo.LaborUnits AS U ON U.Id = O.LaborUnitId
	WHERE O.HedId = @HeaderID



	END
    
	ELSE IF(@TransactionType = 37)
	BEGIN

	SELECT  'Document No' AS ColumnDiscription1,  WDR.DocumentNo AS ColumnValue1, 
			'Project Name' AS ColumnDiscription2,PD.ProjectName AS ColumnValue2, 
			'Section' AS ColumnDiscription3, WA.Description AS ColumnValue3, 
			'Work' AS ColumnDiscription4, WH.Description AS ColumnValue4,
			'Assessed Value' AS ColumnDiscription5, WDR.AssessedValue AS ColumnValue5,
			'Billed Value' AS ColumnDiscription6, WDR.BilledValue AS ColumnValue6 
	from WorkDoneRegistries WDR INNER JOIN  ProjectDetails PD on WDR.ProjectID= PD.Id
	--INNER JOIN Clients C ON C.Id = PD.ClientID
	INNER JOIN WorkHeaders WH ON  WDR.WorkID=  WH.Id
	INNER JOIN BOQMainWorkAllocations WA ON  WDR.MainWorkID= WA.Id AND WDR.BOQID= WA.BOQID
	WHERE WDR.Id = @HeaderID

	SELECT '' AS ColumnValue1, '' AS ColumnValue2, '' AS ColumnValue3, '' AS ColumnValue4, '' AS ColumnValue5, 
	' ' AS ColumnValue6

	SELECT '' AS ColumnValue1, '' AS ColumnValue2, 
	'' AS ColumnValue3 , '' AS ColumnValue4, '' AS ColumnValue5, '' AS ColumnValue6		
	  from WorkDoneRegistries WDR INNER JOIN  ProjectDetails PD on WDR.ProjectID= PD.Id
	INNER JOIN WorkHeaders WH ON  WDR.WorkID=  WH.Id
	INNER JOIN BOQMainWorkAllocations WA ON  WDR.MainWorkID= WA.Id AND WDR.BOQID= WA.BOQID
	WHERE WDR.ID =@HeaderID

	--PRINT ('work done')
	END

	ELSE IF(@TransactionType = 38)
	BEGIN
	
	SELECT 'Document No' AS ColumnDiscription1, C.TxnNumber AS ColumnValue1, 'Project Name' AS ColumnDiscription2, P.ProjectName AS ColumnValue2, 
	'Client' AS ColumnDiscription3, CC.Name AS ColumnValue3, 'BOQ' AS ColumnDiscription4, B.BOQCode AS ColumnValue4, 'Department' AS ColumnDiscription5, 
	D.Name AS ColumnValue5, 'Document  Date' AS ColumnDiscription6, C.TxnDate AS ColumnValue6
	FROM dbo.CustomerSuppliedStockHeaders AS C
	INNER JOIN dbo.ProjectDetails AS P ON P.Id = C.ProjectId
	INNER JOIN dbo.BOQHeaders AS B ON B.Id = C.BOQID
	INNER JOIN dbo.Clients AS CC ON CC.Id = C.CustID
	INNER JOIN dbo.Departments AS D ON D.Id = C.deptID
	WHERE C.Id = @HeaderID

	SELECT 'Item' AS ColumnValue1, 'Unit' AS ColumnValue2, 'Quantity' AS ColumnValue3, 'Unit Price' AS ColumnValue4, 'Total' AS ColumnValue5
	 
	SELECT S.Name AS ColumnValue1, U.Name AS ColumnValue2, 
	C.Qunatity AS ColumnValue3 , C.UnitPrice AS ColumnValue4, C.TotalValue AS ColumnValue5	
	FROM dbo.CustomerSuppliedStockDetails AS C
	INNER JOIN dbo.StockItemHeaders AS S ON S.Id = C.ItemID
	INNER JOIN dbo.Units AS U ON U.Id = C.unitID
	WHERE C.HeaderID = @HeaderID


	END
    	
END

GO

