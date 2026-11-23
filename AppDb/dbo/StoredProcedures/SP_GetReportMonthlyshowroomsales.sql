

-- [dbo].[SP_GetReportMonthlyshowroomsales] '01/01/2018','01/12/2019','thiwanka'

CREATE PROCEDURE [dbo].[SP_GetReportMonthlyshowroomsales]
(@fromyear date, @toYear DATE,@username VARCHAR(100))

AS
Begin

BEGIN TRY

 BEGIN TRANSACTION 
 

 
  select l.Id AS Id,l.Name AS Showroom,DATENAME(MONTH,h.InvoiceDate) [MONTH] ,SUM(ID.QTY*ID.UnitPrice)AS Amount
  from invoicedetails as ID 
  inner join InvoiceHeaders h on h.id= id.InvoiceHeaderID
  inner join  dbo.Locations as L on h.Location= l.Id  
  where Year(h.InvoiceDate) between Year(@fromyear) and Year(@toYear)
  GROUP BY l.Id,l.Name,DATENAME(MONTH,h.InvoiceDate)


 COMMIT TRANSACTION 
   
END TRY

BEGIN CATCH 
  IF (@@TRANCOUNT > 0)
   BEGIN
      ROLLBACK TRANSACTION SCHEDULEDELETE
      PRINT 'Error detected, all changes reversed'
   END 
    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() AS ErrorState,
        ERROR_PROCEDURE() AS ErrorProcedure,
        ERROR_LINE() AS ErrorLine,
        ERROR_MESSAGE() AS ErrorMessage
END CATCH



ENd

GO

