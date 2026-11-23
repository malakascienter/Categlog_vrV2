

--[dbo].[SP_PRT_ItemWiseSales] '2018-04-08', '2018-08-30',45,1
CREATE PROCEDURE [dbo].[SP_PRT_ItemWiseSales]
    (
      @DateForm DATE ,
      @DateTo DATE ,
      @StockItemHeaderID INT ,
      @DepartmentID INT
    )
AS
    SET DATEFORMAT DMY 

    SELECT  SH.StockItemCode ,
            SH.Name ,
            IH.InvoiceNo ,
            IH.CustomerName ,
            ID.QTY ,
            ID.UnitPrice ,
            ID.QTY * ID.UnitPrice GrossTotal ,
            CASE WHEN ID.IsPercentageForDiscount=1
			THEN
			ID.UnitPrice*(id.ItemDiscountPercentage /100)*ID.QTY
			ELSE 
			ID.ItemDiscountValue*ID.QTY
			end
			 Discount ,
            ID.TaxValue *ID.QTY TaxTotal ,
            --( ID.QTY * ID.UnitPrice ) - IH.ItemDiscountTotal + IH.TaxTotal NetTotal
			 (ID.QTY * ID.UnitPrice)-CASE WHEN ID.IsPercentageForDiscount=1
			THEN
			ID.UnitPrice*(id.ItemDiscountPercentage /100)*ID.QTY
			ELSE 
			ID.ItemDiscountValue*ID.QTY
			end+ (ID.TaxValue *ID.QTY)   NetTotal
    FROM    InvoiceHeaders IH
            INNER JOIN InvoiceDetails ID ON ID.InvoiceHeaderID = IH.ID
            INNER JOIN StockItemHeaders SH ON SH.Id = ID.ItemID
    WHERE   CONVERT(VARCHAR(10), InvoiceDate, 103) BETWEEN @DateForm
                                                   AND     @DateTo
            AND IH.DepartmentID = @DepartmentID
            AND ID.ItemID = @StockItemHeaderID
    ORDER BY IH.InvoiceNo

GO

