-- [dbo].[rptTransferNote_TeaAvenue] 26,''

CREATE  PROCEDURE [dbo].[rptTransferNote_TeaAvenue]
    (
      @StockTxnID INT,
	  @UserName varchar(50)
    )
AS
SELECT 
    sh.DocumentNo,
    sh.TransactionDate,
    l.Name AS location,
    sh.ReferenceNo AS InvoiceNo,
    si.StockItemCode,
    si.Name AS ItemName,
    sd.Remarks,
    sd.UnitPrice,
    ISNULL(sd.Quantity,0) Quantity,
    u.Name AS unit,
    sd.DiscountValue,
    c.Name,
    c.Address1 AS compAdd1,
    c.Address2 AS compAdd2,
    c.Address3 AS compAdd3,
    c.Telephone1 AS compTel1,
    c.Email AS compEmail,
    c.WebAddress,
    TL.Name AS ReqDep,
    ISNULL(sd.UnitPrice,0) * ISNULL(sd.Quantity,0) AS Total,
    [dbo].[FN_GetUnitConvertionRate](
    sh.Id,
    COALESCE(sd.MasterUnitID, rd.UnitID),  -- fall back to request's unit
    rd.UnitID
) * rd.ApprovedQuantity AS RequestedQuantity
FROM StockTransactionHeaders AS sh
INNER JOIN Locations AS l 
    ON sh.LocationID = l.Id
INNER JOIN Companies AS c 
    ON l.CompanyID = c.CompanyID
INNER JOIN Locations AS TL 
    ON sh.TransferLocationID = TL.Id
OUTER APPLY (
    SELECT rd.StockItemID, rd.UnitID, rd.ApprovedQuantity
    FROM RequestDetails rd 
    INNER JOIN RequestionStatus RQ ON RD.StockItemID = RQ.StockItemID AND RQ.RequestHeaderID = RD.RequestHeaderID
    WHERE rd.RequestHeaderID = sh.ReferenceID
    AND RQ.TransactionHeaderID = @StockTxnID
    AND RQ.TransactionType='TO' 
) rd
LEFT JOIN StockTransactionDetails AS sd 
    ON sd.StockTransactionHeaderID = sh.Id
   AND (rd.StockItemID = sd.StockItemID OR sh.ReferenceID = -999)
LEFT JOIN StockItemHeaders AS si 
    ON si.Id = ISNULL(sd.StockItemID, rd.StockItemID)
LEFT JOIN Units AS u 
    ON u.Id = sd.TxnUnitID
where		sh.id=@StockTxnID and sh.TransactionType='TO'

GO

