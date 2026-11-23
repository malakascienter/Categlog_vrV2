

--[dbo].[SP_POPreperation_1Venora] '<BOQWiseMrn><BOQId>2</BOQId><ProjectId>1</ProjectId><DepartmentId>1</DepartmentId><LocationId>1</LocationId><CompantId>1</CompantId><MRNList><MRNGridList><item_id>1</item_id><item_text>MR000686</item_text></MRNGridList><MRNGridList><item_id>2</item_id><item_text>MR000687</item_text></MRNGridList></MRNList></BOQWiseMrn>'
CREATE PROCEDURE [dbo].[SP_POPreperation_1Venora]
(@XMLData AS XML)
AS
DECLARE @ApprovelCount INT;
DECLARE @TransactionHeaderID INT;
DECLARE @rCount INT;
DECLARE @RequestHeaderID INT,
        @LocationID INT,
        @DocumentNo VARCHAR(50),
        @RequestDate DATETIME;
DECLARE @HRemarks VARCHAR(500),
        @DepartmentID INT,
        @DepartmentName VARCHAR(200),
        @StockItemID INT;
DECLARE @ItemName VARCHAR(200),
        @StockItemCode VARCHAR(50),
        @LocationName VARCHAR(200);
DECLARE @UnitID INT,
        @UnitName VARCHAR(200),
        @ApprovedQuantity MONEY;
DECLARE @ItemRemarks VARCHAR(200),
        @RequestedQuantity MONEY;
DECLARE @SupplierPurchaseUnitID INT,
        @Supplier VARCHAR(200),
        @CostPrice MONEY,
        @SupplierID INT;
DECLARE @Temp TABLE
(
    RequestHeaderID INT,
    LocationID INT,
    DocumentNo VARCHAR(50),
    RequestDate DATETIME,
    HRemarks VARCHAR(500),
    DepartmentID INT,
    DepartmentName VARCHAR(200),
    StockItemID INT,
    ItemName VARCHAR(200),
    StockItemCode VARCHAR(50),
    UnitID INT,
    UnitName VARCHAR(200),
    ApprovedQuantity MONEY,
    ItemRemarks VARCHAR(200),
    RequestedQuantity MONEY,
    SupplierPurchaseUnitID INT,
    Supplier VARCHAR(200),
    CostPrice MONEY,
    SupplierID INT,
    LocationName VARCHAR(200),
	IsForeign BIT
);
--SELECT * FROM ApprovalLogs
--SELECT * FROM RequestHeaders
DECLARE @iDocID INT;
DECLARE @PropertyID INT,
        @SelectedLocationID INT,
        @BOQId INT,
        @DepartmentId2 INT,
		@IsForeign BIT,
		@IsForeignCheck BIT,
        @ProjectId INT;

EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLData;

SELECT @PropertyID = CompantId,
       @SelectedLocationID = LocationId,
       @BOQId = BOQId,
       @DepartmentId2 = DepartmentId,
       @ProjectId = ProjectId,
	   @IsForeign= IsForeign
FROM
    OPENXML(@iDocID, 'BOQWiseMrn', 2)
    WITH
    (
        CompantId INT,
        LocationId INT,
        BOQId INT,
        DepartmentId INT,
        ProjectId INT,
		IsForeign BIT
    );



SELECT *
INTO #TempMrn
FROM
    OPENXML(@iDocID, 'BOQWiseMrn/MRNList/MRNGridList', 2)
    WITH
    (
        item_id INT,
        item_text VARCHAR(50)
    );

--select * from #TempMrn

BEGIN TRY
    SET @ApprovelCount = 0;
    SELECT @ApprovelCount = COUNT(a.TransactionApprovalID)
    FROM TransactionWiseApprovalTypes AS a
        INNER JOIN TransactionTypes AS b
            ON a.TransactionID = b.Id
    WHERE (b.Code = 'RP')
          AND PropertyID = @PropertyID
          AND a.LocationID = @SelectedLocationID; -- add location

    SELECT a.TransactionHeaderID,
           COUNT(*) AS rCount
    INTO #table
    FROM ApprovalLogs AS a
        INNER JOIN RequestHeaders AS b
            ON a.TransactionHeaderID = b.Id
    WHERE (b.RequestType = 'RP')
          AND (b.DocumentStatus = 'P')
          AND (a.IsComplete = 1)
          AND a.PropertyID = @PropertyID
          AND a.LocationID = @SelectedLocationID
    GROUP BY a.TransactionHeaderID
    HAVING (COUNT(*) >= @ApprovelCount);



    ---added for MRN 2019-02-27---------------------------------------------------------------------
    INSERT INTO #table
    SELECT R.Id,
           COUNT(*)
    FROM ApprovalLogs AS a
        INNER JOIN dbo.MRNRegistries AS b
            ON a.TransactionHeaderID = b.ID
        INNER JOIN dbo.RequestHeaders R
            ON b.RequestionID = R.Id
    WHERE (R.RequestType = 'RP')
          AND (R.DocumentStatus = 'P')
          AND (a.IsComplete = 1)
          AND a.PropertyID = @PropertyID
          AND a.LocationID = @SelectedLocationID
    GROUP BY a.TransactionHeaderID,
             R.Id
    HAVING (COUNT(*) >= @ApprovelCount);

    --------end here------------------------------------------------------------------------------
    SELECT @TransactionHeaderID = TransactionHeaderID,
           @rCount = rCount
    FROM #table;
    WHILE @@rowcount > 0
    BEGIN
        --SELECT * FROM StocKItemsHeaders 		
        SELECT a.Id,
               a.LocationID,
               a.RequestType,
               a.DocumentNo,
               a.RequestDate,
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
               Locations.Name AS LocationName
        INTO [#t]
        --SELECT * FROM Departments
        FROM RequestHeaders AS a
            INNER JOIN RequestDetails AS b
                ON a.Id = b.RequestHeaderID
            INNER JOIN
            (
                SELECT *
                FROM MRNRegistries AS MR
                    INNER JOIN #TempMrn AS TM
                        ON MR.ID = TM.item_id
            ) MRN
                ON a.Id = MRN.RequestionID
            INNER JOIN StockItemHeaders AS s
                ON b.StockItemID = s.Id
            INNER JOIN Units AS u
                ON b.UnitID = u.Id
            INNER JOIN Departments AS d
                ON a.DepartmentID = d.Id
                   AND a.RequestType = 'RP'
                   AND a.DocumentStatus = 'P'
                   AND a.IsApproved = 1
            INNER JOIN Locations
                ON a.LocationID = Locations.Id
        WHERE a.PropertyID = @PropertyID
              AND a.Id = @TransactionHeaderID
              AND (b.ApprovedQuantity - b.IssuedQuantity) > 0; --added (b.ApprovedQuantity - b.IssuedQuantity) > 0 -- and a.LocationID = @SelectedLocationID 


        SELECT @RequestHeaderID = Id,
               @LocationID = LocationID,
               @DocumentNo = DocumentNo,
               @RequestDate = RequestDate,
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
        WHILE @@Rowcount > 0
        BEGIN

            --SELECT * FROM Suppliers	
            IF (
               (
                   SELECT COUNT(*)
                   FROM SupplierWiseItemDetails
                   WHERE IsDefaultSupplier = 1
                         AND CompanyId = @PropertyID
                         AND StockItemID = @StockItemID
               ) > 0
               )
            BEGIN
			
                SELECT TOP (1)
                       @SupplierID = SupplierWiseItemDetails.SupplierID,
                       @CostPrice = MIN(SupplierWiseItemDetails.CostPrice),
                       @SupplierPurchaseUnitID = SupplierWiseItemDetails.PurchaseUnitID,
                       @Supplier = Concat(Suppliers.Name,'/','(',Curr.Symbol,')'),
					   @IsForeignCheck = ISNULL(Suppliers.IsForeign,0)
                FROM SupplierWiseItemDetails
                    INNER JOIN Suppliers LEFT JOIN CurrencyMasters As CURR ON Suppliers.CurrencyID= CURR.Id
                        ON SupplierWiseItemDetails.SupplierID = Suppliers.ID
                WHERE SupplierWiseItemDetails.StockItemID = @StockItemID
                      AND Suppliers.PropertyID = @PropertyID
                      AND SupplierWiseItemDetails.IsDefaultSupplier = 1
                      AND SupplierWiseItemDetails.LocationId = @SelectedLocationID ----added 21/12/2018
                GROUP BY SupplierWiseItemDetails.CostPrice,
                         SupplierWiseItemDetails.PurchaseUnitID,
                         Suppliers.Name,
                         SupplierWiseItemDetails.SupplierID,
						 Suppliers.IsForeign,Curr.Symbol
                ORDER BY SupplierWiseItemDetails.CostPrice ASC;
            END;
            ELSE
            BEGIN
                SELECT TOP (1)
                       @SupplierID = SupplierWiseItemDetails.SupplierID,
                       @CostPrice = MIN(SupplierWiseItemDetails.CostPrice),
                       @SupplierPurchaseUnitID = SupplierWiseItemDetails.PurchaseUnitID,
                       @Supplier = Suppliers.Name
                FROM SupplierWiseItemDetails
                    INNER JOIN Suppliers
                        ON SupplierWiseItemDetails.SupplierID = Suppliers.ID
                WHERE SupplierWiseItemDetails.StockItemID = @StockItemID
                      AND SupplierWiseItemDetails.LocationId = @SelectedLocationID --added 21/12/2018
                      AND Suppliers.PropertyID = @PropertyID
                GROUP BY SupplierWiseItemDetails.CostPrice,
                         SupplierWiseItemDetails.PurchaseUnitID,
                         Suppliers.Name,
                         SupplierWiseItemDetails.SupplierID
                ORDER BY SupplierWiseItemDetails.CostPrice ASC;
            END;
            INSERT INTO @Temp
            (
                RequestHeaderID,
                LocationID,
                DocumentNo,
                RequestDate,
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
				IsForeign
            )
            VALUES
            (@RequestHeaderID, @LocationID, @DocumentNo, @RequestDate, @HRemarks, @DepartmentID, @DepartmentName,
             @StockItemID, @ItemName, @StockItemCode, @UnitID, @UnitName, @ApprovedQuantity, @ItemRemarks,
             @RequestedQuantity, @SupplierPurchaseUnitID, @Supplier, ISNULL(@CostPrice, 0), @SupplierID, @LocationName,@IsForeignCheck);
            DELETE FROM #t
            WHERE StockItemID = @StockItemID
                  AND LocationID = @LocationID
                  AND DepartmentID = @DepartmentID;
            SELECT @RequestHeaderID = Id,
                   @LocationID = LocationID,
                   @DocumentNo = DocumentNo,
                   @RequestDate = RequestDate,
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
        END;
        DROP TABLE #t;
        DELETE FROM #table
        WHERE TransactionHeaderID = @TransactionHeaderID;
        SELECT @TransactionHeaderID = TransactionHeaderID,
               @rCount = rCount
        FROM #table;
    END;
    DROP TABLE #table;
    SELECT *
    FROM @Temp where IsForeign=@IsForeign;
END TRY
BEGIN CATCH

--INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
--VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())

END CATCH;

GO

