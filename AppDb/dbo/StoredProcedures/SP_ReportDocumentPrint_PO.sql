
CREATE PROCEDURE [dbo].[SP_ReportDocumentPrint_PO] --3272,1,2
    @HeaderID INT ,
    @userid INT ,
    @TransactionType INT
AS

	DECLARE @CompanyId INT, @IsCentrallogn BIT

	DECLARE @UserData TABLE(
	Id INT,
	UserName NVARCHAR(200)
	)

	SELECT @CompanyId = PropertyId FROM PoHeaders WHERE Id = @HeaderID
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

    SELECT  H.Id ,
            CONVERT(VARCHAR(10), H.DocumentDate, 103) AS TransactionDate ,
            '' ReferenceDocument ,
            TT.DocumentTitle ,
            H.PoNo AS DocumentNo ,
			H.DeliveryAddressID AS DeliveryAddress,
			CONVERT(VARCHAR(10), H.DeliveryDate, 103) AS DeliveryDate ,
            C.Name AS 'CompanyName' ,
			C.Email,
			C.FaxNo,
			C.Telephone1,
            S.Name AS 'SupplierName' ,
            S.Code AS suppliercode ,
            L.Name AS 'LocationName' ,
            CM.Name AS 'SupplyCurrency' ,
            ( CASE WHEN ( H.Isprint = 1 ) THEN 'DUPLICATE'
                   ELSE 'ORIGINAL'
              END ) AS 'Printed' ,
            ( CASE WHEN ( H.isApproved = 1 ) THEN 'ACCEPTED'
                   ELSE 'PENDING'
              END ) AS 'ACCEPTED' ,
            CONVERT(VARCHAR(10), GETDATE(), 103) AS printeddate ,
            CONVERT(VARCHAR(10), GETDATE(), 108) AS printedtime ,
            '' usename ,
            S.Address1 AS supplieradd ,
			S.Email AS SuppEmail,
			S.Telephone1 AS SuppTelephone1,
            C.Address1 ,
            C.Address2 ,
            C.Address3,
			C.ContactPerson,
			C.TaxRegistrationNumber1,
			C.Mobile,
			'8.30 am- 5.00 pm (Monday-Friday)' AS OpeningHours,
			UM.UserName AS PreparedBy,
			'This is a system generated document and does not require a signature All goods to be directly delivered to the delivery address' AS Word2,
			PT.Name AS TypeName
    FROM    dbo.PoHeaders AS H
            INNER JOIN dbo.Companies AS C ON H.PropertyID = C.CompanyID
            INNER JOIN dbo.Suppliers AS S ON H.SupplierID = S.ID
            INNER JOIN dbo.Locations AS L ON H.LocationID = L.Id
            INNER JOIN dbo.TransactionTypes AS TT ON TT.Id = 2
            LEFT  JOIN dbo.CurrencyMasters AS CM ON H.CurrencyId = CM.Id
			LEFT JOIN @UserData UM ON UM.Id = H.CreatedUserID
			LEFT JOIN POTypesNew PT ON PT.Id = H.POType
    WHERE   H.Id = @HeaderID

    SELECT  SH.StockItemCode ,
            SH.Name ,
            CAST(PO.ApprovedQuantity AS DECIMAL(8,2)) AS Quantity ,
            CAST(CONVERT(VARCHAR, CAST(PO.UnitPrice AS MONEY), 1) AS VARCHAR) AS UnitPrice ,
            CAST(CONVERT(VARCHAR, CAST(0 AS MONEY), 1) AS VARCHAR) AS TaxAmount ,
            ( CONVERT(VARCHAR(10), PO.DiscountPercentage) + '%' ) AS discont ,
            U.Name AS 'UnitName' ,
            CAST(CONVERT(VARCHAR, CAST(15897566 AS MONEY), 1) AS VARCHAR) AS netammount ,
            CAST(CONVERT(VARCHAR, CAST(( PO.ApprovedQuantity * PO.UnitPrice ) AS MONEY), 1) AS VARCHAR) AS grossAmmount
    FROM    dbo.PoDetails AS PO
            INNER JOIN dbo.StockItemHeaders AS SH ON PO.StockItemID = SH.Id
            INNER JOIN dbo.Units AS U ON PO.UnitID = U.Id
    WHERE   PoHeaderID = @HeaderID

    CREATE TABLE #ReportSummeryTemp
        (
          id INT IDENTITY(1, 1) ,
          Description VARCHAR(100) ,
          amount MONEY ,
          factor INT
        )

    INSERT  INTO #ReportSummeryTemp
            ( Description ,
              amount ,
              factor
            )
            SELECT  'Gross Amount' ,
                    SUM(ApprovedQuantity * UnitPrice) ,
                    1
            FROM    dbo.PoDetails
            WHERE   PoHeaderID = @HeaderID


	  --INSERT  INTO #ReportSummeryTemp
   --         ( Description ,
   --           amount ,
   --           factor
   --         )
   --         SELECT  'Discount' ,
   --                 SUM((sd.DiscountValue+(sd.UnitPrice*sd.DiscountPercentage/100)) *sd.RequestedQuantity),
   --                 -1
   --         FROM    dbo.PoDetails sd
   --         WHERE   sd.PoHeaderID = @HeaderID

      INSERT  INTO #ReportSummeryTemp
         ( Description ,
           amount ,
           factor
         )
         SELECT  'Discount' ,
                 sd.TotalDiscount,
                 -1
         FROM    dbo.PoHeaders sd
         WHERE   sd.Id = @HeaderID



    INSERT  INTO #ReportSummeryTemp
            ( Description ,
              amount ,
              factor
            )
            SELECT  'Tax -' + td.Name ,
                    SUM(tt.TaxAmount) ,
                    1
            FROM    dbo.POwiseTaxes tt
                    INNER JOIN dbo.PoDetails sd ON sd.Id = tt.PODetailID
                                                   AND sd.StockItemID = tt.StockItemID
                    INNER JOIN dbo.TaxDetails td ON td.TaxTypeId = tt.TaxTypeID
            WHERE   sd.PoHeaderID = @HeaderID
            GROUP BY td.Name


  


 

    INSERT  INTO #ReportSummeryTemp
            ( Description ,
              amount
            )
            SELECT  'Net Total' ,
                    SUM(amount * factor)
            FROM    #ReportSummeryTemp


    SELECT  id ,
            Description ,
            CAST(CONVERT(VARCHAR, CAST(amount AS MONEY), 1) AS VARCHAR) AS amount ,
            factor
    FROM    #ReportSummeryTemp
    ORDER BY id


    SELECT  *
    FROM    PrintReportTitles
    WHERE   TransactionType = @TransactionType


    SELECT  Description
    FROM    dbo.SignaturesReportModels
    WHERE   TransactionID = @TransactionType
    ORDER BY OrderNum

	-----------Added----------------
	 

	SELECT * INTO #TempAllApprovals FROM dbo.ApprovalLogs WHERE TransactionHeaderID = @HeaderID AND TransactionID = @TransactionType

		--SELECT A.* INTO #TempAllApprovals 
		--			FROM dbo.ApprovalLogs A
		--			INNER JOIN dbo.PoHeaders PH
		--			ON A.TransactionHeaderID = PH.Id AND A.LocationID = PH.LocationID
		--			WHERE A.TransactionHeaderID = @HeaderID AND A.TransactionID = @TransactionType

	CREATE TABLE #TempApproval(Id INT IDENTITY(1,1) PRIMARY KEY, Description VARCHAR(250), Value VARCHAR(250))
	CREATE TABLE #TempPOApproval(Id INT IDENTITY(1,1) PRIMARY KEY, Description VARCHAR(250), Value VARCHAR(250)) 
	CREATE TABLE #TempPRApprovalForPO(Id INT IDENTITY(1,1) PRIMARY KEY, Description VARCHAR(250), Value VARCHAR(250)) 

	INSERT INTO #TempApproval VALUES('Prepared by :',
	(SELECT UM.UserName  FROM dbo.PoHeaders A INNER JOIN @UserData UM ON A.UserProfileID = UM.Id
	 WHERE A.Id = @HeaderID ))

	 WHILE (SELECT COUNT(*) FROM #TempAllApprovals) > 0
	 BEGIN
		INSERT INTO #TempApproval VALUES('Approved by :',(SELECT TOP(1) UM.UserName  FROM #TempAllApprovals A 
		INNER JOIN @UserData UM ON A.ApprovalUserID = UM.Id AND A.IsComplete = 1
		WHERE A.TransactionHeaderID = @HeaderID ))
		
		DELETE TOP(1) FROM #TempAllApprovals
	 END 

	 DECLARE @RequestHeaderId INT

	 SELECT @RequestHeaderId = RequestHeaderID FROM PoWisePRs WHERE PoHeaderID = @HeaderID

	 SELECT * INTO #TempPRApprovals FROM dbo.ApprovalLogs WHERE TransactionHeaderID = @RequestHeaderId AND TransactionID = '1'

	  WHILE (SELECT COUNT(*) FROM #TempPRApprovals) > 0
	 BEGIN
		INSERT INTO #TempPRApprovalForPO VALUES('PR Approved by :',(SELECT TOP(1) UM.UserName  FROM #TempPRApprovals A 
		INNER JOIN @UserData UM ON A.ApprovalUserID = UM.Id AND A.IsComplete = 1
		WHERE A.TransactionHeaderID = @RequestHeaderId ))
		
		DELETE TOP(1) FROM #TempPRApprovals
	 END 
	
	SELECT * FROM #TempApproval WHERE Value IS NOT NULL
	SELECT * FROM #TempPOApproval WHERE Value IS NOT NULL
	 SELECT * FROM #TempPRApprovalForPO WHERE Value IS NOT NULL

	-----------Added----------------
		---Added 7/12/2021------
		 SELECT '' Name, 0 ChargeAmount 
		 ---Added 7/12/2021------

GO

