-- exec [dbo].[rptIssueNote] 46200,'Thilini'
CREATE  PROCEDURE [dbo].[rptIssueNote]
    (
      @StockTxnID INT,
	  @UserName varchar(50)
    )
AS

DECLARE @UserData TABLE(
Id INT,
UserName NVARCHAR(200),
EmployeeId NVARCHAR(MAX)
)
DECLARE @IsCentralLogin BIT


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


		DECLARE @RequestUserName VARCHAR(50)

		SELECT @RequestUserName = Users.UserName
		FROM StockTransactionHeaders SH
		LEFT JOIN RequestHeaders RH ON SH.ReferenceID = RH.Id
		LEFT JOIN @UserData Users ON RH.UserProfileID = Users.Id 
		WHERE 	SH.id=@StockTxnID and SH.TransactionType='IN'


SELECT        sh.DocumentNo, sh.TransactionDate, l.Name AS location,CASE WHEN SH.ReferenceNo <>'' AND SH.SupplierID <>'' THEN STH.DocumentNo ELSE RH.DocumentNo END AS InvoiceNo, si.StockItemCode, si.Name AS ItemName, sd.Remarks, sd.UnitPrice, sd.Quantity, u.Name AS unit, sd.DiscountValue, Companies.Name, 
                         Companies.Address1 AS compAdd1, Companies.Address2 AS compAdd2, Companies.Address3 AS compAdd3, Companies.Telephone1 AS compTel1, Companies.Email AS compEmail, Companies.WebAddress, 
                         DP.Name AS ReqDep,
						 sd.UnitPrice* sd.Quantity as Total, Users.Username, @RequestUserName RequestUserName, sd.Remarks ItemRemark
FROM            StockTransactionHeaders AS sh INNER JOIN
                         StockTransactionDetails AS sd ON sh.Id = sd.StockTransactionHeaderID INNER JOIN
                         Locations AS l ON sh.LocationID = l.Id INNER JOIN
                         Units AS u ON sd.TxnUnitID = u.Id INNER JOIN
                         StockItemHeaders AS si ON sd.StockItemID = si.Id INNER JOIN
                         Companies ON l.CompanyID = Companies.CompanyID 
						 INNER JOIN
                         departments AS DP ON sh.departmentID = DP.Id
						LEFT JOIN @UserData Users ON sh.CreatedUserID = Users.Id 
						LEFT JOIN RequestHeaders RH ON SH.ReferenceID = RH.Id
						LEFT JOIN STOCKTRANSACTIONHEADERS STH ON STH.ReferenceNo = SH.ReferenceNo 
						AND STH.SUPPLIERID= SH.SUPPLIERID AND STH.PropertyID = SH.PropertyID AND STH.TransactionType = 'GR' AND SH.TransactionDate = STH.TransactionDate
where		sh.id=@StockTxnID and sh.TransactionType='IN'

GO

