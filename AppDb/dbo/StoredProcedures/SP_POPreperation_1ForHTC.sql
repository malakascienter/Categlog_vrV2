-- [dbo].[SP_POPreperation_1ForHTC] 1,-999,-999,-999,-999,-999,'',-999,2

CREATE PROCEDURE [dbo].[SP_POPreperation_1ForHTC]
(@PropertyID			INT,
 @SelectedLocationID	INT,
 @SelectedDepartmentId  INT,
 @SelectedDocId			INT,
 @SelectedCategoryId	INT,
 @SelectedItemId		INT,
 @ApprovalDate			DATETIME = null,
 @searchSupplieId		INT = 0,
 @SortOPtionID INT			=1
)
AS
DROP TABLE MYXXX
SELECT @PropertyID			P,
 @SelectedLocationID	L,
 @SelectedDepartmentId  D,
 @SelectedDocId			DOC,
 @SelectedCategoryId	CAT,
 @SelectedItemId		I,
 @ApprovalDate			DATEX
 INTO MYXXX

	DECLARE @IsQuotationAttributeId INT

 SELECT @IsQuotationAttributeId = IsQuotationAttributeId
 FROM CompanySettings
 WHERE ID =@PropertyID

	IF(@SortOPtionID =0 OR @SortOPtionID IS NULL)
	BEGIN
		SET @SortOPtionID =1
	END
     DECLARE @ApprovelCount INT;
     DECLARE @TransactionHeaderID INT;
     DECLARE @rCount INT;
     DECLARE @RequestHeaderID INT, @LocationID INT, @DocumentNo VARCHAR(50), @RequestDate DATETIME, @DeliverytDate DATETIME = NULL,@Urgent BIT,@UrgentRemark VARCHAR(200);
     DECLARE @HRemarks VARCHAR(500), @DepartmentID INT, @DepartmentName VARCHAR(200), @StockItemID INT;
     DECLARE @ItemName VARCHAR(200), @StockItemCode VARCHAR(50), @LocationName VARCHAR(200);
     DECLARE @UnitID INT, @UnitName VARCHAR(200), @ApprovedQuantity MONEY;
     DECLARE @ItemRemarks VARCHAR(200), @RequestedQuantity MONEY;
     DECLARE @SupplierPurchaseUnitID INT, @Supplier VARCHAR(200), @CostPrice MONEY, @SupplierID INT,@IsContractedSupplier BIT ;
	 DECLARE @TenderBoardHeaderNo varchar(200) , @TenderBoardHeaderId int,@IsContractSupplier BIT
	 DECLARE @IsSupplierEvaluate BIT,
	 @IsPartialPR BIT =0 --Added by Nivesh 2025-11-11

		SELECT @IsSupplierEvaluate = IsSupplierEvaluate
		FROM Companies
		WHERE CompanyID = @PropertyID

     DECLARE @Temp TABLE
		(
			UniqueId			    INT IDENTITY(1,1) NOT NULL,
			RequestHeaderID        INT,
			LocationID             INT,
			DocumentNo             VARCHAR(50),
			RequestDate            DATETIME,
			DeliveryDate			DATETIME,
			HRemarks               VARCHAR(500),
			DepartmentID           INT,
			DepartmentName         VARCHAR(200),
			StockItemID            INT,
			ItemName               VARCHAR(200),
			StockItemCode          VARCHAR(50),
			UnitID                 INT,
			UnitName               VARCHAR(200),
			ApprovedQuantity       MONEY,
			ItemRemarks            VARCHAR(200),
			RequestedQuantity      MONEY,
			SupplierPurchaseUnitID INT,
			Supplier               VARCHAR(200),
			CostPrice              MONEY,
			SupplierID             INT,
			LocationName           VARCHAR(200),
			TenderBoardHeaderNo	varchar(200),
			TenderBoardHeaderId	int,
			Urgent					BIT,
			UrgentRemark			varchar(200),
			ApprovedDate VARCHAR(30),
			QtyInHand decimal(18,6),
			ItemTaxAmount decimal(18,6)
		,IsContractedSupplier BIT
		,IsPartialPR BIT NULL --Added by Nivesh 2025-11-11
		);

	CREATE TABLE #table
	(
	RequestHederid INT,
	rCount INT
	)


	CREATE TABLE #t(
		Id INT,
		LocationID INT,
		RequestType VARCHAR(4),
		DocumentNo VARCHAR(100),
		RequestDate datetime,
		DeliveryDate datetime,
		DocumentStatus CHAR(2),
		Remarks VARCHAR(MAX),
		DepartmentID INT,
		Name VARCHAR(100),
		StockItemID INT,
		ItemName VARCHAR(MAX),
		StockItemCode VARCHAR(MAX),
		UnitID INT,
		UnitName VARCHAR(100),
		ApprovedQuantity DECIMAL(18,6),
		DetailRemarks VARCHAR(MAX),
		RequestedQuantity DECIMAL(18,6),
		LocationName VARCHAR(100),
		Urgent BIT,
		UrgentRemark varchar(200)
		,IsPartialPR BIT NULL --Added by Nivesh 2025-11-11
	)

    BEGIN TRY
 

 	IF(@PropertyID = 0)
		BEGIN
			--SET @ErrorMsg2  =  'User ID Invalid, Please Log Again'
			--RAISERROR ( @ErrorMsg2, 16, 1 ); 
			RAISERROR('Property ID Invalid, Please Log In Again',16,1)
			ROLLBACK TRANSACTION
		END

        SET @ApprovelCount = 0;

		SELECT @IsContractSupplier =IsContractedSupplier
		FROM COMPANIES
		WHERE CompanyID = @PropertyID

		IF(@IsSupplierEvaluate = 1)

		BEGIN 
			IF(@SortOPtionID = 1) -- Default Supplier
			BEGIN
				SELECT @ApprovelCount = COUNT(b.id)
					FROM TransactionWiseApprovalTypes AS a
							INNER JOIN TransactionTypes AS b ON a.TransactionID = b.Id
					WHERE(b.Code = 'RP')
							AND PropertyID = @PropertyID
							AND b.LocationID = CASE WHEN @SelectedLocationID = -999 THEN b.LocationID ELSE  @SelectedLocationID END;
							-- add location

					INSERT INTO #table
					SELECT b.id RequestHederid,
							COUNT(*) AS rCount
					--INTO #table
					FROM RequestHeaders AS b 
					WHERE(b.RequestType = 'RP')
							AND (b.DocumentStatus = 'P')
							AND b.IsApproved = 1
							AND b.PropertyID = @PropertyID
							AND b.LocationID = CASE WHEN @SelectedLocationID = -999 THEN b.LocationID ELSE  @SelectedLocationID END
							AND b.DepartmentID = CASE WHEN @SelectedDepartmentId = -999 THEN b.DepartmentID ELSE @SelectedDepartmentId END
							AND b.Id = CASE WHEN @SelectedDocId = -999 THEN b.Id ELSE @SelectedDocId END
						-- AND convert(date, a.ApprovalDate) = CASE WHEN @ApprovalDate IS NULL THEN convert(date, a.ApprovalDate) ELSE @ApprovalDate END
					GROUP BY b.id
       
 
					SELECT @TransactionHeaderID = requesthederid,
							@rCount = rCount
					FROM #table;
	
	
					WHILE @@rowcount > 0
						BEGIN

							INSERT INTO #t (Id,	LocationID,	RequestType,	DocumentNo,	RequestDate,	DeliveryDate,	
							DocumentStatus,	Remarks,	DepartmentID,	Name,	StockItemID,	ItemName,	
							StockItemCode,	UnitID,	UnitName,	ApprovedQuantity,	DetailRemarks,	RequestedQuantity,	
							LocationName,	Urgent,UrgentRemark,IsPartialPR)
							SELECT a.Id,
									a.LocationID,
									a.RequestType,
									a.DocumentNo,
									a.RequestDate,
									a.DeliveryDate,
									a.DocumentStatus,
									b.Remarks,
									a.DepartmentID,
									d.Name,
									b.StockItemID,
									s.Name AS ItemName,
									s.StockItemCode,
									b.UnitID,
									u.Name AS UnitName,
									(b.ApprovedQuantity - b.IssuedQuantity) AS ApprovedQuantity,
									b.Remarks AS DetailRemarks,
									b.ApprovedQuantity RequestedQuantity,
									Locations.Name AS LocationName,
									a.Urgent,
									ISNULL(a.UrgentRemark,'') AS UrgentRemark
									,CASE 
										WHEN EXISTS (SELECT 1 FROM [dbo].[PoWisePRs] where RequestHeaderID = a.Id) 
										THEN 1 
										ELSE 0 
									END AS IsPartialPR --Added by Nivesh 2025-11-11
									
							--INTO [#t]
							FROM RequestHeaders AS a
									INNER JOIN RequestDetails AS b ON a.Id = b.RequestHeaderID
									INNER JOIN StockItemHeaders AS s ON b.StockItemID = s.Id
									INNER JOIN Units AS u ON b.UnitID = u.Id
									INNER JOIN Departments AS d ON a.DepartmentID = d.Id
																AND a.RequestType = 'RP'
																AND a.DocumentStatus = 'P'
																AND a.IsApproved = 1
									INNER JOIN Locations ON a.LocationID = Locations.Id

									left outer JOIN TenderBoardPaperItemDetails as TD on b.stockitemId=TD.StockitemheaderID
									left outer JOIN TenderBoardPaperHeaders as TH on TD.TBPHeaderId = TH.Id 
									and TH.status=2 and  TH.BaseType = 1 AND TH.ExpireDate > getdate() and TH.Id= TD.TBPHeaderId

									WHERE a.PropertyID = @PropertyID 
									AND a.Id = @TransactionHeaderID 
									AND (b.ApprovedQuantity - b.IssuedQuantity) > 0
									AND s.CategoryID = CASE WHEN @SelectedCategoryId = -999 THEN s.CategoryID ELSE @SelectedCategoryId END --added (b.ApprovedQuantity - b.IssuedQuantity) > 0 -- and a.LocationID = @SelectedLocationID 
									AND b.StockItemID = CASE WHEN @SelectedItemId = -999 THEN b.StockItemID ELSE @SelectedItemId END
									AND A.QuotationStatus = 'P' --Added by Nivesh 2025-11-10 For Filtering Quotation related PR
					

							SELECT @RequestHeaderID = Id,
									@LocationID = LocationID,
									@DocumentNo = DocumentNo,
									@RequestDate = RequestDate,
									@DeliverytDate = DeliveryDate,
									@HRemarks = Remarks,
									@DepartmentID = DepartmentID,
									@DepartmentName = Name,
									@StockItemID = StockItemID,
									@ItemName = ItemName,
									@StockItemCode = StockItemCode,
									@UnitID = UnitID,
									@UnitName = UnitName,
									@ApprovedQuantity = ApprovedQuantity,
									@ItemRemarks = Remarks,
									@RequestedQuantity = RequestedQuantity,
									@LocationName = LocationName,
									@Urgent = Urgent,
									@UrgentRemark = ISNULL(UrgentRemark,''),
									@IsPartialPR = IsPartialPR --Added by Nivesh 2025-11-11
								   
							FROM #t;
							
							WHILE @@Rowcount > 0
								BEGIN
								
									IF(	(	SELECT COUNT(*)
											FROM SupplierWiseItemDetails
											WHERE IsDefaultSupplier = 1
											--AND CompanyId = @PropertyID
											AND StockItemID = @StockItemID
											AND LocationId = @LocationID -- Added by Isuru 2025-04-24 for loading correct location related suppliers
										) > 0)

										BEGIN
					                    
											SELECT TOP (1) @SupplierID = SupplierWiseItemDetails.SupplierID,
															@CostPrice = MIN(SupplierWiseItemDetails.CostPrice),
															@SupplierPurchaseUnitID = SupplierWiseItemDetails.PurchaseUnitID,
															@Supplier = Suppliers.Name--,
															-- @TenderBoardHeaderNo = tbph.TBPNumber,
															--@TenderBoardHeaderId = tbph.ID
											FROM SupplierWiseItemDetails
													INNER JOIN Suppliers ON SupplierWiseItemDetails.SupplierID = Suppliers.ID  AND Suppliers.IsActive = 1
--												 INNER JOIN dbo.TenderBoardPaperHeaders tbph ON SupplierWiseItemDetails.TBPHeaderID = tbph.ID
					                        
											WHERE SupplierWiseItemDetails.StockItemID = @StockItemID
													--AND Suppliers.PropertyID = @PropertyID
													AND SupplierWiseItemDetails.IsDefaultSupplier = 1
													AND SupplierWiseItemDetails.LocationId=@LocationID
													--AND tbph.BaseType = 1
													--AND tbph.Status= 2 
													--AND tbph.ExpireDate > getdate()
													AND SupplierWiseItemDetails.StockItemID = @StockItemID
													--AND (GETDATE() BETWEEN dbo.SupplierWiseItemDetails.ValidFrom AND dbo.SupplierWiseItemDetails.ValidTo)
					                        
											GROUP BY SupplierWiseItemDetails.CostPrice,
														SupplierWiseItemDetails.PurchaseUnitID,
														Suppliers.Name,
														SupplierWiseItemDetails.SupplierID--,
														--tbph.TBPNumber,
														--tbph.ID
											ORDER BY SupplierWiseItemDetails.CostPrice ASC;

											
										END

									ELSE
										BEGIN
										SET @SupplierID = NULL
										SET @Supplier = NULL
										SET @CostPrice = NULL
										SET @SupplierPurchaseUnitID = NULL
											SELECT TOP (1) @SupplierID = SupplierWiseItemDetails.SupplierID,
															@CostPrice = MIN(SupplierWiseItemDetails.CostPrice),
															@SupplierPurchaseUnitID = SupplierWiseItemDetails.PurchaseUnitID,
															@Supplier = Suppliers.Name
											FROM SupplierWiseItemDetails
													INNER JOIN Suppliers ON SupplierWiseItemDetails.SupplierID = Suppliers.ID  AND Suppliers.IsActive = 1
											WHERE SupplierWiseItemDetails.StockItemID = @StockItemID
												AND SupplierWiseItemDetails.LocationId=@LocationID --added 21/12/2018
												--AND Suppliers.PropertyID = @PropertyID
												AND  SupplierWiseItemDetails.StockItemID = @StockItemID
												--AND (GETDATE() BETWEEN dbo.SupplierWiseItemDetails.ValidFrom AND dbo.SupplierWiseItemDetails.ValidTo)
											GROUP BY SupplierWiseItemDetails.CostPrice,
														SupplierWiseItemDetails.PurchaseUnitID,
														Suppliers.Name,
														SupplierWiseItemDetails.SupplierID
											ORDER BY SupplierWiseItemDetails.CostPrice ASC;

										
										END
				--select  @SupplierID
									INSERT INTO @Temp
													(RequestHeaderID,
														LocationID,
														DocumentNo,
														RequestDate,
														DeliveryDate,
														HRemarks,
														DepartmentID,
														DepartmentName,
														StockItemID,
														ItemName,
														StockItemCode,
														UnitID,
														UnitName,
														ApprovedQuantity,
														ItemRemarks,
														RequestedQuantity,
														SupplierPurchaseUnitID,
														Supplier,
														CostPrice,
														SupplierID,
														LocationName,
														TenderBoardHeaderNo,
														TenderBoardHeaderId,
														Urgent,
														UrgentRemark,
														ApprovedDate,
														QtyInHand,
														ItemTaxAmount
														,IsContractedSupplier,
														IsPartialPR --Added by Nivesh 2025-11-11
													)
											VALUES
													(@RequestHeaderID,
														@LocationID,
														@DocumentNo,
														@RequestDate,
														@DeliverytDate,
														@HRemarks,
														@DepartmentID,
														@DepartmentName,
														@StockItemID,
														@ItemName,
														@StockItemCode,
														@UnitID,
														@UnitName,
														@ApprovedQuantity,
														@ItemRemarks,
														@RequestedQuantity,
														@SupplierPurchaseUnitID,
														@Supplier,
														isnull(@CostPrice, 0),
														@SupplierID,
														@LocationName,
														@TenderBoardHeaderNo,
														@TenderBoardHeaderId,
														@Urgent,
														ISNULL(@UrgentRemark,''),
														dbo.GetRequestApproveDate(@RequestHeaderID),
													dbo.FN_GetStockInHand(@PropertyID,@LocationID,@StockItemID),
													dbo.FN_GetItemWiseTax(@StockItemID, isnull(@CostPrice*@ApprovedQuantity, 0),@SupplierID,@LocationID,0,0)
													,0,
													@IsPartialPR --Added by Nivesh 2025-11-11
													);

									DELETE FROM #t
									WHERE StockItemID = @StockItemID
											AND LocationID = @LocationID
											AND DepartmentID = @DepartmentID;

									SELECT @RequestHeaderID = Id,
											@LocationID = LocationID,
											@DocumentNo = DocumentNo,
											@RequestDate = RequestDate,
											@DeliverytDate = DeliveryDate,
											@HRemarks = Remarks,
											@DepartmentID = DepartmentID,
											@DepartmentName = Name,
											@StockItemID = StockItemID,
											@ItemName = ItemName,
											@StockItemCode = StockItemCode,
											@UnitID = UnitID,
											@UnitName = UnitName,
											@ApprovedQuantity = ApprovedQuantity,
											@ItemRemarks = Remarks,
											@RequestedQuantity = RequestedQuantity,
											@LocationName = LocationName
									FROM #t;
								END
								
							TRUNCATE TABLE #t;
							DELETE FROM #Table
							WHERE RequestHederid = @TransactionHeaderID;
							SELECT @TransactionHeaderID = RequestHederid,
									@rCount = rCount
							FROM #table;
						END

					DROP TABLE #Table;
					UPDATE @Temp SET SupplierID = '' WHERE SupplierID IS NULL

					SELECT 
					T.UniqueId,
					T.RequestHeaderID,
					T.LocationID,
					T.DocumentNo,
					T.RequestDate,
					T.DeliveryDate,
					T.HRemarks,
					T.DepartmentID,
					T.DepartmentName,
					T.StockItemID,
					T.ItemName,
					T.StockItemCode,
					T.UnitID,
					T.UnitName,
					T.ApprovedQuantity,
					T.ItemRemarks,
					T.RequestedQuantity,
					T.SupplierPurchaseUnitID,
					T.Supplier,
					T.CostPrice,
					T.SupplierID,
					T.LocationName,
					T.TenderBoardHeaderNo,
					T.TenderBoardHeaderId,
					T.Urgent,
					ISNULL(T.UrgentRemark,'') AS UrgentRemark,
					T.ApprovedDate,
					T.QtyInHand,
					T.ItemTaxAmount,
					T.IsContractedSupplier,
					T.ApprovedQuantity AS CheckQty
					,T.CostPrice AS CheckPrice ,
					SA.IsActive IsQuotationApply
					,CASE WHEN SA.IsActive = 1 THEN 'Available' ELSE '' END AS ProcurementNO,
					IsPartialPR --Added by Nivesh 2025-11-11
					FROM @Temp T
					LEFT JOIN StockItemWiseAttributes SA ON SA.StockItemHeaderID = T.StockItemID AND SA.StockItemAttributeID = @IsQuotationAttributeId
					where SupplierID = CASE WHEN @searchSupplieId = -999 THEN SupplierID ELSE @searchSupplieId END 
					ORDER BY RequestHeaderID DESC,RequestDate DESC

			END

			IF(@SortOPtionID =2) --Last GRN Supplier
			BEGIN
			SELECT @ApprovelCount = COUNT(b.id)
					FROM TransactionWiseApprovalTypes AS a
							INNER JOIN TransactionTypes AS b ON a.TransactionID = b.Id
					WHERE(b.Code = 'RP')
							AND PropertyID = @PropertyID
							AND b.LocationID = CASE WHEN @SelectedLocationID = -999 THEN b.LocationID ELSE  @SelectedLocationID END;
							-- add location

					INSERT INTO #table
					SELECT b.id RequestHederid,
							COUNT(*) AS rCount
					--INTO #table
					FROM RequestHeaders AS b 
					WHERE(b.RequestType = 'RP')
							AND (b.DocumentStatus = 'P')
							AND b.IsApproved = 1
							AND b.PropertyID = @PropertyID
							AND b.LocationID = CASE WHEN @SelectedLocationID = -999 THEN b.LocationID ELSE  @SelectedLocationID END
							AND b.DepartmentID = CASE WHEN @SelectedDepartmentId = -999 THEN b.DepartmentID ELSE @SelectedDepartmentId END
							AND b.Id = CASE WHEN @SelectedDocId = -999 THEN b.Id ELSE @SelectedDocId END
						-- AND convert(date, a.ApprovalDate) = CASE WHEN @ApprovalDate IS NULL THEN convert(date, a.ApprovalDate) ELSE @ApprovalDate END
					GROUP BY b.id
       
 
					SELECT @TransactionHeaderID = requesthederid,
							@rCount = rCount
					FROM #table;
	
	
					WHILE @@rowcount > 0
						BEGIN

										INSERT INTO #t (Id,	LocationID,	RequestType,	DocumentNo,	RequestDate,	DeliveryDate,	
							DocumentStatus,	Remarks,	DepartmentID,	Name,	StockItemID,	ItemName,	
							StockItemCode,	UnitID,	UnitName,	ApprovedQuantity,	DetailRemarks,	RequestedQuantity,	
							LocationName,	Urgent,UrgentRemark,IsPartialPR)
							SELECT a.Id,
									a.LocationID,
									a.RequestType,
									a.DocumentNo,
									a.RequestDate,
									a.DeliveryDate,
									a.DocumentStatus,
									b.Remarks,
									a.DepartmentID,
									d.Name,
									b.StockItemID,
									s.Name AS ItemName,
									s.StockItemCode,
									b.UnitID,
									u.Name AS UnitName,
									(b.ApprovedQuantity - b.IssuedQuantity) AS ApprovedQuantity,
									b.Remarks AS DetailRemarks,
									b.ApprovedQuantity RequestedQuantity,
									Locations.Name AS LocationName,
									a.Urgent,
									ISNULL(a.UrgentRemark,'') AS UrgentRemark
									,CASE 
									WHEN EXISTS (SELECT 1 FROM [dbo].[PoWisePRs] where RequestHeaderID = a.Id) 
									THEN 1 
									ELSE 0 
									END AS IsPartialPR --Added by Nivesh 2025-11-11
								  
							--INTO [#t]
							FROM RequestHeaders AS a
									INNER JOIN RequestDetails AS b ON a.Id = b.RequestHeaderID
									INNER JOIN StockItemHeaders AS s ON b.StockItemID = s.Id
									INNER JOIN Units AS u ON b.UnitID = u.Id
									INNER JOIN Departments AS d ON a.DepartmentID = d.Id
																AND a.RequestType = 'RP'
																AND a.DocumentStatus = 'P'
																AND a.IsApproved = 1
									INNER JOIN Locations ON a.LocationID = Locations.Id

									left outer JOIN TenderBoardPaperItemDetails as TD on b.stockitemId=TD.StockitemheaderID
									left outer JOIN TenderBoardPaperHeaders as TH on TD.TBPHeaderId = TH.Id 
									and TH.status=2 and  TH.BaseType = 1 AND TH.ExpireDate > getdate() and TH.Id= TD.TBPHeaderId

									WHERE a.PropertyID = @PropertyID 
									AND a.Id = @TransactionHeaderID 
									AND (b.ApprovedQuantity - b.IssuedQuantity) > 0
									AND s.CategoryID = CASE WHEN @SelectedCategoryId = -999 THEN s.CategoryID ELSE @SelectedCategoryId END --added (b.ApprovedQuantity - b.IssuedQuantity) > 0 -- and a.LocationID = @SelectedLocationID 
									AND b.StockItemID = CASE WHEN @SelectedItemId = -999 THEN b.StockItemID ELSE @SelectedItemId END
					

							SELECT @RequestHeaderID = Id,
									@LocationID = LocationID,
									@DocumentNo = DocumentNo,
									@RequestDate = RequestDate,
									@DeliverytDate = DeliveryDate,
									@HRemarks = Remarks,
									@DepartmentID = DepartmentID,
									@DepartmentName = Name,
									@StockItemID = StockItemID,
									@ItemName = ItemName,
									@StockItemCode = StockItemCode,
									@UnitID = UnitID,
									@UnitName = UnitName,
									@ApprovedQuantity = ApprovedQuantity,
									@ItemRemarks = Remarks,
									@RequestedQuantity = RequestedQuantity,
									@LocationName = LocationName,
									@Urgent = Urgent,
									@UrgentRemark = ISNULL(UrgentRemark,''),
									@IsPartialPR = IsPartialPR --Added by Nivesh 2025-11-11
								   
							FROM #t;

							
							WHILE @@Rowcount > 0
								BEGIN
								SELECT @SupplierID = [dbo].[FN_GetLastGRNSupplier_ID](@LocationID,@StockItemID,CONVERT(DATE,GETDATE()))

							
									IF(@SupplierID >0)

										BEGIN
					                    
											SELECT TOP (1) @CostPrice = MIN(SupplierWiseItemDetails.CostPrice),
															@SupplierID = @SupplierID,
															@SupplierPurchaseUnitID = SupplierWiseItemDetails.PurchaseUnitID,
															@Supplier = Suppliers.Name--,
															-- @TenderBoardHeaderNo = tbph.TBPNumber,
															--@TenderBoardHeaderId = tbph.ID
											FROM SupplierWiseItemDetails
													INNER JOIN Suppliers ON SupplierWiseItemDetails.SupplierID = Suppliers.ID  AND Suppliers.IsActive = 1
													WHERE Suppliers.ID  = @SupplierID
													AND SupplierWiseItemDetails.StockItemID = @StockItemID
													AND SupplierWiseItemDetails.LocationId =@LocationID

											GROUP BY SupplierWiseItemDetails.CostPrice,
														SupplierWiseItemDetails.PurchaseUnitID,
														Suppliers.Name,
														SupplierWiseItemDetails.SupplierID--,
														ORDER BY SupplierWiseItemDetails.CostPrice ASC;
																	
										--SELECT	@CostPrice CostPrice,@SupplierID SupplierID,@SupplierPurchaseUnitID SupplierPurchaseUnitID,@Supplier Supplier
										END

									ELSE
										BEGIN
										SET @SupplierID = NULL
										SET @Supplier = NULL
										SET @CostPrice = NULL
										SET @SupplierPurchaseUnitID = NULL
											SELECT TOP (1) @SupplierID = SupplierWiseItemDetails.SupplierID,
															@CostPrice = MIN(SupplierWiseItemDetails.CostPrice),
															@SupplierPurchaseUnitID = SupplierWiseItemDetails.PurchaseUnitID,
															@Supplier = Suppliers.Name
											FROM SupplierWiseItemDetails
													INNER JOIN Suppliers ON SupplierWiseItemDetails.SupplierID = Suppliers.ID  AND Suppliers.IsActive = 1
											WHERE SupplierWiseItemDetails.StockItemID = @StockItemID
												AND SupplierWiseItemDetails.LocationId=@LocationID --added 21/12/2018
												--AND Suppliers.PropertyID = @PropertyID
												AND  SupplierWiseItemDetails.StockItemID = @StockItemID
												--AND (GETDATE() BETWEEN dbo.SupplierWiseItemDetails.ValidFrom AND dbo.SupplierWiseItemDetails.ValidTo)
											GROUP BY SupplierWiseItemDetails.CostPrice,
														SupplierWiseItemDetails.PurchaseUnitID,
														Suppliers.Name,
														SupplierWiseItemDetails.SupplierID
											ORDER BY SupplierWiseItemDetails.CostPrice ASC;

										
										END
				--select  @SupplierID
									INSERT INTO @Temp
													(RequestHeaderID,
														LocationID,
														DocumentNo,
														RequestDate,
														DeliveryDate,
														HRemarks,
														DepartmentID,
														DepartmentName,
														StockItemID,
														ItemName,
														StockItemCode,
														UnitID,
														UnitName,
														ApprovedQuantity,
														ItemRemarks,
														RequestedQuantity,
														SupplierPurchaseUnitID,
														Supplier,
														CostPrice,
														SupplierID,
														LocationName,
														TenderBoardHeaderNo,
														TenderBoardHeaderId,
														Urgent,
														UrgentRemark,
														ApprovedDate,
														QtyInHand,
														ItemTaxAmount
														,IsContractedSupplier
														,IsPartialPR --Added by Nivesh 2025-11-11
													)
											VALUES
													(@RequestHeaderID,
														@LocationID,
														@DocumentNo,
														@RequestDate,
														@DeliverytDate,
														@HRemarks,
														@DepartmentID,
														@DepartmentName,
														@StockItemID,
														@ItemName,
														@StockItemCode,
														@UnitID,
														@UnitName,
														@ApprovedQuantity,
														@ItemRemarks,
														@RequestedQuantity,
														@SupplierPurchaseUnitID,
														@Supplier,
														isnull(@CostPrice, 0),
														@SupplierID,
														@LocationName,
														@TenderBoardHeaderNo,
														@TenderBoardHeaderId,
														@Urgent,
														ISNULL(@UrgentRemark,''),
														dbo.GetRequestApproveDate(@RequestHeaderID),
													dbo.FN_GetStockInHand(@PropertyID,@LocationID,@StockItemID),
													dbo.FN_GetItemWiseTax(@StockItemID, isnull(@CostPrice*@ApprovedQuantity, 0),@SupplierID,@LocationID,0,0)
													,0
													,@IsPartialPR --Added by Nivesh 2025-11-11
													);

									DELETE FROM #t
									WHERE StockItemID = @StockItemID
											AND LocationID = @LocationID
											AND DepartmentID = @DepartmentID;

									SELECT @RequestHeaderID = Id,
											@LocationID = LocationID,
											@DocumentNo = DocumentNo,
											@RequestDate = RequestDate,
											@DeliverytDate = DeliveryDate,
											@HRemarks = Remarks,
											@DepartmentID = DepartmentID,
											@DepartmentName = Name,
											@StockItemID = StockItemID,
											@ItemName = ItemName,
											@StockItemCode = StockItemCode,
											@UnitID = UnitID,
											@UnitName = UnitName,
											@ApprovedQuantity = ApprovedQuantity,
											@ItemRemarks = Remarks,
											@RequestedQuantity = RequestedQuantity,
											@LocationName = LocationName
									FROM #t;
								END
								
							TRUNCATE TABLE #t;
							DELETE FROM #Table
							WHERE RequestHederid = @TransactionHeaderID;
							SELECT @TransactionHeaderID = RequestHederid,
									@rCount = rCount
							FROM #table;
						END

					DROP TABLE #Table;
					UPDATE @Temp SET SupplierID = '' WHERE SupplierID IS NULL

					--SELECT *,ApprovedQuantity AS CheckQty,CostPrice AS CheckPrice 
					--FROM @Temp where SupplierID = CASE WHEN @searchSupplieId = -999 THEN SupplierID ELSE @searchSupplieId END ;
					
					SELECT 
					T.UniqueId,
					T.RequestHeaderID,
					T.LocationID,
					T.DocumentNo,
					T.RequestDate,
					T.DeliveryDate,
					T.HRemarks,
					T.DepartmentID,
					T.DepartmentName,
					T.StockItemID,
					T.ItemName,
					T.StockItemCode,
					T.UnitID,
					T.UnitName,
					T.ApprovedQuantity,
					T.ItemRemarks,
					T.RequestedQuantity,
					T.SupplierPurchaseUnitID,
					T.Supplier,
					T.CostPrice,
					T.SupplierID,
					T.LocationName,
					T.TenderBoardHeaderNo,
					T.TenderBoardHeaderId,
					T.Urgent,
					ISNULL(T.UrgentRemark,'') AS UrgentRemark,
					T.ApprovedDate,
					T.QtyInHand,
					T.ItemTaxAmount,
					T.IsContractedSupplier,
					T.ApprovedQuantity AS CheckQty
					,T.CostPrice AS CheckPrice ,
					SA.IsActive IsQuotationApply
					,CASE WHEN SA.IsActive = 1 THEN 'Available' ELSE '' END AS ProcurementNO
					,IsPartialPR --Added by Nivesh 2025-11-11
					FROM @Temp T
					LEFT JOIN StockItemWiseAttributes SA ON SA.StockItemHeaderID = T.StockItemID AND SA.StockItemAttributeID = @IsQuotationAttributeId
					where SupplierID = CASE WHEN @searchSupplieId = -999 THEN SupplierID ELSE @searchSupplieId END 
					ORDER BY RequestHeaderID DESC,RequestDate DESC
			END

			IF(@SortOPtionID =3) -- Lowest price
			BEGIN
			SELECT @ApprovelCount = COUNT(b.id)
					FROM TransactionWiseApprovalTypes AS a
							INNER JOIN TransactionTypes AS b ON a.TransactionID = b.Id
					WHERE(b.Code = 'RP')
							AND PropertyID = @PropertyID
							AND b.LocationID = CASE WHEN @SelectedLocationID = -999 THEN b.LocationID ELSE  @SelectedLocationID END;
							-- add location

					INSERT INTO #table
					SELECT b.id RequestHederid,
							COUNT(*) AS rCount
					--INTO #table
					FROM RequestHeaders AS b 
					WHERE(b.RequestType = 'RP')
							AND (b.DocumentStatus = 'P')
							AND b.IsApproved = 1
							AND b.PropertyID = @PropertyID
							AND b.LocationID = CASE WHEN @SelectedLocationID = -999 THEN b.LocationID ELSE  @SelectedLocationID END
							AND b.DepartmentID = CASE WHEN @SelectedDepartmentId = -999 THEN b.DepartmentID ELSE @SelectedDepartmentId END
							AND b.Id = CASE WHEN @SelectedDocId = -999 THEN b.Id ELSE @SelectedDocId END
						-- AND convert(date, a.ApprovalDate) = CASE WHEN @ApprovalDate IS NULL THEN convert(date, a.ApprovalDate) ELSE @ApprovalDate END
					GROUP BY b.id
       
 
					SELECT @TransactionHeaderID = requesthederid,
							@rCount = rCount
					FROM #table;
	
	
					WHILE @@rowcount > 0
						BEGIN

							INSERT INTO #t (Id,	LocationID,	RequestType,	DocumentNo,	RequestDate,	DeliveryDate,	
							DocumentStatus,	Remarks,	DepartmentID,	Name,	StockItemID,	ItemName,	
							StockItemCode,	UnitID,	UnitName,	ApprovedQuantity,	DetailRemarks,	RequestedQuantity,	
							LocationName,	Urgent,UrgentRemark,IsPartialPR)
							SELECT a.Id,
									a.LocationID,
									a.RequestType,
									a.DocumentNo,
									a.RequestDate,
									a.DeliveryDate,
									a.DocumentStatus,
									b.Remarks,
									a.DepartmentID,
									d.Name,
									b.StockItemID,
									s.Name AS ItemName,
									s.StockItemCode,
									b.UnitID,
									u.Name AS UnitName,
									(b.ApprovedQuantity - b.IssuedQuantity) AS ApprovedQuantity,
									b.Remarks AS DetailRemarks,
									b.ApprovedQuantity RequestedQuantity,
									Locations.Name AS LocationName,
									a.Urgent,
									ISNULL(a.UrgentRemark,'') AS UrgentRemark
									,CASE 
									WHEN EXISTS (SELECT 1 FROM [dbo].[PoWisePRs] where RequestHeaderID = a.Id) 
									THEN 1 
									ELSE 0 
									END AS IsPartialPR --Added by Nivesh 2025-11-11
							--INTO [#t]
							FROM RequestHeaders AS a
									INNER JOIN RequestDetails AS b ON a.Id = b.RequestHeaderID
									INNER JOIN StockItemHeaders AS s ON b.StockItemID = s.Id
									INNER JOIN Units AS u ON b.UnitID = u.Id
									INNER JOIN Departments AS d ON a.DepartmentID = d.Id
																AND a.RequestType = 'RP'
																AND a.DocumentStatus = 'P'
																AND a.IsApproved = 1
									INNER JOIN Locations ON a.LocationID = Locations.Id

									left outer JOIN TenderBoardPaperItemDetails as TD on b.stockitemId=TD.StockitemheaderID
									left outer JOIN TenderBoardPaperHeaders as TH on TD.TBPHeaderId = TH.Id 
									and TH.status=2 and  TH.BaseType = 1 AND TH.ExpireDate > getdate() and TH.Id= TD.TBPHeaderId

									WHERE a.PropertyID = @PropertyID 
									AND a.Id = @TransactionHeaderID 
									AND (b.ApprovedQuantity - b.IssuedQuantity) > 0
									AND s.CategoryID = CASE WHEN @SelectedCategoryId = -999 THEN s.CategoryID ELSE @SelectedCategoryId END --added (b.ApprovedQuantity - b.IssuedQuantity) > 0 -- and a.LocationID = @SelectedLocationID 
									AND b.StockItemID = CASE WHEN @SelectedItemId = -999 THEN b.StockItemID ELSE @SelectedItemId END
					

							SELECT @RequestHeaderID = Id,
									@LocationID = LocationID,
									@DocumentNo = DocumentNo,
									@RequestDate = RequestDate,
									@DeliverytDate = DeliveryDate,
									@HRemarks = Remarks,
									@DepartmentID = DepartmentID,
									@DepartmentName = Name,
									@StockItemID = StockItemID,
									@ItemName = ItemName,
									@StockItemCode = StockItemCode,
									@UnitID = UnitID,
									@UnitName = UnitName,
									@ApprovedQuantity = ApprovedQuantity,
									@ItemRemarks = Remarks,
									@RequestedQuantity = RequestedQuantity,
									@LocationName = LocationName,
									@Urgent = Urgent,
									@UrgentRemark = ISNULL(UrgentRemark,''),
									@IsPartialPR = IsPartialPR --Added by Nivesh 2025-11-11
								   
							FROM #t;

							
							WHILE @@Rowcount > 0
								BEGIN
								
							
										SET @SupplierID = NULL
										SET @Supplier = NULL
										SET @CostPrice = NULL
										SET @SupplierPurchaseUnitID = NULL

											SELECT TOP (1) @SupplierID = SupplierWiseItemDetails.SupplierID,
															@CostPrice = MIN(SupplierWiseItemDetails.CostPrice),
															@SupplierPurchaseUnitID = SupplierWiseItemDetails.PurchaseUnitID,
															@Supplier = Suppliers.Name
											FROM SupplierWiseItemDetails
													INNER JOIN Suppliers ON SupplierWiseItemDetails.SupplierID = Suppliers.ID  AND Suppliers.IsActive = 1
											WHERE SupplierWiseItemDetails.StockItemID = @StockItemID
												AND SupplierWiseItemDetails.LocationId=@LocationID --added 21/12/2018
												AND  SupplierWiseItemDetails.StockItemID = @StockItemID
												GROUP BY SupplierWiseItemDetails.CostPrice,
														SupplierWiseItemDetails.PurchaseUnitID,
														Suppliers.Name,
														SupplierWiseItemDetails.SupplierID
											ORDER BY SupplierWiseItemDetails.CostPrice ASC;

											

										
										
				--select  @SupplierID
									INSERT INTO @Temp
													(RequestHeaderID,
														LocationID,
														DocumentNo,
														RequestDate,
														DeliveryDate,
														HRemarks,
														DepartmentID,
														DepartmentName,
														StockItemID,
														ItemName,
														StockItemCode,
														UnitID,
														UnitName,
														ApprovedQuantity,
														ItemRemarks,
														RequestedQuantity,
														SupplierPurchaseUnitID,
														Supplier,
														CostPrice,
														SupplierID,
														LocationName,
														TenderBoardHeaderNo,
														TenderBoardHeaderId,
														Urgent,
														UrgentRemark,
														ApprovedDate,
														QtyInHand,
														ItemTaxAmount
														,IsContractedSupplier
														,IsPartialPR --Added by Nivesh 2025-11-11
													)
											VALUES
													(@RequestHeaderID,
														@LocationID,
														@DocumentNo,
														@RequestDate,
														@DeliverytDate,
														@HRemarks,
														@DepartmentID,
														@DepartmentName,
														@StockItemID,
														@ItemName,
														@StockItemCode,
														@UnitID,
														@UnitName,
														@ApprovedQuantity,
														@ItemRemarks,
														@RequestedQuantity,
														@SupplierPurchaseUnitID,
														@Supplier,
														isnull(@CostPrice, 0),
														@SupplierID,
														@LocationName,
														@TenderBoardHeaderNo,
														@TenderBoardHeaderId,
														@Urgent,
														ISNULL(@UrgentRemark,''),
														dbo.GetRequestApproveDate(@RequestHeaderID),
													dbo.FN_GetStockInHand(@PropertyID,@LocationID,@StockItemID),
													dbo.FN_GetItemWiseTax(@StockItemID, isnull(@CostPrice*@ApprovedQuantity, 0),@SupplierID,@LocationID,0,0)
													,0
													,@IsPartialPR --Added by Nivesh 2025-11-11
													);

									DELETE FROM #t
									WHERE StockItemID = @StockItemID
											AND LocationID = @LocationID
											AND DepartmentID = @DepartmentID;

									SELECT @RequestHeaderID = Id,
											@LocationID = LocationID,
											@DocumentNo = DocumentNo,
											@RequestDate = RequestDate,
											@DeliverytDate = DeliveryDate,
											@HRemarks = Remarks,
											@DepartmentID = DepartmentID,
											@DepartmentName = Name,
											@StockItemID = StockItemID,
											@ItemName = ItemName,
											@StockItemCode = StockItemCode,
											@UnitID = UnitID,
											@UnitName = UnitName,
											@ApprovedQuantity = ApprovedQuantity,
											@ItemRemarks = Remarks,
											@RequestedQuantity = RequestedQuantity,
											@LocationName = LocationName
									FROM #t;
								END
								
							TRUNCATE TABLE #t;
							DELETE FROM #Table
							WHERE RequestHederid = @TransactionHeaderID;
							SELECT @TransactionHeaderID = RequestHederid,
									@rCount = rCount
							FROM #table;
						END

					DROP TABLE #Table;
					UPDATE @Temp SET SupplierID = '' WHERE SupplierID IS NULL
					--SELECT *,ApprovedQuantity AS CheckQty,CostPrice AS CheckPrice 
					--FROM @Temp where SupplierID = CASE WHEN @searchSupplieId = -999 THEN SupplierID ELSE @searchSupplieId END ;
					
					SELECT 
					T.UniqueId,
					T.RequestHeaderID,
					T.LocationID,
					T.DocumentNo,
					T.RequestDate,
					T.DeliveryDate,
					T.HRemarks,
					T.DepartmentID,
					T.DepartmentName,
					T.StockItemID,
					T.ItemName,
					T.StockItemCode,
					T.UnitID,
					T.UnitName,
					T.ApprovedQuantity,
					T.ItemRemarks,
					T.RequestedQuantity,
					T.SupplierPurchaseUnitID,
					T.Supplier,
					T.CostPrice,
					T.SupplierID,
					T.LocationName,
					T.TenderBoardHeaderNo,
					T.TenderBoardHeaderId,
					T.Urgent,
					ISNULL(T.UrgentRemark,'') AS UrgentRemark,
					T.ApprovedDate,
					T.QtyInHand,
					T.ItemTaxAmount,
					T.IsContractedSupplier,
					T.ApprovedQuantity AS CheckQty
					,T.CostPrice AS CheckPrice ,
					SA.IsActive IsQuotationApply
					,CASE WHEN SA.IsActive = 1 THEN 'Available' ELSE '' END AS ProcurementNO
					,T.IsPartialPR --Added by Nivesh 2025-11-11
					FROM @Temp T
					LEFT JOIN StockItemWiseAttributes SA ON SA.StockItemHeaderID = T.StockItemID AND SA.StockItemAttributeID = @IsQuotationAttributeId
					where SupplierID = CASE WHEN @searchSupplieId = -999 THEN SupplierID ELSE @searchSupplieId END 
					ORDER BY RequestHeaderID DESC,RequestDate DESC
					
			END

		END
		ELSE
		BEGIN
			IF(@IsContractSupplier =1)
			BEGIN
			
			SELECT @ApprovelCount = COUNT(b.id)
			FROM TransactionWiseApprovalTypes AS a
				 INNER JOIN TransactionTypes AS b ON a.TransactionID = b.Id
			WHERE(b.Code = 'RP')
				 AND PropertyID = @PropertyID
				 AND b.LocationID = CASE WHEN @SelectedLocationID = -999 THEN b.LocationID ELSE  @SelectedLocationID END;
				 -- add location

			INSERT INTO #table
			SELECT b.id RequestHederid,
				   COUNT(*) AS rCount
		   -- INTO #table
			FROM RequestHeaders AS b 
			WHERE(b.RequestType = 'RP')
				 AND (b.DocumentStatus = 'P')
				 AND b.IsApproved = 1
				 AND b.PropertyID = @PropertyID
				 AND b.LocationID = CASE WHEN @SelectedLocationID = -999 THEN b.LocationID ELSE  @SelectedLocationID END
				 AND b.DepartmentID = CASE WHEN @SelectedDepartmentId = -999 THEN b.DepartmentID ELSE @SelectedDepartmentId END
				 AND b.Id = CASE WHEN @SelectedDocId = -999 THEN b.Id ELSE @SelectedDocId END
				-- AND convert(date, a.ApprovalDate) = CASE WHEN @ApprovalDate IS NULL THEN convert(date, a.ApprovalDate) ELSE @ApprovalDate END
			GROUP BY b.id
       
 
			SELECT @TransactionHeaderID = requesthederid,
				   @rCount = rCount
			FROM #table;
	
	
			WHILE @@rowcount > 0
				BEGIN

					INSERT INTO #t (Id,	LocationID,	RequestType,	DocumentNo,	RequestDate,	DeliveryDate,	
					DocumentStatus,	Remarks,	DepartmentID,	Name,	StockItemID,	ItemName,	
					StockItemCode,	UnitID,	UnitName,	ApprovedQuantity,	DetailRemarks,	RequestedQuantity,	
					LocationName,	Urgent,UrgentRemark)
					SELECT a.Id,
						   a.LocationID,
						   a.RequestType,
						   a.DocumentNo,
						   a.RequestDate,
						   a.DeliveryDate,
						   a.DocumentStatus,
						   b.Remarks,
						   a.DepartmentID,
						   d.Name,
						   b.StockItemID,
						   s.Name AS ItemName,
						   s.StockItemCode,
						   b.UnitID,
						   u.Name AS UnitName,
						   (b.ApprovedQuantity - b.IssuedQuantity) AS ApprovedQuantity,
						   b.Remarks AS DetailRemarks,
						   b.ApprovedQuantity RequestedQuantity,
						   Locations.Name AS LocationName,
						   a.Urgent,
						   ISNULL(a.UrgentRemark,'') AS UrgentRemark
					  
				 --   INTO [#t]
					FROM RequestHeaders AS a
						 INNER JOIN RequestDetails AS b ON a.Id = b.RequestHeaderID
						 INNER JOIN StockItemHeaders AS s ON b.StockItemID = s.Id
						 INNER JOIN Units AS u ON b.UnitID = u.Id
						 INNER JOIN Departments AS d ON a.DepartmentID = d.Id
														AND a.RequestType = 'RP'
														AND a.DocumentStatus = 'P'
														AND a.IsApproved = 1
						 INNER JOIN Locations ON a.LocationID = Locations.Id

						 left outer JOIN TenderBoardPaperItemDetails as TD on b.stockitemId=TD.StockitemheaderID
						 left outer JOIN TenderBoardPaperHeaders as TH on TD.TBPHeaderId = TH.Id 
						 and TH.status=2 and  TH.BaseType = 1 AND TH.ExpireDate > getdate() and TH.Id= TD.TBPHeaderId

						 WHERE a.PropertyID = @PropertyID 
							AND a.Id = @TransactionHeaderID 
							AND (b.ApprovedQuantity - b.IssuedQuantity) > 0
							AND s.CategoryID = CASE WHEN @SelectedCategoryId = -999 THEN s.CategoryID ELSE @SelectedCategoryId END --added (b.ApprovedQuantity - b.IssuedQuantity) > 0 -- and a.LocationID = @SelectedLocationID 
							AND b.StockItemID = CASE WHEN @SelectedItemId = -999 THEN b.StockItemID ELSE @SelectedItemId END
		

					SELECT @RequestHeaderID = Id,
						   @LocationID = LocationID,
						   @DocumentNo = DocumentNo,
						   @RequestDate = RequestDate,
						   @DeliverytDate = DeliveryDate,
						   @HRemarks = Remarks,
						   @DepartmentID = DepartmentID,
						   @DepartmentName = Name,
						   @StockItemID = StockItemID,
						   @ItemName = ItemName,
						   @StockItemCode = StockItemCode,
						   @UnitID = UnitID,
						   @UnitName = UnitName,
						   @ApprovedQuantity = ApprovedQuantity,
						   @ItemRemarks = Remarks,
						   @RequestedQuantity = RequestedQuantity,
						   @LocationName = LocationName,
						   @Urgent = Urgent,
						   @UrgentRemark = ISNULL(UrgentRemark,'')

					   
					FROM #t;
				
					WHILE @@Rowcount > 0
						BEGIN
					
							IF(	(	SELECT COUNT(*)
									FROM SupplierWiseItemDetails
									WHERE ISNULL(IsContractedSupplier,0) = 1
									--AND CompanyId = @PropertyID
									AND StockItemID = @StockItemID
									AND LocationId = @LocationID -- Added by Isuru 2025-04-24 for loading correct location related suppliers
									AND CONVERT(DATE,GETDATE()) BETWEEN Validfrom AND ValidTo
								) > 0)

								BEGIN
                            
									SELECT TOP (1) @SupplierID = SupplierWiseItemDetails.SupplierID,
												   @CostPrice = MIN(SupplierWiseItemDetails.CostPrice),
												   @SupplierPurchaseUnitID = SupplierWiseItemDetails.PurchaseUnitID,
												   @IsContractedSupplier = ISNULL(IsContractedSupplier,0),
												   @Supplier = Suppliers.Name--,
												  -- @TenderBoardHeaderNo = tbph.TBPNumber,
												   --@TenderBoardHeaderId = tbph.ID
									FROM SupplierWiseItemDetails
										 INNER JOIN Suppliers ON SupplierWiseItemDetails.SupplierID = Suppliers.ID  AND Suppliers.IsActive = 1 
									WHERE SupplierWiseItemDetails.StockItemID = @StockItemID
                                     
										  AND SupplierWiseItemDetails.IsContractedSupplier = 1
										  AND SupplierWiseItemDetails.LocationId=@LocationID
									
										  AND SupplierWiseItemDetails.StockItemID = @StockItemID
										  AND (GETDATE() BETWEEN dbo.SupplierWiseItemDetails.ValidFrom AND dbo.SupplierWiseItemDetails.ValidTo)
                                
									GROUP BY SupplierWiseItemDetails.CostPrice,
											 SupplierWiseItemDetails.PurchaseUnitID,
											 Suppliers.Name,
											 SupplierWiseItemDetails.SupplierID,
											 SupplierWiseItemDetails.IsContractedSupplier
									ORDER BY SupplierWiseItemDetails.CostPrice ASC;

								
								END

							ELSE
								BEGIN
								SET @SupplierID = NULL
								SET @Supplier = NULL
								SET @CostPrice = NULL
								SET @IsContractedSupplier = 0
								SET @SupplierPurchaseUnitID = NULL
									SELECT TOP (1) @SupplierID = SupplierWiseItemDetails.SupplierID,
												   @CostPrice = MIN(SupplierWiseItemDetails.CostPrice),
												   @SupplierPurchaseUnitID = SupplierWiseItemDetails.PurchaseUnitID,
												   @Supplier = Suppliers.Name,
												   @IsContractedSupplier = ISNULL(IsContractedSupplier,0)
									FROM SupplierWiseItemDetails
										 INNER JOIN Suppliers ON SupplierWiseItemDetails.SupplierID = Suppliers.ID  AND Suppliers.IsActive = 1
									WHERE SupplierWiseItemDetails.StockItemID = @StockItemID
										AND SupplierWiseItemDetails.LocationId=@LocationID --added 21/12/2018
										--AND Suppliers.PropertyID = @PropertyID
										AND  SupplierWiseItemDetails.StockItemID = @StockItemID
										--AND (GETDATE() BETWEEN dbo.SupplierWiseItemDetails.ValidFrom AND dbo.SupplierWiseItemDetails.ValidTo)
									GROUP BY SupplierWiseItemDetails.CostPrice,
											 SupplierWiseItemDetails.PurchaseUnitID,
											 Suppliers.Name,
											 SupplierWiseItemDetails.SupplierID,
											 SupplierWiseItemDetails.IsContractedSupplier
									ORDER BY SupplierWiseItemDetails.CostPrice ASC;

							
								END
		--select  @SupplierID
							INSERT INTO @Temp
											(RequestHeaderID,
											 LocationID,
											 DocumentNo,
											 RequestDate,
											 DeliveryDate,
											 HRemarks,
											 DepartmentID,
											 DepartmentName,
											 StockItemID,
											 ItemName,
											 StockItemCode,
											 UnitID,
											 UnitName,
											 ApprovedQuantity,
											 ItemRemarks,
											 RequestedQuantity,
											 SupplierPurchaseUnitID,
											 Supplier,
											 CostPrice,
											 SupplierID,
											 LocationName,
											 TenderBoardHeaderNo,
											 TenderBoardHeaderId,
											 Urgent,
											 UrgentRemark,
											 ApprovedDate,
											 QtyInHand,
											 ItemTaxAmount,
											 IsContractedSupplier
											)
									VALUES
											(@RequestHeaderID,
											 @LocationID,
											 @DocumentNo,
											 @RequestDate,
											 @DeliverytDate,
											 @HRemarks,
											 @DepartmentID,
											 @DepartmentName,
											 @StockItemID,
											 @ItemName,
											 @StockItemCode,
											 @UnitID,
											 @UnitName,
											 @ApprovedQuantity,
											 @ItemRemarks,
											 @RequestedQuantity,
											 @SupplierPurchaseUnitID,
											 @Supplier,
											 isnull(@CostPrice, 0),
											 @SupplierID,
											 @LocationName,
											 @TenderBoardHeaderNo,
											 @TenderBoardHeaderId,
											 @Urgent,
											 ISNULL(@UrgentRemark,''),
											 dbo.GetRequestApproveDate(@RequestHeaderID),
											dbo.FN_GetStockInHand(@PropertyID,@LocationID,@StockItemID),
											dbo.FN_GetItemWiseTax(@StockItemID, isnull(@CostPrice*@ApprovedQuantity, 0),@SupplierID,@LocationID,0,0)
											,@IsContractedSupplier
											);

							DELETE FROM #t
							WHERE StockItemID = @StockItemID
								  AND LocationID = @LocationID
								  AND DepartmentID = @DepartmentID;

							SELECT @RequestHeaderID = Id,
								   @LocationID = LocationID,
								   @DocumentNo = DocumentNo,
								   @RequestDate = RequestDate,
								   @DeliverytDate = DeliveryDate,
								   @HRemarks = Remarks,
								   @DepartmentID = DepartmentID,
								   @DepartmentName = Name,
								   @StockItemID = StockItemID,
								   @ItemName = ItemName,
								   @StockItemCode = StockItemCode,
								   @UnitID = UnitID,
								   @UnitName = UnitName,
								   @ApprovedQuantity = ApprovedQuantity,
								   @ItemRemarks = Remarks,
								   @RequestedQuantity = RequestedQuantity,
								   @LocationName = LocationName
							FROM #t;
						END

					TRUNCATE TABLE #t;
					DELETE FROM #Table
					WHERE RequestHederid = @TransactionHeaderID;
					SELECT @TransactionHeaderID = RequestHederid,
						   @rCount = rCount
					FROM #table;
				END

			DROP TABLE #Table;
			UPDATE @Temp SET SupplierID = '' WHERE SupplierID IS NULL
			SELECT *,ApprovedQuantity AS CheckQty,CostPrice AS CheckPrice FROM @Temp where SupplierID = CASE WHEN @searchSupplieId = -999 THEN SupplierID ELSE @searchSupplieId END 
			ORDER BY RequestHeaderID DESC,RequestDate DESC;
		

			END
			ELSE
			BEGIN

				SELECT @ApprovelCount = COUNT(b.id)
				FROM TransactionWiseApprovalTypes AS a
					 INNER JOIN TransactionTypes AS b ON a.TransactionID = b.Id
				WHERE(b.Code = 'RP')
					 AND PropertyID = @PropertyID
					 AND b.LocationID = CASE WHEN @SelectedLocationID = -999 THEN b.LocationID ELSE  @SelectedLocationID END;
					 -- add location

				INSERT INTO #table
				SELECT b.id RequestHederid,
					   COUNT(*) AS rCount
				--INTO #table
				FROM RequestHeaders AS b 
				WHERE(b.RequestType = 'RP')
					 AND (b.DocumentStatus = 'P')
					 AND b.IsApproved = 1
					 AND b.PropertyID = @PropertyID
					 AND b.LocationID = CASE WHEN @SelectedLocationID = -999 THEN b.LocationID ELSE  @SelectedLocationID END
					 AND b.DepartmentID = CASE WHEN @SelectedDepartmentId = -999 THEN b.DepartmentID ELSE @SelectedDepartmentId END
					 AND b.Id = CASE WHEN @SelectedDocId = -999 THEN b.Id ELSE @SelectedDocId END
					-- AND convert(date, a.ApprovalDate) = CASE WHEN @ApprovalDate IS NULL THEN convert(date, a.ApprovalDate) ELSE @ApprovalDate END
				GROUP BY b.id
       
 
				SELECT @TransactionHeaderID = requesthederid,
					   @rCount = rCount
				FROM #table;
	
	
				WHILE @@rowcount > 0
					BEGIN

							INSERT INTO #t (Id,	LocationID,	RequestType,	DocumentNo,	RequestDate,	DeliveryDate,	
							DocumentStatus,	Remarks,	DepartmentID,	Name,	StockItemID,	ItemName,	
							StockItemCode,	UnitID,	UnitName,	ApprovedQuantity,	DetailRemarks,	RequestedQuantity,	
							LocationName,	Urgent,UrgentRemark)
						SELECT a.Id,
							   a.LocationID,
							   a.RequestType,
							   a.DocumentNo,
							   a.RequestDate,
							   a.DeliveryDate,
							   a.DocumentStatus,
							   b.Remarks,
							   a.DepartmentID,
							   d.Name,
							   b.StockItemID,
							   s.Name AS ItemName,
							   s.StockItemCode,
							   b.UnitID,
							   u.Name AS UnitName,
							   (b.ApprovedQuantity - b.IssuedQuantity) AS ApprovedQuantity,
							   b.Remarks AS DetailRemarks,
							   b.ApprovedQuantity RequestedQuantity,
							   Locations.Name AS LocationName,
							   a.Urgent,
							   ISNULL(a.UrgentRemark,'') AS UrgentRemark
						  
						--INTO [#t]
						FROM RequestHeaders AS a
							 INNER JOIN RequestDetails AS b ON a.Id = b.RequestHeaderID
							 INNER JOIN StockItemHeaders AS s ON b.StockItemID = s.Id
							 INNER JOIN Units AS u ON b.UnitID = u.Id
							 INNER JOIN Departments AS d ON a.DepartmentID = d.Id
															AND a.RequestType = 'RP'
															AND a.DocumentStatus = 'P'
															AND a.IsApproved = 1
							 INNER JOIN Locations ON a.LocationID = Locations.Id

							 left outer JOIN TenderBoardPaperItemDetails as TD on b.stockitemId=TD.StockitemheaderID
							 left outer JOIN TenderBoardPaperHeaders as TH on TD.TBPHeaderId = TH.Id 
							 and TH.status=2 and  TH.BaseType = 1 AND TH.ExpireDate > getdate() and TH.Id= TD.TBPHeaderId

							 WHERE a.PropertyID = @PropertyID 
								AND a.Id = @TransactionHeaderID 
								AND (b.ApprovedQuantity - b.IssuedQuantity) > 0
								AND s.CategoryID = CASE WHEN @SelectedCategoryId = -999 THEN s.CategoryID ELSE @SelectedCategoryId END --added (b.ApprovedQuantity - b.IssuedQuantity) > 0 -- and a.LocationID = @SelectedLocationID 
								AND b.StockItemID = CASE WHEN @SelectedItemId = -999 THEN b.StockItemID ELSE @SelectedItemId END
			

						SELECT @RequestHeaderID = Id,
							   @LocationID = LocationID,
							   @DocumentNo = DocumentNo,
							   @RequestDate = RequestDate,
							   @DeliverytDate = DeliveryDate,
							   @HRemarks = Remarks,
							   @DepartmentID = DepartmentID,
							   @DepartmentName = Name,
							   @StockItemID = StockItemID,
							   @ItemName = ItemName,
							   @StockItemCode = StockItemCode,
							   @UnitID = UnitID,
							   @UnitName = UnitName,
							   @ApprovedQuantity = ApprovedQuantity,
							   @ItemRemarks = Remarks,
							   @RequestedQuantity = RequestedQuantity,
							   @LocationName = LocationName,
							   @Urgent = Urgent,
							   @UrgentRemark = ISNULL(UrgentRemark,'')

						   
						FROM #t;
					
						WHILE @@Rowcount > 0
							BEGIN
						
								IF(	(	SELECT COUNT(*)
										FROM SupplierWiseItemDetails
										WHERE IsDefaultSupplier = 1
										--AND CompanyId = @PropertyID
										AND StockItemID = @StockItemID
										AND LocationId = @LocationID -- Added by Isuru 2025-04-24 for loading correct location related suppliers
									) > 0)

									BEGIN
			                    
										SELECT TOP (1) @SupplierID = SupplierWiseItemDetails.SupplierID,
													   @CostPrice = MIN(SupplierWiseItemDetails.CostPrice),
													   @SupplierPurchaseUnitID = SupplierWiseItemDetails.PurchaseUnitID,
													   @Supplier = Suppliers.Name--,
													  -- @TenderBoardHeaderNo = tbph.TBPNumber,
													   --@TenderBoardHeaderId = tbph.ID
										FROM SupplierWiseItemDetails
											 INNER JOIN Suppliers ON SupplierWiseItemDetails.SupplierID = Suppliers.ID  AND Suppliers.IsActive = 1
	--										 INNER JOIN dbo.TenderBoardPaperHeaders tbph ON SupplierWiseItemDetails.TBPHeaderID = tbph.ID
			                        
										WHERE SupplierWiseItemDetails.StockItemID = @StockItemID
											  --AND Suppliers.PropertyID = @PropertyID
											  AND SupplierWiseItemDetails.IsDefaultSupplier = 1
											  AND SupplierWiseItemDetails.LocationId=@LocationID
											  --AND tbph.BaseType = 1
											  --AND tbph.Status= 2 
											  --AND tbph.ExpireDate > getdate()
											  AND SupplierWiseItemDetails.StockItemID = @StockItemID
											  --AND (GETDATE() BETWEEN dbo.SupplierWiseItemDetails.ValidFrom AND dbo.SupplierWiseItemDetails.ValidTo)
			                        
										GROUP BY SupplierWiseItemDetails.CostPrice,
												 SupplierWiseItemDetails.PurchaseUnitID,
												 Suppliers.Name,
												 SupplierWiseItemDetails.SupplierID--,
												 --tbph.TBPNumber,
												 --tbph.ID
										ORDER BY SupplierWiseItemDetails.CostPrice ASC;

									
									END

								ELSE
									BEGIN
									SET @SupplierID = NULL
									SET @Supplier = NULL
									SET @CostPrice = NULL
									SET @SupplierPurchaseUnitID = NULL
										SELECT TOP (1) @SupplierID = SupplierWiseItemDetails.SupplierID,
													   @CostPrice = MIN(SupplierWiseItemDetails.CostPrice),
													   @SupplierPurchaseUnitID = SupplierWiseItemDetails.PurchaseUnitID,
													   @Supplier = Suppliers.Name
										FROM SupplierWiseItemDetails
											 INNER JOIN Suppliers ON SupplierWiseItemDetails.SupplierID = Suppliers.ID  AND Suppliers.IsActive = 1
										WHERE SupplierWiseItemDetails.StockItemID = @StockItemID
											AND SupplierWiseItemDetails.LocationId=@LocationID --added 21/12/2018
											--AND Suppliers.PropertyID = @PropertyID
											AND  SupplierWiseItemDetails.StockItemID = @StockItemID
											--AND (GETDATE() BETWEEN dbo.SupplierWiseItemDetails.ValidFrom AND dbo.SupplierWiseItemDetails.ValidTo)
										GROUP BY SupplierWiseItemDetails.CostPrice,
												 SupplierWiseItemDetails.PurchaseUnitID,
												 Suppliers.Name,
												 SupplierWiseItemDetails.SupplierID
										ORDER BY SupplierWiseItemDetails.CostPrice ASC;

								
									END
			--select  @SupplierID
								INSERT INTO @Temp
												(RequestHeaderID,
												 LocationID,
												 DocumentNo,
												 RequestDate,
												 DeliveryDate,
												 HRemarks,
												 DepartmentID,
												 DepartmentName,
												 StockItemID,
												 ItemName,
												 StockItemCode,
												 UnitID,
												 UnitName,
												 ApprovedQuantity,
												 ItemRemarks,
												 RequestedQuantity,
												 SupplierPurchaseUnitID,
												 Supplier,
												 CostPrice,
												 SupplierID,
												 LocationName,
												 TenderBoardHeaderNo,
												 TenderBoardHeaderId,
												 Urgent,
												 UrgentRemark,
												 ApprovedDate,
												 QtyInHand,
												 ItemTaxAmount
												 ,IsContractedSupplier
												)
										VALUES
												(@RequestHeaderID,
												 @LocationID,
												 @DocumentNo,
												 @RequestDate,
												 @DeliverytDate,
												 @HRemarks,
												 @DepartmentID,
												 @DepartmentName,
												 @StockItemID,
												 @ItemName,
												 @StockItemCode,
												 @UnitID,
												 @UnitName,
												 @ApprovedQuantity,
												 @ItemRemarks,
												 @RequestedQuantity,
												 @SupplierPurchaseUnitID,
												 @Supplier,
												 isnull(@CostPrice, 0),
												 @SupplierID,
												 @LocationName,
												 @TenderBoardHeaderNo,
												 @TenderBoardHeaderId,
												 @Urgent,
												 ISNULL(@UrgentRemark,''),
												 dbo.GetRequestApproveDate(@RequestHeaderID),
												dbo.FN_GetStockInHand(@PropertyID,@LocationID,@StockItemID),
												dbo.FN_GetItemWiseTax(@StockItemID, isnull(@CostPrice*@ApprovedQuantity, 0),@SupplierID,@LocationID,0,0)
												,0
												);

								DELETE FROM #t
								WHERE StockItemID = @StockItemID
									  AND LocationID = @LocationID
									  AND DepartmentID = @DepartmentID;

								SELECT @RequestHeaderID = Id,
									   @LocationID = LocationID,
									   @DocumentNo = DocumentNo,
									   @RequestDate = RequestDate,
									   @DeliverytDate = DeliveryDate,
									   @HRemarks = Remarks,
									   @DepartmentID = DepartmentID,
									   @DepartmentName = Name,
									   @StockItemID = StockItemID,
									   @ItemName = ItemName,
									   @StockItemCode = StockItemCode,
									   @UnitID = UnitID,
									   @UnitName = UnitName,
									   @ApprovedQuantity = ApprovedQuantity,
									   @ItemRemarks = Remarks,
									   @RequestedQuantity = RequestedQuantity,
									   @LocationName = LocationName
								FROM #t;
							END

						TRUNCATE TABLE #t;
						
						DELETE FROM #Table
						WHERE RequestHederid = @TransactionHeaderID;
						SELECT @TransactionHeaderID = RequestHederid,
							   @rCount = rCount
						FROM #table;
					END

				DROP TABLE #Table;
				UPDATE @Temp SET SupplierID = '' WHERE SupplierID IS NULL
				SELECT *,ApprovedQuantity AS CheckQty,CostPrice AS CheckPrice FROM @Temp where SupplierID = CASE WHEN @searchSupplieId = -999 THEN SupplierID ELSE @searchSupplieId END ;
			END
		END
    END TRY
    BEGIN CATCH


        --INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
        --VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())
	IF @@TRANCOUNT>0
 
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
    END CATCH;

GO

