-- =============================================
-- Author:		Nivesh
-- Create date: 2025-05-25
-- Description:	Save Supplier Quotation Comparison View
-- =============================================
-- SP_GetSupplierQuotationComparisonView 1,1
CREATE PROCEDURE [dbo].[SP_GetSupplierQuotationComparisonView]
    @PropertyID INT,
    @PurchaseRequestID INT
AS
BEGIN
	SET NOCOUNT ON;
    DECLARE @cols NVARCHAR(MAX), @sql NVARCHAR(MAX);

SELECT @cols = STRING_AGG(QUOTENAME(Name), ',')
FROM (
    SELECT DISTINCT s.Name
    FROM SupplierQuotationUploadDetail squd 
    INNER JOIN QuotationRequestHeader qrh ON qrh.Id = squd.QuotationHeaderID
    INNER JOIN QuotationRequestDetail qr ON qr.QuotationRequestId = squd.QuotationHeaderID
    INNER JOIN StockItemHeaders sih ON sih.Id = squd.ItemID
    INNER JOIN Suppliers s ON s.Id = squd.SupplierID
    WHERE qrh.PurchaseRequestID = @PurchaseRequestID AND qrh.PropertyID = @PropertyID
	and squd.NetPrice>0 and squd.IsQuotationUpload =1
) AS SupplierList;

-- 2. Build the dynamic SQL
SET @sql = '
IF OBJECT_ID(''tempdb..#temp1'') IS NOT NULL DROP TABLE #temp1;

SELECT StockItemCode, Item,ItemID, ' + @cols + '
INTO #temp1
FROM (
    SELECT 
        sih.StockItemCode,
		sih.id ItemID,
        sih.Name AS Item,
        s.Name AS columnName,
        squd.NetPrice AS value
    FROM SupplierQuotationUploadDetail squd
    INNER JOIN QuotationRequestHeader qrh ON qrh.Id = squd.QuotationHeaderID
    INNER JOIN QuotationRequestDetail qr ON qr.QuotationRequestId = squd.QuotationHeaderID
    INNER JOIN StockItemHeaders sih ON sih.Id = squd.ItemID
    INNER JOIN Suppliers s ON s.Id = squd.SupplierID
    WHERE qrh.PurchaseRequestID = '+CAST(@PurchaseRequestID AS NVARCHAR)  +' AND qrh.PropertyID = '+CAST(@PropertyID AS NVARCHAR)+'
	and squd.NetPrice>0 and squd.IsQuotationUpload=1
) AS SourceTable
PIVOT (
    MAX(value)
    FOR columnName IN (' + @cols + ')
) AS PivotTable;

SELECT T.*,RD.ApprovedQuantity Quantity,U.name Unit,null MinSupDetail,(SELECT 
    squd2.ItemID,
    s3.name SupplierName,
	squd2.SupplierID,
    squd2.NetPrice
FROM SupplierQuotationUploadDetail squd2
INNER JOIN (
    SELECT ItemID, MIN(NetPrice) AS MinPrice
    FROM SupplierQuotationUploadDetail squ4
	inner join QuotationRequestHeader QH4 on qh4.Id = squ4.QuotationHeaderID
	where squ4.NetPrice>0 and squ4.IsQuotationUpload =1 and qh4.PurchaseRequestID ='+CAST(@PurchaseRequestID AS NVARCHAR)  +' and qh4.PropertyID ='+CAST(@PropertyID AS NVARCHAR)+'
    GROUP BY ItemID
) AS minp 
    ON squd2.ItemID = minp.ItemID 
   AND squd2.NetPrice = minp.MinPrice
inner join QuotationRequestHeader QH2 on qh2.Id = squd2.QuotationHeaderID
inner join Suppliers S3 ON s3.id =squd2.SupplierID
where qh2.PurchaseRequestID ='+CAST(@PurchaseRequestID AS NVARCHAR)  +' and qh2.PropertyID ='+CAST(@PropertyID AS NVARCHAR)+' and squd2.ItemID =T.ItemID and squd2.NetPrice>0 and squd2.IsQuotationUpload =1 FOR JSON PATH) AS MinSupDetailJson
 FROM #temp1 T 
INNER JOIN RequestDetails RD ON RD.StockItemID = T.ItemID
INNER JOIN Units U ON U.id = RD.UnitID
where RD.RequestHeaderID='+CAST(@PurchaseRequestID AS NVARCHAR)  +' ;


';

-- 3. Execute the dynamic SQL
EXEC sp_executesql @sql;
IF NOT EXISTS ( SELECT DISTINCT s.Name
    FROM SupplierQuotationUploadDetail squd 
    INNER JOIN QuotationRequestHeader qrh ON qrh.Id = squd.QuotationHeaderID
    INNER JOIN QuotationRequestDetail qr ON qr.QuotationRequestId = squd.QuotationHeaderID
    INNER JOIN StockItemHeaders sih ON sih.Id = squd.ItemID
    INNER JOIN Suppliers s ON s.Id = squd.SupplierID
    WHERE qrh.PurchaseRequestID = @PurchaseRequestID AND qrh.PropertyID = @PropertyID
	and squd.NetPrice>0 and squd.IsQuotationUpload =1)

	BEGIN
	SELECT 'Empty' ColumnName
	END
END;

GO

