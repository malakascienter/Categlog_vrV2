


CREATE PROCEDURE [dbo].[SP_GRNPrint] (@TxnId INT)
AS
BEGIN


	DECLARE @XMLData XML,@hdoc INT,@DocNo VARCHAR(20),@SuppId INT, @LocationId INT,@PropertyId INT,@SuppCurrencyID INT,@ReferenceID INT,
	@DelAdd VARCHAR(300)
	SELECT @XMLData = XMLDetails ,@DocNo = ApprovalDocNo FROM GRNApprovalLog WHERE Id = @TxnId

	CREATE TABLE #HeaderData (
		Id INT,
		TransactionDate	 VARCHAR(20),
		DocumentTitle	VARCHAR(150),
		DocumentNo	VARCHAR(20),
		CompanyName	 VARCHAR(200),
		Email	 VARCHAR(200),
		FaxNo	 VARCHAR(200),
		Telephone1	 VARCHAR(15),
		SupplierName VARCHAR(300),
		suppliercode VARCHAR(150),
		LocationName VARCHAR(200),
		SupplyCurrency	VARCHAR(200),
		ReferenceDocument INT,
		--Printed VARCHAR(100),
		--ACCEPTED VARCHAR(100),
		printeddate	VARCHAR(100),
		printedtime	VARCHAR(100),
		--usename	VARCHAR(200),
		supplieradd	VARCHAR(500),
		SuppEmail VARCHAR(200),
		SuppTelephone1	VARCHAR(11),
		Address1 VARCHAR(200),	
		Address2 VARCHAR(200),		
		Address3 VARCHAR(200),
		PoNo VARCHAR(20),
		Word1 VARCHAR(250),	
		DeliveryAddress VARCHAR(200)
	)



	CREATE TABLE #ReportSummery(
		id INT IDENTITY(1, 1) ,
        Description VARCHAR(100) ,
        amount MONEY ,
        factor INT

	)

	CREATE TABLE #TempApproval(Id INT IDENTITY(1,1) PRIMARY KEY, Description VARCHAR(250), Value VARCHAR(250))
	CREATE TABLE #TempPOApproval(Id INT IDENTITY(1,1) PRIMARY KEY, Description VARCHAR(250), Value VARCHAR(250)) 
	CREATE TABLE #TempPRApprovalForPO(Id INT IDENTITY(1,1) PRIMARY KEY, Description VARCHAR(250), Value VARCHAR(250)) 

	EXEC sp_xml_preparedocument @hdoc OUTPUT, @XMLData
	SELECT * iNTO #TempGrN
	FROM OPENXML (@hdoc, '/StockTransactionHeader' , 2)
	WITH(
		SupplierID INT,
		TransactionDate DATE,
		LocationID INT,
		ReferenceNo VARCHAR(200),
		ReferenceID INT,
		TransactionID INT,
		PropertyID INT,
		SuppCurrencyID INT
		)

	SELECT * iNTO #TempGrNDetails
	FROM OPENXML (@hdoc, '/StockTransactionHeader/StockDetailList/StockTransactionDetail' ,2)
	WITH(
		StockItemID INT,
		Quantity DECIMAL(18,6),
		UnitPrice DECIMAL(18,6),
		DiscountPercentage DECIMAL(18,6),
		DiscountValue DECIMAL(18,6),
		TxnUnitID INT,
		PropertyID INT,
		Remarks VARCHAR(300)
		)


	SELECT * iNTO #TempGrNDetailsExp
	FROM OPENXML (@hdoc, '/StockTransactionHeader/ItemWiseExpireDates/ItemWiseExpireDates' ,2)
	WITH(
		StockItemID INT,
		EXPDate DATE
		)

		
	SELECT * iNTO #TempGrNDetailsTemp
	FROM OPENXML (@hdoc, '/StockTransactionHeader/ItemWiseTemperature/ItemWiseTemperature' ,2)
	WITH(
		StockItemID INT,
		Temperature DECIMAL(6,2),
		TypeId INT
		)

	SELECT @SuppId = SupplierID,@LocationId = LocationID ,@PropertyId = PropertyId,@SuppCurrencyID = SuppCurrencyID,@ReferenceID = ReferenceID
	FROM #TempGrN

	SELECT @DelAdd = Address FROM DeliveryAddressDetails WHERE PropertyID = @PropertyId

	INSERT INTO #HeaderData (Id,TransactionDate,SupplierName	,suppliercode,ReferenceDocument,DocumentTitle,DocumentNo,CompanyName,
	Email,FaxNo,Telephone1,LocationName,SupplyCurrency,printeddate,printedtime,supplieradd,SuppEmail,SuppTelephone1,Address1,Address2,Address3,
	PONo,Word1,DeliveryAddress)
	SELECT @TxnId, TransactionDate,(SELECT Name FROM Suppliers WHERE ID = @SuppId),(SELECT Code FROM Suppliers WHERE ID = @SuppId),ReferenceNo,
	'Good Received Note',@DocNo,(SELECT Name FROM Companies WHERE CompanyID = @PropertyId),(SELECT Email FROM Companies WHERE CompanyID = @PropertyId),
	(SELECT FaxNo FROM Companies WHERE CompanyID = @PropertyId),(SELECT Telephone1 FROM Companies WHERE CompanyID = @PropertyId),(SELECT Name FROM Locations WHERE Id = @LocationId),
	(SELECT Name FROM CurrencyMasters WHERE Id = @SuppCurrencyID),CONVERT(VARCHAR(10), GETDATE(), 103) AS printeddate , CONVERT(VARCHAR(10), GETDATE(), 108) ,
	(SELECT Address1 FROM Suppliers WHERE id = @SuppId),(SELECT Email FROM Suppliers WHERE id = @SuppId),(SELECT Telephone1 FROM Suppliers WHERE id = @SuppId),
	(SELECT Address1 FROM Companies WHERE CompanyID = @PropertyId),(SELECT Address2 FROM Companies WHERE CompanyID = @PropertyId),
	(SELECT Address3 FROM Companies WHERE CompanyID = @PropertyId),(SELECT PoNo FROM PoHeaders WHERE Id = @ReferenceID),'This is a system generated document',
	(SELECT CASE WHEN @ReferenceID = 0 THEN @DelAdd ELSE (SELECT PH.DeliveryAddressID FROM PoHeaders PH WHERE PH.Id = @ReferenceID) END)
	 FROM #TempGrN

	            SELECT  SH.StockItemCode ,
                    SH.Name ,
                    --FORMAT(STD.Quantity, '#,0.') AS Quantity ,
					FORMAT(STD.Quantity, '#,0.') AS SystemQuantity,
					FORMAT(SD.QuantityInHand, '#,0.') AS PhysicalQuantity,
					STD.Quantity as xx,
					SD.QuantityInHand,
					FORMAT((STD.Quantity - SD.QuantityInHand), '#,0.') AS Variance,
                    CAST(CONVERT(VARCHAR, CAST(STD.UnitPrice AS MONEY), 1) AS VARCHAR) AS UnitPrice ,
                    CAST(CONVERT(VARCHAR, CAST(0 AS MONEY), 1) AS VARCHAR) AS TaxAmount ,
                   ( CONVERT(VARCHAR(10), STD.DiscountPercentage) + '%' )   AS discont ,
                    U.Name AS 'UnitName' ,
                  CAST(CONVERT(VARCHAR, CAST(15897566 AS MONEY), 1) AS VARCHAR)  netammount ,
                    CAST(CONVERT(VARCHAR, CAST(( STD.Quantity * STD.UnitPrice ) AS MONEY), 1) AS VARCHAR) AS grossAmmount ,
					STD.Quantity,
				   SIE.EXPDate,
				   STD.Remarks,
				   CAST(CONVERT(DECIMAL(18,2),ST.Temperature) AS VARCHAR(MAX)) + CASE WHEN ST.TypeId = 1 THEN 'C' ELSE 'F' END AS 'Temperature' 
				   INTO #TempQtyData				
				   
            FROM    #TempGrNDetails AS STD
                    INNER JOIN dbo.StockItemHeaders AS SH ON STD.StockItemID = SH.Id
					INNER JOIN StockItemDetails SD ON SH.Id = SD.StockItemHeaderID AND SD.LocationID = @LocationId
                    INNER JOIN dbo.Units AS U ON STD.TxnUnitID = U.Id
					LEFT JOIN #TempGrNDetailsExp SIE ON  SH.Id = SIE.StockItemID
					LEFT JOIN #TempGrNDetailsTemp ST ON ST.StockItemID = SH.Id


	SELECT * FROM #HeaderData
	SELECT  * FROM #TempQtyData
	----------------------------------------------------
	   INSERT  INTO #ReportSummery
                    ( Description ,
                      amount ,
                      factor
                    )
                    SELECT  'Gross Amount' ,
                            SUM(Quantity * UnitPrice) ,
                            1
                    FROM    #TempGrNDetails

             INSERT  INTO #ReportSummery
                    ( Description ,
                      amount ,
                      factor
                    )
                    SELECT  'Discount' ,
                            SUM(sd.DiscountValue+(sd.UnitPrice*sd.DiscountPercentage/100)*sd.Quantity) ,
                            -1
                    FROM    #TempGrNDetails sd

			SELECT * INTO #TempGrNDetailsCopy FROM #TempGrNDetails

			DECLARE @ItemTotal DECIMAL(18,6),@StockItemID INT,@Qty DECIMAL(18,6)
				CREATE TABLE #TaxTable
				(
					TaxTypeId INT,
					TaxValue DECIMAL(18,6)
				);

				CREATE TABLE #StockTransactionwiseTaxes(
					StockItemID INT,
					TaxTypeID INT,
					TaxAmount DECIMAL(18,6)
				)
		WHILE(SELECT COUNT(*) FROM #TempGrNDetailsCopy)	 > 0
		BEGIN
			  SELECT TOP(1) @ItemTotal =  ROUND((UnitPrice - CASE WHEN DiscountValue>0 THEN ( DiscountValue / Quantity) ELSE UnitPrice * DiscountPercentage /100 END ),2) FROM #TempGrNDetailsCopy
			  SELECT TOP(1) @StockItemID = StockItemID  FROM #TempGrNDetailsCopy 
			  SELECT TOP(1) @Qty = Quantity  FROM #TempGrNDetailsCopy 

			  
				INSERT INTO #TaxTable
				EXEC [SP_Select_StockItemWiseTaxAmount] @StockItemID, @ItemTotal,@suppId;

				INSERT INTO #StockTransactionwiseTaxes
						(
						
							StockItemID,
							TaxTypeID,
							TaxAmount
						)
						SELECT 
							   @StockItemID,
							   TaxTypeId,
							   ROUND(TaxValue * @Qty,2)
						FROM #TaxTable;
						DELETE FROM #TaxTable;
						DELETE TOP(1) FROM #TempGrNDetailsCopy
		END

		
			       INSERT  INTO #ReportSummery
                    ( Description ,
                      amount ,
                      factor
                    )
                    SELECT  'Tax -' + td.Name ,
                            SUM(tt.TaxAmount) ,
                            1
                    FROM    #StockTransactionwiseTaxes tt
                            INNER JOIN #TempGrNDetails g ON G.stockitemid = tt.StockItemID
                            INNER JOIN dbo.TaxDetails td ON td.TaxTypeId = tt.TaxTypeID
                   
                    GROUP BY td.Name


            INSERT  INTO #ReportSummery
                    ( Description ,
                      amount
                    )
                    SELECT  'Net Total' ,
                            SUM(amount * factor)
                    FROM    #ReportSummery

			

            SELECT  id ,
                    Description ,
                    CAST(CONVERT(VARCHAR, CAST(amount AS MONEY), 1) AS VARCHAR) AS amount ,
                    factor
            FROM    #ReportSummery
            ORDER BY id
	----------------------------------------------------
	SELECT  *  FROM  PrintReportTitles  WHERE   TransactionType = 3
	SELECT  Description
    FROM    dbo.SignaturesReportModels
    WHERE   TransactionID = 3
    ORDER BY OrderNum

	SELECT  *  FROM  #TempPOApproval
	SELECT  *  FROM  #TempApproval
	SELECT  *  FROM  #TempPRApprovalForPO

	   

		


END

GO

