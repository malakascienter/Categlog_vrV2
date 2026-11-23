
/**
[dbo].[rptPrintGRN] 5229, 1
 [dbo].[rptPrintGRN] 6612, 1
 **/

CREATE  PROCEDURE [dbo].[rptPrintGRN]
    (
      @StockTxnID INT,
	  @UserName varchar(50)
    )
AS

--------------------------
DECLARE @UserData TABLE(
Id INT,
UserName NVARCHAR(200),
EmployeeId NVARCHAR(MAX)
)

declare @IsCentralLogin BIT, @IsFreeGRN BIT =0,@ApprovedUserName VARCHAR(500)


SELECT @IsCentralLogin = IsCentralLogin FROM Companies C
inner join StockTransactionHeaders H ON h.PropertyID = c.CompanyID
WHERE H.Id= @StockTxnID;

	IF OBJECT_ID('tempdb..#TempFreeQuantity') IS NOT NULL
	DROP TABLE #TempFreeQuantity

	CREATE TABLE #TempFreeQuantity(
	Id INT,
	ReferenceID INT,
	ReferenceNo VARCHAR(50),
	DocumentNo VARCHAR(50),
	StockItemID INT,
	Quantity DECIMAL(18,6)
	)

		print '03 A'

		IF(@IsCentralLogin = 1)
		BEGIN
		print 'P'
			 		
			INSERT INTO @UserData
			SELECT Id, UserName, EmpNumber
			FROM [dbo].[CentralUsers]
			

		END
		ELSE
		BEGIN
		print 'Q'

			INSERT INTO @UserData
			SELECT Id, UserName,EmployeeId
			FROM UserMasters

		END
--------------------------

DECLARE @DocStatus VARCHAR(100),
			@AdditionalCharge DECIMAL(18,2) -- added by Isuru 2023-05-08

--added by isuru
		select @AdditionalCharge= ISNULL(sum(stw.ChargeAmount),0) 
		from StockTransactionwiseCharges STW
		inner join StockTransactionHeaders ST on stw.StockTransactionHeaderID= st.Id
		where st.id= @StockTxnID
--end
	-----------------------------Get Free Qty --Added by Nivesh 2024-10-28
	INSERT INTO #TempFreeQuantity(Id, ReferenceID,DocumentNo,ReferenceNo,StockItemID,Quantity)
	SELECT sh.Id, sh.ReferenceID,sh.DocumentNo, sh.ReferenceNo, sd.StockItemID, sd.Quantity FROM
	StockTransactionHeaders sh
	INNER JOIN StockTransactionDetails sd on sd.StockTransactionHeaderID = sh.Id
	WHERE sh.ReferenceID = @StockTxnID and sh.ReferenceNo ='FreeQty'
	-----------------------------

	
--Added by Isuru  2025-01-20 for viewing Free GRN
			IF EXISTS (SELECT 1 FROM StockTransactionHeaders sh INNER JOIN StockTransactionDetails sd ON sh.ID = sd.StockTransactionHeaderID
			WHERE sh.TransactionType = 'GR' AND SH.Id = @StockTxnID HAVING SUM(sd.UnitPrice * sd.Quantity) = 0)
			BEGIN
				SET @IsFreeGRN = 1
			END
			ELSE
			BEGIN
				SET @IsFreeGRN = 0
			END

--End

	--added by Isuru 2024-12-18
	SELECT @ApprovedUserName = STUFF((
    SELECT ' | ' + UserName
    FROM (
        SELECT DISTINCT CU.UserName, AP.ApprovedDateTime
        FROM grnapprovallog AP 
        INNER JOIN CentralUsers CU 
            ON CU.Id = AP.UserProfileId
        WHERE AP.TransactionType = 'GR'
        AND AP.StockTransactionHeaderID = @StockTxnID
    ) x
    ORDER BY x.ApprovedDateTime
    FOR XML PATH('')
), 1, 3, '')
	--ENd


   SELECT   sh.DocumentNo,  sh.ExchangeRate , sh.TransactionDate, l.Name AS location,s.Name AS supplierName, s.Address1, s.Telephone1, s.Email, 
                cm.Name AS Currency, sh.ReferenceNo as InvoiceNo, s.Code AS suppCode,si.StockItemCode, si.Name AS ItemName, ct.Name AS Category, 
                sd.Remarks, sd.UnitPrice  UnitPrice, sd.Quantity,
				ROUND(ISNULL((SELECT Quantity FROM #TempFreeQuantity WHERE ReferenceID =@StockTxnID AND StockItemID = SD.StockItemID),0),2) FreeQuantity, --Added by Nivesh 2024-10-28
				sd.unitprice*sd.quantity total,
				--(sd.unitprice*sd.quantity + (sd.unitprice*ISNULL((SELECT Quantity FROM #TempFreeQuantity WHERE ReferenceID =@StockTxnID AND StockItemID = SD.StockItemID),0)) ) as total, --Modified by Nivesh 2024-10-28
				u.Name AS unit, 
				CASE WHEN Sd.DiscountPercentage>0 and  sd.DiscountValue =0 THEN (UnitPrice *Sd.DiscountPercentage /100)* Quantity else sd.DiscountValue end DiscountValue , St.TaxAmount TaxAmount ,
				Companies.Name, Companies.Address1 AS compAdd1, Companies.Address2 AS compAdd2, 
                Companies.Address3 AS compAdd3, Companies.Telephone1 AS compTel1, Companies.Email AS compEmail, Companies.WebAddress,Po.PoNo,
				(SELECT DocumentNo FROM #TempFreeQuantity WHERE ReferenceID =@StockTxnID AND StockItemID = SD.StockItemID) ReferenceNo, --Added by Nivesh 2024-10-28
				Users.Username,
				concat( si.name, case when (select Temperature from StockItemWiseTemperature where StockItemID=sd.StockItemID and LocationID=sh.LocationID 
				and TransactionID=sd.StockTransactionHeaderID and TransactionType='GR')is not null then 
				concat (' Temp: ' , (select Temperature from StockItemWiseTemperature where StockItemID=sd.StockItemID and LocationID=sh.LocationID 
				and TransactionID=sd.StockTransactionHeaderID and TransactionType='GR') ) else '' end,
				case when (select top(1)convert(char(10),EXPDate,103) from StockItemWiseEXPDateIns where StockItemID=sd.StockItemID and LocationID=sh.LocationID 
				and TransactionID=sd.StockTransactionHeaderID and TransactionType='GR') is not null then 
				concat(' Exp:',(select top(1)convert(char(10),EXPDate,103) from StockItemWiseEXPDateIns where StockItemID=sd.StockItemID and LocationID=sh.LocationID 
				and TransactionID=sd.StockTransactionHeaderID and TransactionType='GR')) else '' end) as ItemNameN, 'APPROVED' as DocumentStatus,
				CASE  WHEN sh.Isprint = 1 THEN 'DUPLICATE'  WHEN sh.Isprint = 0 THEN 'ORIGINAL' END  as IsPrint,
				@AdditionalCharge ChargeAmount, --added by Isuru 
				isnull(po.Remarks,'') PORemarks, -- CHARITHA
				isnull(sh.Remarks,'') GRNRemarks  -- CHARITHA
				,CASE when @IsFreeGRN = 1 THEN 'FREE GOOD RECIEVED NOTE' ELSE 'GOOD RECIEVED NOTE' END AS ReportHeader
				,ISNULL(@ApprovedUserName,'N/A') ApprovedUserName
FROM        StockTransactionHeaders AS sh INNER JOIN
				StockTransactionDetails AS sd ON sh.Id = sd.StockTransactionHeaderID INNER JOIN
				Locations AS l ON sh.LocationID = l.Id INNER JOIN
				Suppliers AS s ON sh.SupplierID = s.ID INNER JOIN
				CurrencyMasters AS cm ON s.CurrencyID = cm.Id INNER JOIN --sh.SuppCurrencyID = cm.Id INNER JOIN ISURU 2023-03-09
				Units AS u ON sd.TxnUnitID = u.Id LEFT JOIN
				StockItemHeaders AS si INNER JOIN
				Categories AS ct ON si.CategoryID = ct.Id ON sd.StockItemID = si.Id INNER JOIN
				Companies ON l.CompanyID = Companies.CompanyID LEFT JOIN
				PoHeaders po ON sh.ReferenceID = Po.ID AND sh.LocationID = Po.LocationID AND sh.SupplierID = Po.SupplierID 
				INNER JOIN @UserData Users ON sh.CreatedUserID = Users.Id 
				LEFT OUTER JOIN
				StockTransactionwiseTaxes AS st ON sd.Id = st.StockTransactionDetailID AND sd.StockItemID = st.StockItemID
where		sh.id=@StockTxnID and sh.TransactionType='GR' --OR (sh.ReferenceID = @StockTxnID AND sh.ReferenceNo = 'FreeQty')


--updating IsPrint after View
UPDATE StockTransactionHeaders
SET Isprint =1
WHERE StockTransactionHeaders.ID = @StockTxnID

GO

