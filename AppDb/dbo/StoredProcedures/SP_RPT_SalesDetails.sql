-- [dbo].[SP_RPT_SalesDetails] '2018-08-08', '2018-08-30' ,1  
CREATE  PROCEDURE [dbo].[SP_RPT_SalesDetails]
    (
      @DateForm DATE ,
      @DateTo DATE ,
      @DepartmentID INT
    )
AS
    SELECT  InvoiceNo ,
            CONVERT(VARCHAR(10), InvoiceDate, 103) InvoiceDate ,
            CustomerName ,
            ID.UnitPrice * ID.QTY AS GrossTotal ,
            round(CASE WHEN ID.IsPercentageForDiscount = 1
                 THEN ID.UnitPrice * ( ID.ItemDiscountPercentage / 100 )
                      * ID.QTY
                 ELSE ID.ItemDiscountValue * ID.QTY
            END,2) Discount ,
            ROUND(ID.TaxValue * ID.QTY,2) TaxTotal ,
            ROUND(( ID.QTY * ID.UnitPrice )
            - CASE WHEN ID.IsPercentageForDiscount = 1
                   THEN ID.UnitPrice * ( ID.ItemDiscountPercentage / 100 )
                        * ID.QTY
                   ELSE ID.ItemDiscountValue * ID.QTY
              END + ( ID.TaxValue * ID.QTY ),2) NetTotal ,
            SH.StockItemCode ,
            SH.Name ,
            ID.QTY ,
            ID.UnitPrice ,
            ID.QTY * ID.UnitPrice Price
    FROM    InvoiceHeaders IH
            INNER JOIN InvoiceDetails ID ON ID.InvoiceHeaderID = IH.ID
            INNER JOIN StockItemHeaders SH ON SH.Id = ID.ItemID
--where convert(varchar(10),InvoiceDate,103) between @DateForm and @DateTo and IH.DepartmentID =@DepartmentID 
    WHERE   CAST(InvoiceDate AS DATE) BETWEEN @DateForm
                                      AND     @DateTo
            AND IH.DepartmentID = @DepartmentID
    ORDER BY IH.InvoiceNo

GO

