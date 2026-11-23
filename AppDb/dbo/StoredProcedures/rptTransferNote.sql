
CREATE  PROCEDURE [dbo].[rptTransferNote]
    (
      @StockTxnID INT,
	  @UserName varchar(50)
    )
AS
SELECT        sh.DocumentNo, sh.TransactionDate, l.Name AS location, sh.ReferenceNo AS InvoiceNo, si.StockItemCode, si.Name AS ItemName, sd.Remarks, sd.UnitPrice, sd.Quantity, u.Name AS unit, sd.DiscountValue, Companies.Name, 
                         Companies.Address1 AS compAdd1, Companies.Address2 AS compAdd2, Companies.Address3 AS compAdd3, Companies.Telephone1 AS compTel1, Companies.Email AS compEmail, Companies.WebAddress, 
                         TL.Name AS ReqDep, sd.UnitPrice* sd.Quantity as Total
FROM            StockTransactionHeaders AS sh INNER JOIN
                         StockTransactionDetails AS sd ON sh.Id = sd.StockTransactionHeaderID INNER JOIN
                         Locations AS l ON sh.LocationID = l.Id INNER JOIN
                         Units AS u ON sd.TxnUnitID = u.Id INNER JOIN
                         StockItemHeaders AS si ON sd.StockItemID = si.Id INNER JOIN
                         Companies ON l.CompanyID = Companies.CompanyID INNER JOIN
                         Locations AS TL ON sh.TransferLocationID = TL.Id
where		sh.id=@StockTxnID and sh.TransactionType='TO'

GO

