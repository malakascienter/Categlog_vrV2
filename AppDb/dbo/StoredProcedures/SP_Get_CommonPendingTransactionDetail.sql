
-- =============================================
-- Author:		Nivesh
-- Create date: 2025-03-26
-- Description:	Get detail of common transaction detail
-- =============================================
-- SP_Get_CommonPendingTransactionDetail 1,4168,78,3075

CREATE PROCEDURE [dbo].[SP_Get_CommonPendingTransactionDetail] 
	@CompanyId INT ,
	@UserProfileId INT ,
	@TransactionID INT ,
	@TransactionHeaderID INT 
AS
BEGIN
	SET NOCOUNT ON;
-- Insert statements for procedure here
	IF(@UserProfileId = 0)
	BEGIN
		RAISERROR('User ID Invalid, Please Log In Again',16,1)
		ROLLBACK TRANSACTION
	END

	DECLARE @IsCentralLogin BIT
	SELECT	TOP (1) @IsCentralLogin = IsCentralLogin FROM Companies
	WHERE CompanyID =  CASE WHEN @CompanyId = -999 THEN CompanyID ELSE @CompanyId END

	CREATE TABLE #TempUserTable (Id INT, UserName NVARCHAR(250), IsActive BIT , CreatedUserId INT, Password NVARCHAR(300),
	FirstName NVARCHAR(300), LastName NVARCHAR(300))

	IF(@IsCentralLogin  = 1)
	BEGIN
		INSERT INTO #TempUserTable 
		SELECT Id,UserName,IsActive,CreatedUserId, Password, FullName, ''
		FROM [dbo].[CentralUsers]

		
	END	
	ELSE
	BEGIN
		INSERT INTO #TempUserTable 
		SELECT Id,UserName,IsActive,CreatedUserId , Password, FirstName, LastName
		FROM UserMasters
	END
	IF @TransactionID = 2
	BEGIN
	Declare @T1 varchar(max),
			@T2 varchar(max),
			@T3 varchar(max),
			@Sql varchar(max),
			@IsPoModificationComponent bit

			IF OBJECT_ID('tempdb..#PENINGPOHEADER') IS NOT NULL
			DROP TABLE #PENINGPOHEADER

			create table #PENINGPOHEADER (POHeaderID int ,ApprovalTypeID int,ReqUserProfId int, ReqUserProf varchar(max),POValue DECIMAL(18,2), TransactionID INT)

			insert into #PENINGPOHEADER 
			EXEC [dbo].[SP_SelectPeningPOApprovalForUser]  @UserProfileId, @CompanyId

			set @IsPoModificationComponent = 
			(select IsPoModificationComponent from Companies where CompanyID = @CompanyId) 


		DECLARE @LocationID int
			
		
		DECLARE @tblRequestHeader AS TABLE (Id INT IDENTITY(1,1),PoDetailID INT,PoHeaderID INT,StockItemID INT,StockItemCode INT,
		ItemName VARCHAR(max),UnitCode int,UnitName VARCHAR(max), StockInHand  DECIMAL(18,2) ,RequestedQuantity float ,
		ApprovedQuantity float ,ReceivedQuantity float,Remarks VARCHAR(max),UnitPrice DECIMAL(18,2),flag INT,
		RequestHeaderID INT,RequestionQty float, LocationID int, Tax DECIMAL(18,2) )

		INSERT INTO @tblRequestHeader
				(
				  PoDetailID ,
				  PoHeaderID ,
				  StockItemID ,
				  StockItemCode ,
				  ItemName ,
				  UnitCode ,
				  UnitName ,
				  RequestedQuantity ,
				  ApprovedQuantity,
				  ReceivedQuantity ,
				  Remarks ,
				  UnitPrice,
				  flag,
				  RequestHeaderID,
				  RequestionQty,
				  StockInHand,
				  LocationID,
				  Tax
				)
		SELECT	DISTINCT	
			d.Id AS PoDetailID,
			d.PoHeaderID, 
			PWR.StockItemID,  
			i.StockItemID AS StockItemCode,			
			ih.Name AS ItemName,
			d.UnitID AS UnitCode, 
	        u.Name  AS UnitName,
			d.RequestedQuantity, 
			d.ApprovedQuantity, 
			ReceivedQuantity, 
			d.Remarks,
			d.UnitPrice - case when DiscountValue<> 0 THEN DiscountValue ELSE (d.UnitPrice *DiscountPercentage /100) END  ,
			RH.flag,
			PWR.RequestHeaderID,
			PWR.RequestionQty,
			--dbo.GetStockInHand(h.PropertyID,h.LocationID,d.StockItemID),
			 dbo.[FN_GetStockInHand_Reatils](h.PropertyID,h.LocationID,d.StockItemID),
			h.LocationID,
			h.TaxTotal

		FROM         dbo.PoDetails d
			inner join	dbo.PoHeaders h on h.Id = d.PoHeaderID
			inner join	dbo.StockItemDetails i 
			on i.PropertyID = h.PropertyID and h.LocationID = i.LocationID and i.StockItemHeaderID=d.StockItemID
			inner join dbo.StockItemHeaders ih
			on ih.Id = i.StockItemHeaderID and ih.CompanyId = i.CompanyID
			inner join dbo.Units u on u.Id=d.UnitID 
		LEFT  JOIN dbo.PoWisePRs AS PWR ON PWR.PoHeaderID = h.Id AND d.StockItemID=PWR.StockItemID
			LEFT  JOIN dbo.RequestHeaders RH ON RH.Id=PWR.RequestHeaderID 

			--inner join  #PENINGPOHEADER on #PENINGPOHEADER.POHeaderID = h.PoHeaderID 
			

		WHERE     (d.PoHeaderID = @TransactionHeaderID )

		--SELECT * FROM @tblRequestHeader 

		DECLARE @tblRequestHeaderW AS TABLE (Id INT IDENTITY(1,1),PoDetailID INT,PoHeaderID INT,StockItemID INT,StockItemCode INT,
		ItemName VARCHAR(max),UnitCode int,UnitName VARCHAR(max),RequestedQuantity float ,ApprovedQuantity float ,ReceivedQuantity float,Remarks VARCHAR(max),UnitPrice DECIMAL(18,2),ISMrn BIT, StockInHand  DECIMAL(18,2),AdditonalChargesTotal Decimal(18,3),LastPurchasePrice Decimal(18,3), TotalTax Decimal(18,2), Value  DECIMAL(18,2))


		--SELECT * FROM @tblRequestHeader

		WHILE (SELECT count(*) FROM @tblRequestHeader)>0
        BEGIN

		DECLARE @PoHeaderID1 INT,@StockItemID INT 
		SELECT DISTINCT TOP (1)  @PoHeaderID1 = PoHeaderID,@StockItemID=StockItemID, @LocationID =LocationID  FROM @tblRequestHeader

		IF EXISTS(SELECT * FROM @tblRequestHeader WHERE PoHeaderID=@PoHeaderID1 AND StockItemID=@StockItemID AND flag=1)
		BEGIN		
		INSERT INTO @tblRequestHeaderW
		        ( 
		          PoDetailID ,
		          PoHeaderID ,
		          StockItemID ,
		          StockItemCode ,
		          ItemName ,
		          UnitCode ,
		          UnitName ,
		          RequestedQuantity ,
		          ApprovedQuantity ,
		          ReceivedQuantity ,
		          Remarks ,
		          UnitPrice ,
		          ISMrn,
				  StockInHand,
				  AdditonalChargesTotal,
				  LastPurchasePrice,
				  TotalTax,
				  Value
					)
		SELECT  PoDetailID,PoHeaderID,StockItemID,StockItemCode,ItemName,UnitCode,UnitName,SUM(RequestedQuantity),ApprovedQuantity,SUM(ReceivedQuantity),Remarks,UnitPrice,1 ,StockInHand,[dbo].[FN_GetPOwiseAdditionalChargesTotal](@TransactionHeaderID) , dbo.FN_GetLastGRNPrice(@LocationID,@StockItemID),Tax,ISNULL(UnitPrice,0)*ISNULL(ApprovedQuantity,0)
		FROM @tblRequestHeader WHERE PoHeaderID=@PoHeaderID1 AND StockItemID=@StockItemID
		GROUP BY PoDetailID,PoHeaderID,StockItemID,StockItemCode,ItemName,UnitCode,UnitName,Remarks,UnitPrice,ApprovedQuantity,StockInHand,Tax

		END 

		ELSE 
		BEGIN
		--select * from @tblRequestHeader

		INSERT INTO @tblRequestHeaderW
		        ( 
		          PoDetailID ,
		          PoHeaderID ,
		          StockItemID ,
		          StockItemCode ,
		          ItemName ,
		          UnitCode ,
		          UnitName ,
		          RequestedQuantity ,
		          ApprovedQuantity ,
		          ReceivedQuantity ,
		          Remarks ,
		          UnitPrice ,
		          ISMrn,
				  StockInHand,
				  AdditonalChargesTotal,
				  LastPurchasePrice,
				  TotalTax,
				  Value
		        )

		SELECT  PoDetailID,PoHeaderID,StockItemID,StockItemCode,ItemName,UnitCode,UnitName,SUM(RequestedQuantity),ApprovedQuantity,SUM(ReceivedQuantity),Remarks,UnitPrice,0 ,StockInHand,[dbo].[FN_GetPOwiseAdditionalChargesTotal](@TransactionHeaderID) , dbo.FN_GetLastGRNPrice(@LocationID,@StockItemID),Tax,ISNULL(UnitPrice,0)*ISNULL(ApprovedQuantity,0)
		FROM @tblRequestHeader WHERE PoHeaderID=@PoHeaderID1 AND StockItemID=@StockItemID
		GROUP BY PoDetailID,PoHeaderID,StockItemID,StockItemCode,ItemName,UnitCode,UnitName,Remarks,UnitPrice,ApprovedQuantity,StockInHand,Tax
		END
		DELETE FROM @tblRequestHeader 
	    WHERE  PoHeaderID=@PoHeaderID1 AND StockItemID=@StockItemID 

		END 

		SELECT * FROM @tblRequestHeaderW
	 		
	END
	ELSE IF (@TransactionID = 1 OR @TransactionID = 11 OR @TransactionID = 8 OR @TransactionID = 14)
	BEGIN
		SELECT RD.RequestedQuantity,
			RD.UnitPrice,
			(SELECT U.Name FROM dbo.Units AS U WHERE RD.UnitID=u.Id ) AS UnitName,
			SID.Name AS ItemName,
			RD.StockItemID,
			CASE WHEN rd.ApprovedQuantity= 0 THEN Rd.requestedQuantity ELSE  rd.ApprovedQuantity END ApprovedQuantity,
			rd.id AS RequestDetailID,
			RD.Id, RD.RequestedQuantity - RD.IssuedQuantity AS BalanceQuantity,
			D.Name AS DepartmentName,
			RD.IssuedQuantity,
			dbo.[FN_GetStockInHand_Reatils](RH.PropertyID,RH.LocationID,RD.StockItemID) AS StockInHand
			,RD.Remarks
		FROM dbo.RequestDetails AS RD 
		INNER JOIN dbo.StockItemHeaders AS SID ON RD.StockItemID = SID.Id
		INNER JOIN dbo.RequestHeaders RH ON RH.Id = RD.RequestHeaderID
		LEFT JOIN dbo.Departments D ON D.Id = RH.DepartmentID
		WHERE RD.RequestHeaderID = @TransactionHeaderID AND RH.PropertyID = @CompanyId
		AND RH.TransactionTypeCode = @TransactionID
	END
	ELSE IF (@TransactionID =76)
	BEGIN

	IF (SELECT NewItem
		FROM ProcurementRequest
		WHERE ID = @TransactionHeaderID) = 1
	BEGIN
		SELECT TSIR.ItemDescription ItemName, TSIR.ItemCode StockItemCode, U.Name Unit, C.Name Category, SC.Name SubCategory, SC2.Description SubCategory2, 
		CASE WHEN TSIR.Approved =1 THEN'Approved Item' ELSE 'Pending Item' END ItemStatus, 
		'Yes' NewItem, pcr.Quantity Quantity
		FROM ProcurementRequest PCR
		INNER JOIN TempStockItemRequest TSIR ON TSIR.Id = PCR.StockItemRequestID
		INNER JOIN Units U ON U.Id = TSIR.ItemUnit
		INNER JOIN Categories C ON C.Id = TSIR.CategoryId
		INNER JOIN SubCategories SC ON SC.Id = TSIR.SubCategoryId
		INNER JOIN SubCategories02 SC2 ON SC2.Id = TSIR.SubCategory2Id
		WHERE PCR.ID = @TransactionHeaderID
	END

	ELSE IF(SELECT NewItem
		FROM ProcurementRequest
		WHERE ID = @TransactionHeaderID) = 0
	BEGIN
	
		
		SELECT SIH.Name ItemName, SIH.StockItemCode StockItemCode, U.Name Unit, C.Name Category, SC.Name SubCategory, SC2.Description SubCategory2, 'Exists Item' ItemStatus, 'No' NewItem, pcr.Quantity Quantity
		FROM ProcurementRequest PCR
		INNER JOIN StockItemHeaders SIH ON SIH.Id = PCR.ItemID
		INNER JOIN Units U ON U.Id = PCR.UnitID
		INNER JOIN Categories C ON C.Id = SIH.CategoryID
		INNER JOIN SubCategories SC ON SC.Id = SIH.SubCategoryID
		INNER JOIN SubCategories02 SC2 ON SC2.Id = SIH.SubCategory2ID
		WHERE PCR.ID = @TransactionHeaderID
	END
		
	END
	--added by isuru 2026-10-28
	--Reason: Supplier Grading (SGR) approval - graded GRN / Supplier Return documents of the submit
	ELSE IF (@TransactionID = (SELECT TOP (1) Id FROM dbo.TransactionTypes WHERE Code = 'SGR'))
	BEGIN

		SELECT SH.DocumentNo,
			   CASE WHEN SH.TransactionType = 'SR' THEN 'Supplier Return' ELSE 'GRN' END AS DocumentType,
			   FORMAT(SH.TransactionDate, 'yyyy-MM-dd') AS TransactionDate,
			   L.Name AS Location,
			   CAST(SUM(D.MaxMarks) AS DECIMAL(18,2)) AS MaxMarks,
			   CAST(SUM(D.Score) AS DECIMAL(18,2)) AS Score,
			   MAX(D.Remarks) AS Remarks
		FROM dbo.SupplierEvaluationDetail D
		INNER JOIN dbo.StockTransactionHeaders SH WITH (NOLOCK) ON SH.Id = D.StockTransactionHeaderID
		LEFT JOIN dbo.Locations L ON L.Id = SH.LocationID
		WHERE D.EvaluationHeaderID = @TransactionHeaderID
		GROUP BY SH.Id, SH.DocumentNo, SH.TransactionType, SH.TransactionDate, L.Name
		ORDER BY SH.TransactionDate, SH.Id

	END
	--End
	ELSE IF (@TransactionID = 81)
	BEGIN

		SELECT TG.Code,TG.Description,TG.BankName,TG.BranchName,TG.AccountNo,TG.CompanyRegistrationNo
		FROM TourGuideCompanies TG
		WHERE TG.ID = @TransactionHeaderID 

	END
	ELSE IF (@TransactionID = 82)
	BEGIN

		SELECT TG.Code,TG.Description,TG.TourGuideLicense,TG.Address,TG.BankName,TG.Branch,TG.BankAccount,TT.Name TourGuideType
		FROM TourGuideMaster TG
		LEFT JOIN TourGuideType TT ON TG.TourGuideTypeID = TT.ID
		WHERE TG.ID = @TransactionHeaderID 

	END

	ELSE IF (@TransactionID = 5)
	BEGIN
		DECLARE @XMLDetails XML,@iDocID INT,@LocationId5 INT,@ItemTotal DECIMAl(18,6),@StockItemID5 INT,@SupplierID INT, @TaxAmount DECIMAL(18,6),
		@Qty DECIMAL(18,6)
		DECLARE @GRNXML VARCHAR(MAX),@NEWGRNXML XML,@iDocIDORG INT

		SELECT @XMLDetails = CONVERT(XML,XMLDetails),@LocationId = LocationId
		FROM  GRNApprovalLog 
		WHERE Id = @TransactionHeaderID


		CREATE TABLE #AllData(
		StockItemID INT,
		ItemCode VARCHAR(MAX),
		Quantity DECIMAL(18,6),
		UnitPrice DECIMAL(18,6),
		UnitName VARCHAR(200),
		ItemName VARCHAR(MAX),
		Remarks VARCHAR(MAX),
		LocationId INT,
		QuantityInHand DECIMAL(18,6)
		)

		-----------------------------------------------------------------------------------------
		SELECT @GRNXML = XMLDetails FROM  [dbo].[GRNApprovalLog] WHERE Id = @TransactionHeaderID
		SET @NEWGRNXML = CONVERT(XML,@GRNXML)

		EXEC sp_xml_preparedocument @iDocIDORG OUTPUT, @NEWGRNXML;
		declare @tempDate varchar(20)

		SELECT @tempDate= TransactionDate  FROM
			OPENXML(@iDocIDORG, '/StockTransactionHeader', 2)
			WITH (TransactionDate DATE)
		---------------------------------------------------------------------------------------------

		EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;
		
  		SELECT * 
		INTO #tempItemDetails 
		FROM OPENXML(@iDocID, '/StockTransactionHeader/StockDetailList/StockTransactionDetail', 2) 
		WITH (StockItemID INT, Quantity DECIMAL(18,6),UnitPrice DECIMAL(18,6),TxnUnitID INT, Remarks VARCHAR(MAX))


		----------------------------------------------------------------------------------------------

		WHILE (SELECT COUNT(*) FROM #tempItemDetails)>0
		BEGIN
				SELECT TOP(1) @StockItemID = StockItemID, @Qty = Quantity FROM #tempItemDetails
				SELECT  TOP(1)  @ItemTotal = UnitPrice * Quantity
				FROM #tempItemDetails

			--added by Isuru 2023-08-02
			 DECLARE @TransactionType VARCHAR(10),
					@GRNHeaderID INT


			 SELECT @GRNHeaderID = ReferenceID  FROM 
			OPENXML(@iDocID, '/StockTransactionHeader', 2) 
			WITH (ReferenceID INT)


			 SELECT @TransactionType = TransactionType
			 FROM GRNApprovalLog
			 WHERE Id = @TransactionHeaderID
		

			INSERT INTO #AllData
			SELECT TOP(1) TD.StockItemID,SH.StockItemCode ItemCode,TD.Quantity AS Quantity,TD.UnitPrice,U.Name AS UnitName,
			SH.Name ItemName, TD.Remarks,@LocationId AS LocationId,
			(SELECT QuantityInHand FROM  StockItemDetails WHERE StockItemHeaderID = TD.StockItemID AND LocationID = @LocationId) AS QuantityInHand
			FROM #tempItemDetails TD
			INNER JOIN Units U ON U.Id = TD.TxnUnitId
			INNER JOIN StockItemHeaders SH ON SH.Id = TD.StockItemID
			
			DELETE TOP(1) FROM #tempItemDetails
		END
		
		SELECT * FROM  #AllData where Quantity > 0
	END
	ELSE IF (@TransactionID = 78) -- ADDED Tharuka 2026-08-10 - Production Process Plan (PL)
	BEGIN
		
		SELECT	SH.StockItemCode											AS ItemCode,
				SH.Name														AS ItemName,
				ISNULL(U.Name,'')											AS UnitName,
				CAST(ISNULL(PCD.RequestedQTY,0)       AS DECIMAL(18,3))		AS RequestedQuantity,
				CAST(ISNULL(PCD.ProductionQuantity,0) AS DECIMAL(18,3))		AS ProductionQty,
				CAST(ISNULL(PCD.QuantityInHand,0)     AS DECIMAL(18,3))		AS QuantityInHand
		FROM ProductionConsolidateDetails PCD
		INNER JOIN StockItemHeaders SH	ON SH.Id	= PCD.StockItemID
		LEFT  JOIN Units U				ON U.Id		= PCD.MasterUnitID
		WHERE PCD.HeaderID = @TransactionHeaderID
		ORDER BY SH.Name
	END
END

GO

