 --[dbo].[SP_InsertPurchaseOrder_Temp] '<PoHeader xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><IPAddress>::1</IPAddress><CreatedUserID>0</CreatedUserID><LastModUserID>0</LastModUserID><CreatedDate>2024-10-07T07:27:29.886Z</CreatedDate><LastModDate>2024-10-07T07:27:29.886Z</LastModDate><Id>0</Id><Isprint>false</Isprint><PoHeaderID>1</PoHeaderID><PropertyID>1</PropertyID><LocationID>1</LocationID><PoNo>no</PoNo><SupplierID>1</SupplierID><DocumentDate>1970-01-01T00:00:00Z</DocumentDate><Remarks /><DocumentStatus>PO</DocumentStatus><UserProfileID>4168</UserProfileID><IsDirectPo>true</IsDirectPo><isApproved>false</isApproved><DeliveryDate>2024-10-07T00:00:00</DeliveryDate><PaymentTermsDetailID>16</PaymentTermsDetailID><CurrencyId>1</CurrencyId><POTypeId>1</POTypeId><NetTotal>0</NetTotal><GrossTotal>0</GrossTotal><TotalDiscount>0</TotalDiscount><TaxTotal>0</TaxTotal><POType>1</POType><IsForeign>false</IsForeign><isModificationComplete>false</isModificationComplete><DetailList><PoDetail><IPAddress>232</IPAddress><CreatedUserID>4168</CreatedUserID><LastModUserID>4168</LastModUserID><CreatedDate>2024-10-07T07:27:24.131Z</CreatedDate><LastModDate>2024-10-07T07:27:24.131Z</LastModDate><Id>0</Id><PoHeaderID>0</PoHeaderID><PoDetailID>0</PoDetailID><StockItemID>42</StockItemID><UnitID>26</UnitID><UnitPrice>500</UnitPrice><RequestedQuantity>10</RequestedQuantity><ApprovedQuantity>0</ApprovedQuantity><ReceivedQuantity>0</ReceivedQuantity><Remarks /><DiscountValue>0</DiscountValue><DiscountPercentage>0</DiscountPercentage><LocationID>1</LocationID><SupplierID>1</SupplierID><RequestHeaderID>0</RequestHeaderID><TaxValue>90</TaxValue><TBPHeaderId>0</TBPHeaderId></PoDetail><PoDetail><IPAddress>232</IPAddress><CreatedUserID>4168</CreatedUserID><LastModUserID>4168</LastModUserID><CreatedDate>2024-10-07T07:27:28.108Z</CreatedDate><LastModDate>2024-10-07T07:27:28.108Z</LastModDate><Id>0</Id><PoHeaderID>0</PoHeaderID><PoDetailID>0</PoDetailID><StockItemID>1</StockItemID><UnitID>37</UnitID><UnitPrice>136</UnitPrice><RequestedQuantity>4</RequestedQuantity><ApprovedQuantity>0</ApprovedQuantity><ReceivedQuantity>0</ReceivedQuantity><Remarks /><DiscountValue>0</DiscountValue><DiscountPercentage>0</DiscountPercentage><LocationID>1</LocationID><SupplierID>1</SupplierID><RequestHeaderID>0</RequestHeaderID><TaxValue>0</TaxValue><TBPHeaderId>0</TBPHeaderId></PoDetail></DetailList><AdditionalCharges /></PoHeader>','',0
 
 --go
CREATE PROCEDURE [dbo].[SP_InsertPurchaseOrder_Temp]
(
    @XMLDetails XML,
    @docNo VARCHAR(MAX) OUTPUT,
    @headerid INT OUTPUT
)
AS
DECLARE @Doc VARCHAR(100);
DECLARE @MinValue INT

DECLARE @UserData TABLE(
Id INT,
UserName NVARCHAR(200),
EmployeeId NVARCHAR(MAX)
)


INSERT INTO tempPOInput
(
    xmldata
)
VALUES
(@XMLDetails);

DECLARE @tempInputID INT
SELECT TOP (1) @tempInputID = ID FROM tempPOInput
ORDER BY ID DESC -- Added by Nivesh 2024-03-06



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
            @LocationID INT, @DocumentNo VARCHAR(MAX),@TransactionType CHAR(3),
            @PoHeaderID BIGINT,@RequestHeaderID BIGINT,@userId INT,
            @ipAddress VARCHAR(MAX),@GetLocationFromDetail bit,@IsCentralLogin BIT, @isModificationComplete bit

    SET @TransactionType = 'TP';

    SELECT @PropertyID = PropertyID,
           @SupplierId2 = SupplierID,
           @LocationID = LocationID,
           @RequestHeaderID = RequestHeaderID,
           @userId = UserProfileID,
           @ipAddress = IPAddress,
		   @POType = POType,
		   @isModificationComplete = isModificationComplete
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
			isModificationComplete bit

        );


		IF @userId <>0
		BEGIN

		SELECT @IsCentralLogin = IsCentralLogin FROM Companies WHERE CompanyID = @PropertyID 
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
    );
    DECLARE @SupplierID AS INT;

    INSERT INTO @supplierList
    SELECT SupplierID, LocationID
    FROM
        OPENXML(@iDocID, '/PoHeader/DetailList/PoDetail', 2)
        WITH
        (
            SupplierID INT,LocationID INT
        );

		-----------------------
	

-------Added 26/11/2021-------------
	CREATE TABLE	#TempPOXML(
				PoHeaderID INT,
                PoDetailID INT,
                StockItemID INT,
                UnitID INT,
                UnitPrice DECIMAL(18, 2),
                RequestedQuantity FLOAT,
                ApprovedQuantity FLOAT,
                ReceivedQuantity FLOAT,
                Remarks NVARCHAR(500),
                DiscountValue FLOAT,
                DiscountPercentage FLOAT,
                TaxValue DECIMAL(18, 2),
                IPAddress NVARCHAR(MAX),
                CreatedUserID INT,
                LastModUserID INT,
                CreatedDate DATETIME,
                LastModDate DATETIME,
                SupplierID INT,
				LocationID INT,
				StockName varchar(50),
				UnitName varchar(50),
				CurrentStock decimal(18, 8),
				ItemTotal decimal(18, 8))

	CREATE TABLE #tempAdditionalCharges(
	Id INT, Amount DECIMAL(18,6)
	)
-------Added 26/11/2021-------------
	CREATE TABLE	#TempPOXML2(
                StockItemID INT,
                RequestHeaderID INT	)
	

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

		select @DocumentNo DocumentNo
        SET @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @LocationID, @TransactionType);

			select @DocumentNo DocumentNo
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

SELECT  @DeliveryAddress = Address FROM DeliveryAddressDetails WHERE PropertyID = @PropertyID
---------------Added for Delivery address----------------------

        INSERT INTO PoHeaders_Temp
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
               GETDATE(),
               GETDATE(),
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
				@isModificationComplete
        FROM
            OPENXML(@iDocID, '/PoHeader', 2) WITH PoHeaders_Temp; --24
       
        SET @PoHeaderID = SCOPE_IDENTITY();

		UPDATE tempPOInput
		SET POHeaderID = @PoHeaderID
		WHERE ID = @tempInputID --Added by Nivesh 2024-03-06

	
-------Added 26/11/2021-------------
	INSERT INTO #TempPOXML
	 SELECT  @PoHeaderID,
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
                                                  (UnitPrice - DiscountValue - (UnitPrice * (DiscountPercentage / 100)))
                                              ,@SupplierID,@LocationID),0),
               @ipAddress,
               CreatedUserID,
               LastModUserID,
               GETDATE(),
               GETDATE(),
			   SupplierID,
			   LocationID,
			   StockName,
			   UnitName,
			   CurrentStock,
			   ItemTotal
        FROM
            OPENXML(@iDocID, '/PoHeader/DetailList/PoDetail', 2)
            WITH
            (
                PoHeaderID INT,
                PoDetailID INT,
                StockItemID INT,
                UnitID INT,
                UnitPrice DECIMAL(18, 2),
                RequestedQuantity FLOAT,
                ApprovedQuantity FLOAT,
                ReceivedQuantity FLOAT,
                Remarks NVARCHAR(500),
                DiscountValue FLOAT,
                DiscountPercentage FLOAT,
                TaxValue DECIMAL(18, 2),
                IPAddress NVARCHAR(MAX),
                CreatedUserID INT,
                LastModUserID INT,
                CreatedDate DATETIME,
                LastModDate DATETIME,
                SupplierID INT,
				LocationID INT,
				StockName varchar(50),
				UnitName varchar(50),
				CurrentStock decimal(18, 8),
				ItemTotal decimal(18,8)
            )
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

		-------Addedd by Isuru For Check Unit Conversion-----2023/12/27-------------

        INSERT INTO PoDetails_Temp
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
			StockName,
			UnitName,
			CurrentStock,
			ItemTotal
        )
        SELECT @PoHeaderID,
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
                                                  (UnitPrice - DiscountValue - (UnitPrice * (DiscountPercentage / 100)))
                                              ,@SupplierID,@LocationID),0),
               @ipAddress,
               CreatedUserID,
               LastModUserID,
               GETDATE(),
               GETDATE(),
			   StockName,
			   UnitName,
			   CurrentStock,
			   ItemTotal
     FROM #TempPOXML           
        WHERE SupplierID = @SupplierID AND LocationID =@LocationID
        

        -------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------- 

        DELETE FROM @supplierList
        WHERE SupplierID = @SupplierID AND LocationID = @LocationID ;

		TRUNCATE TABLE #TempPOXML
		TRUNCATE TABLE #TempPOXML2
    END;
 
	INSERT INTO #tempAdditionalCharges
 	SELECT Id,Amount 
	FROM
	OPENXML(@iDocID, '/PoHeader/AdditionalCharges/AdditionalChargesDetails',2)
	WITH(Id INT, Amount DECIMAL(18,6))
  
	INSERT INTO [dbo].[POwiseCharges_Temp]
	SELECT @PoHeaderID,Id,Amount 
	FROM #tempAdditionalCharges
   
    SET @docNo = @DocumentNo;
 
    SET @headerid = @PoHeaderID;
 
	DROP TABLE #tempAdditionalCharges;
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


    END CATCH;

GO

