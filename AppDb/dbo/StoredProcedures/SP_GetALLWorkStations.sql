--SP_GetALLWorkStations 1,1
CREATE  PROCEDURE [dbo].[SP_GetALLWorkStations] 
	@Locationid INT,
	@Department INT
   WITH RECOMPILE
AS
BEGIN
DECLARE @InvoicePrifix VARCHAR(2)
SELECT @InvoicePrifix=WS.InvoicePrifix 
FROM WorkStations WS   (HOLDLOCK)
WHERE WS.Location = @Locationid AND WS.Department = @Department

SELECT c.Name Company,WS.Computer_Name,L.Name Location,D.Name Department,WS.InvoicePrifix+RIGHT('00000000'+CONVERT(VARCHAR(MAX),WS.BillNo+1),8)  BillNo
FROM WorkStations WS   (HOLDLOCK)
INNER JOIN dbo.Locations L ON L.id = WS.Location
INNER JOIN dbo.Departments D ON D.Id = WS.Department
INNER JOIN dbo.Companies C ON C.CompanyID = L.CompanyID
WHERE WS.Location = @Locationid AND WS.Department = @Department

UPDATE 	WorkStations SET BillNo = 	BillNo + 1 
WHERE  Location = @Locationid AND  Department = @Department


SELECT TOP(1) H.InvoiceNo,H.GrossTotal,H.TotalDiscount+H.ItemDiscountTotal TotalDiscount,H.NetTotal,(SELECT COUNT(*) FROM dbo.InvoiceDetails WHERE InvoiceHeaderID = H.ID) AS ItemCount
FROM dbo.InvoiceHeaders H 
WHERE InvoiceNo LIKE @InvoicePrifix+'%'	AND Location = @Locationid AND DepartmentID = @Department
ORDER BY ID DESC
 
SELECT COUNT(*) TotalBillCount,SUM(GrossTotal)/ COUNT(*) AvgValuePerBill,11.58 AvgTimeTaken
FROM dbo.InvoiceHeaders 
WHERE  InvoiceNo LIKE @InvoicePrifix+'%' AND CONVERT(VARCHAR(20),sysDate, 102)  = CONVERT(VARCHAR(20), GETDATE(), 102)  AND  Location = @Locationid AND  DepartmentID = @Department

END

GO

