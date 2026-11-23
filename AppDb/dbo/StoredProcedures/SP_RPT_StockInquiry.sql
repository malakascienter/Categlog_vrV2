-- =============================================
-- Author:		Nivesh
-- Create date: 2024-10-01
-- Description:	Report Stock Inquiry
-- =============================================
-- SP_RPT_StockInquiry '1,2,3,4,14',-999,-999,-999,1,'2024-10-03',0

CREATE PROCEDURE [dbo].[SP_RPT_StockInquiry]
	@LocationID VARCHAR(MAX),
	@CategoryID INT =-999,
	@SubCategoryID INT = -999,
	@Sub2CategoryID INT = -999,
	@PropertyID INT,
	@ToDate DATE,
	@IsZeroBalance BIT
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @IsHotelConnect BIT,@IsResturant BIT,@IsRetail BIT,@SelecttedLocID INT,@Date DATE,
	@LocID2 INT

	IF OBJECT_ID('tempdb..#LocationWithDate') IS NOT NULL
	DROP TABLE #LocationWithDate
	CREATE TABLE #LocationWithDate (LocationID INT, CurrentDate DATE);

	IF OBJECT_ID('tempdb..#Outlets') IS NOT NULL
	DROP TABLE #Outlets
	CREATE TABLE #Outlets (Code CHAR(3) );

	IF OBJECT_ID('tempdb..#TempTodayConsumption') IS NOT NULL
	DROP TABLE #TempTodayConsumption
	CREATE TABLE #TempTodayConsumption(StockItemID INT,StockItemCode VARCHAR(200),Unitname VARCHAR(200),ItemName VARCHAR(200),IssueQty DECIMAL(18,8),QtyInHand DECIMAL(18,8),description VARCHAR(100),LocationID INT)

	IF OBJECT_ID('tempdb..#StockBalance') IS NOT NULL
	DROP TABLE #StockBalance
	CREATE TABLE #StockBalance(StockItemID INT,StockItemCode VARCHAR(200),Unitname VARCHAR(200),ItemName VARCHAR(200),QtyInHand DECIMAL(18,8),description VARCHAR(100),LocationID INT)

	
	SELECT @IsHotelConnect=IsHotelConnect,@IsResturant=IsRestaurant,@IsRetail=IsRetail  
	FROM Companies WHERE CompanyID=@PropertyID

	SELECT Id, Name LocationName 
	into #LocationListTable 
	from Locations
	WHERE Id in (SELECT * FROM string_split(@LocationID,N','))

	


	WHILE EXISTS(SELECT 1 FROM #LocationListTable)
	BEGIN
	SELECT TOP(1) @SelecttedLocID = Id FROM #LocationListTable

	INSERT INTO #LocationWithDate(LocationID,CurrentDate)
	SELECT  @SelecttedLocID,[dbo].[FN_GetCurrentDate](@PropertyID,@SelecttedLocID)
		
		INSERT INTO #Outlets( Code )
		SELECT Code
		FROM Location_Ref
		WHERE StockLocationID= @SelecttedLocID
	

	DELETE TOP (1) FROM #LocationListTable
	END

	WHILE EXISTS(SELECT 1 FROM #LocationWithDate)
	BEGIN
	SELECT TOP(1) @Date = CurrentDate,@LocID2 = LocationID FROM #LocationWithDate

	IF(@Date <> @ToDate OR @Date IS NULL)
	BEGIN
	INSERT INTO #StockBalance(StockItemID,StockItemCode,Unitname,ItemName,QtyInHand,description,LocationID)
	SELECT SH.Id,SH.StockItemCode,UN.Name Unitname,SH.Name ItemName,[dbo].[GetBalance](@ToDate,SH.ID,@LocID2,0, 0) ,LO.Name LocationName,LO.ID LocationID
	FROM STOCKITEMHEADERS SH
	INNER JOIN STOCKITEMDETAILS SD ON SH.ID = SD.StockItemHeaderID
	INNER JOIN LOCATIONS LO ON LO.ID = SD.LOCATIONID
	INNER JOIN Units UN ON UN.ID = SD.MasterUnitID 
	WHERE SD.LOCATIONID = @LocID2
	AND SH.CompanyID =  @PropertyID
	AND SH.CategoryID = CASE WHEN @CategoryID = -999 THEN SH.CategoryID ELSE @CategoryID END
	AND SH.SubCategoryID = CASE WHEN @SubCategoryID = -999 THEN SH.SubCategoryID ELSE @SubCategoryID END
	AND SH.SubCategory2ID = CASE WHEN @Sub2CategoryID = -999 THEN SH.SubCategory2ID ELSE @Sub2CategoryID END
	--AND SD.QuantityInHand >0


	END
	ELSE
	BEGIN
		INSERT INTO #Outlets( Code )
		SELECT Code
		FROM Location_Ref
		WHERE StockLocationID= @LocID2

		--Used to get Consumptions
		INSERT INTO #TempTodayConsumption(StockItemID,StockItemCode,Unitname,ItemName,IssueQty,QtyInHand,description,LocationID)
		SELECT SH.ID,SH.StockItemCode,UN.Name Unitname ,SH.Name ItemName,SUM(PD.Quantity) IssueQty,0,LO.Name description,PH.LocationID  --Union TO GET RETAIL CONSUMPTION
		FROM POS_InvoiceHeader PH
		INNER JOIN POS_InvoiceDetail PD ON PH.InvHeaderID = PD.InvHeaderID
		INNER JOIN StockItemHeaders SH ON SH.ID = PD.ItemID
		INNER JOIN Locations LO ON LO.Id = PH.LocationID
		INNER JOIN StockItemDetails SD ON SD.StockItemHeaderID = SH.Id AND SD.LocationID = PH.LocationID
		INNER JOIN Units UN ON UN.ID = SD.MasterUnitID 
		WHERE PH.LocationID  =@LocID2
		AND CONVERT(DATE, PH.BusinessDate) =  CONVERT(DATE,@Date) 
		AND SH.CompanyID =  @PropertyID
		AND SH.CategoryID = CASE WHEN @CategoryID = -999 THEN SH.CategoryID ELSE @CategoryID END
		AND SH.SubCategoryID = CASE WHEN @SubCategoryID = -999 THEN SH.SubCategoryID ELSE @SubCategoryID END
		AND SH.SubCategory2ID = CASE WHEN @Sub2CategoryID = -999 THEN SH.SubCategory2ID ELSE @Sub2CategoryID END
		GROUP BY UN.Name,SH.ID,SH.StockItemCode,PD.ItemCode,SH.Name,LO.Name,PH.LocationID
		UNION ALL
		SELECT	SH.ID,SH.StockItemCode,UN.Name Unitname, SH.Name ItemName,SUM(RD.Qty * IB.Qty * BT.Qty) AS IssueQty,0, LR.description,LR.StockLocationID LocationID --Union TO GET RECIPE CONSUMPTION
		FROM	RecipeDetails AS RD INNER JOIN RecipeHeader AS RH ON RD.RecipeCode = RH.RecipeCode AND RD.PropertyId = RH.PropertyId 
		INNER JOIN ItemBreakDown AS IB ON RH.RecipeCode = IB.RecipeCode AND IB.PropertyId = RH.PropertyId 
		INNER JOIN BillTrans AS BT ON IB.MainMenuCode = BT.MainMenuCode AND BT.PropertyId = IB.PropertyId 
		INNER JOIN Location_Ref AS LR ON BT.Outlet = LR.code AND LR.PropertyId = BT.PropertyId 
		INNER JOIN StockItemDetails AS SD ON RD.StockItemCode = SD.StockItemHeaderID AND SD.PropertyID = BT.PropertyId AND SD.LocationID = LR.StockLocationID
		INNER JOIN STOCKITEMHEADERS SH ON SH.ID = SD.StockItemHeaderID
		INNER JOIN Units UN ON UN.ID = SD.MasterUnitID  
		WHERE	BT.PropertyId = CASE WHEN @PropertyID = -999 THEN BT.PropertyId ELSE @PropertyID END 
		AND CONVERT(DATE, BT.OrderDate) =  CONVERT(DATE,@Date) 
		AND LR.code IN(SELECT Code FROM #Outlets) 
		AND SH.CompanyID =  @PropertyID
		AND SH.CategoryID = CASE WHEN @CategoryID = -999 THEN SH.CategoryID ELSE @CategoryID END
		AND SH.SubCategoryID = CASE WHEN @SubCategoryID = -999 THEN SH.SubCategoryID ELSE @SubCategoryID END
		AND SH.SubCategory2ID = CASE WHEN @Sub2CategoryID = -999 THEN SH.SubCategory2ID ELSE @Sub2CategoryID END
		GROUP BY  UN.Name,SH.ID,SH.StockItemCode,SH.Name, LR.description,LR.StockLocationID

		UNION ALL 
		SELECT SH.ID,SH.StockItemCode,UN.Name Unitname,SH.Name ItemName, SUM(BT.Qty) AS IssueQty,0, LR.description,LR.StockLocationID LocationID -- Union TO GET ONE TO ONE MAPPED RECIPE CONSUMPTION
		FROM	BillTrans AS BT 
				INNER JOIN MainMenu MM ON BT.MainMenuCode = MM.ItemCode AND BT.PropertyId = MM.PropertyId
				INNER JOIN Location_Ref AS LR ON BT.Outlet = LR.code AND LR.PropertyId = BT.PropertyId 
				INNER JOIN StockItemDetails AS SD ON MM.StockItemId = SD.StockItemHeaderID AND MM.PropertyID = SD.PropertyId AND SD.LocationID = LR.StockLocationID
				INNER JOIN STOCKITEMHEADERS SH ON SH.ID = SD.StockItemHeaderID
				INNER JOIN Units UN ON UN.ID = SD.MasterUnitID 
		WHERE	BT.PropertyId =  @PropertyId AND CONVERT(DATE, BT.OrderDate) =  CONVERT(DATE,@Date) 
		and LR.Code IN(SELECT Code FROM #Outlets) 
		AND SH.CompanyID =  @PropertyID
		AND SH.CategoryID = CASE WHEN @CategoryID = -999 THEN SH.CategoryID ELSE @CategoryID END
		AND SH.SubCategoryID = CASE WHEN @SubCategoryID = -999 THEN SH.SubCategoryID ELSE @SubCategoryID END
		AND SH.SubCategory2ID = CASE WHEN @Sub2CategoryID = -999 THEN SH.SubCategory2ID ELSE @Sub2CategoryID END
		GROUP BY  UN.Name,SH.ID,SH.StockItemCode,SH.Name, LR.description,LR.StockLocationID
		UNION ALL
		SELECT SH.Id,SH.StockItemCode,UN.Name Unitname,SH.Name ItemName,0,SD.QuantityInHand ,LO.Name LocationName,LO.ID LocationID
		FROM STOCKITEMHEADERS SH
		INNER JOIN STOCKITEMDETAILS SD ON SH.ID = SD.StockItemHeaderID
		INNER JOIN LOCATIONS LO ON LO.ID = SD.LOCATIONID
		INNER JOIN Units UN ON UN.ID = SD.MasterUnitID 
		WHERE SD.LOCATIONID = @LocID2
		AND SH.CompanyID =  @PropertyID
		AND SH.CategoryID = CASE WHEN @CategoryID = -999 THEN SH.CategoryID ELSE @CategoryID END
		AND SH.SubCategoryID = CASE WHEN @SubCategoryID = -999 THEN SH.SubCategoryID ELSE @SubCategoryID END
		AND SH.SubCategory2ID = CASE WHEN @Sub2CategoryID = -999 THEN SH.SubCategory2ID ELSE @Sub2CategoryID END
		
		--End

		UPDATE #TempTodayConsumption
		SET QtyInHand = QtyInHand - IssueQty
		WHERE LocationID = @LocID2

	END

	DELETE TOP(1) FROM #LocationWithDate
	END

	IF(@IsZeroBalance = 0)
	BEGIN
		SELECT  *
		FROM (SELECT StockItemID,StockItemCode,Unitname,ItemName,IssueQty,QtyInHand,description,LocationID
		FROM #TempTodayConsumption
		UNION ALL
		SELECT StockItemID,StockItemCode,Unitname,ItemName,0,QtyInHand,description,LocationID
		FROM #StockBalance) AS A
		WHERE A.QtyInHand>0
		ORDER BY A.LocationID,A.StockItemID

	END
	ELSE
	BEGIN
		SELECT  *
		FROM (SELECT StockItemID,StockItemCode,Unitname,ItemName,IssueQty,QtyInHand,description,LocationID
		FROM #TempTodayConsumption
		UNION ALL
		SELECT StockItemID,StockItemCode,Unitname,ItemName,0,QtyInHand,description,LocationID
		FROM #StockBalance) AS A
		ORDER BY A.LocationID,A.StockItemID
	END
	

END

GO

