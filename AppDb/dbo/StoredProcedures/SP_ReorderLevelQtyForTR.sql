-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2024-09-06
-- Description:	Loading re-Order reched items for transfer request

--  [dbo].[SP_ReorderLevelQtyForTR] 1,-999,1,5

-- =============================================
CREATE PROCEDURE [dbo].[SP_ReorderLevelQtyForTR]
	@locationID INT,
	@categoryid INT,
	@PropertyID INT,
	@TransferLocationID INT
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#Temp') IS NOT NULL DROP TABLE #Temp
	CREATE TABLE #Temp (
						 UniqueId INT IDENTITY(1,1) NOT NULL,
						  RequestHeaderID INT NOT NULL,
						  RequestDetailID INT NOT NULL,
						  CategoryID INT,  -- Assuming a length of 50 for string fields, adjust as necessary
						  CategoryName NVARCHAR(200),  -- Adjust length as necessary
						  Status BIT,  -- Boolean in TypeScript maps to BIT in SQL
						  StockItemID INT,
						  StockName NVARCHAR(MAX),  -- Adjust length as necessary
						  UnitID INT,
						  UnitName NVARCHAR(200),  -- Adjust length as necessary
						  RequestedQuantity DECIMAL(18, 2),  -- Adjust precision and scale as needed
						  IssuedQuantity DECIMAL(18, 2),  -- Adjust precision and scale as needed
						  AvailableQTY DECIMAL(18, 2),  -- Adjust precision and scale as needed
						  ApprovedQuantity DECIMAL(18, 2),  -- Adjust precision and scale as needed
						  Remarks NVARCHAR(MAX),  -- For large text
						  TimeStamp DATE,
						  UnitPrice DECIMAL(18, 2),  -- Adjust precision and scale as needed
						  InvAccountID INT,
						  RemarksForshow NVARCHAR(MAX),  -- For large text
						  MasterUnitID INT,
						  CostId INT,
						  CostQuantity DECIMAL(18, 2),  -- Adjust precision and scale as needed
						  ItemDeliveryDate DATE
						);

		INSERT INTO #Temp (RequestHeaderID,RequestDetailID,CategoryID,CategoryName,Status,StockItemID,StockName, UnitID,UnitName, RequestedQuantity,IssuedQuantity, 
		AvailableQTY, ApprovedQuantity, Remarks,  TimeStamp,  UnitPrice, InvAccountID,RemarksForshow,MasterUnitID,CostId,CostQuantity,ItemDeliveryDate)
		
		SELECT 0 RequestHeaderID,0 RequestDetailID,SH.CategoryID CategoryID,CA.Name CategoryName,1 Status,SH.Id StockItemID,SH.Name StockName,SD.MasterUnitID UnitID
		,U.Name UnitName,SD.ReOrderQuantity RequestedQuantity,SD.ReOrderQuantity IssuedQuantity, 
		SD.QuantityInHand AvailableQTY,SD.ReOrderQuantity ApprovedQuantity,'' Remarks, CONVERT(DATE,GETDATE()) TimeStamp,  
		--SD.AveragePrice UnitPrice,
		 dbo.FN_GetAveragePrice(@PropertyID,@TransferLocationID,SH.ID, 'RT', 0,U.ID, 0) UnitPrice,
		0 InvAccountID,'' RemarksForshow,SD.MasterUnitID,0 CostId,SD.ReOrderQuantity CostQuantity,CONVERT(DATE,GETDATE()) ItemDeliveryDate
		FROM StockItemHeaders SH
		INNER JOIN StockItemDetails SD ON SH.Id = SD.StockItemHeaderID
		INNER JOIN Categories CA ON SH.CategoryID = CA.Id
		INNER JOIN Locations LO ON LO.Id = SD.LocationID
		INNER JOIN Units U ON U.Id = SD.MasterUnitID
		INNER JOIN Companies CO ON CO.CompanyID = SH.CompanyId
		INNER JOIN Departments DEP ON CO.DefaultDepartmentID = DEP.Id
		WHERE SH.CompanyId = @PropertyID AND SD.ReOrderLevel>0
		AND SD.QuantityInHand <= SD.ReOrderLevel
		AND SD.LocationID = @locationID
		AND SH.CategoryID = CASE WHEN @categoryid=-999 THEN SH.CategoryID ELSE @categoryid END
		ORDER BY SD.QuantityInHand ASC

	
		SELECT TP.*
		FROM #Temp TP
		INNER JOIN StockItemHeaders SH ON SH.Id = TP.StockItemID
		INNER JOIN StockItemDetails SD ON SD.StockItemHeaderID = SH.Id
		WHERE SD.LocationID=@TransferLocationID
		
   
END

GO

