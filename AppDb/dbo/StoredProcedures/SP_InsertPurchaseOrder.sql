--=============================================
-- Last Modified by     : Ravish
-- Last Modified date   : 2026-01-01
-- Description          : Insert Purchase Order

-- [dbo].[SP_InsertPurchaseOrder] '', '', 0,'',0,-999,0

--=============================================
CREATE PROCEDURE [dbo].[SP_InsertPurchaseOrder]
(
    @XMLDetails XML,
    @docNo VARCHAR(MAX) OUTPUT,
    @headerid INT OUTPUT,
    @DocumentListJson NVARCHAR(MAX) = '' OUTPUT,
    @IsQuotation BIT = 0,
    @DepartmentID INT = -999,
    @IsInvoiceBased BIT = 0
)
AS
DECLARE @Doc VARCHAR(100);
DECLARE @MinValue INT, @UniqueDepartmentCount INT =0

DECLARE @UserData TABLE(
Id INT,
UserName NVARCHAR(200),
EmployeeId NVARCHAR(MAX)
)
SET @DocumentListJson = ''

DECLARE @tempInputID INT

INSERT INTO tempInput
(
    xmldata,
    IsQuotation,
    IsInvoiceBased
)
VALUES
(@XMLDetails,
@IsQuotation,
@IsInvoiceBased);

SET @tempInputID = SCOPE_IDENTITY();

--SELECT TOP (1) @tempInputID = ID FROM tempInput
--ORDER BY ID DESC -- Added by Nivesh 2024-03-06



DECLARE @iDocID INT;
 
  
BEGIN TRY
    BEGIN TRANSACTION;

    SET @Doc = '';

	 IF OBJECT_ID('tempdb..#netTotal') IS NOT NULL
      BEGIN
        DROP TABLE #xmldatatable
      END

    EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

    DECLARE @PropertyID INT, @CurrencyId INT,@SupplierId2 INT,@POType INT,
            @LocationID INT, @DocumentNo VARCHAR(MAX),@TransactionType CHAR(2),
            @PoHeaderID BIGINT,@RequestHeaderID BIGINT,@userId INT,
            @ipAddress VARCHAR(MAX),@GetLocationFromDetail bit,@IsCentralLogin BIT, @isModificationComplete bit,@IsContractedSupplier bit,
			@IsSupplierEvaluate BIT,
			@tempPONO VARCHAR(50), @tempPOHeaderID INT,@DeliveryAddressID VARCHAR(MAX)
            ,@IsQuatoationRequest BIT = 0,
            @IsDepartmentWisePOApproval BIT =0,
            @DirectPODepartmentID INT = -999,
            @IsDirectPo BIT =0
            ,@InvoiceID INT = 0;

    SET @TransactionType = 'PO';

    DECLARE  @DepartmentList TABLE(
        DepartmentID INT
    )


    DECLARE  @RequestHeaderIds TABLE(
    RequestHeaderID BIGINT
    )

     INSERT INTO @RequestHeaderIds(RequestHeaderID)
    SELECT DISTINCT
        RequestHeaderID
    FROM
    OPENXML(@iDocID, '/PoHeader/DetailList/PoDetail', 2)
    WITH
    (
        RequestHeaderID BIGINT
    )


    INSERT INTO @DepartmentList(DepartmentID)
    SELECT DISTINCT ISNULL(DepartmentID,0)
    FROM RequestHeaders
    WHERE ID IN (SELECT DISTINCT  RequestHeaderID
    FROM @RequestHeaderIds
    WHERE RequestHeaderID <> 0)
     AND RequestType = 'RP'

    --INSERT INTO @DepartmentList(DepartmentID)
    --SELECT DISTINCT
    --    DepartmentID
    --FROM
    --OPENXML(@iDocID, '/PoHeader/DetailList/PoDetail', 2)
    --WITH
    --(
    --    DepartmentID INT
    --)
    

    SELECT @PropertyID = PropertyID,
           @SupplierId2 = SupplierID,
           @LocationID = LocationID,
           @RequestHeaderID = RequestHeaderID,
           @userId = UserProfileID,
           @ipAddress = IPAddress,
		   @POType = POType,
		   @isModificationComplete = isModificationComplete,
		   @tempPONO = tempPONO,
		   @tempPOHeaderID = tempPOHeaderID,
		   @DeliveryAddressID = DeliveryAddressID,
           @IsDirectPo = IsDirectPo
           ,@InvoiceID = InvoiceID
    FROM
        OPENXML(@iDocID, '/PoHeader', 2)
        WITH
        (
            PropertyID INT,
            LocationID INT,
            SupplierID INT,
            RequestHeaderID BIGINT,
            UserProfileID INT,
            IPAddress VARCHAR(MAX),
			POType INT,
			isModificationComplete bit,
			tempPONO VARCHAR(50),
			tempPOHeaderID INT,
			DeliveryAddressID VARCHAR(MAX),
            IsDirectPo BIT,
            InvoiceID INT
        );


		IF @userId <>0
		BEGIN

		SELECT @IsCentralLogin = IsCentralLogin,
        @IsContractedSupplier = IsContractedSupplier ,
        @IsSupplierEvaluate = IsSupplierEvaluate
        ,@IsQuatoationRequest = IsQuatoationRequest,
        @IsDepartmentWisePOApproval = IsDepartmentWisePOApproval,
        @DirectPODepartmentID = DirectPODepartmentID
		FROM Companies 
        WHERE CompanyID = @PropertyID 

		IF(@IsCentralLogin = 1)
		BEGIN
			INSERT INTO @UserData
			SELECT Id, UserName, EmpNumber
			FROM [dbo].[CentralUsers]
			WHERE IsActive=1
		END
		ELSE
		BEGIN
			INSERT INTO @UserData
			SELECT Id, UserName,EmployeeId
			FROM UserMasters
		END

		-----------------------
		IF @locationID = -999
		BEGIN
			SET @GetLocationFromDetail=1
		END 



    DECLARE @supplierList AS TABLE
    (
        SupplierID INT,LocationID INT
        ,RequestHeaderID INT NULL --Added by Nivesh 2025-11-10
    );
    DECLARE @SupplierID AS INT;

    IF( @IsDirectPo = 1) --Added by Isuru 2026-06-09 to fix incorrect supplier details in xml
	BEGIN


		INSERT INTO @supplierList
		SELECT @SupplierId2, @LocationID,0 AS  RequestHeaderID
	END
    ELSE
    BEGIN
        INSERT INTO @supplierList
        SELECT SupplierID, LocationID, RequestHeaderID
        FROM
        OPENXML(@iDocID, '/PoHeader/DetailList/PoDetail', 2)
        WITH
        (
            SupplierID INT,LocationID INT
            ,RequestHeaderID INT --Added by Nivesh 2025-11-10
        );
    END
		-----------------------
	----------------------------Quotation request validation - Added by Nivesh 2025-11-10 ---------------------------------------
    --Commented by Nivesh 2025-11-26 to fix Quotation based PO submit
    --IF (@IsQuatoationRequest = 1) 
    --AND EXISTS
    --(
    --SELECT 1 
    --FROM @supplierList SL
    --INNER JOIN RequestHeaders RH ON RH.Id = SL.RequestHeaderID
    -- WHERE RH.RequestType = 'RP'
    -- AND RH.QuotationStatus <> 'P' 
    -- AND RH.DocumentStatus = 'P'
    --)
    --BEGIN
      
    --  DECLARE @ErrMessage VARCHAR(MAX) = 'The purchase requests were made for the quotation. ';
      
    --    SELECT 
    --        @ErrMessage= @ErrMessage + STRING_AGG(RH.DocumentNo, ', ') 
    --    FROM @supplierList SL
    --    INNER JOIN RequestHeaders RH ON RH.Id = SL.RequestHeaderID
    --    WHERE RH.RequestType = 'RP'
    --    AND RH.QuotationStatus <> 'P' 
    --    AND RH.DocumentStatus = 'P'
      

    --  RAISERROR (@ErrMessage, 16, 1 )
    --  ROLLBACK TRANSACTION

    --END
    ------------------------------------------------------------------------------------------------------
-------Added 26/11/2021-------------
	CREATE TABLE	#TempPOXML(
               RowOrder INT,
				PoHeaderID INT,
                PoDetailID INT,
                StockItemID INT,
                UnitID INT,
                UnitPrice DECIMAL(18, 6),
                RequestedQuantity FLOAT,
                ApprovedQuantity FLOAT,
                ReceivedQuantity FLOAT,
                Remarks NVARCHAR(1000),
                DiscountValue FLOAT,
                DiscountPercentage FLOAT,
                TaxValue DECIMAL(18, 6),
                IPAddress NVARCHAR(MAX),
                CreatedUserID INT,
                LastModUserID INT,
                CreatedDate DATETIME,
                LastModDate DATETIME,
                SupplierID INT,
				LocationID INT,
				ProcurementID INT)
-------Added 26/11/2021-------------
	CREATE TABLE	#TempPOXML2(
                StockItemID INT,
                RequestHeaderID INT	)

    CREATE TABLE	#TempPOXML3(StockItemID INT,UnitPrice DECIMAL(18, 6))

	
	CREATE TABLE #TempContractSupplier(
		StockItemID	INT,
		UnitPrice DECIMAL(18,6),
		RequestedQuantity FLOAT,
		ContractSupplierReason VARCHAR(MAX),
		ContractSupplierPrice DECIMAL(18, 6),
		ContractSupplierID INT
	)
	CREATE TABLE #TempDocNos (
        DocNo VARCHAR(50),     
        HeaderID INT
        );

    WHILE
    (SELECT COUNT(*) FROM @supplierList) > 0
    BEGIN

        SELECT TOP (1)
               @SupplierID = SupplierID, 
			   @LocationID = CASE WHEN @GetLocationFromDetail=1 THEN LocationID ELSE @LocationID END 
        FROM @supplierList;



        SELECT @CurrencyId = CurrencyID
        FROM Suppliers
        WHERE ID = @SupplierID;

        SET @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @LocationID, @TransactionType);


        IF @DocumentNo IS NULL
        BEGIN
            INSERT INTO TransactionTypeWiseNextNumbers
            (
                PropertyID,
                LocationID,
                TransactionType,
                NextNumber,
                LengthOfFormatting
            )
            VALUES
            (@PropertyID, @LocationID, @TransactionType, 1, 6);
            SET @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @LocationID, @TransactionType);
        END;
        DECLARE @Prefix VARCHAR(MAX),
                @Code VARCHAR(MAX);

		
        SELECT @Prefix = Prefix
        FROM dbo.Locations
		--WHERE Id = @LocationID
		WHERE Id = @LocationID

        SELECT @Code = Code
        FROM dbo.TransactionTypes
        WHERE Code = @TransactionType;

       

        SELECT @Prefix = SUBSTRING(@Prefix, 1, 3);

        SET @DocumentNo = @Prefix + '/' + @Code + '/' + @DocumentNo;

        


        UPDATE TransactionTypeWiseNextNumbers
        SET NextNumber = NextNumber + 1
        WHERE LocationID = @LocationID
              AND TransactionType = @TransactionType;
        
---------------Added for Delivery address----------------------

DECLARE @DeliveryAddress VARCHAR(MAX)

IF EXISTS(SELECT 1 FROM DeliveryAddressDetails WHERE CONVERT(VARCHAR(MAX),DeliveryAddressID) =  @DeliveryAddressID OR  Name = @DeliveryAddressID )
BEGIN

 SELECT TOP(1)  @DeliveryAddress = Address FROM DeliveryAddressDetails WHERE CONVERT(VARCHAR(MAX),DeliveryAddressID) =  @DeliveryAddressID  OR  Name = @DeliveryAddressID 

END
ELSE
BEGIN

 SELECT TOP(1)  @DeliveryAddress = Address FROM DeliveryAddressDetails WHERE PropertyID = @PropertyID ORDER BY DeliveryAddressID ASC

END


---------------Added for Delivery address----------------------
        IF(@IsDepartmentWisePOApproval =1)
        BEGIN
             SET @UniqueDepartmentCount = ( SELECT COUNT(*) FROM @DepartmentList)
            
            SET @DepartmentID = CASE WHEN @IsDirectPo =0 AND @DepartmentID = -999 AND @UniqueDepartmentCount >1  THEN @DirectPODepartmentID ELSE
            
            CASE WHEN @IsDirectPo =0 AND @DepartmentID = -999 AND @UniqueDepartmentCount =1 THEN (SELECT DepartmentID FROM @DepartmentList) ELSE @DepartmentID END END -- When PR base PO
            
            SET @DepartmentID = CASE WHEN @IsDirectPo =1 THEN @DirectPODepartmentID ELSE @DepartmentID END -- When Direct PO
        END

        ---Added by Isuru 2026-04-28
        DECLARE @PORemark VARCHAR(MAX),@IsPORemarkMandatory BIT

        SELECT @IsPORemarkMandatory = ISNULL(IsPORemarkMandatory,0)
        FROM Companies
        WHERE CompanyID = @PropertyID



        SELECT  @PORemark = ISNULL(Remarks,'')
        FROM OPENXML(@iDocID, '/PoHeader', 2) WITH 
		([Remarks] [nvarchar](500)); 

        IF(@IsPORemarkMandatory = 1)
        BEGIN
            IF(@PORemark IS NULL OR @PORemark = '')
            BEGIN
                RAISERROR ( 'Header Remark is Mandatory', 16, 1 )
            END
        END
        --End---

        INSERT INTO PoHeaders (PoHeaderID,PropertyID,LocationID,PoNo,SupplierID,DocumentDate,Remarks,DocumentStatus,UserProfileID,IsDirectPo,IsApproved,IPAddress,CreatedUserID,LastModUserID,CreatedDate,LastModDate,DeliveryDate,DeliveryAddressID,PaymentTermsDetailID,CurrencyId,POTypeId,Isprint,NetTotal,GrossTotal,TotalDiscount,TaxTotal,POType,SupplierReferenceNo,isModificationComplete, IsDepartmentWise, DepartmentID,InvoiceID,IsInvoiceBased
        )
        SELECT 1,
               PropertyID,
               @LocationID,
               @DocumentNo,
               @SupplierID,
             --  DocumentDate, commented by Isuru 2024-03-01
			 [dbo].[FN_GetTransactionDate] (@PropertyID), -- Added by Isuru to prevent inserting 1970 as DocumentDate 
               Remarks,
               DocumentStatus,
               UserProfileID,
               IsDirectPo,
               ISNULL(isApproved,0),
               IPAddress,
               @userId,
               @userId,
               GETDATE() CreatedDate,
               GETDATE() LastModDate,
               DeliveryDate,
               @DeliveryAddress,
               PaymentTermsDetailID,
               @CurrencyId,
               POTypeId,
               Isprint,
               isnull(NetTotal,0),
               isnull( GrossTotal,0),
                isnull(TotalDiscount,0),
                isnull(TaxTotal,0),
				@POType,
				SupplierReferenceNo,
				@isModificationComplete,
                ISNULL(@IsDepartmentWisePOApproval,0),
                @DepartmentID
                ,ISNULL(InvoiceID,0)
                ,ISNULL(@IsInvoiceBased,0)

        FROM
            OPENXML(@iDocID, '/PoHeader', 2) WITH 
			(
			[Id] [int],
			[PoHeaderID] [int] ,
			[PropertyID] [int] ,
			[LocationID] [int] ,
			[PoNo] [nvarchar](50) ,
			[SupplierID] [int] ,
			[DocumentDate] [datetime] ,
			[Remarks] [nvarchar](500) ,
			[DocumentStatus] [nvarchar](1) ,
			[UserProfileID] [int] ,
			[IsDirectPo] [bit] ,
			[IsApproved] [bit] ,
			[IPAddress] [nvarchar](max) ,
			[CreatedUserID] [int] ,
			[LastModUserID] [int] ,
			[DeliveryDate] [datetime] ,
			[DeliveryAddressID] [nvarchar](max) ,
			[PaymentTermsDetailID] [int] ,
			[CurrencyId] [int] ,
			[POTypeId] [int] ,
			[Isprint] [bit] ,
			[NetTotal] [decimal](18, 6) ,
			[GrossTotal] [decimal](18, 6) ,
			[TotalDiscount] [decimal](18, 6) ,
			[TaxTotal] [decimal](18, 6) ,
			[POType] [int] ,
			[SupplierReferenceNo] [varchar](50) ,
			[isModificationComplete] [bit]
            ,[InvoiceID] [INT]
			); --24
       
        SET @PoHeaderID = SCOPE_IDENTITY();

		UPDATE tempInput
		SET POHeaderID = @PoHeaderID
		WHERE ID = @tempInputID --Added by Nivesh 2024-03-06


    

		--Inserting into Audit Log Table 2025-05-14
		EXEC Inventry_AuditTail_WriteToLog 'PoHeaders', @PoHeaderID, 'INV', 'POI', 'I', @userId,@PropertyID, '', ''

		--End

	
-------Added 26/11/2021-------------
	INSERT INTO #TempPOXML
	 SELECT  ROW_NUMBER() OVER (ORDER BY (SELECT 1)),
              @PoHeaderID,
               1,
               StockItemID,
               UnitID,
               UnitPrice,
                RequestedQuantity,
               RequestedQuantity,
               0 ReceivedQuantity,
               Remarks,
               DiscountValue,
               DiscountPercentage,
               isnull(dbo.FN_GetStockItemWiseTotalTax(
                                                  StockItemID,
                                                  (CAST(UnitPrice AS DECIMAL(18,6)) - CAST(DiscountValue AS DECIMAL(18,6)) - (CAST(UnitPrice AS DECIMAL(18,6)) * (CAST(DiscountPercentage AS DECIMAL(18,6)) / 100)))
                                              ,@SupplierID,@LocationID),0),
               @ipAddress,
               CreatedUserID,
               LastModUserID,
               GETDATE() CreatedDate,
               GETDATE() LastModDate,
			   SupplierID,
			   LocationID,
			   ProcurementID
			   
			  
        from
            OPENXML(@iDocID, '/PoHeader/DetailList/PoDetail', 2)
            WITH
            (
                PoHeaderID INT,
                PoDetailID INT,
                StockItemID INT,
                UnitID INT,
                UnitPrice DECIMAL(18, 6),
                RequestedQuantity FLOAT,
                ApprovedQuantity FLOAT,
                ReceivedQuantity FLOAT,
                Remarks NVARCHAR(1000),
                DiscountValue FLOAT,
                DiscountPercentage FLOAT,
                TaxValue DECIMAL(18, 6),
                IPAddress NVARCHAR(MAX),
                CreatedUserID INT,
                LastModUserID INT,
                SupplierID INT,
				LocationID INT,
				ProcurementID INT
            )

            SELECT '#TempPOXML',*
            FROM #TempPOXML

		-------Added 26/11/2021-------------
		INSERT INTO #TempPOXML2
	 SELECT 
               StockItemID,
			   RequestHeaderID
        from
            OPENXML(@iDocID, '/PoHeader/DetailList/PoDetail', 2)
            WITH
            (
                 StockItemID INT,
                RequestHeaderID INT
            )
		-----------Added by Nivesh 2024-08-21-----------------
		IF EXISTS (SELECT 1 FROM #TempPOXML2 GROUP BY StockItemID,RequestHeaderID HAVING COUNT(StockItemID)>1)
		BEGIN
			RAISERROR ( 'Duplicate Items found', 16, 1 )
		END
		------------------------------



       -- --Added by Isuru 2025-07-16 to validate same item inserting with multiple unit prices

        INSERT INTO #TempPOXML3(StockItemID,UnitPrice)
        SELECT StockItemID, UnitPrice
        FROM  OPENXML(@iDocID, '/PoHeader/DetailList/PoDetail', 2)
        WITH
        ( StockItemID INT, UnitPrice DECIMAL(18,6) )

       
        IF EXISTS (SELECT 1 FROM #TempPOXML3 GROUP BY StockItemID HAVING COUNT(DISTINCT UnitPrice) > 1)
        BEGIN
         RAISERROR ( 'Duplicate items with different unit prices found for this transaction', 16, 1 )
        END


    -- --    end


		--Added by Isuru 2025-04-23 for Contracted Supplier changes---
		IF(@IsContractedSupplier =1)
		BEGIN
			INSERT INTO #TempContractSupplier
			SELECT StockItemID,UnitPrice,RequestedQuantity,ContractSupplierReason,ContractSupplierPrice,ContractSupplierID
			FROM
            OPENXML(@iDocID, '/PoHeader/DetailList/PoDetail', 2)
            WITH
            (
                StockItemID	INT,
				UnitPrice DECIMAL(18,6),
				RequestedQuantity FLOAT,
				ContractSupplierReason VARCHAR(MAX),
				ContractSupplierPrice DECIMAL(18, 6),
				ContractSupplierID INT
            ) 

			SELECT '#TempContractSupplier',*
			FROM #TempContractSupplier

			SELECT @PropertyID,@LocationID,StockItemID,@PoHeaderID,'PO',@SupplierID,UnitPrice,ContractSupplierID,ContractSupplierPrice,ContractSupplierReason,@userId,GETDATE()
			FROM #TempContractSupplier
			WHERE ContractSupplierID <> 0


			INSERT INTO ContracterChangeReason(PropertyID, LocationID, StockItemID, TransactionHeaderID, TransactionType, 
			SupplierID, SupplierPrice, ContractedSupplierID, ContractSupplierPrice, ContractSupplierChangeReason, CreatedUserID,CreatedDate)
			SELECT @PropertyID,@LocationID,StockItemID,@PoHeaderID,'PO',@SupplierID,UnitPrice,ContractSupplierID,ContractSupplierPrice,ContractSupplierReason,@userId,GETDATE()
			FROM #TempContractSupplier
			WHERE ContractSupplierID <> 0

		END


		---End----

		-------Addedd by Isuru For Check Unit Conversion-----2023/12/27-------------

		DECLARE @UnitConversionRate INT,@InvError2 VARCHAR(MAX),@UnitStockItem VARCHAR(MAX)

		SELECT *
		INTO #tempUnitCheck
		FROM #TempPOXML

		WHILE (SELECT COUNT(*) FROM #tempUnitCheck) > 0
		BEGIN
			
					
			SELECT  top(1)@UnitConversionRate = dbo.FN_GetUnitConvertionRate(@PropertyID,UnitID,dbo.FN_GetMasterUnitID(@PropertyID, @LocationID, StockItemID)),@UnitStockItem =sh.Name
			FROM #tempUnitCheck tp
			inner join StockItemHeaders sh on sh.Id = tp.StockItemID

			IF @UnitConversionRate =-1
			BEGIN
				SET @InvError2 =  'Unit Conversion not Found For'+' '+@UnitStockItem
				RAISERROR ( @InvError2, 16, 1 );  
				-- ROLLBACK TRANSACTION
			END

			DELETE TOP (1) FROM #tempUnitCheck
		END
		-----------End-------------------

        INSERT INTO PoDetails
        (
            PoHeaderID,
            PoDetailID,
            StockItemID,
            UnitID,
            UnitPrice,
            RequestedQuantity,
            ApprovedQuantity,
            ReceivedQuantity,
            Remarks,
            DiscountValue,
            DiscountPercentage,
            TaxValue,
            IPAddress,
            CreatedUserID,
            LastModUserID,
            CreatedDate,
            LastModDate,
			ProcurementID
        )
        SELECT @PoHeaderID,
               1,
               StockItemID,
               UnitID,
               UnitPrice,
               SUM(RequestedQuantity) RequestedQuantity,
               SUM(RequestedQuantity),
               0 ReceivedQuantity,
              --- Remarks, --commented by Nivesh 2024-10-03
			  STRING_AGG(CASE  WHEN ISNULL(Remarks, '') = '' THEN NULL ELSE Remarks END, ', ') , --Added by Nivesh 2024-10-03
               DiscountValue,
               DiscountPercentage,
               isnull(dbo.FN_GetStockItemWiseTotalTax(
                                                  StockItemID,
                                                  (UnitPrice - DiscountValue - (UnitPrice * (DiscountPercentage / 100)))
                                              ,@SupplierID,@LocationID),0),
               @ipAddress,
               CreatedUserID,
               LastModUserID,
               GETDATE(),
               GETDATE(),
			   ProcurementID
        --SELECT					  @PoHeaderID,1,  StockItemID, UnitID, UnitPrice, sum(RequestedQuantity) RequestedQuantity, sum(RequestedQuantity), 0 ReceivedQuantity, Remarks, sum(DiscountValue)DiscountValue, sum(DiscountPercentage),sum(dbo.FN_GetStockItemWiseTotalTax(StockItemID,(UnitPrice-DiscountValue-(UnitPrice*(DiscountPercentage/100))))),@ipAddress,CreatedUserID,LastModUserID,GETDATE(),GETDATE()
        --SELECT					  @PoHeaderID,1,  StockItemID, UnitID, UnitPrice, sum(RequestedQuantity) RequestedQuantity, sum(RequestedQuantity), 0 ReceivedQuantity, Remarks, DiscountValue, DiscountPercentage,TaxValue,@ipAddress,CreatedUserID,LastModUserID,GETDATE(),GETDATE()
         FROM #TempPOXML           
        WHERE SupplierID = @SupplierID AND LocationID =@LocationID
        GROUP BY PoHeaderID,
                 StockItemID,
                 UnitID,
				 -- Remarks, --commented by Nivesh 2024-10-03
                 UnitPrice,
                 IPAddress,
                 CreatedUserID,
                 LastModUserID,
                 TaxValue,
                 DiscountValue,
                 DiscountPercentage,
				 ProcurementID
        ORDER BY MIN(RowOrder);
       

        -------------------------------------------------------------------------------------------
        --------for updating header details--------------------------------------------------------
        SELECT @PoHeaderID POHeaderID,
               SUM(PD.TaxValue * PD.RequestedQuantity) TaxTotal,
               SUM(PD.UnitPrice * PD.RequestedQuantity) GrossTotal,
               SUM(PD.UnitPrice * PD.RequestedQuantity + ((PD.TaxValue * PD.RequestedQuantity))
                   - ((PD.DiscountValue * PD.RequestedQuantity) + (PD.UnitPrice * (PD.DiscountPercentage / 100))
                      * PD.RequestedQuantity
                     )
                  ) NetTotal,
               SUM((PD.DiscountValue * PD.RequestedQuantity) + (PD.UnitPrice * (PD.DiscountPercentage / 100))
                   * PD.RequestedQuantity
                  ) DiscountTotal
        INTO #UpdateHeaders
        FROM dbo.PoHeaders PH
            INNER JOIN dbo.PoDetails PD
                ON PH.Id = PD.PoHeaderID
        WHERE PD.PoHeaderID = @PoHeaderID;

		


        UPDATE SD
        SET SD.TaxTotal = SH.TaxTotal,
            SD.GrossTotal = SH.GrossTotal,
            SD.NetTotal = SH.NetTotal,
            SD.TotalDiscount = SH.DiscountTotal
        FROM dbo.PoHeaders SD
            INNER JOIN #UpdateHeaders SH
                ON SD.Id = SH.POHeaderID
        WHERE SD.Id = @PoHeaderID;

        DROP TABLE #UpdateHeaders;

        ------------------------------------------------------------------------------------------- 



        CREATE TABLE #itemList
        (
            PODetailID BIGINT,
            StockItemID BIGINT,
            ItemTotal MONEY,
            RequestedQTY DECIMAL(18,8),
            requestHeaderID DECIMAL,
            POheaderID DECIMAL,
            IPAddress NVARCHAR(MAX),
            CreatedUserID INT,
            LastModUserID INT,
            CreatedDate DATETIME,
            LastModDate DATETIME,
            ApprovedQuantity DECIMAL(18,2),
			LocationId INT
        );
        DECLARE @PODetailID BIGINT,
                @StockItemID BIGINT,
                @ItemTotal MONEY,
                @RQt DECIMAL(18,8),
                @ReqHeadID INT,
                @issueQty DECIMAL;

        
        INSERT INTO #itemList
        SELECT DISTINCT PoDetailID,
               StockItemID,
               (UnitPrice - DiscountValue - (UnitPrice * (DiscountPercentage / 100))) ItemTotal,
               RequestedQuantity,
               RequestHeaderID,
               @PoHeaderID,
               IPAddress,
               CreatedUserID,
               LastModUserID,
               GETDATE() CreatedDate,
               GETDATE() LastModDate,
               ApprovedQuantity,
			   LocationID
        FROM
            OPENXML(@iDocID, '/PoHeader/DetailList/PoDetail', 2)
            WITH
            (
                PoDetailID INT,
                StockItemID INT,
                UnitPrice DECIMAL(18, 6),
                RequestedQuantity DECIMAL(18,8),
                ApprovedQuantity FLOAT,
                ReceivedQuantity FLOAT,
                Remarks NVARCHAR(1000),
                DiscountValue FLOAT,
                DiscountPercentage FLOAT,
                IPAddress NVARCHAR(MAX),
                CreatedUserID INT,
                LastModUserID INT,
                SupplierID INT,
                RequestHeaderID INT,
				LocationID INT
            )
        WHERE SupplierID = @SupplierID AND LocationID = @LocationID;

        UPDATE IT
        SET IT.PODetailID = PD.Id
        FROM #itemList IT
            INNER JOIN dbo.PoDetails PD
                ON IT.POheaderID = PD.PoHeaderID
                   AND IT.StockItemID = PD.StockItemID
        WHERE PD.PoHeaderID = @PoHeaderID;



		
        CREATE TABLE #TaxTable
        (
            TaxTypeId INT,
            TaxValue MONEY
        );

       

        WHILE (SELECT COUNT(*) FROM #itemList) > 0
        BEGIN

            SELECT TOP (1)
                   @PODetailID = PODetailID,
                   @StockItemID = StockItemID,
                   @ItemTotal = ItemTotal,
                   @RQt = RequestedQTY,
                   @ReqHeadID = requestHeaderID
            FROM #itemList
            ORDER BY requestHeaderID;

            INSERT INTO dbo.PoWisePRs
            (
                PoHeaderID,
                RequestHeaderID,
                StockItemID,
                IPAddress,
                CreatedUserID,
                LastModUserID,
                CreatedDate,
                LastModDate,
                RequestionQty,
                ApprovedQty
            )

            SELECT POheaderID,
                   requestHeaderID,
                   StockItemID,
                   IPAddress,
                   CreatedUserID,
                   LastModUserID,
                   CreatedDate,
                   LastModDate,
                   RequestedQTY,
                   ApprovedQuantity
            FROM #itemList
            WHERE StockItemID = @StockItemID AND requestHeaderID = @ReqHeadID;

		
			 UPDATE RequestDetails
            SET IssuedQuantity = IssuedQuantity + @RQt
            WHERE RequestHeaderID = @ReqHeadID
                  AND StockItemID = @StockItemID;

		


            --INSERT INTO #TaxTable
            --EXEC [SP_Select_StockItemWiseTaxAmount3] @StockItemID, @ItemTotal, @SupplierID;

            --INSERT INTO POwiseTaxes
            --(
            --    PODetailID,
            --    StockItemID,
            --    TaxTypeID,
            --    TaxAmount
            --)
            --SELECT @PODetailID,
            --       @StockItemID,
            --       TaxTypeId,
            --       ROUND(TaxValue * @RQt, 2)
            --FROM #TaxTable;

            --DELETE FROM #TaxTable;

			--select * from #itemList

            DELETE FROM #itemList
            WHERE StockItemID = @StockItemID AND requestHeaderID = @ReqHeadID;

        END;
       
	  ----------added 18/03/2021--------------------- 
	

			SELECT Id, StockItemID,TaxValue,UnitPrice,RequestedQuantity,DiscountValue, DiscountPercentage 
			INTO #TempPODetails 
			FROM PoDetails WHERE Poheaderid = @poheaderid


			DECLARE @ItemId INT, @ItemTotalVal DECIMAL(18,6), @RequestedQuantity DECIMAL(18,6), @PODetailsId INT
		
		
			WHILE(SELECT COUNT(*) FROM #TempPODetails)>0
			BEGIN
				SELECT TOP(1) @PODetailsId = Id, @ItemId = StockItemID, @ItemTotalVal = (UnitPrice - DiscountValue - (UnitPrice * (DiscountPercentage / 100))),
				@RequestedQuantity = RequestedQuantity FROM #TempPODetails
				

			    INSERT INTO #TaxTable
				EXEC [SP_Select_StockItemWiseTaxAmount3] @ItemId, @ItemTotalVal, @SupplierID, @LocationID ;

				INSERT INTO POwiseTaxes
				(
					PODetailID,
					StockItemID,
					TaxTypeID,
					TaxAmount
				)
				SELECT @PODetailsId,
					   @ItemId,
					   TaxTypeId,
					   TaxValue * @RequestedQuantity -- change this round for tax missing issue
				FROM #TaxTable;

				TRUNCATE TABLE #TaxTable;
				DELETE TOP(1) FROM #TempPODetails
			END
       DROP TABLE #TempPODetails


		----------added 18/03/2021--------------------- 


        DROP TABLE #itemList;
        DROP TABLE #TaxTable;
		drop table #tempUnitCheck -- Added By Nivesh 2024-02-21
			--select '11111111'
			
	
        -- Insert for Approvel log
        DECLARE @IsRangeWiseApproval BIT = 0, @DepartmentID1 INT ;

        SELECT @IsRangeWiseApproval = IsRangeWiseApproval FROM Companies WHERE CompanyID = @PropertyID
		select @IsRangeWiseApproval IsRangeWiseApproval 

        IF(ISNULL(@IsInvoiceBased,0) = 0)
        BEGIN
            IF(@IsDepartmentWisePOApproval =1)
            BEGIN
                EXEC SP_InsertDepartmentWisePOApprovalLevelForRequest @PropertyID,
                                                  @LocationID,
                                                  2,
                                                  @PoHeaderID,
                                                  @DepartmentID
            END
            ELSE IF(@IsRangeWiseApproval = 1)
            BEGIN
                SELECT @DepartmentID1 = DepartmentID FROM PoHeaders WHERE ID = @PoHeaderID

                EXEC SP_InsertApprovalLevelForRange @PropertyID, @LocationID, 2, @PoHeaderID, @DepartmentID1, @userId

            END 
            ELSE
            BEGIN
                 EXEC SP_InsertApprovalLevelForRequest @PropertyID,
                                                      @LocationID,
                                                      2,
                                                      @PoHeaderID
            END
        END
        ELSE
        BEGIN
        
            UPDATE PoHeaders
            SET IsApproved = 1
            WHERE ID = @PoHeaderID
        END

    ------Get multiple Document No & PO header id---
        INSERT INTO #TempDocNos (DocNo, HeaderID)
        VALUES (@DocumentNo, @PoHeaderID);

         
    -----------------------------------------------
											  


        DELETE FROM @supplierList
        WHERE SupplierID = @SupplierID AND LocationID = @LocationID ;

		TRUNCATE TABLE #TempPOXML
		TRUNCATE TABLE #TempPOXML2
        TRUNCATE TABLE #TempPOXML3
    END;
 

   
    SET @docNo = @DocumentNo;
 
    SET @headerid = @PoHeaderID;
 



    DECLARE @tblRequestHeader AS TABLE
    (
        RequestHeaderId INT
    );

    INSERT INTO @tblRequestHeader
    SELECT DISTINCT
           RequestHeaderID
    FROM
        OPENXML(@iDocID, '/PoHeader/DetailList/PoDetail', 2)
        WITH
        (
            RequestHeaderID BIGINT
        );
    DECLARE @PRDocNo VARCHAR(MAX)

    WHILE (SELECT COUNT(*) FROM @tblRequestHeader) > 0
    BEGIN


        SELECT TOP (1)
               @RequestHeaderID = RequestHeaderId
        FROM @tblRequestHeader;

        IF EXISTS (SELECT 1 FROM RequestHeaders WHERE ID = @RequestHeaderID AND DocumentStatus='C')
        BEGIN
           
           SELECT @PRDocNo = DocumentNo
            FROM RequestHeaders
            WHERE ID = @RequestHeaderID
            AND DocumentStatus='C'
            
            SET @InvError2 =  @PRDocNo+ ' '+ 'Purchase Request are already completed.. Cannot create PO.'
            SELECT @InvError2 InvError2

            RAISERROR ( @InvError2, 16, 1 );  
            ROLLBACK TRANSACTION
        END

        DECLARE @Flag INT;

        SELECT @Flag = Flag
        FROM dbo.RequestHeaders
        WHERE Id = @RequestHeaderID;
		    DECLARE @total DECIMAL(18,6),@POtotal DECIMAL(18,6);

        IF @Flag <> 1
        BEGIN
            SELECT @total = SUM(RequestedQuantity)
            FROM dbo.RequestDetails
            WHERE RequestHeaderID = @RequestHeaderID;

            SELECT @POtotal = SUM(ApprovedQty) --requestedQty changed to approvedqty
            FROM dbo.PoWisePRs
            WHERE RequestHeaderID = @RequestHeaderID;

            SELECT * FROM RequestDetails
			WHERE RequestHeaderID = @RequestHeaderID AND IssuedQuantity < ApprovedQuantity


			IF NOT EXISTS (SELECT 1 FROM RequestDetails
			WHERE RequestHeaderID = @RequestHeaderID AND IssuedQuantity < ApprovedQuantity)
			BEGIN
			UPDATE RequestHeaders
			SET DocumentStatus = 'C'
			  WHERE Id = @RequestHeaderID
              AND TransactionTypeCode = 1;
			END;	

            --IF (@total = @POtotal)
            --BEGIN
            --    UPDATE RequestHeaders
            --    SET DocumentStatus = 'C'
            --    WHERE Id = @RequestHeaderID
            --          AND TransactionTypeCode = 1;
            --END;

        END;
        ELSE
        BEGIN

            SELECT @total = SUM(RequestedQuantity)
            FROM dbo.RequestDetails
            WHERE RequestHeaderID = @RequestHeaderID;

            SELECT @POtotal = SUM(ApprovedQty) --requestedQty changed to approvedqty
            FROM dbo.PoWisePRs
            WHERE RequestHeaderID = @RequestHeaderID;

            IF (@total = @POtotal)
            BEGIN
                UPDATE RequestHeaders
                SET DocumentStatus = 'C' , Flag =0
                WHERE Id = @RequestHeaderID
                      AND TransactionTypeCode = 1;
            END;

        END;

        DELETE FROM @tblRequestHeader
        WHERE RequestHeaderId = @RequestHeaderID;

    END;

	----------SEND MAIL------------------------------------------------------------------------------------------------------------
	DECLARE @IsMailNotification BIT,@IsWhatsAppNotification BIT ,@SMSText NVARCHAR(MAX)
	
	SELECT @IsMailNotification =  ISNULL(IsMailNotification,0),@IsWhatsAppNotification = ISNULL(IsWhatsAppNotification,0)
	FROM TransactionTypes
	WHERE CODE = @TransactionType

     --ADDED BY ISURU 2025-08-15 TO SEND WHTSAPP MSG
    IF @IsWhatsAppNotification=1
    BEGIN
        EXEC [dbo].[SP_GetTransactionWiseWhatsAppSMS] @LocationID ,@TransactionType,@PropertyID ,'C',@PoHeaderID ,@DocumentNo 
    END
    --END

	--SELECT  @IsMailNotification = IsMailNotification FROM Companies WHERE CompanyID = @PropertyID

	IF @IsMailNotification = 1
	BEGIN
    DECLARE @Email VARCHAR(MAX),@EmailBody VARCHAR(MAX), @CompanyName VARCHAR(200), @LocationName VARCHAR(200), @RequestedUser VARCHAR(200)

	--sending Tranasctionwise emails 2024-09-27
	EXEC [dbo].[SendTransactionWiseEmailS] 'PO',@PoHeaderID,@LocationID,@PropertyID,'C'
	--END

	SELECT @RequestedUser = U.UserName ,@LocationName = L.Name,@CompanyName = C.Name
	FROM PoHeaders PO
	INNER JOIN @UserData U ON PO.CreatedUserID = U.Id
	INNER JOIN Locations L On L.Id = PO.LocationID
	INNER JOIN Companies C ON C.CompanyID =PO.PropertyID
	WHERE PO.Id = @PoHeaderID
 
	SELECT TOP(1) @Email=US.Email
    FROM ApprovalLogs AS AL WITH (NOLOCK)
        INNER JOIN dbo.UserWiseApproveLevels AS UAL WITH (NOLOCK)
			   ON AL.TransactionID = UAL.TransactionTypeID
               AND AL.LocationID = UAL.LocationId
               AND AL.PropertyID = UAL.PropertyId
               AND AL.ApprovalLevelID = UAL.ApproveLevelID
                AND AL.ApprovalUserID = UAL.UserProfileId   
                AND UAL.SendEmail = 1
        INNER JOIN CentralUsers AS US WITH (NOLOCK) ON US.Id = AL.ApprovalUserID
    WHERE AL.TransactionID = 2 AND AL.SendMail = 0  
	AND AL.TransactionHeaderID=@PoHeaderID
     AND UAL.SendEmail=1
	ORDER BY AL.SeqID ASC;

    --Added by Isuru 2024-05-22 for sending multiplle users with approval mail
    SELECT DISTINCT US.Email,AL.ApprovalUserID
    into #TempEmail
    FROM ApprovalLogs AS AL WITH (NOLOCK)
    INNER JOIN dbo.UserWiseApproveLevels AS UAL WITH (NOLOCK)
    ON AL.TransactionID = UAL.TransactionTypeID
    AND AL.LocationID = UAL.LocationId
    AND AL.PropertyID = UAL.PropertyId
    AND AL.ApprovalLevelID = UAL.ApproveLevelID
    AND AL.ApprovalUserID = UAL.UserProfileId   
    AND UAL.SendEmail = 1
    INNER JOIN CentralUsers AS US WITH (NOLOCK) ON US.Id = AL.ApprovalUserID
    WHERE AL.TransactionID = 2 AND AL.SendMail = 0  
    AND AL.TransactionHeaderID=@PoHeaderID AND AL.SeqID=1
    AND UAL.SendEmail=1
    --ORDER BY AL.SeqID ASC;


	---End

	SET @EmailBody = '<html><body><p>You have to respond a pending approval</p>
					  <table border = 1>
					  <thead>
						  <th  style="width: 20%" >Approval type</th>
						  <th  style="width: 20%" >Document Number</th>
						  <th  style="width: 20%" >Company Name</th>
						  <th  style="width: 20%" >Location Name</th>
						  <th  style="width: 20%" >Requested User</th>
					  </thead>
					  <tbody >
						<tr>
						 <td  style="width: 20%" >Purchase Order Request</td>
						 <td  style="width: 20%" >'+@DocumentNo+'</td>
						 <td  style="width: 20%" >'+@CompanyName+'</td>
						 <td  style="width: 20%" >'+@LocationName+'</td>
						 <td  style="width: 20%" >'+@RequestedUser+'</td>
                        </tr>
					  </tbody>
					  </table></html></body>'


	IF @Email IS NOT NULL OR @Email  <> ''
	BEGIN
	DECLARE @NewEmail VARCHAR(MAX),@NewApprovalUserID INT
		WHILE EXISTS(SELECT 1  FROM #TempEmail)
		BEGIN

		SELECT TOP(1) @NewEmail= EMAIL,@NewApprovalUserID =ApprovalUserID  FROM #TempEmail
		--EXEC [dbo].[SendReuestMail] @Email, 'PO Approval', @EmailBody, 2

		EXEC [dbo].[SendReuestMail] @NewEmail, 'PO Approval', @EmailBody, 2

			--UPDATE TOP(1) AL
			--SET AL.SendMail = 1
			--FROM ApprovalLogs AS AL
			--	INNER JOIN dbo.UserWiseApproveLevels AS UAL
			--		ON AL.TransactionID = UAL.TransactionTypeID
			--		   AND AL.LocationID = UAL.LocationId
			--		   AND AL.PropertyID = UAL.PropertyId
			--		   AND AL.ApprovalLevelID = UAL.ApproveLevelID
			--		   AND AL.TransactionHeaderID = @PoHeaderID
			--	INNER JOIN @UserData AS US
			--		ON US.Id = UAL.UserProfileId
			--WHERE AL.TransactionID = 2 AND AL.DocStatus = 'P' 

			;WITH CTE AS (
			SELECT TOP 1 AL.SeqID
			FROM ApprovalLogs AS AL
			INNER JOIN dbo.UserWiseApproveLevels AS UAL ON AL.TransactionID = UAL.TransactionTypeID AND AL.LocationID = UAL.LocationId 
			AND AL.PropertyID = UAL.PropertyId AND AL.ApprovalLevelID = UAL.ApproveLevelID AND AL.TransactionHeaderID = @PoHeaderID
			INNER JOIN @UserData AS US ON US.Id = AL.ApprovalUserID
			WHERE AL.TransactionID = 2 
				AND AL.DocStatus = 'P'
				AND AL.SeqID=1
				AND AL.ApprovalUserID=@NewApprovalUserID
                 AND AL.ApprovalUserID = UAL.UserProfileId   
                 AND UAL.SendEmail = 1
			ORDER BY AL.SeqID ASC
			)
			UPDATE AL
			SET AL.SendMail = 1
			FROM ApprovalLogs AS AL
			--INNER JOIN CTE ON AL.SeqID = CTE.SeqID; -- Commented by Isuru 20261002 to fix all same seq records updating
             INNER JOIN CTE ON AL.SeqID = CTE.SeqID
            WHERE AL.TransactionID = 2
              AND AL.TransactionHeaderID = @PoHeaderID
              AND AL.ApprovalUserID = @NewApprovalUserID
              AND AL.DocStatus = 'P';
		
		DELETE TOP(1) FROM #TempEmail
		END
		DROP TABLE #TempEmail
	END
	END	
	 
	---------Added 8/3/2022--------------------------

	SELECT Id,Amount INTO #tempAdditionalCharges
	FROM
	OPENXML(@iDocID, '/PoHeader/AdditionalCharges/AdditionalChargesDetails',2)
	WITH(Id INT, Amount DECIMAL(18,6))
  
	INSERT INTO [dbo].[POwiseCharges]
	SELECT @PoHeaderID,Id,Amount 
	FROM #tempAdditionalCharges
	---------Added 8/3/2022--------------------------	


	---------Added 8/3/2022--------------------------

	--	DECLARE @AdditionalCharge decimal(18,2),@NetTotal1 decimal(18,2), @NewNetTotal decimal(18,2)
	--SELECT Id,Amount INTO #tempAdditionalCharges
	--FROM
	--OPENXML(@iDocID, '/PoHeader/AdditionalCharges/AdditionalChargesDetails',2)
	--WITH(Id INT, Amount DECIMAL(18,6))

	--select @AdditionalCharge = sum(Amount)
	--from #tempAdditionalCharges
  
	--INSERT INTO [dbo].[POwiseCharges]
	--SELECT @PoHeaderID,Id,Amount 
	--FROM #tempAdditionalCharges

	--select @NetTotal1= NetTotal
	--from poheaders
	--where Id= @PoHeaderID


	--SET @NewNetTotal = @NetTotal1 + isnull(@AdditionalCharge,0)

	--SELECT '@NewNetTotal',@NewNetTotal,'@NetTotal1',@NetTotal1,''

	--update poheaders
	--set NetTotal = @NewNetTotal
	--where Id= @PoHeaderID

	IF EXISTS(SELECT 1 FROM PoHeaders_Temp WHERE Id = @tempPOHeaderID)
	BEGIN
		UPDATE PoHeaders_Temp 
		SET DocumentStatus = 'C'
		WHERE Id = @tempPOHeaderID
	END -- Added by Nivesh 2024-10-08 For apdate complete temp PO
    ------Get Document No list ---------------
    SET  @DocumentListJson = (SELECT 
                                DocNo,
                                HeaderID 
                            FROM #TempDocNos
                            FOR JSON PATH
                            );
    ------------------------------------------

    EXEC sp_xml_removedocument @iDocID;
        COMMIT TRANSACTION;


 END
END TRY
    BEGIN CATCH

 

	ROLLBACK TRANSACTION
	
	DECLARE @ErrorMessage NVARCHAR(4000);  
	DECLARE @ErrorSeverity INT;  
	DECLARE @ErrorState INT;
	DECLARE @ErrorProcedure NVARCHAR(4000);  

	SELECT   
    @ErrorMessage = ERROR_MESSAGE(),  
    @ErrorSeverity = ERROR_SEVERITY(),  
    @ErrorState = ERROR_STATE(),
	@ErrorProcedure = ERROR_PROCEDURE(); 
	RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
	 --SELECT
  --  ERROR_NUMBER() AS ErrorNumber,
  --  ERROR_STATE() AS ErrorState,
  --  ERROR_SEVERITY() AS ErrorSeverity,
  --  ERROR_PROCEDURE() AS ErrorProcedure,
  --  ERROR_LINE() AS ErrorLine,
  --  ERROR_MESSAGE() AS ErrorMessage;

    END CATCH;


--select @DocumentNo



--SELECT * FROM POHeaders

GO

