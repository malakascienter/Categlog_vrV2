CREATE PROCEDURE [dbo].[SP_ReportDocumentPrint]  --72,1,5 --182,1,6 
    @HeaderID INT ,
    @userid INT ,
    @TransactionType INT
AS
BEGIN
BEGIN TRY

	DECLARE @RefNoAsGRN VARCHAR(200), @GRNno VARCHAR(200), @GRNWiseInvoiceNo VARCHAR(200), @CompanyId INT, @IsCentrallogn BIT

	DECLARE @UserData TABLE(
	Id INT,
	UserName NVARCHAR(200)
	)

    IF ( @TransactionType = '3'
		 OR @TransactionType = '4'
         OR @TransactionType = '5'
         OR @TransactionType = '6'
		 OR @TransactionType = '7'
         OR @TransactionType = '13'
		 OR @TransactionType = '53'
		 OR @TransactionType = '10'
       )
        BEGIN

		SELECT @RefNoAsGRN = ReferenceID FROM  StockTransactionHeaders WHERE Id = @HeaderID
		SELECT @GRNno = DocumentNo FROM  StockTransactionHeaders WHERE Id = @RefNoAsGRN
		SELECT @GRNWiseInvoiceNo = ReferenceNo  FROM  StockTransactionHeaders WHERE Id = @RefNoAsGRN
		 
            SELECT TOP(1) H.Id ,
                    CONVERT(VARCHAR(10), H.TransactionDate, 103) AS TransactionDate ,
                    H.ReferenceNo AS ReferenceDocument ,
                    TT.DocumentTitle ,
                    H.DocumentNo ,
                    C.Name AS 'CompanyName' ,
					C.Email,
					C.FaxNo,
					C.Telephone1,
                    S.Name AS 'SupplierName' ,
                    S.Code AS suppliercode ,
                    L.Name AS 'LocationName' ,
                    CM.Name AS 'SupplyCurrency' ,
                    ( CASE WHEN ( H.IsPrint = 1 ) THEN 'DUPLICATE'
                           ELSE 'ORIGINAL'
                      END ) AS 'Printed' ,
                    'ACCEPTED' AS 'ACCEPTED' ,
                    CONVERT(VARCHAR(10), GETDATE(), 103) AS printeddate ,
                    CONVERT(VARCHAR(10), GETDATE(), 108) AS printedtime ,
                    '' usename ,
                    S.Address1 AS supplieradd ,
					S.Email AS SuppEmail,
					S.Telephone1 AS SuppTelephone1,
                    C.Address1 ,
                    C.Address2 ,
                    C.Address3 ,
                    H.Remarks ,
                    TL.Name AS TransferLocationName ,
                    H.LocationID,
					D.Name AS DepartmentName,
					PH.PoNo,
					@GRNno AS GRN,
					@GRNWiseInvoiceNo AS GRNWiseInvoice,
					'This is a system generated document' AS Word1,
					--PH.DeliveryAddressID AS DeliveryAddress
					CASE WHEN (PH.DeliveryAddressID) IS NULL THEN DAD.Address ELSE PH.DeliveryAddressID END AS DeliveryAddress
					--CASE WHEN PH.DeliveryAddressID AS DeliveryAddress IS NULL DAD.Address ELSE PH.DeliveryAddressID  END AS DeliveryAddress
            FROM    dbo.StockTransactionHeaders AS H
                    INNER JOIN dbo.Companies AS C ON H.PropertyID = C.CompanyID
                    LEFT OUTER JOIN dbo.Suppliers AS S ON H.SupplierID = S.ID
                    INNER JOIN dbo.Locations AS L ON H.LocationID = L.Id
                    LEFT OUTER JOIN dbo.Locations AS TL ON H.TransferLocationID = TL.Id
                    INNER JOIN dbo.TransactionTypes AS TT ON H.TransactionType = TT.Code
                    LEFT OUTER JOIN dbo.CurrencyMasters AS CM ON H.SuppCurrencyID = CM.Id
					LEFT JOIN Departments D ON D.Id = H.DepartmentID
					LEFT JOIN PoHeaders PH ON PH.id = H.ReferenceID
					LEFT JOIN DeliveryAddressDetails DAD ON DAD.PropertyID = H.PropertyID 
            WHERE   H.Id = @HeaderID

            SELECT  SH.StockItemCode ,
                    SH.Name ,
                    --FORMAT(STD.Quantity, '#,0.') AS Quantity ,
					FORMAT(STD.StockMasterQuantity, '#,0.') AS SystemQuantity,
					FORMAT(STD.Quantity, '#,0.') AS PhysicalQuantity,
					FORMAT((STD.Quantity - STD.StockMasterQuantity), '#,0.') AS Variance,
                    CAST(CONVERT(VARCHAR, CAST(STD.UnitPrice AS MONEY), 1) AS VARCHAR) AS UnitPrice ,
                    CAST(CONVERT(VARCHAR, CAST(0 AS MONEY), 1) AS VARCHAR) AS TaxAmount ,
                    CASE WHEN @TransactionType='53' THEN FORMAT(STD.StockMasterQuantity, '#,0.') ELSE   ( CONVERT(VARCHAR(10), STD.DiscountPercentage) + '%' )  END AS discont ,
                    U.Name AS 'UnitName' ,
                   CASE WHEN @TransactionType='53' THEN  FORMAT(STD.NewQuantity, '#,0.')  ELSE CAST(CONVERT(VARCHAR, CAST(15897566 AS MONEY), 1) AS VARCHAR) end AS netammount ,
                    CAST(CONVERT(VARCHAR, CAST(( STD.Quantity * STD.UnitPrice ) AS MONEY), 1) AS VARCHAR) AS grossAmmount ,
                   CASE WHEN @TransactionType='53' THEN CASE WHEN STD.txntype='P' THEN '(+)' ELSE '(-)'  END +CAST(CONVERT(VARCHAR, CAST(STD.Quantity AS MONEY), 1) AS VARCHAR) else CAST(CONVERT(VARCHAR, CAST(STD.Quantity AS MONEY), 1) AS VARCHAR)  end AS Quantity,
				   SIE.EXPDate,
				   STD.Remarks AS ItemRemarks,
				   STD.Remarks,
				   CAST(CONVERT(DECIMAL(18,2),ST.Temperature) AS VARCHAR(MAX)) + CASE WHEN ST.TypeId = 1 THEN 'C' ELSE 'F' END AS 'Temperature' ,
				   STD.AccName
				   INTO #TempQtyData				
				   
            FROM    dbo.StockTransactionDetails AS STD
                    LEFT OUTER JOIN dbo.StockItemHeaders AS SH ON STD.StockItemID = SH.Id
                    INNER JOIN dbo.Units AS U ON STD.TxnUnitID = U.Id
					LEFT JOIN dbo.StockTransactionHeaders STH ON STH.Id = STD.StockTransactionHeaderID
					LEFT JOIN StockItemWiseEXPDateIns SIE ON SIE.TransactionID = STH.Id AND SIE.LocationID = STH.LocationID 
					AND SIE.TransactionType = STH.TransactionType AND SH.Id = SIE.StockItemID
					LEFT JOIN StockItemWiseTemperature ST ON ST.StockItemID = SH.Id
--INNER JOIN dbo.StockTransactionwiseTaxes AS ta ON std.StockItemID = ta.StockItemID AND ta.StockTransactionDetailID = STD.Id
            WHERE   StockTransactionHeaderID = @HeaderID

			--select * from #TempQtyData

			  SELECT * FROM  #TempQtyData
			  WHERE CAST(Quantity AS MONEY) > 0;
 
            CREATE TABLE #ReportSummery
                (
                  id INT IDENTITY(1, 1) ,
                  Description VARCHAR(100) ,
                  amount MONEY ,
                  factor INT
                )

				IF(@TransactionType<>6)
				BEGIN

            INSERT  INTO #ReportSummery
                    ( Description ,
                      amount ,
                      factor
                    )
                    SELECT  'Gross Amount' ,
                            SUM(Quantity * UnitPrice) ,
                            1
                    FROM    dbo.StockTransactionDetails
                    WHERE   StockTransactionHeaderID = @HeaderID

             INSERT  INTO #ReportSummery
                    ( Description ,
                      amount ,
                      factor
                    )
                    SELECT  'Discount' ,
                            SUM(sd.DiscountValue+(sd.UnitPrice*sd.DiscountPercentage/100)*sd.Quantity) ,
                            -1
                    FROM    dbo.StockTransactionDetails sd
                    WHERE   sd.StockTransactionHeaderID = @HeaderID

            INSERT  INTO #ReportSummery
                    ( Description ,
                      amount ,
                      factor
                    )
                    SELECT  'Tax -' + td.Name ,
                            SUM(tt.TaxAmount) ,
                            1
                    FROM    dbo.StockTransactionwiseTaxes tt
                            INNER JOIN dbo.StockTransactionDetails sd ON sd.Id = tt.StockTransactionDetailID
                                                              AND sd.StockItemID = tt.StockItemID
                            INNER JOIN dbo.TaxDetails td ON td.TaxTypeId = tt.TaxTypeID
                    WHERE   sd.StockTransactionHeaderID = @HeaderID
                    GROUP BY td.Name


           
		   -----------Added 7/12/2021---------
							IF(@TransactionType = 3)
                            INSERT  INTO #ReportSummery
                                    ( Description ,
                                      amount ,
                                      factor
                                    )
                                    SELECT  'Additional Charges' ,
                                           ROUND((SUM(sd.ChargeAmount)),2) ,
                                            1
                                    FROM    StockTransactionwiseCharges sd
                                    WHERE   sd.StockTransactionHeaderID = @HeaderID
							-----------Added 7/12/2021---------



 

            INSERT  INTO #ReportSummery
                    ( Description ,
                      amount
                    )
                    SELECT  'Net Total' ,
                            SUM(amount * factor)
                    FROM    #ReportSummery
              END
			  ELSE
			  BEGIN
			   INSERT  INTO #ReportSummery
                    ( Description ,
                      amount ,
                      factor
                    )
                    SELECT  'Total' ,
                            SUM(Quantity * UnitPrice) ,
                            1
                    FROM    dbo.StockTransactionDetails
                    WHERE   StockTransactionHeaderID = @HeaderID
			  end 

            SELECT  id ,
                    Description ,
                    CAST(CONVERT(VARCHAR, CAST(amount AS MONEY), 1) AS VARCHAR) AS amount ,
                    factor
            FROM    #ReportSummery
            ORDER BY id

            SELECT  *
            FROM    PrintReportTitles
            WHERE   TransactionType = @TransactionType


            SELECT  Description
            FROM    dbo.SignaturesReportModels
            WHERE   TransactionID = @TransactionType
            ORDER BY OrderNum

			

        END


    ELSE

        IF ( @TransactionType = '1'
             OR @TransactionType = '8'
             OR @TransactionType = '11'
             OR @TransactionType = '14'
           )
            BEGIN

			SELECT @CompanyId = PropertyID FROM RequestHeaders WHERE Id = @HeaderID
			SELECT @IsCentrallogn = IsCentralLogin FROM Companies WHERE  CompanyID = @CompanyId

			IF(@IsCentrallogn = 1)
			BEGIN
				INSERT INTO @UserData
				SELECT Id, UserName
				FROM [dbo].[CentralUsers]
			END
			ELSE
			BEGIN
				INSERT INTO @UserData
				SELECT Id, UserName
				FROM UserMasters
			END

                SELECT  H.Id ,
                        CONVERT(VARCHAR(10), H.RequestDate, 103) AS TransactionDate ,
                        H.DocumentNo ,
						 CONVERT(VARCHAR(10), H.DeliveryDate, 103) AS DeliveryDate ,
						 H.Remarks,
                        ( CASE WHEN ( @TransactionType = '8'
                                      OR @TransactionType = '14'
									  OR @TransactionType = '11'
                                    ) THEN L.Name
                               ELSE D.Name
                          END ) AS LocationName ,
                        ( CASE WHEN ( @TransactionType = '8' ) THEN TL.Name
                               ELSE ''
                          END ) AS TransferLocationName ,
                        C.Name AS CompanyName ,
						C.Email,
						C.FaxNo,
						C.Telephone1,
						C.Address1,
						C.Address2,
						C.Address3,
                        U.UserName AS RequestBy ,
                        ( CASE WHEN ( H.Isprint = 1 ) THEN 'DUPLICATE'
                               ELSE 'ORIGINAL'
                          END ) AS 'Printed' ,
                        ( CASE WHEN ( H.IsApproved = 1 ) THEN 'ACCEPTED'
                               ELSE 'PENDING'
                          END ) AS 'ACCEPTED' ,
                        CONVERT(VARCHAR(10), GETDATE(), 103) AS printeddate ,
                        CONVERT(VARCHAR(10), GETDATE(), 108) AS printedtime ,
                        '' usename ,
                        TT.Name AS DocumentTitle,
						D.Name AS DepartmentName,
						'This is a system generated document' AS Word1
                FROM    dbo.RequestHeaders AS H
                        INNER JOIN dbo.Companies AS C ON H.PropertyID = C.CompanyID
                        LEFT OUTER JOIN dbo.Locations AS L ON H.LocationID = L.Id
                        LEFT OUTER JOIN dbo.Locations AS TL ON H.TransferLocation = TL.Id
                        LEFT OUTER JOIN dbo.Departments AS D ON H.DepartmentID = D.Id
                        INNER JOIN @UserData AS U ON H.UserProfileID = U.Id
                        INNER JOIN dbo.TransactionTypes AS TT ON H.TransactionTypeCode = TT.Id
                WHERE   H.Id = @HeaderID
				
--SELECT SH.StockItemCode, SH.Name, CAST(CONVERT(varchar, CAST(SD.AveragePrice AS MONEY), 1) AS varchar) AS UnitPrice, 
--CAST(CONVERT(varchar, CAST(D.RequestedQuantity AS MONEY), 1) AS varchar) AS Quantity, 
--CAST(CONVERT(varchar, CAST((SD.AveragePrice*D.RequestedQuantity) AS MONEY), 1) AS varchar) AS GrossAmmount,
--u.Name AS 'UnitName'
--FROM dbo.RequestDetails AS D
--INNER JOIN dbo.StockItemHeaders AS SH ON D.StockItemID = SH.Id
--INNER JOIN dbo.StockItemDetails AS SD ON SH.Id = SD.StockItemHeaderID AND SH.CompanyId = SD.CompanyID AND SH.LocationId = SD.LocationID
--INNER JOIN dbo.Units AS u ON sd.MasterUnitID = u.Id
--WHERE D.RequestHeaderID = @HeaderID


                SELECT  SH.StockItemCode ,
                        SH.Name ,
                        --CAST(CONVERT(VARCHAR, CAST(SD.AveragePrice AS MONEY), 1) AS VARCHAR) AS UnitPrice ,
						CAST(CONVERT(VARCHAR, CAST(D.UnitPrice AS MONEY), 1) AS VARCHAR) AS UnitPrice  ,
                       CASE WHEN R.IsApproved = 0 THEN CAST(CONVERT(VARCHAR, CAST(D.RequestedQuantity AS MONEY), 1) AS VARCHAR)
					   ELSE  CAST(CONVERT(VARCHAR, CAST(D.ApprovedQuantity AS MONEY), 1) AS VARCHAR) END  AS Quantity ,
						--CAST(CONVERT(VARCHAR, CAST(D.ApprovedQuantity AS MONEY), 1) AS VARCHAR) AS ApprovedQty ,
                       CASE WHEN R.IsApproved = 0 THEN CAST(CONVERT(VARCHAR, CAST(( D.UnitPrice
                         * D.RequestedQuantity ) AS MONEY), 1) AS VARCHAR) ELSE CAST(CONVERT(VARCHAR, CAST(( D.UnitPrice
                         * D.ApprovedQuantity ) AS MONEY), 1) AS VARCHAR)  END AS GrossAmmount ,
                        u.Name AS 'UnitName',
						D.Remarks,
						SD.QuantityInHand AS CurrentStockBalance
                FROM    dbo.RequestDetails AS D
                        INNER JOIN dbo.RequestHeaders R ON R.Id = D.RequestHeaderID
                        INNER JOIN dbo.StockItemHeaders AS SH ON D.StockItemID = SH.Id
                        INNER JOIN dbo.StockItemDetails AS SD ON SH.Id = SD.StockItemHeaderID
                                                              AND SH.CompanyId = SD.CompanyID
                                                              AND R.LocationID = SD.LocationID
                        INNER JOIN dbo.Units AS u ON d.UnitID = u.Id
                WHERE   D.RequestHeaderID = @HeaderID

                CREATE TABLE #ReportSummeryr
                    (
                      id INT IDENTITY(1, 1) ,
                      Description VARCHAR(100) ,
                      amount MONEY ,
                      factor INT
                    )

                --INSERT  INTO #ReportSummeryr
                --        ( Description, amount, factor )
                --VALUES  ( 'a', 1, 1 )

                --SELECT  id ,
                --        Description ,
                --        CAST(CONVERT(VARCHAR, CAST(amount AS MONEY), 1) AS VARCHAR) AS amount ,
                --        factor
                --FROM    #ReportSummeryr

				INSERT  INTO #ReportSummeryr
                    ( Description ,
                      amount ,
                      factor
                    )
                    SELECT  'Total' ,
                            SUM((CASE WHEN RequestHeaders.IsApproved = 0 THEN RequestedQuantity ELSE ApprovedQuantity END) * UnitPrice) ,
                            1
                    FROM    dbo.RequestDetails
					INNER JOIN RequestHeaders ON RequestHeaders.Id = RequestDetails.RequestHeaderID
                    WHERE   RequestHeaderID = @HeaderID
			   

            SELECT  id ,
                    Description ,
                    CAST(CONVERT(VARCHAR, CAST(amount AS MONEY), 1) AS VARCHAR) AS amount ,
                    factor
            FROM    #ReportSummeryr
            ORDER BY id

                SELECT  *
                FROM    PrintReportTitles
                WHERE   TransactionType = @TransactionType


                SELECT  Description
                FROM    dbo.SignaturesReportModels
                WHERE   TransactionID = @TransactionType
                ORDER BY OrderNum
            END

        ELSE
            IF ( @TransactionType = '-999' )
                BEGIN 

				
			SELECT @CompanyId = PropertyID FROM InvoiceHeaders WHERE Id = @HeaderID
			SELECT @IsCentrallogn = IsCentralLogin FROM Companies WHERE  CompanyID = @CompanyId

			IF(@IsCentrallogn = 1)
			BEGIN
				INSERT INTO @UserData
				SELECT Id, UserName
				FROM [dbo].[CentralUsers]
			END
			ELSE
			BEGIN
				INSERT INTO @UserData
				SELECT Id, UserName
				FROM UserMasters
			END
				
				DECLARE @Mode INT 
				SELECT @Mode=InvoiceMode FROM dbo.InvoiceHeaders WHERE ID=@HeaderID

				IF(@Mode=1)
				BEGIN


				 DECLARE @UserName VARCHAR(MAX)

				  SELECT  
                            @UserName=U.UserName 
                           
                    FROM    dbo.InvoiceHeaders H
                         
                            LEFT OUTER JOIN @UserData U ON U.Id = H.UserID                          
                    WHERE   H.ID = @HeaderID		
                    


                    SELECT  H.ID ,
                            CONVERT(VARCHAR(10), H.InvoiceDate, 103) AS TransactionDate ,
                            ( CASE WHEN ( C.IsVat = 0 ) THEN ''
                                   ELSE H.VATNo
                              END ) AS ReferenceDocument ,							
						--	H.VATNo AS ReferenceDocument,
                            H.InvoiceNo AS DocumentNo ,
                            L.Name AS LocationName ,
                            SP.SalesPersonName AS TransferLocationName ,
                            CM.Name AS CompanyName ,
							CM.Email,
							CM.FaxNo,
							CM.Telephone1,
                            C.Code+'/'+H.CustomerName+' (Tel:'+C.Tele1+')' AS 'SupplierName' ,
                            U.UserName AS RequestBy ,
                            ( CASE WHEN ( H.IsPrint = 1 ) THEN 'DUPLICATE'
                           ELSE 'ORIGINAL'
                      END ) AS 'Printed' ,
                            '' AS 'ACCEPTED' ,
                            CONVERT(VARCHAR(10), GETDATE(), 103) AS printeddate ,
                            CONVERT(VARCHAR(10), GETDATE(), 108) AS printedtime ,
                            '' usename ,
                    case when H.InvoiceMode = 2 then 'SALES RETURN NOTE' else  (case when   ( C.IsVat = 0 )   then 'INVOICE' else 'TAX INVOICE  ' end) end AS DocumentTitle,	
							C.AddLine1+ CASE WHEN C.AddLine2='' THEN '' ELSE ','+C.AddLine2 END +CASE WHEN C.AddLine3='' THEN '' ELSE ','+C.AddLine3 END  AS supplieradd				
                                                   
                    FROM    dbo.InvoiceHeaders H
                            LEFT OUTER JOIN dbo.Locations L ON L.Id = H.Location
                            LEFT OUTER JOIN @UserData U ON U.Id = H.UserID
                            LEFT OUTER JOIN dbo.Customers C ON C.Id = H.CustomerID
                            LEFT OUTER JOIN dbo.Companies CM ON CM.CompanyID = H.PropertyID
							left outer join SalesPersons SP on H.SalesPersonID=SP.Id 
                    WHERE   H.ID = @HeaderID					

        
		    DECLARE @LocationID INT
            
			SELECT @LocationID=Location FROM  dbo.InvoiceHeaders WHERE ID=@HeaderID
		
		
		 IF EXISTS ( SELECT  CustomerID
                                FROM     dbo.InvoiceHeaders IH
                                        INNER JOIN dbo.Customers C ON C.Id = IH.CustomerID
                                WHERE   IH.ID = @HeaderID
                                        AND C.IsVat = 1 )
					BEGIN
					
					SELECT  SH.StockItemCode ,
                            SH.Name ,
                            CAST(CONVERT(VARCHAR, CAST(ID.UnitPrice AS MONEY), 1) AS VARCHAR) AS UnitPrice ,
                            CAST(CONVERT(VARCHAR, CAST(ID.QTY AS MONEY), 1) AS VARCHAR) AS Quantity ,
							CASE WHEN ID.IsPercentageForDiscount=1 THEN CAST(CONVERT(VARCHAR, CAST(ID.ItemDiscountPercentage AS MONEY), 1) AS VARCHAR)+'%' ELSE  CAST(CONVERT(VARCHAR, CAST(ID.UnitPrice-ID.CostPrice AS MONEY), 1) AS VARCHAR) end AS discont,
                            CAST(CONVERT(VARCHAR, CAST(( ID.UnitPrice * ID.QTY ) AS MONEY), 1) AS VARCHAR) AS GrossAmmount ,
                            UN.Name AS 'UnitName'
                    FROM    dbo.InvoiceDetails ID
                            LEFT OUTER JOIN dbo.StockItemHeaders SH ON ID.ItemID = SH.Id
                            LEFT OUTER JOIN dbo.Units UN ON UN.Id = ID.UnitID
                    WHERE   ID.InvoiceHeaderID = @HeaderID          

                    

					END
					

					ELSE
                    BEGIN

					SELECT  SH.StockItemCode ,
                            SH.Name ,
                            CAST(CONVERT(VARCHAR, CAST(
							CASE WHEN (SELECT  dbo.FN_GetActualPriceWithoutTax(SD.SellingPrice,
                                                              SH.TaxGroupID))<>ID.UnitPrice THEN ID.UnitPrice+ID.TaxForSellPrice 

															  ELSE 

															 SD.SellingPrice 

															 END AS MONEY
                            
							
							
							), 1) AS VARCHAR) AS UnitPrice ,
                            CAST(CONVERT(VARCHAR, CAST(ID.QTY AS MONEY), 1) AS VARCHAR) AS Quantity ,
							CASE WHEN ID.IsPercentageForDiscount=1 THEN CAST(CONVERT(VARCHAR, CAST(ID.ItemDiscountPercentage AS MONEY), 1) AS VARCHAR)+'%' ELSE  CAST(CONVERT(VARCHAR, CAST(ID.ItemDiscountValue AS MONEY), 1) AS VARCHAR) end AS discont,
                            CAST(CONVERT(VARCHAR, CAST(( CASE WHEN (SELECT  dbo.FN_GetActualPriceWithoutTax(SD.SellingPrice,
                                                              SH.TaxGroupID))<>ID.UnitPrice THEN ID.UnitPrice+ID.TaxForSellPrice 

															  ELSE 

															 SD.SellingPrice 

															 END * ID.QTY ) AS MONEY), 1) AS VARCHAR) AS GrossAmmount ,
                            UN.Name AS 'UnitName'
                    FROM    dbo.InvoiceDetails ID
                            LEFT OUTER JOIN dbo.StockItemHeaders SH ON ID.ItemID = SH.Id
                            LEFT OUTER JOIN dbo.Units UN ON UN.Id = ID.UnitID
							LEFT OUTER JOIN dbo.StockItemDetails SD ON SD.StockItemHeaderID=SH.Id
                    WHERE   ID.InvoiceHeaderID = @HeaderID AND SD.LocationID=@LocationID
					


					END
                    
                    





                    CREATE TABLE #ReportSummery1
                        (
                          id INT IDENTITY(1, 1) ,
                          Description VARCHAR(MAX) ,
                          amount VARCHAR(MAX) ,
                          factor INT
                        )

                   

                    IF EXISTS ( SELECT  CustomerID
                                FROM    dbo.InvoiceHeaders IH
                                        INNER JOIN dbo.Customers C ON C.Id = IH.CustomerID
                                WHERE   IH.ID = @HeaderID
                                        AND C.IsVat = 1 )
                        BEGIN


						 INSERT  INTO #ReportSummery1
                            ( Description ,
                              amount ,
                              factor
                            )
                            SELECT  'Gross Amount' ,
                                    ROUND((SUM(ID.UnitPrice*QTY)),2) ,
                                    1
                            FROM    dbo.InvoiceDetails ID
							
                            WHERE   ID.InvoiceHeaderID = @HeaderID 

							 INSERT  INTO #ReportSummery1
                                    ( Description ,
                                      amount ,
                                      factor
                                    )
                                    SELECT  'Discount' ,
                                            ROUND((SUM(sd.TotalDiscount)),2),
                                            -1
                                    FROM    dbo.InvoiceHeaders sd
                                    WHERE   sd.ID = @HeaderID

                            INSERT  INTO #ReportSummery1
                                    ( Description ,
                                      amount ,
                                      factor
                                    )
                                    SELECT  'Tax' ,
                                            ROUND((SUM(tt.TaxValue*tt.QTY)),2) ,
                                            1
                                    FROM    dbo.InvoiceDetails tt
                                    WHERE   tt.InvoiceHeaderID = @HeaderID

                          

                            INSERT  INTO #ReportSummery1
                                    ( Description ,
                                      amount
                                    )
                                    SELECT  'Net Total' ,
                                            ROUND(NetTotal,2)
                                    FROM    dbo.InvoiceHeaders
                                    WHERE   ID = @HeaderID
                        END 


                    ELSE
                        BEGIN
						   INSERT  INTO #ReportSummery1
                            ( Description ,
                              amount ,
                              factor
                            )
                            SELECT  'Gross Amount' ,
                                    ROUND((SUM((ID.UnitPrice+ID.TaxForSellPrice)*QTY)),2) ,
                                    1
                            FROM    dbo.InvoiceDetails ID
							INNER JOIN dbo.StockItemDetails SD 
							ON SD.StockItemHeaderID=ID.ItemID						
                            WHERE   ID.InvoiceHeaderID = @HeaderID AND SD.LocationID=@LocationID 

                            INSERT  INTO #ReportSummery1
                                    ( Description ,
                                      amount ,
                                      factor
                                    )
                                    SELECT  'Discount' ,
                                           ROUND((SUM(sd.totalprintdiscount)),2) ,
                                            -1
                                    FROM    dbo.InvoiceHeaders sd
                                    WHERE   sd.ID = @HeaderID
							

                            INSERT  INTO #ReportSummery1
                                    ( Description ,
                                      amount
                                    )
                                    SELECT  'Net Total' ,
                                            ROUND(NetTotal,2)
                                    FROM    dbo.InvoiceHeaders
                                    WHERE   ID = @HeaderID



                        END

						 INSERT  INTO #ReportSummery1
                                    ( Description ,
                                      amount
                                    )
								SELECT '',''

								 INSERT  INTO #ReportSummery1
                                    ( Description ,
                                      amount
                                    )
								SELECT '',''
								INSERT  INTO #ReportSummery1
                                    ( Description ,
                                      amount
                                    )
								SELECT '',''

								 INSERT  INTO #ReportSummery1
                                    ( Description ,
                                      amount
                                    )
								SELECT 'SETTLEMENTS',''

								INSERT  INTO #ReportSummery1
                                    ( Description ,
                                      amount
                                    )
								SELECT '',''

								 INSERT  INTO #ReportSummery1
                                    ( Description ,
                                      amount
                                    )
								SELECT '',''

								 INSERT  INTO #ReportSummery1
                                    ( Description ,
                                      amount
                                    )
								SELECT '',''

						 INSERT  INTO #ReportSummery1
                                    ( Description ,
                                      amount
                                    )

						
						SELECT P.Description,SUM(ROUND(IPD.TenderedAmount,2)) FROM dbo.InvoicePaymentsDetails IPD INNER JOIN dbo.PaymentTypes P ON P.Id=IPD.PaymentTypeID WHERE InvoiceHeaderID=@HeaderID GROUP BY P.Description

					 
	

						 DECLARE @total MONEY
						 INSERT  INTO #ReportSummery1
                                    ( Description ,
                                      amount
                                    )
						SELECT 'Accepted Amount',ROUND((SUM(TenderedAmount)),2) FROM dbo.InvoicePaymentsDetails WHERE dbo.InvoicePaymentsDetails.InvoiceHeaderID=@HeaderID


					    DECLARE @CustomerID INT,@ISVat BIT

		                SELECT @CustomerID=CustomerID FROM dbo.InvoiceHeaders WHERE ID=@HeaderID

		                SELECT @ISVat=IsVat FROM dbo.Customers WHERE Id=@CustomerID

		                IF(@ISVat=1)
						BEGIN

						SELECT @total=NetTotal FROM dbo.InvoiceHeaders WHERE ID=@HeaderID

						END

						ELSE

                        BEGIN

						SELECT @total=NetTotal FROM dbo.InvoiceHeaders WHERE ID=@HeaderID

						END
                        

						INSERT  INTO #ReportSummery1
                                    ( Description ,
                                      amount
                                    )
						SELECT 'Balance Amount',ABS(ROUND((@total-(SUM(TenderedAmount))),2)) FROM dbo.InvoicePaymentsDetails WHERE dbo.InvoicePaymentsDetails.InvoiceHeaderID=@HeaderID

		

									
								
                    SELECT  id ,
                            Description ,
                            (CASE WHEN
                            amount='' THEN amount
							ELSE 
							CAST(CONVERT(VARCHAR, CAST(amount AS MONEY), 1) AS VARCHAR) 
							END 
							) AS amount,
                            factor
                    FROM    #ReportSummery1
                    ORDER BY id

                    SELECT  *
                    FROM    PrintReportTitles
                    WHERE   TransactionType = -999


                    SELECT  Description
                    FROM    dbo.SignaturesReportModels
                    WHERE   TransactionID = 3
                    ORDER BY OrderNum


                END

				ELSE 

				BEGIN

				-- DECLARE @UserName VARCHAR(MAX)

				  SELECT  
                            @UserName=U.UserName 
                           
                    FROM    dbo.InvoiceHeaders H
                         
                            LEFT OUTER JOIN @UserData U ON U.Id = H.UserID                          
                    WHERE   H.ID = @HeaderID		
                    


                    SELECT  H.ID ,
                            CONVERT(VARCHAR(10), H.InvoiceDate, 103) AS TransactionDate ,
                            ( CASE WHEN ( C.IsVat = 0 ) THEN ''
                                   ELSE H.VATNo
                              END ) AS ReferenceDocument ,							
						--	H.VATNo AS ReferenceDocument,
                            H.InvoiceNo AS DocumentNo ,
                            L.Name AS LocationName ,
                            SP.SalesPersonName AS TransferLocationName ,
                            CM.Name AS CompanyName ,
							CM.Email,
							CM.FaxNo,
							CM.Telephone1,
                            C.Code+'/'+H.CustomerName+' (Tel:'+C.Tele1+')' AS 'SupplierName' ,
                            U.UserName AS RequestBy ,
                            ( CASE WHEN ( H.IsPrint = 1 ) THEN 'DUPLICATE'
                           ELSE 'ORIGINAL'
                      END ) AS 'Printed' ,
                            '' AS 'ACCEPTED' ,
                            CONVERT(VARCHAR(10), GETDATE(), 103) AS printeddate ,
                            CONVERT(VARCHAR(10), GETDATE(), 108) AS printedtime ,
                            '' usename ,
                    case when H.InvoiceMode = 2 then 'SALES RETURN NOTE' else  (case when   ( C.IsVat = 0 )   then 'INVOICE' else 'TAX INVOICE  ' end) end AS DocumentTitle,	
							C.AddLine1+ CASE WHEN C.AddLine2='' THEN '' ELSE ','+C.AddLine2 END +CASE WHEN C.AddLine3='' THEN '' ELSE ','+C.AddLine3 END  AS supplieradd				
                                                   
                    FROM    dbo.InvoiceHeaders H
                            LEFT OUTER JOIN dbo.Locations L ON L.Id = H.Location
                            LEFT OUTER JOIN @UserData U ON U.Id = H.UserID
                            LEFT OUTER JOIN dbo.Customers C ON C.Id = H.CustomerID
                            LEFT OUTER JOIN dbo.Companies CM ON CM.CompanyID = H.PropertyID
							left outer join SalesPersons SP on H.SalesPersonID=SP.Id 
                    WHERE   H.ID = @HeaderID					

        
		  --  DECLARE @LocationID INT
            
			SELECT @LocationID=Location FROM  dbo.InvoiceHeaders WHERE ID=@HeaderID
		
		
		 
                   

					SELECT  SH.StockItemCode ,
                            SH.Name ,
                            CAST(CONVERT(VARCHAR, CAST(
							CASE WHEN (SELECT  dbo.FN_GetActualPriceWithoutTax(SD.SellingPrice,
                                                              SH.TaxGroupID))<>ID.UnitPrice THEN ID.UnitPrice+ID.TaxForSellPrice 

															  ELSE 

															 SD.SellingPrice 

															 END AS MONEY
                            
							
							
							), 1) AS VARCHAR) AS UnitPrice ,
                            CAST(CONVERT(VARCHAR, CAST(ID.QTY AS MONEY), 1) AS VARCHAR) AS Quantity ,
							CASE WHEN ID.IsPercentageForDiscount=1 THEN CAST(CONVERT(VARCHAR, CAST(ID.ItemDiscountPercentage AS MONEY), 1) AS VARCHAR)+'%' ELSE  CAST(CONVERT(VARCHAR, CAST(ID.ItemDiscountValue AS MONEY), 1) AS VARCHAR) end AS discont,
                            CAST(CONVERT(VARCHAR, CAST(( CASE WHEN (SELECT  dbo.FN_GetActualPriceWithoutTax(SD.SellingPrice,
                                                              SH.TaxGroupID))<>ID.UnitPrice THEN ID.UnitPrice+ID.TaxForSellPrice 

															  ELSE 

															 SD.SellingPrice 

															 END * ID.QTY ) AS MONEY), 1) AS VARCHAR) AS GrossAmmount ,
                            UN.Name AS 'UnitName'
                    FROM    dbo.InvoiceDetails ID
                            LEFT OUTER JOIN dbo.StockItemHeaders SH ON ID.ItemID = SH.Id
                            LEFT OUTER JOIN dbo.Units UN ON UN.Id = ID.UnitID
							LEFT OUTER JOIN dbo.StockItemDetails SD ON SD.StockItemHeaderID=SH.Id
                    WHERE   ID.InvoiceHeaderID = @HeaderID AND SD.LocationID=@LocationID
					


			
                    
                    





                    CREATE TABLE #ReportSummery11
                        (
                          id INT IDENTITY(1, 1) ,
                          Description VARCHAR(MAX) ,
                          amount VARCHAR(MAX) ,
                          factor INT
                        )

                   

                 


                 
                      
						   INSERT  INTO #ReportSummery11
                            ( Description ,
                              amount ,
                              factor
                            )
                            SELECT  'Gross Amount' ,
                                    ROUND((SUM((ID.UnitPrice+ID.TaxForSellPrice)*QTY)),2) ,
                                    1
                            FROM    dbo.InvoiceDetails ID
							INNER JOIN dbo.StockItemDetails SD 
							ON SD.StockItemHeaderID=ID.ItemID						
                            WHERE   ID.InvoiceHeaderID = @HeaderID AND SD.LocationID=@LocationID 

                            INSERT  INTO #ReportSummery11
                                    ( Description ,
                                      amount ,
                                      factor
                                    )
                                    SELECT  'Discount' ,
                                           ROUND((SUM(sd.totalprintdiscount)),2) ,
                                            -1
                                    FROM    dbo.InvoiceHeaders sd
                                    WHERE   sd.ID = @HeaderID


                            INSERT  INTO #ReportSummery11
                                    ( Description ,
                                      amount
                                    )
                                    SELECT  'Net Total' ,
                                            ROUND(NetTotal,2)
                                    FROM    dbo.InvoiceHeaders
                                    WHERE   ID = @HeaderID





						 INSERT  INTO #ReportSummery11
                                    ( Description ,
                                      amount
                                    )
								SELECT '',''

								 INSERT  INTO #ReportSummery11
                                    ( Description ,
                                      amount
                                    )
								SELECT '',''
								INSERT  INTO #ReportSummery11
                                    ( Description ,
                                      amount
                                    )
								SELECT '',''
								
								 INSERT  INTO #ReportSummery11
                                    ( Description ,
                                      amount
                                    )
								SELECT 'SETTLEMENTS',''

								INSERT  INTO #ReportSummery11
                                    ( Description ,
                                      amount
                                    )
								SELECT '',''

								 INSERT  INTO #ReportSummery11
                                    ( Description ,
                                      amount
                                    )
								SELECT '',''

								 INSERT  INTO #ReportSummery11
                                    ( Description ,
                                      amount
                                    )
								SELECT '',''

						 INSERT  INTO #ReportSummery11
                                    ( Description ,
                                      amount
                                    )

						
						SELECT P.Description,SUM(ROUND(IPD.TenderedAmount,2)) FROM dbo.InvoicePaymentsDetails IPD INNER JOIN dbo.PaymentTypes P ON P.Id=IPD.PaymentTypeID WHERE InvoiceHeaderID=@HeaderID GROUP BY P.Description

					 
	

					
						 INSERT  INTO #ReportSummery11
                                    ( Description ,
                                      amount
                                    )
						SELECT 'Accepted Amount',ROUND((SUM(TenderedAmount)),2) FROM dbo.InvoicePaymentsDetails WHERE dbo.InvoicePaymentsDetails.InvoiceHeaderID=@HeaderID


			

		                

						

                  

						SELECT @total=NetTotal FROM dbo.InvoiceHeaders WHERE ID=@HeaderID

                        

						INSERT  INTO #ReportSummery11
                                    ( Description ,
                                      amount
                                    )
						SELECT 'Balance Amount',ABS(ROUND((@total-(SUM(TenderedAmount))),2)) FROM dbo.InvoicePaymentsDetails WHERE dbo.InvoicePaymentsDetails.InvoiceHeaderID=@HeaderID

		

									
								
                    SELECT  id ,
                            Description ,
                            (CASE WHEN
                            amount='' THEN amount
							ELSE 
							CAST(CONVERT(VARCHAR, CAST(amount AS MONEY), 1) AS VARCHAR) 
							END 
							) AS amount,
                            factor
                    FROM    #ReportSummery11
                    ORDER BY id

                    SELECT  *
                    FROM    PrintReportTitles
                    WHERE   TransactionType = -999


                    SELECT  Description
                    FROM    dbo.SignaturesReportModels
                    WHERE   TransactionID = 3
                    ORDER BY OrderNum



				END 


				END 

				
					
					-----------Added----------------

					SELECT * INTO #TempAllApprovals FROM dbo.ApprovalLogs WHERE TransactionHeaderID = @HeaderID AND TransactionID = @TransactionType

					--SELECT A.* INTO #TempAllApprovals 
					--FROM dbo.ApprovalLogs A
					--INNER JOIN dbo.StockTransactionHeaders SH
					--ON A.TransactionHeaderID = SH.Id AND A.LocationID = SH.LocationID
					--WHERE A.TransactionHeaderID = @HeaderID AND A.TransactionID = @TransactionType

					CREATE TABLE #TempApproval(Id INT IDENTITY(1,1) PRIMARY KEY, Description VARCHAR(250), Value VARCHAR(250))
					CREATE TABLE #TempPOApproval(Id INT IDENTITY(1,1) PRIMARY KEY, Description VARCHAR(250), Value VARCHAR(250)) 
					CREATE TABLE #TempPRApprovalForPO(Id INT IDENTITY(1,1) PRIMARY KEY, Description VARCHAR(250), Value VARCHAR(250)) 
					
					if(@TransactionType = '11')
					BEGIN

					SELECT @CompanyId = PropertyId FROM #TempAllApprovals WHERE ApprovalLogID = @HeaderID
					SELECT @IsCentrallogn = IsCentralLogin FROM Companies WHERE CompanyID = @CompanyId
					
						IF(@IsCentrallogn = 1)
						BEGIN
							INSERT INTO @UserData
							SELECT Id, UserName
							FROM [dbo].[CentralUsers]
						END
						ELSE
						BEGIN
							INSERT INTO @UserData
							SELECT Id, UserName
							FROM UserMasters
						END

					 WHILE (SELECT COUNT(*) FROM #TempAllApprovals) > 0
					 BEGIN
						INSERT INTO #TempApproval VALUES('Approved by :',(SELECT TOP(1) UM.UserName  FROM #TempAllApprovals A 
						INNER JOIN @UserData UM ON A.ApprovalUserID = UM.Id AND A.IsComplete = 1
						WHERE A.TransactionHeaderID = @HeaderID ))
		
						DELETE TOP(1) FROM #TempAllApprovals
					 END 
					 END 

					 IF(@TransactionType = '3')
					 BEGIN

					 	DECLARE @ReferenceId INT
						
						SELECT @CompanyId = PropertyId FROM StockTransactionHeaders WHERE Id = @HeaderID
					    SELECT @IsCentrallogn = IsCentralLogin FROM Companies WHERE CompanyID = @CompanyId
					
						IF(@IsCentrallogn = 1)
						BEGIN
							INSERT INTO @UserData
							SELECT Id, UserName
							FROM [dbo].[CentralUsers]
						END
						ELSE
						BEGIN
							INSERT INTO @UserData
							SELECT Id, UserName
							FROM UserMasters
						END

						SELECT @ReferenceId = ReferenceID FROM dbo.StockTransactionHeaders WHERE Id = @HeaderID AND TransactionID = @TransactionType
						
						SELECT * INTO #TempPOApprovalsFroGRN FROM dbo.ApprovalLogs 
						WHERE TransactionHeaderID = @ReferenceId AND TransactionID = '2'


						 WHILE (SELECT COUNT(*) FROM #TempPOApprovalsFroGRN) > 0
						 BEGIN
							INSERT INTO #TempPOApproval VALUES('PO Approved by :',(SELECT TOP(1) UM.UserName  FROM #TempPOApprovalsFroGRN A 
							INNER JOIN @UserData UM ON A.ApprovalUserID = UM.Id AND A.IsComplete = 1
							WHERE A.TransactionHeaderID = @ReferenceId ))
		
							DELETE TOP(1) FROM #TempPOApprovalsFroGRN

						 END

						INSERT INTO #TempApproval VALUES('Prepared by :',
						(SELECT  UM.UserName  FROM dbo.StockTransactionHeaders A 
						INNER JOIN @UserData UM ON A.UserProfileID = UM.Id
						 WHERE A.Id = @HeaderID AND TransactionID = @TransactionType ))

						 --WHILE (SELECT COUNT(*) FROM #TempAllApprovals) > 0
						 --BEGIN
							--INSERT INTO #TempApproval VALUES('Approved by :',(SELECT TOP(1) UM.UserName  FROM #TempAllApprovals A 
							--INNER JOIN dbo.UserMasters UM ON A.ApprovalUserID = UM.Id AND A.IsComplete = 1
							--WHERE A.TransactionHeaderID = @HeaderID ))
		
							--DELETE TOP(1) FROM #TempAllApprovals
						 --END 
                     END
					  IF(@TransactionType = '7')
					 BEGIN

					 SELECT @CompanyId = PropertyId FROM StockTransactionHeaders WHERE Id = @HeaderID
					 SELECT @IsCentrallogn = IsCentralLogin FROM Companies WHERE CompanyID = @CompanyId
					
						IF(@IsCentrallogn = 1)
						BEGIN
							INSERT INTO @UserData
							SELECT Id, UserName
							FROM [dbo].[CentralUsers]
						END
						ELSE
						BEGIN
							INSERT INTO @UserData
							SELECT Id, UserName
							FROM UserMasters
						END

						INSERT INTO #TempApproval VALUES('Prepared by :',
						(SELECT  UM.UserName  FROM dbo.StockTransactionHeaders A 
						INNER JOIN @UserData UM ON A.UserProfileID = UM.Id
						 WHERE A.Id = @HeaderID AND TransactionID = @TransactionType ))

						 INSERT INTO #TempApproval VALUES('Checked by :','-------------------------------------------')
						  INSERT INTO #TempApproval VALUES('Issued by :','-------------------------------------------')

						 WHILE (SELECT COUNT(*) FROM #TempAllApprovals) > 0
						 BEGIN
							INSERT INTO #TempApproval VALUES('Approved by :',(SELECT TOP(1) UM.UserName  FROM #TempAllApprovals A 
							INNER JOIN @UserData UM ON A.ApprovalUserID = UM.Id AND A.IsComplete = 1
							WHERE A.TransactionHeaderID = @HeaderID ))
		
							DELETE TOP(1) FROM #TempAllApprovals
						 END 
                     END
                     
					 SELECT * FROM #TempApproval WHERE Value IS NOT NULL

					 SELECT * FROM #TempPOApproval WHERE Value IS NOT NULL

					 SELECT * FROM #TempPRApprovalForPO WHERE Value IS NOT NULL

					-----------Added----------------
					---Added 7/12/2021------
				SELECT AD.Name, ST.ChargeAmount 
				FROM StockTransactionwiseCharges ST
				INNER JOIN AdditionalChargesDetails AD ON AD.Id = ST.AdditionalChargeID
				WHERE StockTransactionHeaderID = @HeaderID
			---Added 7/12/2021------
	END TRY
	BEGIN CATCH
   SELECT  
            ERROR_NUMBER() AS ErrorNumber  
            ,ERROR_SEVERITY() AS ErrorSeverity  
            ,ERROR_STATE() AS ErrorState  
            ,ERROR_PROCEDURE() AS ErrorProcedure  
            ,ERROR_LINE() AS ErrorLine  
            ,ERROR_MESSAGE() AS ErrorMessage;  
	END CATCH
	END

GO

