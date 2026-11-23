-- [dbo].[SP_RPT_SalesSummery] '2018-04-08', '2018-08-31',1
CREATE  procedure [dbo].[SP_RPT_SalesSummery] (@DateForm date, @DateTo DATE,@DepartmentID int)
as
set dateformat dmy 

select InvoiceNo,convert(varchar(10),InvoiceDate,103)InvoiceDate,  CustomerName, GrossTotal GrossTotal,TotalDiscount Discount,NetTotal from InvoiceHeaders
where CAST(InvoiceDate AS DATE) between @DateForm and @DateTo AND DepartmentID=@DepartmentID

GO

