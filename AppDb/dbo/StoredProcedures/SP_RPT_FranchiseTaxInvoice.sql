
-- [dbo].[SP_RPT_FranchiseTaxInvoice] 13120

CREATE   PROCEDURE [dbo].[SP_RPT_FranchiseTaxInvoice]
    @StockTxnID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SubTotal   DECIMAL(18,6),
            @TaxTotal   DECIMAL(18,6),
            @GrandTotal DECIMAL(18,6);

    SELECT @SubTotal = SUM(SD.Quantity * SD.SellingPrice)
    FROM   StockTransactionDetails SD
    WHERE  SD.StockTransactionHeaderID = @StockTxnID;

    SELECT @TaxTotal = SUM(STX.TaxAmount)
    FROM   StockTransactionDetails SD
    INNER JOIN StockTransactionwiseTaxes STX ON STX.StockTransactionDetailID = SD.Id
    WHERE  SD.StockTransactionHeaderID = @StockTxnID;

    SET @SubTotal   = ISNULL(@SubTotal, 0);
    SET @TaxTotal   = ISNULL(@TaxTotal, 0);
    SET @GrandTotal = @SubTotal + @TaxTotal;

    SELECT
            /* ---- invoice line ---- */
            SIH.Name                              AS ItemName,
            SIH.StockItemCode                     AS StockItemCode,
            U.Name                                AS UOM,
            SD.Quantity                           AS Qty,
            SD.SellingPrice                       AS Price,
            SD.Quantity * SD.SellingPrice         AS LineTotal,
            SD.Remarks                            AS ItemRemark,

            /* ---- invoice header ---- */
            SH.TaxInvoiceNumber                   AS TaxInvoiceNumber,
            SH.DocumentNo                         AS DocumentNo,
            SH.TransactionDate                    AS InvoiceDate,
            SH.TransactionDate                    AS DeliveryDate,
            SH.Remarks                            AS AdditionalInformation,
            LSup.Name                             AS PlaceOfSupply,

            /* ---- supplier: gazette clause 2 (top left) ---- */
            C.Name                                AS SupplierName,
            ISNULL(C.TaxRegistrationNumber1, '')  AS SupplierTIN,
            LTRIM(RTRIM(CONCAT(ISNULL(C.Address1,''), ' ',
                               ISNULL(C.Address2,''), ' ',
                               ISNULL(C.Address3,'')))) AS SupplierAddress,
            ISNULL(C.Telephone1, '')              AS SupplierTel,

            /* ---- purchaser: gazette clause 3 (top right) ---- */
          --  ISNULL(CU.CustomerName, D.Name)       AS PurchaserName,
            CONCAT(ISNULL(CU.FirstName, ''),' ',ISNULL(CU.LastName , '')) AS PurchaserName,
            ISNULL(CU.VatRegNo, '')              AS PurchaserTIN,
            LTRIM(RTRIM(CONCAT(ISNULL(CU.Addr1,''), ' ',
                               ISNULL(CU.Addr2,''), ' ',
                               ISNULL(CU.Addr3,'')))) AS PurchaserAddress,
            ISNULL(CU.Mobile, '')                  AS PurchaserTel,
            D.Name                                AS FranchiseName,
            D.CustomerBSPCode                     AS CustomerBSPCode,

            /* ---- totals: gazette clause 4.1.g ---- */
            @SubTotal                             AS SubTotal,
            @TaxTotal                             AS TaxTotal,
            @GrandTotal                           AS GrandTotal,
            dbo.FN_AmountInWords(CAST(@GrandTotal AS DECIMAL(18,2))) AS GrandTotalInWords,

            /* ---- deliberately blank for now (see notes) ---- */
             CONVERT(VARCHAR(10), SH.InvoiceDueDate, 101) AS InvoiceDueOn,

            /* ---- gazette clause 4.1.h - built here, not in the RDL, so the
                    wording can be changed without redeploying the report ---- */
            CAST('All Cheques Should Be Crossed and Made Payable to, "' + LTRIM(RTRIM(C.Name)) + '"' + CHAR(13) + CHAR(10)
               + 'Bank Details: National Development Bank PLC, Head Office , No 40 Nawam Mawatha, Colombo 02.' + CHAR(13) + CHAR(10)
               + 'Account Number:101000303071' AS VARCHAR(MAX)) AS ModeOfPayment
            ,RH.DocumentNo AS RequestDocNo

    FROM        StockTransactionHeaders  SH
    INNER JOIN  StockTransactionDetails  SD   ON SD.StockTransactionHeaderID = SH.Id
    INNER JOIN  StockItemHeaders         SIH  ON SIH.Id       = SD.StockItemID
    INNER JOIN  Units                    U    ON U.Id         = SD.TxnUnitID
    INNER JOIN  Companies                C    ON C.CompanyID  = SH.PropertyID
    INNER JOIN  Departments              D    ON D.Id         = SH.DepartmentID
    LEFT  JOIN  Locations                LSup ON LSup.Id      = SH.LocationID
    LEFT  JOIN  destinity_BusinessPartnerRef CU   ON CU.Code      = D.CustomerBSPCode
    LEFT JOIN   RequestHeaders RH ON RH.Id = SH.ReferenceID
    WHERE  SH.Id             = @StockTxnID
      AND  SH.TransactionType = 'BI';
END

GO

