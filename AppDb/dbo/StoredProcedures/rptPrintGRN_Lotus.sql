
-- [dbo].[rptPrintGRN_Lotus] 341, 1
create  PROCEDURE [dbo].[rptPrintGRN_Lotus]
    (
      @StockTxnID INT,
	  @UserName varchar(50)
    )
AS

--------------------------
DECLARE @UserData TABLE(
Id INT,
UserName NVARCHAR(200),
EmployeeId INT
)

declare @IsCentralLogin BIT


SELECT @IsCentralLogin = IsCentralLogin FROM Companies C
inner join StockTransactionHeaders H ON h.PropertyID = c.CompanyID
WHERE H.Id= @StockTxnID

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
		select @AdditionalCharge= sum(stw.ChargeAmount) 
		from StockTransactionwiseCharges STW
		inner join StockTransactionHeaders ST on stw.StockTransactionHeaderID= st.Id
		where st.id= @StockTxnID
--end



   SELECT   sh.DocumentNo,  sh.ExchangeRate , sh.TransactionDate, l.Name AS location,s.Name AS supplierName, s.Address1, s.Telephone1, s.Email, 
                cm.Name AS Currency, sh.ReferenceNo as InvoiceNo, s.Code AS suppCode,si.StockItemCode, si.Name AS ItemName, ct.Name AS Category, 
                sd.Remarks, sd.UnitPrice  UnitPrice, sd.Quantity,sd.unitprice*sd.quantity    as total, u.Name AS unit, 
				CASE WHEN Sd.DiscountPercentage>0 and  sd.DiscountValue =0 THEN (UnitPrice *Sd.DiscountPercentage /100)* Quantity else sd.DiscountValue end DiscountValue , St.TaxAmount TaxAmount ,
				Companies.Name, Companies.Address1 AS compAdd1, Companies.Address2 AS compAdd2, 
                Companies.Address3 AS compAdd3, Companies.Telephone1 AS compTel1, Companies.Email AS compEmail, Companies.WebAddress,Po.PoNo,Users.Username,
				concat( si.name, case when (select Temperature from StockItemWiseTemperature where StockItemID=sd.StockItemID and LocationID=sh.LocationID 
				and TransactionID=sd.StockTransactionHeaderID and TransactionType='GR')is not null then 
				concat (' Temp: ' , (select Temperature from StockItemWiseTemperature where StockItemID=sd.StockItemID and LocationID=sh.LocationID 
				and TransactionID=sd.StockTransactionHeaderID and TransactionType='GR') ) else '' end,
				case when (select convert(char(10),EXPDate,103) from StockItemWiseEXPDateIns where StockItemID=sd.StockItemID and LocationID=sh.LocationID 
				and TransactionID=sd.StockTransactionHeaderID and TransactionType='GR') is not null then 
				concat(' Exp:',(select convert(char(10),EXPDate,103) from StockItemWiseEXPDateIns where StockItemID=sd.StockItemID and LocationID=sh.LocationID 
				and TransactionID=sd.StockTransactionHeaderID and TransactionType='GR')) else '' end) as ItemNameN, 'APPROVED' as DocumentStatus,
				CASE  WHEN sh.Isprint = 1 THEN 'DUPLICATE'  WHEN sh.Isprint = 0 THEN 'ORIGINAL' END  as IsPrint,
				@AdditionalCharge ChargeAmount --added by Isuru 
				 ,CASE WHEN po.POType =2 THEN 'SHOW' ELSE '' END AS IsServicePO
FROM        StockTransactionHeaders AS sh INNER JOIN
				StockTransactionDetails AS sd ON sh.Id = sd.StockTransactionHeaderID INNER JOIN
				Locations AS l ON sh.LocationID = l.Id INNER JOIN
				Suppliers AS s ON sh.SupplierID = s.ID INNER JOIN
				CurrencyMasters AS cm ON s.CurrencyID = cm.Id INNER JOIN --sh.SuppCurrencyID = cm.Id INNER JOIN ISURU 2023-03-09
				Units AS u ON sd.TxnUnitID = u.Id INNER JOIN
				StockItemHeaders AS si INNER JOIN
				Categories AS ct ON si.CategoryID = ct.Id ON sd.StockItemID = si.Id INNER JOIN
				Companies ON l.CompanyID = Companies.CompanyID LEFT JOIN
				PoHeaders po ON sh.ReferenceID = Po.ID AND sh.LocationID = Po.LocationID AND sh.SupplierID = Po.SupplierID 
				INNER JOIN @UserData Users ON sh.CreatedUserID = Users.Id 
				LEFT OUTER JOIN
				StockTransactionwiseTaxes AS st ON sd.Id = st.StockTransactionDetailID AND sd.StockItemID = st.StockItemID
where		sh.id=@StockTxnID and sh.TransactionType='GR'


--updating IsPrint after View
UPDATE StockTransactionHeaders
SET Isprint =1
WHERE StockTransactionHeaders.ID = @StockTxnID

GO

