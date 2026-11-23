
--  [dbo].[rptTransferIn] 15674,4

CREATE  PROCEDURE [dbo].[rptTransferIn]
    (
      @StockTxnID INT,
	  @UserName varchar(50)
    )
AS
	SELECT sh.DocumentNo, sh.TransactionDate, l.Name AS location, sh.ReferenceNo AS InvoiceNo, si.StockItemCode, si.Name AS ItemName, sd.Remarks, sd.UnitPrice, sd.Quantity, u.Name AS unit, sd.DiscountValue, Companies.Name, 
	Companies.Address1 AS compAdd1, Companies.Address2 AS compAdd2, Companies.Address3 AS compAdd3, Companies.Telephone1 AS compTel1, Companies.Email AS compEmail, Companies.WebAddress, 
	TL.Name AS ReqDep, sd.UnitPrice* sd.Quantity as Total,SH2.DocumentNo TransferNoteNo
	,SD2.Quantity OriginalQuantity,CU.UserName,sh.CreatedDate
	FROM            StockTransactionHeaders AS sh 
	INNER JOIN StockTransactionDetails AS sd ON sh.Id = sd.StockTransactionHeaderID 
	INNER JOIN StockTransactionHeaders SH2 ON SH.ReferenceID = SH2.Id AND SH2.TransactionType='TO'
	INNER JOIN StockTransactionDetails SD2 ON SD2.StockTransactionHeaderID = SH2.Id AND SD2.StockItemID = SD.StockItemID
	INNER JOIN Locations AS l ON sh.LocationID = l.Id 
	INNER JOIN Units AS u ON sd.TxnUnitID = u.Id 
	INNER JOIN StockItemHeaders AS si ON sd.StockItemID = si.Id 
	INNER JOIN Companies ON l.CompanyID = Companies.CompanyID 
	INNER JOIN Locations AS TL ON sh.TransferLocationID = TL.Id
	INNER JOIN CentralUsers CU ON CU.Id = SH.UserProfileID 
	where	sh.id=@StockTxnID --and sh.TransactionType='TO' 
	UNION ALL 

	SELECT DISTINCT sh.DocumentNo, sh.TransactionDate, l.Name AS location, sh.ReferenceNo AS InvoiceNo, si.StockItemCode, si.Name AS ItemName, sd.Remarks, sd.UnitPrice, sd.Quantity, u.Name AS unit, sd.DiscountValue, Companies.Name, 
	Companies.Address1 AS compAdd1, Companies.Address2 AS compAdd2, Companies.Address3 AS compAdd3, Companies.Telephone1 AS compTel1, Companies.Email AS compEmail, Companies.WebAddress, 
	TL.Name AS ReqDep, sd.UnitPrice* sd.Quantity as Total,SH2.DocumentNo TransferNoteNo
	,SD2.Quantity OriginalQuantity,CU.UserName,sh.CreatedDate
	FROM            StockTransactionHeaders AS sh 
	INNER JOIN StockTransactionDetails AS sd ON sh.Id = sd.StockTransactionHeaderID 
	INNER JOIN RequestHeaders RH ON RH.ID = SH.ReferenceID AND RH.RequestType ='RT'
	INNER JOIN StockTransactionHeaders SH2 ON SH2.ReferenceID = RH.Id AND SH2.TransactionType='TO'
	INNER JOIN StockTransactionDetails SD2 ON SD2.StockTransactionHeaderID = SH2.Id AND SD2.StockItemID = SD.StockItemID
	INNER JOIN Locations AS l ON sh.LocationID = l.Id 
	INNER JOIN Units AS u ON sd.TxnUnitID = u.Id 
	INNER JOIN StockItemHeaders AS si ON sd.StockItemID = si.Id 
	INNER JOIN Companies ON l.CompanyID = Companies.CompanyID 
	INNER JOIN Locations AS TL ON sh.TransferLocationID = TL.Id
	INNER JOIN CentralUsers CU ON CU.Id = SH.UserProfileID 
	where	sh.id=@StockTxnID

GO

