-- =============================================
-- Author:		<Thisen Dewnim>
-- Create date: <08/12/2025>
-- Description:	<Creating the rpt Kitchen Issue Note>
-- =============================================
CREATE  PROCEDURE [dbo].[rptKitchenIssueNote]
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

	

SELECT        sh.DocumentNo, sh.TransactionDate, l.Name AS location,  si.StockItemCode, si.Name AS ItemName, sd.Remarks, sd.UnitPrice, sd.Quantity, u.Name AS unit, sd.DiscountValue, Companies.Name, 
                         Companies.Address1 AS compAdd1, Companies.Address2 AS compAdd2, Companies.Address3 AS compAdd3, Companies.Telephone1 AS compTel1, Companies.Email AS compEmail, Companies.WebAddress, 
                         DP.Name AS ReqDep,
						 sd.UnitPrice* sd.Quantity as Total, @RequestUserName RequestUserName, sd.Remarks ItemRemark
FROM            StockTransactionHeaders AS sh INNER JOIN
                         StockTransactionDetails AS sd ON sh.Id = sd.StockTransactionHeaderID INNER JOIN
                         Locations AS l ON sh.LocationID = l.Id INNER JOIN
                         Units AS u ON sd.TxnUnitID = u.Id INNER JOIN
                         StockItemHeaders AS si ON sd.StockItemID = si.Id INNER JOIN
                         Companies ON l.CompanyID = Companies.CompanyID 
						 INNER JOIN
                         departments AS DP ON sh.departmentID = DP.Id
	
where		sh.id=@StockTxnID and sh.TransactionType='IF'

GO

