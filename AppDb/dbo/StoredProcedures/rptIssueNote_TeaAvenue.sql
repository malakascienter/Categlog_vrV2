-- exec [dbo].[rptIssueNote_TeaAvenue] 39,'Thilini'

CREATE  PROCEDURE [dbo].[rptIssueNote_TeaAvenue]
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


 SELECT  
        sh.DocumentNo, 
        sh.TransactionDate, 
        l.Name AS location, 
        RH.DocumentNo AS InvoiceNo, 
        si.StockItemCode, 
        si.Name AS ItemName, 
        sd.Remarks, 
        sd.UnitPrice, 
        ISNULL(sd.Quantity,0) Quantity, 
        u.Name AS unit, 
        sd.DiscountValue, 
        Companies.Name, 
        Companies.Address1 AS compAdd1, 
        Companies.Address2 AS compAdd2, 
        Companies.Address3 AS compAdd3, 
        Companies.Telephone1 AS compTel1, 
        Companies.Email AS compEmail, 
        Companies.WebAddress, 
        DP.Name AS ReqDep,
        ISNULL(sd.UnitPrice,0) * ISNULL(sd.Quantity,0) AS Total, 
        Users.Username, 
        @RequestUserName AS RequestUserName, 
        sd.Remarks AS ItemRemark,
        COALESCE(
            [dbo].[FN_GetUnitConvertionRate](
                sh.Id, 
                COALESCE(sd.MasterUnitID, rd.UnitID),  -- fallback when no issue row
                rd.UnitID
            ) * rd.ApprovedQuantity,
            rd.ApprovedQuantity
        ) AS RequestedQuantity
    FROM StockTransactionHeaders AS sh
    INNER JOIN Locations AS l 
        ON sh.LocationID = l.Id
    INNER JOIN Companies 
        ON l.CompanyID = Companies.CompanyID
    INNER JOIN Departments AS DP 
        ON sh.DepartmentID = DP.Id
    LEFT JOIN @UserData Users 
        ON sh.CreatedUserID = Users.Id 
    LEFT JOIN RequestHeaders RH 
        ON sh.ReferenceID = RH.Id
    OUTER APPLY (
        SELECT rd.StockItemID, rd.UnitID, rd.ApprovedQuantity
        FROM RequestDetails rd
        INNER JOIN RequestionStatus RQ ON RD.StockItemID = RQ.StockItemID AND RQ.RequestHeaderID = RD.RequestHeaderID
        WHERE rd.RequestHeaderID = sh.ReferenceID
        AND RQ.TransactionHeaderID = @StockTxnID
        AND RQ.TransactionType='IN' 
    ) rd
    LEFT JOIN StockTransactionDetails AS sd 
        ON sd.StockTransactionHeaderID = sh.Id
       AND (rd.StockItemID = sd.StockItemID OR sh.ReferenceID = -999)
    LEFT JOIN StockItemHeaders AS si 
        ON si.Id = ISNULL(sd.StockItemID, rd.StockItemID)
    LEFT JOIN Units AS u 
        ON u.Id = sd.TxnUnitID
    WHERE sh.Id = @StockTxnID
      AND sh.TransactionType = 'IN';

GO

