CREATE PROCEDURE [dbo].[SP_GetReportMonthlyshowroomsalesDivisionWise]
(@fromyear date, @toYear DATE,@username VARCHAR(100),@LocationID INT )

AS
Begin

 


 
  select CA.Id AS Id,CA.Name AS Division,CASE WHEN @LocationID=-999 THEN ' ' ELSE l.Name END AS Showroom,CASE WHEN @LocationID=-999 THEN DATENAME(MONTH,h.InvoiceDate) ELSE CONCAT(DATENAME(MONTH,h.InvoiceDate),' ',DATENAME(YEAR,h.InvoiceDate)) END AS MONTH ,SUM(ID.QTY*ID.UnitPrice)AS Amount
  from invoicedetails as ID 
  inner join InvoiceHeaders h on h.id= id.InvoiceHeaderID 
  inner join  dbo.Locations as L on h.Location= l.Id  
  inner join  stockitemheaders as SH on ID.ItemID= SH.ID 
  inner join categories as CA on SH.CategoryID=CA.Id 
  where Year(h.InvoiceDate) between Year(@fromyear) and Year(@toYear) AND l.Id= CASE WHEN @LocationID=-999 THEN l.Id ELSE @LocationID END
  GROUP BY l.Id,l.Name,DATENAME(MONTH,h.InvoiceDate),CA.Id,CA.Name,DATENAME(YEAR,h.InvoiceDate)


  




ENd

GO

