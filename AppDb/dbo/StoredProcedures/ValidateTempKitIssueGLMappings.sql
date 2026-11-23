CREATE procedure [dbo].[ValidateTempKitIssueGLMappings](@PropertyID int = 2 , @TxnDate DATE ='2020-08-22')
AS
BEGIN

	SELECT 'KTI' BLOCKCODE, D.CODE L1, CA.CODE L2, SC.CODE L3, SC2.CODE L4, C.CODE GLCOMPCODE
	INTO	#tempData
	FROM	OutletKitchenIssues K
	INNER JOIN StockItemdetails I 	
			ON		K.StockItemID= I.StockItemHeaderID AND K.LocationID= I.LocationID
	INNER JOIN StockItemHeaders H
			ON H.ID= K.StockItemID  AND  H.CompanyID = K.PropertyID
	INNER JOIN Companies C on  K.PropertyID = C.CompanyID
	INNER JOIN Categories CA ON CA.ID= H.CategoryID
	INNER JOIN SubCategories SC ON SC.ID = H.SubCategoryID
	INNER JOIN SubCategories02 SC2 ON SC2.ID = H.SubCategory2ID
	INNER JOIN Locations L On I.LocationID= L.ID
	INNER JOIN Departments D ON D.ID= K.DepartmentID
	WHERE	TxnDate= @TxnDate and K.PropertyID= @PropertyID  


	SELECT T.* INTO #MissingMappings 
	FROM #TempDATA T
	LEFT OUTER JOIN [dbo].[Destinity_GLIntegrationAccountMapping] M 
	ON M.Level1= T.L1 AND M.Level2= T.L2 AND M.Level3= T.L3 AND M.Level4= T.L4 
	AND M.GLCOMPCODE= T.GLCOMPCODE AND M.BLOCKCODE= T.BLOCKCODE
	WHERE M.Level1 IS NULL
 

	SELECT 'GRN' BLOCKCODE,  L1,  L2, '' L3, '' L4, t.GLCOMPCODE INTO #MissingMappings2 
	FROM #TempDATA T
	LEFT OUTER JOIN [dbo].[Destinity_GLIntegrationAccountMapping] M 
	ON M.Level1= T.L1 AND M.Level2= T.L2  
	AND M.GLCOMPCODE= T.GLCOMPCODE AND M.BLOCKCODE= 'GRN'
	WHERE M.Level1 IS NULL

	SELECT * FROm #MissingMappings
	UNION ALL
	SELECT * FROM #MissingMappings2
 
END

GO

