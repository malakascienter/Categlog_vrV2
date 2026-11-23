
CREATE PROCEDURE [dbo].[SP_GetReportSalesMonthly]
(@fromMonth date, @toMonth DATE,@username VARCHAR(100)
)
AS
Begin

BEGIN TRY

 BEGIN TRANSACTION 
 

  select CA.Id AS Id,CA.Name AS Division,DATENAME(MONTH,h.InvoiceDate) [MONTH] ,SUM(ID.QTY*ID.UnitPrice) AS Amount 
  from invoicedetails as ID 
  inner join InvoiceHeaders h on h.id= id.InvoiceHeaderID
  inner join  stockitemheaders as SH on ID.ItemID= SH.ID 
  inner join categories as CA on SH.CategoryID=CA.Id 
  where h.InvoiceDate between @fromMonth and @toMonth
  GROUP BY CA.Name,CA.Id,DATENAME(MONTH,h.InvoiceDate)


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

